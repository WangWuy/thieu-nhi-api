const { prisma, Prisma } = require('../../prisma/client');
const ScoreService = require('../services/scoreService');
const { getWeekRange, getAttendanceTargetDate, formatWeekRange } = require('../utils/weekUtils');

// Redis connection with proper error handling
let redis = null;
if (process.env.REDIS_URL) {
    const Redis = require('redis');
    redis = Redis.createClient({ url: process.env.REDIS_URL });

    redis.on('error', (err) => {
        console.log('Redis Client Error:', err);
        redis = null;
    });

    redis.on('connect', () => {
        console.log('✅ Redis connected');
    });

    redis.on('disconnect', () => {
        console.log('❌ Redis disconnected');
        redis = null;
    });

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

    // Get attendance by date and class - theo tuần
    async getAttendanceByClass(req, res) {
        try {
            const { classId } = req.params;
            const { date, type } = req.query;

            if (!date || !type) {
                return res.status(400).json({ error: 'Thiếu ngày và loại điểm danh' });
            }

            // Tính tuần từ ngày được chọn
            const { startDate, endDate } = getWeekRange(date);

            const cacheKey = `attendance:${classId}:${startDate.toISOString().split('T')[0]}:${type}`;

            // Check cache
            if (redis?.isReady) {
                try {
                    const cached = await redis.get(cacheKey);
                    if (cached) {
                        return res.json(JSON.parse(cached));
                    }
                } catch (err) {
                    console.log('Cache error:', err.message);
                }
            }

            const students = await prisma.student.findMany({
                where: {
                    classId: parseInt(classId),
                    isActive: true
                },
                include: {
                    attendance: {
                        where: {
                            attendanceDate: {
                                gte: startDate,
                                lte: endDate
                            },
                            attendanceType: type
                        }
                    }
                },
                orderBy: { fullName: 'asc' }
            });

            const attendanceData = students.map(student => ({
                ...student,
                attendanceRecord: student.attendance[0] || null,
                weekRange: {
                    start: startDate.toISOString().split('T')[0],
                    end: endDate.toISOString().split('T')[0],
                    formatted: formatWeekRange(date)
                }
            }));

            // Cache result
            if (redis?.isReady) {
                try {
                    await redis.setEx(cacheKey, 300, JSON.stringify(attendanceData));
                } catch (err) {
                    console.log('Cache set error:', err.message);
                }
            }

            res.json(attendanceData);

        } catch (error) {
            console.error('Get attendance error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get attendance statistics - theo tuần
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

            // Date filtering - mở rộng để bao gồm cả tuần
            if (startDate && endDate) {
                const startWeek = getWeekRange(startDate);
                const endWeek = getWeekRange(endDate);

                whereClause.attendanceDate = {
                    gte: startWeek.startDate,
                    lte: endWeek.endDate
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

    // Get attendance trend by date range - theo tuần  
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

            // Date filtering - mở rộng theo tuần
            if (startDate && endDate) {
                const startWeek = getWeekRange(startDate);
                const endWeek = getWeekRange(endDate);

                whereClause.attendanceDate = {
                    gte: startWeek.startDate,
                    lte: endWeek.endDate
                };
            }

            const trendData = await prisma.attendance.groupBy({
                by: ['attendanceDate', 'attendanceType', 'isPresent'],
                where: whereClause,
                _count: { id: true },
                orderBy: { attendanceDate: 'asc' }
            });

            // Group by week instead of individual dates
            const weekMap = new Map();

            trendData.forEach(item => {
                const { startDate: weekStart } = getWeekRange(item.attendanceDate);
                const weekKey = weekStart.toISOString().split('T')[0];

                if (!weekMap.has(weekKey)) {
                    weekMap.set(weekKey, {
                        weekStart: weekKey,
                        weekEnd: new Date(weekStart.getTime() + 6 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
                        weekFormatted: formatWeekRange(weekStart),
                        thursday: { present: 0, absent: 0 },
                        sunday: { present: 0, absent: 0 }
                    });
                }

                const weekData = weekMap.get(weekKey);
                const type = item.attendanceType;
                const status = item.isPresent ? 'present' : 'absent';

                weekData[type][status] += item._count.id;
            });

            const result = Array.from(weekMap.values());

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
                // Mở rộng theo tuần
                const startWeek = getWeekRange(startDate);
                const endWeek = getWeekRange(endDate);

                whereClause.attendanceDate = {
                    gte: startWeek.startDate,
                    lte: endWeek.endDate
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

            // Group by week for easier frontend processing
            const groupedByWeek = _groupRecordsByWeek(records);

            // Group by month
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
                groupedByWeek,
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

    // Get student attendance statistics
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
                    ${year ? Prisma.sql`AND EXTRACT(YEAR FROM attendance_date) = ${parseInt(year)}` : Prisma.empty}
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

    // Universal attendance - sử dụng weekUtils
    async universalAttendance(req, res) {
        try {
            const { studentCodes, attendanceDate, attendanceType, note } = req.body;

            // Tính tuần và ngày target sử dụng weekUtils
            const { startDate, endDate } = getWeekRange(attendanceDate);
            const targetDate = getAttendanceTargetDate(attendanceDate, attendanceType);

            console.log('Week-based attendance:', {
                inputDate: attendanceDate,
                weekRange: formatWeekRange(attendanceDate),
                targetDate: targetDate.toISOString().split('T')[0],
                type: attendanceType
            });

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

            if (students.length === 0) {
                return res.status(400).json({
                    success: false,
                    error: 'Không tìm thấy thiếu nhi nào',
                    count: 0
                });
            }

            const result = await prisma.$transaction(async (tx) => {
                const results = [];
                const errors = [];

                for (const student of students) {
                    try {
                        const attendance = await tx.attendance.upsert({
                            where: {
                                studentId_attendanceDate_attendanceType: {
                                    studentId: student.id,
                                    attendanceDate: targetDate,
                                    attendanceType
                                }
                            },
                            update: {
                                isPresent: true,
                                note: note || `Week ${formatWeekRange(attendanceDate)}`,
                                markedBy: req.user.userId,
                                markedAt: new Date()
                            },
                            create: {
                                studentId: student.id,
                                attendanceDate: targetDate,
                                attendanceType,
                                isPresent: true,
                                note: note || `Week ${formatWeekRange(attendanceDate)}`,
                                markedBy: req.user.userId
                            }
                        });

                        results.push({
                            studentCode: student.studentCode,
                            studentName: student.fullName,
                            className: student.class?.name,
                            department: student.class?.department?.displayName,
                            isPresent: true,
                            actualDate: targetDate.toISOString().split('T')[0],
                            weekRange: formatWeekRange(attendanceDate),
                            status: 'success'
                        });

                    } catch (error) {
                        console.error(`Error marking attendance for ${student.studentCode}:`, error);
                        errors.push({
                            studentCode: student.studentCode,
                            error: error.message
                        });
                    }
                }

                // Update attendance counts
                if (results.length > 0) {
                    const studentIds = results.map(r =>
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
                        WHERE id = ANY(${studentIds}::int[])
                    `;
                }

                return { results, errors };
            });

            res.json({
                success: true,
                message: `Điểm danh thành công ${result.results.length}/${studentCodes.length} thiếu nhi`,
                count: result.results.length,
                weekInfo: {
                    inputDate: attendanceDate,
                    actualDate: targetDate.toISOString().split('T')[0],
                    weekRange: formatWeekRange(attendanceDate)
                },
                results: result.results,
                errors: result.errors
            });

        } catch (error) {
            console.error('Universal attendance error:', error);
            res.status(500).json({
                success: false,
                error: 'Lỗi server khi điểm danh'
            });
        }
    },

    // Undo attendance - sử dụng weekUtils
    async undoAttendance(req, res) {
        try {
            const { studentCodes, attendanceDate, attendanceType, note } = req.body;

            // Tính tuần từ ngày được chọn
            const { startDate, endDate } = getWeekRange(attendanceDate);

            console.log('Undo attendance request:', {
                inputDate: attendanceDate,
                weekRange: formatWeekRange(attendanceDate),
                type: attendanceType,
                totalCodes: studentCodes.length
            });

            // Tìm students theo codes
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

            // Xóa attendance records trong tuần đó
            const result = await prisma.$transaction(async (tx) => {
                const deletedRecords = [];
                const notFoundRecords = [];

                for (const student of students) {
                    try {
                        // Tìm record trong tuần
                        const existingRecord = await tx.attendance.findFirst({
                            where: {
                                studentId: student.id,
                                attendanceDate: {
                                    gte: startDate,
                                    lte: endDate
                                },
                                attendanceType
                            }
                        });

                        if (existingRecord) {
                            // Xóa record
                            await tx.attendance.delete({
                                where: { id: existingRecord.id }
                            });

                            deletedRecords.push({
                                studentCode: student.studentCode,
                                studentName: student.fullName,
                                className: student.class?.name,
                                department: student.class?.department?.displayName,
                                wasPresent: existingRecord.isPresent,
                                deletedDate: existingRecord.attendanceDate,
                                weekRange: formatWeekRange(attendanceDate),
                                status: 'deleted'
                            });
                        } else {
                            notFoundRecords.push({
                                studentCode: student.studentCode,
                                studentName: student.fullName,
                                weekRange: formatWeekRange(attendanceDate),
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

                // Update attendance counts
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

            }, { timeout: 5000 });

            // Background score updates
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

            const response = {
                success: true,
                message: `Đã hủy điểm danh ${result.deletedCount}/${studentCodes.length} thiếu nhi`,
                count: result.deletedCount,
                weekInfo: {
                    inputDate: attendanceDate,
                    weekRange: formatWeekRange(attendanceDate)
                },
                details: {
                    total: studentCodes.length,
                    deleted: result.deletedCount,
                    notFound: result.notFoundCount
                },
                deletedRecords: result.deletedRecords,
                notFoundRecords: result.notFoundRecords.length > 0 ? result.notFoundRecords : undefined
            };

            console.log('Undo attendance completed:', response.details);
            res.json(response);

        } catch (error) {
            console.error('Undo attendance error:', error);
            res.status(500).json({
                success: false,
                error: 'Lỗi server khi hủy điểm danh',
                code: 'UNDO_ATTENDANCE_ERROR'
            });
        }
    },

    // Get today's attendance status for students - sử dụng weekUtils
    async getTodayAttendanceStatus(req, res) {
        try {
            const { date, type } = req.query;
            const { studentCodes } = req.body;

            if (!date || !type || !studentCodes) {
                return res.status(400).json({
                    error: 'Date, type, and studentCodes are required'
                });
            }

            // Tính tuần từ ngày được chọn
            const { startDate, endDate } = getWeekRange(date);

            const attendanceRecords = await prisma.attendance.findMany({
                where: {
                    attendanceDate: {
                        gte: startDate,
                        lte: endDate
                    },
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
                    actualDate: record.attendanceDate,
                    weekRange: formatWeekRange(date)
                };
            });

            const attendedCount = Object.values(statusMap).filter(s => s.isPresent).length;
            const absentCount = Object.values(statusMap).filter(s => !s.isPresent).length;

            res.json({
                date,
                type,
                weekRange: {
                    start: startDate.toISOString().split('T')[0],
                    end: endDate.toISOString().split('T')[0],
                    formatted: formatWeekRange(date)
                },
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
    }
};

// Helper function to group records by week
function _groupRecordsByWeek(records) {
    const grouped = {};

    records.forEach(record => {
        const { startDate } = getWeekRange(record.attendanceDate);
        const weekKey = startDate.toISOString().split('T')[0];

        if (!grouped[weekKey]) {
            const endDate = new Date(startDate.getTime() + 6 * 24 * 60 * 60 * 1000);

            grouped[weekKey] = {
                weekStart: weekKey,
                weekEnd: endDate.toISOString().split('T')[0],
                weekFormatted: formatWeekRange(startDate),
                records: [],
                stats: {
                    total: 0,
                    present: 0,
                    absent: 0,
                    thursday: { total: 0, present: 0, absent: 0 },
                    sunday: { total: 0, present: 0, absent: 0 }
                }
            };
        }

        grouped[weekKey].records.push(record);
        grouped[weekKey].stats.total++;

        if (record.isPresent) {
            grouped[weekKey].stats.present++;
        } else {
            grouped[weekKey].stats.absent++;
        }

        // Type-specific stats
        const typeKey = record.attendanceType;
        grouped[weekKey].stats[typeKey].total++;
        if (record.isPresent) {
            grouped[weekKey].stats[typeKey].present++;
        } else {
            grouped[weekKey].stats[typeKey].absent++;
        }
    });

    // Convert to array and sort by week descending (newest first)
    return Object.entries(grouped)
        .map(([key, data]) => ({ weekKey: key, ...data }))
        .sort((a, b) => b.weekKey.localeCompare(a.weekKey));
};

// Helper function to group records by month
function _groupRecordsByMonth(records) {
    const grouped = {};
    const monthNames = [
        '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
        'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];

    records.forEach(record => {
        const date = new Date(record.attendanceDate);
        const year = date.getFullYear();
        const month = date.getMonth() + 1;
        const monthKey = `${year}-${String(month).padStart(2, '0')}`;

        if (!grouped[monthKey]) {
            grouped[monthKey] = {
                monthKey,
                year,
                month,
                monthName: `${monthNames[month]} ${year}`,
                records: [],
                stats: {
                    total: 0,
                    present: 0,
                    absent: 0,
                    thursday: { total: 0, present: 0, absent: 0 },
                    sunday: { total: 0, present: 0, absent: 0 }
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
        } else {
            grouped[monthKey].stats[typeKey].absent++;
        }
    });

    // Convert to array and sort by month descending (newest first)
    return Object.values(grouped)
        .sort((a, b) => b.monthKey.localeCompare(a.monthKey));
}

module.exports = attendanceController;