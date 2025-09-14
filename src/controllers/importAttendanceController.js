const { PrismaClient } = require('@prisma/client');
const multer = require('multer');
const XLSX = require('xlsx');
const ScoreService = require('../services/scoreService');

const prisma = new PrismaClient();

// Multer config for Excel files
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024 }, // 10MB
    fileFilter: (req, file, cb) => {
        const isExcel = file.mimetype.includes('spreadsheet') || 
                       file.mimetype.includes('excel') ||
                       file.originalname.match(/\.(xlsx|xls)$/);
        cb(null, isExcel);
    },
});

const importAttendanceController = {
    uploadExcel: upload.single('file'),

    async importAttendance(req, res) {
        try {
            if (!req.file) {
                return res.status(400).json({ error: 'Vui lòng chọn file Excel' });
            }

            const { attendanceDate, attendanceType } = req.body;

            if (!attendanceDate || !attendanceType) {
                return res.status(400).json({ 
                    error: 'Vui lòng cung cấp ngày điểm danh và loại điểm danh' 
                });
            }

            // Parse Excel file
            const workbook = XLSX.read(req.file.buffer, { 
                type: 'buffer',
                cellDates: true 
            });
            const worksheet = workbook.Sheets[workbook.SheetNames[0]];
            const data = XLSX.utils.sheet_to_json(worksheet, { header: 1, blankrows: false });

            if (data.length < 2) {
                return res.status(400).json({ 
                    error: 'File Excel phải có ít nhất 2 dòng (header + data)' 
                });
            }

            // Find header row and column indices
            let headerRowIndex = -1;
            let studentCodeCol = -1;
            let attendanceCol = -1;

            // Search for header row
            for (let i = 0; i < Math.min(5, data.length); i++) {
                const row = data[i];
                for (let j = 0; j < row.length; j++) {
                    const cell = String(row[j] || '').toLowerCase();
                    if (cell.includes('mã') && (cell.includes('tn') || cell.includes('học sinh'))) {
                        headerRowIndex = i;
                        studentCodeCol = j;
                        break;
                    }
                }
                if (headerRowIndex !== -1) break;
            }

            if (headerRowIndex === -1 || studentCodeCol === -1) {
                return res.status(400).json({ 
                    error: 'Không tìm thấy cột "Mã TN" trong file Excel' 
                });
            }

            // Find attendance column (usually next to student code or has "điểm danh", "có mặt", etc.)
            const headerRow = data[headerRowIndex];
            for (let j = studentCodeCol + 1; j < headerRow.length; j++) {
                const cell = String(headerRow[j] || '').toLowerCase();
                if (cell.includes('điểm') || cell.includes('có') || cell.includes('vắng') || 
                    cell.includes('x') || cell.includes('attendance')) {
                    attendanceCol = j;
                    break;
                }
            }

            // If no specific attendance column found, use the column right after student code
            if (attendanceCol === -1) {
                attendanceCol = studentCodeCol + 1;
            }

            const results = { success: [], failed: [], updated: [] };
            const affectedStudentIds = new Set();

            // Process data rows
            for (let i = headerRowIndex + 1; i < data.length; i++) {
                const row = data[i];
                
                if (!row || row.length === 0) continue;

                try {
                    const studentCode = String(row[studentCodeCol] || '').trim();
                    const attendanceValue = row[attendanceCol];

                    if (!studentCode) {
                        continue; // Skip empty rows
                    }

                    // Determine attendance status
                    let isPresent = false;
                    if (attendanceValue !== undefined && attendanceValue !== null) {
                        const value = String(attendanceValue).toLowerCase().trim();
                        // Present if: "x", "có", "1", "true", "có mặt", non-empty
                        isPresent = value === 'x' || 
                                   value === '1' || 
                                   value === 'true' ||
                                   value.includes('có') ||
                                   value.includes('present') ||
                                   (value !== '' && value !== '0' && value !== 'false');
                    }

                    // Find student
                    const student = await prisma.student.findUnique({
                        where: { studentCode: studentCode },
                        include: { 
                            class: { 
                                select: { 
                                    name: true, 
                                    department: { select: { displayName: true } }
                                }
                            }
                        }
                    });

                    if (!student) {
                        results.failed.push({
                            row: i + 1,
                            studentCode,
                            error: 'Không tìm thấy học sinh'
                        });
                        continue;
                    }

                    if (!student.isActive) {
                        results.failed.push({
                            row: i + 1,
                            studentCode,
                            error: 'Học sinh đã bị vô hiệu hóa'
                        });
                        continue;
                    }

                    // Create or update attendance record
                    const attendanceRecord = await prisma.attendance.upsert({
                        where: {
                            studentId_attendanceDate_attendanceType: {
                                studentId: student.id,
                                attendanceDate: new Date(attendanceDate),
                                attendanceType: attendanceType
                            }
                        },
                        update: {
                            isPresent: isPresent,
                            note: `Import từ Excel - ${req.file.originalname}`,
                            markedBy: req.user.userId,
                            markedAt: new Date()
                        },
                        create: {
                            studentId: student.id,
                            attendanceDate: new Date(attendanceDate),
                            attendanceType: attendanceType,
                            isPresent: isPresent,
                            note: `Import từ Excel - ${req.file.originalname}`,
                            markedBy: req.user.userId
                        }
                    });

                    if (attendanceRecord) {
                        results.success.push({
                            row: i + 1,
                            studentCode,
                            studentName: student.fullName,
                            className: student.class?.name,
                            department: student.class?.department?.displayName,
                            isPresent: isPresent,
                            status: 'imported'
                        });

                        affectedStudentIds.add(student.id);
                    }

                } catch (error) {
                    results.failed.push({
                        row: i + 1,
                        studentCode: row[studentCodeCol] || `Dòng ${i + 1}`,
                        error: error.message
                    });
                }
            }

            // Update attendance counts for affected students
            if (affectedStudentIds.size > 0) {
                const studentIdsArray = Array.from(affectedStudentIds);
                
                // Update counts in database
                await prisma.$executeRaw`
                    UPDATE students 
                    SET 
                        thursday_attendance_count = (
                            SELECT COUNT(*) FROM attendance 
                            WHERE student_id = students.id 
                            AND attendance_type = 'thursday' 
                            AND is_present = true
                        ),
                        sunday_attendance_count = (
                            SELECT COUNT(*) FROM attendance 
                            WHERE student_id = students.id 
                            AND attendance_type = 'sunday' 
                            AND is_present = true
                        )
                    WHERE id = ANY(${studentIdsArray}::int[])
                `;

                // Background score updates
                setImmediate(() => {
                    Promise.allSettled(
                        studentIdsArray.map(async (studentId) => {
                            try {
                                await ScoreService.updateStudentScores(studentId, {});
                            } catch (err) {
                                console.error(`Background score update failed for student ${studentId}:`, err.message);
                            }
                        })
                    );
                });
            }

            // Generate summary
            const summary = {
                totalRows: data.length - headerRowIndex - 1,
                successful: results.success.length,
                failed: results.failed.length,
                attendanceDate,
                attendanceType,
                fileName: req.file.originalname
            };

            console.log('✅ Attendance import completed:', summary);

            res.json({
                success: true,
                message: `Import hoàn thành: ${results.success.length} thành công, ${results.failed.length} thất bại`,
                summary,
                results: {
                    successful: results.success,
                    failed: results.failed.length > 0 ? results.failed : undefined
                },
                markedBy: {
                    userId: req.user.userId,
                    name: req.user.fullName || req.user.username,
                    role: req.user.role
                }
            });

        } catch (error) {
            console.error('❌ Import attendance error:', error);
            res.status(500).json({ 
                success: false,
                error: 'Lỗi server khi import điểm danh: ' + error.message 
            });
        }
    },

    // Preview Excel file before import
    async previewAttendance(req, res) {
        try {
            if (!req.file) {
                return res.status(400).json({ error: 'Vui lòng chọn file Excel' });
            }

            // Parse Excel file
            const workbook = XLSX.read(req.file.buffer, { 
                type: 'buffer',
                cellDates: true 
            });
            const worksheet = workbook.Sheets[workbook.SheetNames[0]];
            const data = XLSX.utils.sheet_to_json(worksheet, { header: 1, blankrows: false });

            // Find header structure
            let headerRowIndex = -1;
            let studentCodeCol = -1;
            let attendanceCol = -1;

            for (let i = 0; i < Math.min(5, data.length); i++) {
                const row = data[i];
                for (let j = 0; j < row.length; j++) {
                    const cell = String(row[j] || '').toLowerCase();
                    if (cell.includes('mã') && (cell.includes('tn') || cell.includes('học sinh'))) {
                        headerRowIndex = i;
                        studentCodeCol = j;
                        break;
                    }
                }
                if (headerRowIndex !== -1) break;
            }

            if (headerRowIndex === -1) {
                return res.status(400).json({ 
                    error: 'Không tìm thấy cột "Mã TN" trong file Excel' 
                });
            }

            // Find attendance column
            const headerRow = data[headerRowIndex];
            for (let j = studentCodeCol + 1; j < headerRow.length; j++) {
                const cell = String(headerRow[j] || '').toLowerCase();
                if (cell.includes('điểm') || cell.includes('có') || cell.includes('vắng') || 
                    cell.includes('x') || cell.includes('attendance')) {
                    attendanceCol = j;
                    break;
                }
            }

            if (attendanceCol === -1) {
                attendanceCol = studentCodeCol + 1;
            }

            // Preview first 10 rows
            const preview = [];
            for (let i = headerRowIndex + 1; i < Math.min(headerRowIndex + 11, data.length); i++) {
                const row = data[i];
                if (!row || row.length === 0) continue;

                const studentCode = String(row[studentCodeCol] || '').trim();
                const attendanceValue = row[attendanceCol];
                
                if (studentCode) {
                    let isPresent = false;
                    if (attendanceValue !== undefined && attendanceValue !== null) {
                        const value = String(attendanceValue).toLowerCase().trim();
                        isPresent = value === 'x' || 
                                   value === '1' || 
                                   value === 'true' ||
                                   value.includes('có') ||
                                   value.includes('present') ||
                                   (value !== '' && value !== '0' && value !== 'false');
                    }

                    preview.push({
                        row: i + 1,
                        studentCode,
                        attendanceValue: attendanceValue || '',
                        interpretedAs: isPresent ? 'Có mặt' : 'Vắng mặt'
                    });
                }
            }

            res.json({
                fileName: req.file.originalname,
                structure: {
                    headerRow: headerRowIndex + 1,
                    studentCodeColumn: studentCodeCol + 1,
                    attendanceColumn: attendanceCol + 1,
                    totalRows: data.length - headerRowIndex - 1
                },
                headers: headerRow,
                preview
            });

        } catch (error) {
            console.error('Preview attendance error:', error);
            res.status(500).json({ error: 'Lỗi server khi preview file' });
        }
    },

    // Mark absent for students not in attendance
    async markAbsentRemaining(req, res) {
        try {
            const { attendanceDate, attendanceType } = req.body;

            if (!attendanceDate || !attendanceType) {
                return res.status(400).json({ 
                    error: 'Vui lòng cung cấp ngày điểm danh và loại điểm danh' 
                });
            }

            // Get all students who haven't been marked for this date/type
            const unmarkedStudents = await prisma.student.findMany({
                where: {
                    isActive: true,
                    attendance: {
                        none: {
                            attendanceDate: new Date(attendanceDate),
                            attendanceType: attendanceType
                        }
                    }
                },
                include: { 
                    class: { 
                        select: { 
                            name: true, 
                            department: { select: { displayName: true } }
                        }
                    }
                }
            });

            const results = { markedAbsent: [], failed: [] };
            const affectedStudentIds = [];

            for (const student of unmarkedStudents) {
                try {
                    await prisma.attendance.create({
                        data: {
                            studentId: student.id,
                            attendanceDate: new Date(attendanceDate),
                            attendanceType: attendanceType,
                            isPresent: false,
                            note: 'Tự động đánh vắng - Không có trong danh sách điểm danh',
                            markedBy: req.user.userId
                        }
                    });

                    results.markedAbsent.push({
                        studentCode: student.studentCode,
                        studentName: student.fullName,
                        className: student.class?.name,
                        department: student.class?.department?.displayName
                    });

                    affectedStudentIds.push(student.id);

                } catch (error) {
                    results.failed.push({
                        studentCode: student.studentCode,
                        error: error.message
                    });
                }
            }

            // Update attendance counts
            if (affectedStudentIds.length > 0) {
                await prisma.$executeRaw`
                    UPDATE students 
                    SET 
                        thursday_attendance_count = (
                            SELECT COUNT(*) FROM attendance 
                            WHERE student_id = students.id 
                            AND attendance_type = 'thursday' 
                            AND is_present = true
                        ),
                        sunday_attendance_count = (
                            SELECT COUNT(*) FROM attendance 
                            WHERE student_id = students.id 
                            AND attendance_type = 'sunday' 
                            AND is_present = true
                        )
                    WHERE id = ANY(${affectedStudentIds}::int[])
                `;

                // Background score updates
                setImmediate(() => {
                    Promise.allSettled(
                        affectedStudentIds.map(async (studentId) => {
                            try {
                                await ScoreService.updateStudentScores(studentId, {});
                            } catch (err) {
                                console.error(`Background score update failed for student ${studentId}:`, err.message);
                            }
                        })
                    );
                });
            }

            res.json({
                success: true,
                message: `Đã đánh vắng ${results.markedAbsent.length} thiếu nhi`,
                summary: {
                    totalMarkedAbsent: results.markedAbsent.length,
                    failed: results.failed.length,
                    attendanceDate,
                    attendanceType
                },
                results: {
                    markedAbsent: results.markedAbsent,
                    failed: results.failed.length > 0 ? results.failed : undefined
                }
            });

        } catch (error) {
            console.error('❌ Mark absent remaining error:', error);
            res.status(500).json({ 
                success: false,
                error: 'Lỗi server khi đánh vắng: ' + error.message 
            });
        }
    },
};

module.exports = importAttendanceController;