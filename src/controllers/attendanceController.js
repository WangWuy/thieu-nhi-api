const { PrismaClient } = require('@prisma/client');
const ScoreService = require('../services/scoreService');
const prisma = new PrismaClient();

const attendanceController = {
    // // Mark attendance with auto score update
    // async markAttendance(req, res) {
    //     try {
    //         const { studentId, attendanceDate, attendanceType, isPresent, note } = req.body;

    //         if (!studentId || !attendanceDate || !attendanceType || isPresent === undefined) {
    //             return res.status(400).json({ error: 'Thiếu thông tin điểm danh' });
    //         }

    //         const attendance = await prisma.attendance.upsert({
    //             where: {
    //                 studentId_attendanceDate_attendanceType: {
    //                     studentId: parseInt(studentId),
    //                     attendanceDate: new Date(attendanceDate),
    //                     attendanceType
    //                 }
    //             },
    //             update: {
    //                 isPresent,
    //                 note,
    //                 markedBy: req.user.userId,
    //                 markedAt: new Date()
    //             },
    //             create: {
    //                 studentId: parseInt(studentId),
    //                 attendanceDate: new Date(attendanceDate),
    //                 attendanceType,
    //                 isPresent,
    //                 note,
    //                 markedBy: req.user.userId
    //             },
    //             include: {
    //                 student: {
    //                     select: { fullName: true, studentCode: true }
    //                 }
    //             }
    //         });

    //         // Recalculate attendance count from database
    //         await this.updateAttendanceCount(parseInt(studentId));

    //         res.json(attendance);
    //     } catch (error) {
    //         console.error('Mark attendance error:', error);
    //         res.status(500).json({ error: 'Lỗi server' });
    //     }
    // },

    // ✅ FIXED: Batch mark attendance with flexible student code matching
    // async batchMarkAttendance(req, res) {
    //     try {
    //         const { classId } = req.params;
    //         const { attendanceDate, attendanceType, attendanceRecords } = req.body;

    //         if (!attendanceDate || !attendanceType || !Array.isArray(attendanceRecords)) {
    //             return res.status(400).json({ error: 'Dữ liệu điểm danh không hợp lệ' });
    //         }

    //         console.log('📥 Batch attendance request:', {
    //             classId,
    //             attendanceDate,
    //             attendanceType,
    //             recordCount: attendanceRecords.length,
    //             records: attendanceRecords
    //         });

    //         // ✅ VALIDATE: Check if class exists
    //         const classObj = await prisma.class.findUnique({
    //             where: { id: parseInt(classId) },
    //             include: { department: true }
    //         });

    //         if (!classObj) {
    //             return res.status(404).json({ error: 'Không tìm thấy lớp học' });
    //         }

    //         // ✅ FIXED: Handle both full codes and partial numbers - FLEXIBLE SEARCH
    //         const inputCodes = attendanceRecords.map(record => record.studentId.toString());
    //         const expandedCodes = [];

    //         inputCodes.forEach(code => {
    //             expandedCodes.push(code); // Original input

    //             // If it's just numbers, try common prefixes
    //             if (/^\d+$/.test(code)) {
    //                 const prefixes = ['TA', 'TN', 'TC', 'TT', 'LP'];
    //                 prefixes.forEach(prefix => {
    //                     expandedCodes.push(`${prefix}${code}`);
    //                 });
    //             }

    //             // Also try with LP prefix removed (reverse case)
    //             if (code.startsWith('LP')) {
    //                 expandedCodes.push(code.substring(2));
    //             }
    //         });

    //         console.log('🔍 Looking for students with expanded codes:', expandedCodes);

    //         // ✅ Find students by expanded search
    //         const validStudents = await prisma.student.findMany({
    //             where: {
    //                 studentCode: { in: expandedCodes },
    //                 classId: parseInt(classId),
    //                 isActive: true
    //             },
    //             select: { id: true, fullName: true, studentCode: true }
    //         });

    //         console.log('✅ Found valid students:', validStudents);

    //         // ✅ Create mapping: original input → actual student
    //         const inputToStudent = new Map();
    //         inputCodes.forEach(originalInput => {
    //             // Find matching student - try exact match first, then partial
    //             let student = validStudents.find(s => s.studentCode === originalInput);

    //             if (!student) {
    //                 // Try partial matching
    //                 student = validStudents.find(s =>
    //                     s.studentCode.endsWith(originalInput) ||
    //                     originalInput.endsWith(s.studentCode.replace(/^[A-Z]+/, ''))
    //                 );
    //             }

    //             if (student) {
    //                 inputToStudent.set(originalInput, student);
    //                 console.log(`✅ Mapped: "${originalInput}" → Student(${student.id}, ${student.studentCode})`);
    //             }
    //         });

    //         const validInputCodes = Array.from(inputToStudent.keys());
    //         const invalidInputCodes = inputCodes.filter(code => !validInputCodes.includes(code));

    //         if (invalidInputCodes.length > 0) {
    //             console.error('❌ Invalid student codes:', invalidInputCodes);
    //             return res.status(400).json({
    //                 error: 'Một số mã học sinh không hợp lệ hoặc không thuộc lớp này',
    //                 invalidStudentCodes: invalidInputCodes,
    //                 validStudents: validStudents.map(s => ({ id: s.id, code: s.studentCode, name: s.fullName })),
    //                 details: `${invalidInputCodes.length}/${inputCodes.length} học sinh không hợp lệ`
    //             });
    //         }

    //         // ✅ PROCESS: Use transaction with increased timeout
    //         const result = await prisma.$transaction(async (tx) => {
    //             const results = [];
    //             const errors = [];
    //             const affectedStudents = new Set();

    //             // Process each attendance record
    //             for (const record of attendanceRecords) {
    //                 try {
    //                     const originalInput = record.studentId.toString();
    //                     const student = inputToStudent.get(originalInput);

    //                     if (!student) {
    //                         throw new Error(`Student input "${originalInput}" not found`);
    //                     }

    //                     const attendance = await tx.attendance.upsert({
    //                         where: {
    //                             studentId_attendanceDate_attendanceType: {
    //                                 studentId: student.id, // Use actual DB ID
    //                                 attendanceDate: new Date(attendanceDate),
    //                                 attendanceType
    //                             }
    //                         },
    //                         update: {
    //                             isPresent: record.isPresent,
    //                             note: record.note || null,
    //                             markedBy: req.user.userId,
    //                             markedAt: new Date()
    //                         },
    //                         create: {
    //                             studentId: student.id, // Use actual DB ID
    //                             attendanceDate: new Date(attendanceDate),
    //                             attendanceType,
    //                             isPresent: record.isPresent,
    //                             note: record.note || null,
    //                             markedBy: req.user.userId
    //                         },
    //                         include: {
    //                             student: {
    //                                 select: { fullName: true, studentCode: true }
    //                             }
    //                         }
    //                     });

    //                     results.push({
    //                         originalInput: originalInput, // What Flutter sent
    //                         studentId: student.id,
    //                         studentCode: student.studentCode, // Full code from DB
    //                         studentName: student.fullName,
    //                         isPresent: attendance.isPresent,
    //                         status: 'success'
    //                     });

    //                     affectedStudents.add(student.id);

    //                 } catch (error) {
    //                     console.error(`❌ Error marking attendance for input ${record.studentId}:`, error);
    //                     errors.push({
    //                         originalInput: record.studentId,
    //                         error: error.message || 'Unknown error',
    //                         status: 'failed'
    //                     });
    //                 }
    //             }

    //             // ✅ Update attendance counts ONLY (fast operation)
    //             if (affectedStudents.size > 0) {
    //                 const studentIdsArray = Array.from(affectedStudents);

    //                 try {
    //                     // Only update attendance counts in transaction (fast)
    //                     await tx.$executeRaw`
    //                         UPDATE students 
    //                         SET 
    //                             thursday_attendance_count = (
    //                                 SELECT COUNT(*) FROM attendance 
    //                                 WHERE student_id = students.id 
    //                                 AND attendance_type = 'thursday' 
    //                                 AND is_present = true
    //                             ),
    //                             sunday_attendance_count = (
    //                                 SELECT COUNT(*) FROM attendance 
    //                                 WHERE student_id = students.id 
    //                                 AND attendance_type = 'sunday' 
    //                                 AND is_present = true
    //                             )
    //                         WHERE id = ANY(${studentIdsArray}::int[])
    //                     `;

    //                     // ✅ REMOVED: Score updates from transaction (too slow)
    //                     console.log('✅ Attendance counts updated for', studentIdsArray.length, 'students');

    //                 } catch (countError) {
    //                     console.error('⚠️ Attendance count update error:', countError);
    //                 }
    //             }

    //             return {
    //                 results,
    //                 errors,
    //                 affectedStudents: affectedStudents.size,
    //                 successCount: results.length,
    //                 errorCount: errors.length
    //             };
    //         }, {
    //             maxWait: 5000,  // Reduced back to 5 seconds
    //             timeout: 8000   // 8 seconds timeout  
    //         });

    //         // ✅ BACKGROUND: Update scores after transaction (non-blocking)
    //         if (result.affectedStudents > 0) {
    //             console.log('🔄 Starting background score updates for', result.affectedStudents, 'students');

    //             // Get affected student IDs and update scores in background
    //             const affectedStudentIds = result.results.map(r => r.studentId).filter(Boolean);

    //             // Background score calculation (don't wait for completion)
    //             setImmediate(() => {
    //                 Promise.allSettled(
    //                     affectedStudentIds.map(async (studentId) => {
    //                         try {
    //                             await ScoreService.updateStudentScores(studentId, {});
    //                             console.log(`✅ Background score updated for student ${studentId}`);
    //                         } catch (err) {
    //                             console.error(`❌ Background score update failed for student ${studentId}:`, err.message);
    //                         }
    //                     })
    //                 ).then(() => {
    //                     console.log('🎯 All background score updates completed');
    //                 });
    //             });
    //         }

    //         // ✅ RESPONSE: Detailed success response
    //         const response = {
    //             message: `Điểm danh hoàn thành: ${result.successCount} thành công, ${result.errorCount} lỗi`,
    //             count: result.successCount,
    //             affectedStudents: result.affectedStudents,
    //             summary: {
    //                 total: attendanceRecords.length,
    //                 success: result.successCount,
    //                 failed: result.errorCount,
    //                 successRate: Math.round((result.successCount / attendanceRecords.length) * 100)
    //             },
    //             results: result.results,
    //             errors: result.errors.length > 0 ? result.errors : undefined
    //         };

    //         console.log('✅ Batch attendance completed:', response.summary);

    //         res.json(response);

    //     } catch (error) {
    //         console.error('❌ Batch mark attendance error:', error);

    //         // Better error responses
    //         if (error.code === 'P2003') {
    //             return res.status(400).json({
    //                 error: 'Học sinh không tồn tại hoặc không thuộc lớp này',
    //                 code: 'INVALID_STUDENT',
    //                 details: error.message
    //             });
    //         }

    //         res.status(500).json({
    //             error: 'Lỗi server khi điểm danh',
    //             code: 'BATCH_ATTENDANCE_ERROR',
    //             details: process.env.NODE_ENV === 'development' ? error.message : undefined
    //         });
    //     }
    // },

    // Update attendance count by counting from database
    async updateAttendanceCount(studentId) {
        try {
            const [thursdayCount, sundayCount] = await Promise.all([
                prisma.attendance.count({
                    where: {
                        studentId: studentId,
                        attendanceType: 'thursday',
                        isPresent: true
                    }
                }),
                prisma.attendance.count({
                    where: {
                        studentId: studentId,
                        attendanceType: 'sunday',
                        isPresent: true
                    }
                })
            ]);

            await ScoreService.updateStudentScores(studentId, {
                thursdayAttendanceCount: thursdayCount,
                sundayAttendanceCount: sundayCount
            });

        } catch (error) {
            console.error('Update attendance count error:', error);
            throw error;
        }
    },

    // Get attendance by date and class
    async getAttendanceByClass(req, res) {
        try {
            const { classId } = req.params;
            const { date, type } = req.query;

            if (!date || !type) {
                return res.status(400).json({ error: 'Thiếu ngày và loại điểm danh' });
            }

            const students = await prisma.student.findMany({
                where: {
                    classId: parseInt(classId),
                    isActive: true
                },
                include: {
                    attendance: {
                        where: {
                            attendanceDate: new Date(date),
                            attendanceType: type
                        }
                    }
                },
                orderBy: { fullName: 'asc' }
            });

            const attendanceData = students.map(student => ({
                ...student,
                attendanceRecord: student.attendance[0] || null
            }));

            res.json(attendanceData);
        } catch (error) {
            console.error('Get attendance error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get attendance statistics
    async getAttendanceStats(req, res) {
        try {
            const { role, departmentId } = req.user;
            const { startDate, endDate, classId } = req.query;

            let whereClause = {};

            // Role-based filtering
            if (role === 'phan_doan_truong') {
                whereClause.student = {
                    class: { departmentId: departmentId }
                };
            } else if (classId) {
                whereClause.student = { classId: parseInt(classId) };
            }

            // Date filtering
            if (startDate && endDate) {
                whereClause.attendanceDate = {
                    gte: new Date(startDate),
                    lte: new Date(endDate)
                };
            }

            const stats = await prisma.attendance.groupBy({
                by: ['attendanceType', 'isPresent'],
                where: whereClause,
                _count: {
                    id: true
                }
            });

            const formattedStats = {
                thursday: {
                    present: stats.find(s => s.attendanceType === 'thursday' && s.isPresent)?._count.id || 0,
                    absent: stats.find(s => s.attendanceType === 'thursday' && !s.isPresent)?._count.id || 0
                },
                sunday: {
                    present: stats.find(s => s.attendanceType === 'sunday' && s.isPresent)?._count.id || 0,
                    absent: stats.find(s => s.attendanceType === 'sunday' && !s.isPresent)?._count.id || 0
                }
            };

            res.json(formattedStats);
        } catch (error) {
            console.error('Get attendance stats error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get attendance trend by date range
    async getAttendanceTrend(req, res) {
        try {
            const { role, departmentId } = req.user;
            const { startDate, endDate, classId } = req.query;

            let whereClause = {};

            // Role-based filtering
            if (role === 'phan_doan_truong') {
                whereClause.student = {
                    class: { departmentId: departmentId }
                };
            } else if (classId) {
                whereClause.student = { classId: parseInt(classId) };
            }

            // Date filtering
            if (startDate && endDate) {
                whereClause.attendanceDate = {
                    gte: new Date(startDate),
                    lte: new Date(endDate)
                };
            }

            const trendData = await prisma.attendance.groupBy({
                by: ['attendanceDate', 'attendanceType', 'isPresent'],
                where: whereClause,
                _count: { id: true },
                orderBy: { attendanceDate: 'asc' }
            });

            // Format data by date
            const dateMap = new Map();

            trendData.forEach(item => {
                const dateKey = item.attendanceDate.toISOString().split('T')[0];
                if (!dateMap.has(dateKey)) {
                    dateMap.set(dateKey, {
                        date: dateKey,
                        thursday: { present: 0, absent: 0 },
                        sunday: { present: 0, absent: 0 }
                    });
                }

                const dayData = dateMap.get(dateKey);
                const type = item.attendanceType;
                const status = item.isPresent ? 'present' : 'absent';

                dayData[type][status] += item._count.id;
            });

            const result = Array.from(dateMap.values());

            res.json(result);
        } catch (error) {
            console.error('Get attendance trend error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    async getStudentAttendanceHistory(req, res) {
        try {
            const { id } = req.params;
            const {
                page = 1,
                limit = 50,
                startDate,
                endDate,
                type,
                status,
                month
            } = req.query;

            // Build where clause
            let whereClause = {
                studentId: parseInt(id)
            };

            // Date filtering - priority: month > date range
            if (month) {
                const [year, monthNum] = month.split('-');
                const startOfMonth = new Date(parseInt(year), parseInt(monthNum) - 1, 1);
                const endOfMonth = new Date(parseInt(year), parseInt(monthNum), 0);

                whereClause.attendanceDate = {
                    gte: startOfMonth,
                    lte: endOfMonth
                };
            } else if (startDate && endDate) {
                whereClause.attendanceDate = {
                    gte: new Date(startDate),
                    lte: new Date(endDate)
                };
            }

            // Type filtering
            if (type) {
                whereClause.attendanceType = type;
            }

            // Status filtering
            if (status !== undefined) {
                whereClause.isPresent = status === 'present';
            }

            // Execute queries
            const skip = (parseInt(page) - 1) * parseInt(limit);

            const [records, total, student] = await Promise.all([
                // Get paginated records
                prisma.attendance.findMany({
                    where: whereClause,
                    include: {
                        marker: {
                            select: { fullName: true, saintName: true }
                        }
                    },
                    orderBy: { attendanceDate: 'desc' },
                    skip,
                    take: parseInt(limit)
                }),

                // Get total count
                prisma.attendance.count({ where: whereClause }),

                // Get student basic info
                prisma.student.findUnique({
                    where: { id: parseInt(id) },
                    select: {
                        id: true,
                        fullName: true,
                        studentCode: true,
                        class: {
                            select: { name: true, department: { select: { displayName: true } } }
                        }
                    }
                })
            ]);

            if (!student) {
                return res.status(404).json({ error: 'Không tìm thấy học sinh' });
            }

            // Group by month for easier frontend processing
            const groupedByMonth = _groupRecordsByMonth(records);

            res.json({
                student: {
                    id: student.id,
                    name: student.fullName,
                    studentCode: student.studentCode,
                    className: student.class?.name,
                    department: student.class?.department?.displayName
                },
                records,
                groupedByMonth,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / parseInt(limit)),
                    hasNext: skip + parseInt(limit) < total,
                    hasPrev: parseInt(page) > 1
                },
                filters: {
                    startDate,
                    endDate,
                    type,
                    status,
                    month
                }
            });

        } catch (error) {
            console.error('Get student attendance history error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // NEW: Get student attendance statistics
    async getStudentAttendanceStats(req, res) {
        try {
            const { id } = req.params;
            const { year } = req.query;

            let whereClause = { studentId: parseInt(id) };

            // Year filtering
            if (year) {
                whereClause.attendanceDate = {
                    gte: new Date(`${year}-01-01`),
                    lte: new Date(`${year}-12-31`)
                };
            }

            // Get stats
            const [monthlyStats, typeStats, student] = await Promise.all([
                // Monthly breakdown
                prisma.$queryRaw`
                    SELECT 
                        EXTRACT(YEAR FROM attendance_date) as year,
                        EXTRACT(MONTH FROM attendance_date) as month,
                        attendance_type,
                        COUNT(*) as total,
                        SUM(CASE WHEN is_present THEN 1 ELSE 0 END) as present
                    FROM attendance 
                    WHERE student_id = ${parseInt(id)}
                    ${year ? prisma.Prisma.sql`AND EXTRACT(YEAR FROM attendance_date) = ${parseInt(year)}` : prisma.Prisma.empty}
                    GROUP BY year, month, attendance_type
                    ORDER BY year DESC, month DESC, attendance_type
                `,

                // Overall type stats
                prisma.attendance.groupBy({
                    by: ['attendanceType', 'isPresent'],
                    where: whereClause,
                    _count: { id: true }
                }),

                // Student info
                prisma.student.findUnique({
                    where: { id: parseInt(id) },
                    select: {
                        fullName: true,
                        studentCode: true,
                        thursdayAttendanceCount: true,
                        sundayAttendanceCount: true,
                        attendanceAverage: true
                    }
                })
            ]);

            if (!student) {
                return res.status(404).json({ error: 'Không tìm thấy học sinh' });
            }

            // Format monthly stats
            const formattedMonthlyStats = monthlyStats.map(stat => ({
                year: parseInt(stat.year),
                month: parseInt(stat.month),
                type: stat.attendance_type,
                total: parseInt(stat.total),
                present: parseInt(stat.present),
                absent: parseInt(stat.total) - parseInt(stat.present),
                percentage: Math.round((parseInt(stat.present) / parseInt(stat.total)) * 100)
            }));

            // Format type stats
            const formattedTypeStats = {
                thursday: {
                    present: typeStats.find(s => s.attendanceType === 'thursday' && s.isPresent)?._count.id || 0,
                    absent: typeStats.find(s => s.attendanceType === 'thursday' && !s.isPresent)?._count.id || 0
                },
                sunday: {
                    present: typeStats.find(s => s.attendanceType === 'sunday' && s.isPresent)?._count.id || 0,
                    absent: typeStats.find(s => s.attendanceType === 'sunday' && !s.isPresent)?._count.id || 0
                }
            };

            res.json({
                student: {
                    name: student.fullName,
                    studentCode: student.studentCode,
                    thursdayCount: student.thursdayAttendanceCount,
                    sundayCount: student.sundayAttendanceCount,
                    attendanceAverage: parseFloat(student.attendanceAverage || 0)
                },
                monthlyStats: formattedMonthlyStats,
                typeStats: formattedTypeStats,
                year: year ? parseInt(year) : new Date().getFullYear()
            });

        } catch (error) {
            console.error('Get student attendance stats error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // ✅ NEW: Universal attendance - cross-class attendance marking
    async universalAttendance(req, res) {
        try {
            const { studentCodes, attendanceDate, attendanceType, note, isPresent } = req.body;

            console.log('🌍 Universal attendance request:', {
                studentCodes,
                attendanceDate,
                attendanceType,
                isPresent,
                codeCount: studentCodes.length,
                user: req.user.userId
            });

            // ✅ STEP 1: Find all students by codes (cross-class lookup)
            const students = await prisma.student.findMany({
                where: {
                    studentCode: { in: studentCodes },
                    isActive: true
                },
                include: {
                    class: {
                        select: {
                            id: true,
                            name: true,
                            department: { select: { displayName: true } }
                        }
                    }
                }
            });

            console.log('👥 Found students:', students.map(s => ({
                code: s.studentCode,
                name: s.fullName,
                class: s.class?.name
            })));

            // ✅ STEP 2: Identify valid vs invalid codes
            const foundCodes = students.map(s => s.studentCode);
            const invalidCodes = studentCodes.filter(code => !foundCodes.includes(code));

            if (students.length === 0) {
                return res.status(400).json({
                    success: false,
                    error: 'Không tìm thấy thiếu nhi nào với các mã đã quét',
                    invalidStudentCodes: invalidCodes,
                    count: 0
                });
            }

            // ✅ STEP 3: Universal permissions - ALL roles can mark cross-class/cross-department
            const userRole = req.user.role;
            const userDepartmentId = req.user.departmentId;
            const userClassIds = req.user.classIds || [];

            // ✅ UNIVERSAL LOGIC: Allow cross-class and cross-department for all roles
            let authorizedStudents = students; // Default: allow all

            console.log(`🌍 ${userRole} marking universal attendance for ${students.length} students across departments`);

            // Optional: Add basic validation for active students only
            authorizedStudents = students.filter(s => s.isActive);

            // Log cross-department summary
            const departmentSummary = {};
            authorizedStudents.forEach(student => {
                const dept = student.class?.department?.displayName || 'Unknown';
                departmentSummary[dept] = (departmentSummary[dept] || 0) + 1;
            });

            console.log('📊 Cross-department attendance:', departmentSummary);

            if (authorizedStudents.length === 0) {
                return res.status(400).json({
                    success: false,
                    error: 'Không tìm thấy thiếu nhi nào hợp lệ để điểm danh',
                    invalidStudentCodes: studentCodes,
                    count: 0
                });
            }

            // ✅ STEP 4: Process attendance in transaction
            const result = await prisma.$transaction(async (tx) => {
                const results = [];
                const errors = [];
                const affectedStudents = new Set();

                for (const student of authorizedStudents) {
                    try {
                        const attendance = await tx.attendance.upsert({
                            where: {
                                studentId_attendanceDate_attendanceType: {
                                    studentId: student.id,
                                    attendanceDate: new Date(attendanceDate),
                                    attendanceType
                                }
                            },
                            update: {
                                isPresent: isPresent, // Universal attendance always marks present
                                note: note || (isPresent ? 'Universal QR Scan' : 'Manual Absent Mark'),
                                markedBy: req.user.userId,
                                markedAt: new Date()
                            },
                            create: {
                                studentId: student.id,
                                attendanceDate: new Date(attendanceDate),
                                attendanceType,
                                isPresent: isPresent,
                                note: note || (isPresent ? 'Universal QR Scan' : 'Manual Absent Mark'),
                                markedBy: req.user.userId
                            }
                        });

                        results.push({
                            studentCode: student.studentCode,
                            studentName: student.fullName,
                            className: student.class?.name,
                            department: student.class?.department?.displayName,
                            isPresent: isPresent,
                            status: 'success'
                        });

                        affectedStudents.add(student.id);

                    } catch (error) {
                        console.error(`❌ Error marking attendance for ${student.studentCode}:`, error);
                        errors.push({
                            studentCode: student.studentCode,
                            error: error.message,
                            status: 'failed'
                        });
                    }
                }

                // ✅ STEP 5: Update attendance counts (fast)
                if (affectedStudents.size > 0) {
                    const studentIdsArray = Array.from(affectedStudents);

                    await tx.$executeRaw`
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
                }

                return {
                    results,
                    errors,
                    affectedStudents: affectedStudents.size,
                    successCount: results.length,
                    errorCount: errors.length
                };

            }, {
                maxWait: 5000,
                timeout: 10000
            });

            // ✅ STEP 6: Background score updates
            if (result.affectedStudents > 0) {
                const affectedStudentIds = result.results.map(r =>
                    authorizedStudents.find(s => s.studentCode === r.studentCode)?.id
                ).filter(Boolean);

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

            // ✅ STEP 7: Comprehensive response with cross-department summary
            const response = {
                success: true,
                message: `Điểm danh thành công ${result.successCount}/${studentCodes.length} thiếu nhi`,
                count: result.successCount,
                isPresent: isPresent,
                details: {
                    total: studentCodes.length,
                    found: students.length,
                    success: result.successCount,
                    failed: result.errorCount,
                    invalid: invalidCodes.length,
                    crossDepartment: Object.keys(departmentSummary).length > 1 // Multiple departments
                },
                results: result.results,
                invalidStudentCodes: invalidCodes.length > 0 ? invalidCodes : undefined,
                errors: result.errors.length > 0 ? result.errors : undefined,
                crossDepartmentSummary: _generateDepartmentSummary(result.results),
                markedBy: {
                    userId: req.user.userId,
                    name: req.user.fullName || req.user.username,
                    role: req.user.role,
                    department: req.user.departmentName || 'Unknown'
                }
            };

            console.log('✅ Universal cross-department attendance completed:', response.details);

            res.json(response);

        } catch (error) {
            console.error('❌ Universal attendance error:', error);

            res.status(500).json({
                success: false,
                error: 'Lỗi server khi điểm danh',
                code: 'UNIVERSAL_ATTENDANCE_ERROR',
                details: process.env.NODE_ENV === 'development' ? error.message : undefined
            });
        }
    },

    // ✅ Get today's attendance status for students
    async getTodayAttendanceStatus(req, res) {
        try {
            const { date, type } = req.query; // date format: YYYY-MM-DD, type: thursday/sunday
            const { studentCodes } = req.body; // Array of student codes to check

            if (!date || !type) {
                return res.status(400).json({
                    error: 'Date and type are required',
                    example: { date: '2024-03-15', type: 'thursday' }
                });
            }

            if (!studentCodes || !Array.isArray(studentCodes)) {
                return res.status(400).json({
                    error: 'Student codes array is required'
                });
            }

            const attendanceRecords = await prisma.attendance.findMany({
                where: {
                    attendanceDate: new Date(date),
                    attendanceType: type,
                    student: {
                        studentCode: { in: studentCodes },
                        isActive: true
                    }
                },
                include: {
                    student: {
                        select: {
                            studentCode: true,
                            fullName: true,
                            class: {
                                select: {
                                    name: true,
                                    department: { select: { displayName: true } }
                                }
                            }
                        }
                    },
                    marker: {
                        select: { fullName: true, saintName: true }
                    }
                }
            });

            // Create status map
            const statusMap = {};
            attendanceRecords.forEach(record => {
                statusMap[record.student.studentCode] = {
                    studentCode: record.student.studentCode,
                    studentName: record.student.fullName,
                    className: record.student.class?.name,
                    department: record.student.class?.department?.displayName,
                    isPresent: record.isPresent,
                    markedAt: record.markedAt,
                    markedBy: record.marker?.fullName || record.marker?.saintName,
                    note: record.note,
                    canToggle: true // Always allow toggle
                };
            });

            res.json({
                date,
                type,
                attendanceStatus: statusMap,
                summary: {
                    total: studentCodes.length,
                    attended: Object.values(statusMap).filter(s => s.isPresent).length,
                    absent: Object.values(statusMap).filter(s => !s.isPresent).length,
                    notMarked: studentCodes.length - Object.keys(statusMap).length
                }
            });

        } catch (error) {
            console.error('Get today attendance status error:', error);
            res.status(500).json({ error: 'Server error' });
        }
    },
};

// Helper function to group records by month
function _groupRecordsByMonth(records) {
    const grouped = {};

    records.forEach(record => {
        const date = new Date(record.attendanceDate);
        const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;

        if (!grouped[monthKey]) {
            grouped[monthKey] = {
                year: date.getFullYear(),
                month: date.getMonth() + 1,
                monthName: date.toLocaleDateString('vi-VN', { month: 'long', year: 'numeric' }),
                records: [],
                stats: {
                    total: 0,
                    present: 0,
                    absent: 0,
                    thursday: { total: 0, present: 0 },
                    sunday: { total: 0, present: 0 }
                }
            };
        }

        grouped[monthKey].records.push(record);
        grouped[monthKey].stats.total++;

        if (record.isPresent) {
            grouped[monthKey].stats.present++;
        } else {
            grouped[monthKey].stats.absent++;
        }

        // Type-specific stats
        const typeKey = record.attendanceType;
        grouped[monthKey].stats[typeKey].total++;
        if (record.isPresent) {
            grouped[monthKey].stats[typeKey].present++;
        }
    });

    // Convert to array and sort by date descending
    return Object.entries(grouped)
        .map(([key, data]) => ({ monthKey: key, ...data }))
        .sort((a, b) => b.monthKey.localeCompare(a.monthKey));
}

// Enhanced helper function for cross-department summary
function _generateDepartmentSummary(results) {
    const departmentSummary = {};

    results.forEach(result => {
        const department = result.department || 'Unknown Department';
        const className = result.className || 'Unknown Class';

        if (!departmentSummary[department]) {
            departmentSummary[department] = {
                total: 0,
                classes: {}
            };
        }

        if (!departmentSummary[department].classes[className]) {
            departmentSummary[department].classes[className] = {
                count: 0,
                students: []
            };
        }

        departmentSummary[department].total++;
        departmentSummary[department].classes[className].count++;
        departmentSummary[department].classes[className].students.push({
            code: result.studentCode,
            name: result.studentName
        });
    });

    return departmentSummary;
}

module.exports = attendanceController;