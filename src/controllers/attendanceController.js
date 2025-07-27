const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const attendanceController = {
    // Mark attendance
    async markAttendance(req, res) {
        try {
            const { studentId, attendanceDate, attendanceType, isPresent, note } = req.body;

            if (!studentId || !attendanceDate || !attendanceType || isPresent === undefined) {
                return res.status(400).json({ error: 'Thiếu thông tin điểm danh' });
            }

            const attendance = await prisma.attendance.upsert({
                where: {
                    studentId_attendanceDate_attendanceType: {
                        studentId: parseInt(studentId),
                        attendanceDate: new Date(attendanceDate),
                        attendanceType
                    }
                },
                update: {
                    isPresent,
                    note,
                    markedBy: req.user.userId,
                    markedAt: new Date()
                },
                create: {
                    studentId: parseInt(studentId),
                    attendanceDate: new Date(attendanceDate),
                    attendanceType,
                    isPresent,
                    note,
                    markedBy: req.user.userId
                },
                include: {
                    student: {
                        select: { fullName: true, studentCode: true }
                    }
                }
            });

            res.json(attendance);
        } catch (error) {
            console.error('Mark attendance error:', error);
            res.status(500).json({ error: 'Lỗi server' });
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

    // Batch mark attendance for entire class
    async batchMarkAttendance(req, res) {
        try {
            const { classId } = req.params;
            const { attendanceDate, attendanceType, attendanceRecords } = req.body;

            if (!attendanceDate || !attendanceType || !attendanceRecords || !Array.isArray(attendanceRecords)) {
                return res.status(400).json({ error: 'Dữ liệu điểm danh không hợp lệ' });
            }

            const attendancePromises = attendanceRecords.map(record =>
                prisma.attendance.upsert({
                    where: {
                        studentId_attendanceDate_attendanceType: {
                            studentId: record.studentId,
                            attendanceDate: new Date(attendanceDate),
                            attendanceType
                        }
                    },
                    update: {
                        isPresent: record.isPresent,
                        note: record.note || null,
                        markedBy: req.user.userId,
                        markedAt: new Date()
                    },
                    create: {
                        studentId: record.studentId,
                        attendanceDate: new Date(attendanceDate),
                        attendanceType,
                        isPresent: record.isPresent,
                        note: record.note || null,
                        markedBy: req.user.userId
                    }
                })
            );

            const results = await Promise.all(attendancePromises);

            res.json({
                message: 'Điểm danh thành công',
                count: results.length,
                records: results
            });
        } catch (error) {
            console.error('Batch mark attendance error:', error);
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
    }
};

module.exports = attendanceController;