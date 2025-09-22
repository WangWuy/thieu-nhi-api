const { prisma } = require('../../prisma/client');
const multer = require('multer');
const XLSX = require('xlsx');
const ScoreService = require('../services/scoreService');
const { getWeekRange, getAttendanceTargetDate, formatWeekRange } = require('../utils/weekUtils');

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
    
            // Tính target date sử dụng weekUtils
            const targetDate = getAttendanceTargetDate(attendanceDate, attendanceType);
            const weekInfo = {
                inputDate: attendanceDate,
                targetDate: targetDate.toISOString().split('T')[0],
                weekRange: formatWeekRange(attendanceDate)
            };
    
            console.log('Import attendance with week logic:', weekInfo);
    
            // Parse Excel file
            const workbook = XLSX.read(req.file.buffer, { 
                type: 'buffer',
                cellDates: true 
            });
            const worksheet = workbook.Sheets[workbook.SheetNames[0]];
            const data = XLSX.utils.sheet_to_json(worksheet, { header: 1, blankrows: false });
    
            if (data.length === 0) {
                return res.status(400).json({ 
                    error: 'File Excel không có dữ liệu' 
                });
            }
    
            // Thu thập tất cả mã thiếu nhi từ file (bỏ qua header, lấy tất cả cells có data)
            const studentCodesFromFile = new Set();
            
            data.forEach((row, rowIndex) => {
                if (!row || row.length === 0) return;
                
                row.forEach(cell => {
                    if (cell && typeof cell === 'string' || typeof cell === 'number') {
                        const code = String(cell).trim();
                        if (code && code.length > 0) {
                            studentCodesFromFile.add(code);
                        }
                    }
                });
            });
    
            if (studentCodesFromFile.size === 0) {
                return res.status(400).json({ 
                    error: 'Không tìm thấy mã thiếu nhi nào trong file' 
                });
            }
    
            console.log(`Found ${studentCodesFromFile.size} student codes in file`);
    
            const results = { 
                present: [], 
                absent: [], 
                failed: [],
                notFound: []
            };
    
            // STEP 1: Đánh dấu có mặt cho các mã trong file
            for (const studentCode of studentCodesFromFile) {
                try {
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
                        results.notFound.push({
                            studentCode,
                            error: 'Không tìm thấy học sinh'
                        });
                        continue;
                    }
    
                    if (!student.isActive) {
                        results.failed.push({
                            studentCode,
                            error: 'Học sinh đã bị vô hiệu hóa'
                        });
                        continue;
                    }
    
                    // Tạo/cập nhật attendance record - có mặt
                    await prisma.attendance.upsert({
                        where: {
                            studentId_attendanceDate_attendanceType: {
                                studentId: student.id,
                                attendanceDate: targetDate,
                                attendanceType: attendanceType
                            }
                        },
                        update: {
                            isPresent: true,
                            note: `Import từ Excel - ${req.file.originalname} (${weekInfo.weekRange})`,
                            markedBy: req.user.userId,
                            markedAt: new Date()
                        },
                        create: {
                            studentId: student.id,
                            attendanceDate: targetDate,
                            attendanceType: attendanceType,
                            isPresent: true,
                            note: `Import từ Excel - ${req.file.originalname} (${weekInfo.weekRange})`,
                            markedBy: req.user.userId
                        }
                    });
    
                    results.present.push({
                        studentCode,
                        studentName: student.fullName,
                        className: student.class?.name,
                        department: student.class?.department?.displayName,
                        actualDate: targetDate.toISOString().split('T')[0],
                        weekRange: weekInfo.weekRange
                    });
    
                } catch (error) {
                    results.failed.push({
                        studentCode,
                        error: error.message
                    });
                }
            }
    
            // STEP 2: Không tự động đánh vắng - chỉ import bổ sung
            // Bỏ phần tự động đánh vắng vì đây chỉ là import bổ sung
    
            // STEP 3: Update attendance counts chỉ cho những student được import
            if (results.present.length > 0) {
                const affectedStudents = await prisma.student.findMany({
                    where: {
                        studentCode: { in: results.present.map(r => r.studentCode) }
                    },
                    select: { id: true }
                });
                
                const studentIds = affectedStudents.map(s => s.id);
    
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
                    WHERE id = ANY(${studentIds}::int[])
                `;
    
                // Background score updates
                setImmediate(() => {
                    Promise.allSettled(
                        studentIds.map(async (studentId) => {
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
                totalCodesInFile: studentCodesFromFile.size,
                present: results.present.length,
                failed: results.failed.length,
                notFound: results.notFound.length,
                weekInfo,
                fileName: req.file.originalname
            };
    
            console.log('✅ Attendance import completed:', summary);
    
            res.json({
                success: true,
                message: `Import hoàn thành: ${results.present.length} thiếu nhi được đánh có mặt`,
                summary,
                results: {
                    present: results.present,
                    failed: results.failed.length > 0 ? results.failed : undefined,
                    notFound: results.notFound.length > 0 ? results.notFound : undefined
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

    // Mark absent for students not in attendance - theo tuần
    async markAbsentRemaining(req, res) {
        try {
            const { attendanceDate, attendanceType } = req.body;

            if (!attendanceDate || !attendanceType) {
                return res.status(400).json({ 
                    error: 'Vui lòng cung cấp ngày điểm danh và loại điểm danh' 
                });
            }

            // Tính target date và week info
            const targetDate = getAttendanceTargetDate(attendanceDate, attendanceType);
            const weekInfo = {
                inputDate: attendanceDate,
                targetDate: targetDate.toISOString().split('T')[0],
                weekRange: formatWeekRange(attendanceDate)
            };

            // Get all students who haven't been marked for this target date/type
            const unmarkedStudents = await prisma.student.findMany({
                where: {
                    isActive: true,
                    attendance: {
                        none: {
                            attendanceDate: targetDate,
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
                            attendanceDate: targetDate,
                            attendanceType: attendanceType,
                            isPresent: false,
                            note: `Tự động đánh vắng - Không có trong danh sách điểm danh (${weekInfo.weekRange})`,
                            markedBy: req.user.userId
                        }
                    });

                    results.markedAbsent.push({
                        studentCode: student.studentCode,
                        studentName: student.fullName,
                        className: student.class?.name,
                        department: student.class?.department?.displayName,
                        actualDate: targetDate.toISOString().split('T')[0],
                        weekRange: weekInfo.weekRange
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
                    weekInfo
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