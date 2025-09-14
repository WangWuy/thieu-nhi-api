const { PrismaClient } = require('@prisma/client');
const ScoreService = require('../services/scoreService');
const prisma = new PrismaClient();

// Redis connection with proper error handling
let redis = null;
if (process.env.REDIS_URL) {
    const Redis = require('redis');
    redis = Redis.createClient({ url: process.env.REDIS_URL });

    redis.on('error', (err) => {
        console.log('Redis Client Error:', err);
        redis = null; // Set to null if error
    });

    redis.on('connect', () => {
        console.log('✅ Redis connected');
    });

    redis.on('disconnect', () => {
        console.log('❌ Redis disconnected');
        redis = null; // Set to null if disconnected
    });

    // Connect to Redis
    redis.connect().catch((err) => {
        console.log('Redis connection failed:', err);
        redis = null;
    });
}

const attendanceController = {
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

            // Safe Redis check
            const cacheKey = `attendance:${classId}:${date}:${type}`;
            let cachedData = null;

            if (redis && redis.isReady) {
                try {
                    const cached = await redis.get(cacheKey);
                    if (cached) {
                        cachedData = JSON.parse(cached);
                        return res.json(Array.isArray(cachedData) ? cachedData : Object.values(cachedData));
                    }
                } catch (cacheError) {
                    console.log('Cache error, continuing without cache:', cacheError.message);
                }
            }

            // Direct database query
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

            // Safe cache set
            if (redis && redis.isReady) {
                try {
                    await redis.setEx(cacheKey, 300, JSON.stringify(attendanceData));
                } catch (cacheError) {
                    console.log('Cache set error:', cacheError.message);
                }
            }

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

    // ✅ NEW: Undo attendance - xóa record điểm danh
    async undoAttendance(req, res) {
        try {
            const { studentCodes, attendanceDate, attendanceType, note } = req.body;

            console.log('🔄 Undo attendance request:', {
                studentCodes: studentCodes.slice(0, 5),
                attendanceDate,
                attendanceType,
                totalCodes: studentCodes.length
            });

            // ✅ STEP 1: Find students by codes
            const students = await prisma.student.findMany({
                where: {
                    studentCode: { in: studentCodes },
                    isActive: true
                },
                select: {
                    id: true,
                    studentCode: true,
                    fullName: true,
                    class: {
                        select: {
                            id: true,
                            name: true,
                            department: { select: { displayName: true } }
                        }
                    }
                }
            });

            if (students.length === 0) {
                return res.status(400).json({
                    success: false,
                    error: 'Không tìm thấy thiếu nhi nào với các mã đã cung cấp',
                    count: 0
                });
            }

            // ✅ STEP 2: Delete attendance records in transaction
            const result = await prisma.$transaction(async (tx) => {
                const deletedRecords = [];
                const notFoundRecords = [];

                for (const student of students) {
                    try {
                        // Check if attendance record exists
                        const existingRecord = await tx.attendance.findUnique({
                            where: {
                                studentId_attendanceDate_attendanceType: {
                                    studentId: student.id,
                                    attendanceDate: new Date(attendanceDate),
                                    attendanceType
                                }
                            }
                        });

                        if (existingRecord) {
                            // Delete the record
                            await tx.attendance.delete({
                                where: {
                                    studentId_attendanceDate_attendanceType: {
                                        studentId: student.id,
                                        attendanceDate: new Date(attendanceDate),
                                        attendanceType
                                    }
                                }
                            });

                            deletedRecords.push({
                                studentCode: student.studentCode,
                                studentName: student.fullName,
                                className: student.class?.name,
                                department: student.class?.department?.displayName,
                                wasPresent: existingRecord.isPresent,
                                status: 'deleted'
                            });
                        } else {
                            notFoundRecords.push({
                                studentCode: student.studentCode,
                                studentName: student.fullName,
                                status: 'not_found'
                            });
                        }
                    } catch (error) {
                        console.error(`Error deleting attendance for ${student.studentCode}:`, error);
                        notFoundRecords.push({
                            studentCode: student.studentCode,
                            error: error.message,
                            status: 'error'
                        });
                    }
                }

                // ✅ STEP 3: Update attendance counts for affected students
                if (deletedRecords.length > 0) {
                    const affectedStudentIds = deletedRecords.map(r =>
                        students.find(s => s.studentCode === r.studentCode)?.id
                    ).filter(Boolean);

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
                        WHERE id = ANY(${affectedStudentIds}::int[])
                    `;
                }

                return {
                    deletedRecords,
                    notFoundRecords,
                    deletedCount: deletedRecords.length,
                    notFoundCount: notFoundRecords.length
                };

            }, {
                maxWait: 3000,
                timeout: 5000
            });

            // ✅ STEP 4: Background score updates
            if (result.deletedCount > 0) {
                const affectedStudentIds = result.deletedRecords.map(r =>
                    students.find(s => s.studentCode === r.studentCode)?.id
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

            // ✅ STEP 5: Response
            const response = {
                success: true,
                message: `Đã hủy điểm danh ${result.deletedCount}/${studentCodes.length} thiếu nhi`,
                count: result.deletedCount,
                details: {
                    total: studentCodes.length,
                    deleted: result.deletedCount,
                    notFound: result.notFoundCount
                },
                deletedRecords: result.deletedRecords,
                notFoundRecords: result.notFoundRecords.length > 0 ? result.notFoundRecords : undefined,
                markedBy: {
                    userId: req.user.userId,
                    name: req.user.fullName || req.user.username,
                    role: req.user.role
                }
            };

            console.log('✅ Undo attendance completed:', response.details);

            res.json(response);

        } catch (error) {
            console.error('❌ Undo attendance error:', error);
            res.status(500).json({
                success: false,
                error: 'Lỗi server khi hủy điểm danh',
                code: 'UNDO_ATTENDANCE_ERROR'
            });
        }
    },

    // ✅ NEW: Universal attendance - cross-class attendance marking
    async universalAttendance(req, res) {
        try {
            const { studentCodes, attendanceDate, attendanceType, note } = req.body;

            console.log('🌍 Universal attendance request:', {
                studentCodes: studentCodes.slice(0, 5),
                attendanceDate,
                attendanceType,
                totalCodes: studentCodes.length
            });

            // ✅ STEP 1: Find students by codes
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

            // ✅ STEP 2: Universal permissions - allow all active students
            const authorizedStudents = students.filter(s => s.isActive);

            if (authorizedStudents.length === 0) {
                return res.status(400).json({
                    success: false,
                    error: 'Không tìm thấy thiếu nhi nào hợp lệ để điểm danh',
                    invalidStudentCodes: studentCodes,
                    count: 0
                });
            }

            // ✅ STEP 3: Process attendance in transaction
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
                                isPresent: true, // Always present
                                note: note || 'Universal QR Scan',
                                markedBy: req.user.userId,
                                markedAt: new Date()
                            },
                            create: {
                                studentId: student.id,
                                attendanceDate: new Date(attendanceDate),
                                attendanceType,
                                isPresent: true, // Always present
                                note: note || 'Universal QR Scan',
                                markedBy: req.user.userId
                            }
                        });

                        results.push({
                            studentCode: student.studentCode,
                            studentName: student.fullName,
                            className: student.class?.name,
                            department: student.class?.department?.displayName,
                            isPresent: true,
                            status: 'success'
                        });

                        affectedStudents.add(student.id);

                    } catch (error) {
                        console.error(`Error marking attendance for ${student.studentCode}:`, error);
                        errors.push({
                            studentCode: student.studentCode,
                            error: error.message,
                            status: 'failed'
                        });
                    }
                }

                // ✅ STEP 4: Update attendance counts
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
                maxWait: 3000,
                timeout: 5000
            });

            // ✅ STEP 5: Background score updates
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

            // ✅ STEP 6: Response
            const response = {
                success: true,
                message: `Điểm danh thành công ${result.successCount}/${studentCodes.length} thiếu nhi`,
                count: result.successCount,
                details: {
                    total: studentCodes.length,
                    success: result.successCount,
                    failed: result.errorCount,
                    invalid: invalidCodes.length
                },
                results: result.results,
                invalidStudentCodes: invalidCodes.length > 0 ? invalidCodes : undefined,
                errors: result.errors.length > 0 ? result.errors : undefined
            };

            console.log('✅ Universal attendance completed:', response.details);

            res.json(response);

        } catch (error) {
            console.error('❌ Universal attendance error:', error);
            res.status(500).json({
                success: false,
                error: 'Lỗi server khi điểm danh',
                code: 'UNIVERSAL_ATTENDANCE_ERROR'
            });
        }
    },

    // ✅ NEW: Queue score updates for background processing
    async queueScoreUpdates(studentIds) {
        try {
            if (redis) {
                // Add to Redis queue
                await redis.lPush('score_update_queue', JSON.stringify({
                    studentIds,
                    timestamp: new Date().toISOString(),
                    type: 'attendance_update'
                }));
            } else {
                // Fallback: immediate background processing
                setImmediate(() => {
                    Promise.allSettled(
                        studentIds.map(async (studentId) => {
                            try {
                                await ScoreService.updateStudentScores(studentId, {});
                            } catch (err) {
                                console.error(`Score update failed for student ${studentId}:`, err.message);
                            }
                        })
                    );
                });
            }
        } catch (error) {
            console.error('Queue score updates error:', error);
        }
    },

    // ✅ Get today's attendance status for students
    async getTodayAttendanceStatus(req, res) {
        try {
            const { date, type } = req.query;
            const { studentCodes } = req.body;

            if (!date || !type || !studentCodes || !Array.isArray(studentCodes)) {
                return res.status(400).json({
                    error: 'Date, type, and studentCodes array are required'
                });
            }

            // Single query to get all attendance records
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

            // Build status map
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
                    canToggle: true
                };
            });

            const attendedCount = Object.values(statusMap).filter(s => s.isPresent).length;
            const absentCount = Object.values(statusMap).filter(s => !s.isPresent).length;

            res.json({
                date,
                type,
                attendanceStatus: statusMap,
                summary: {
                    total: studentCodes.length,
                    attended: attendedCount,
                    absent: absentCount,
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