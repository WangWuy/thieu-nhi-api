const { prisma } = require('../../prisma/client');
const { getWeekRange, getAttendanceTargetDate } = require('../utils/weekUtils');

const dashboardController = {
    // Get dashboard stats - optimized for performance
    async getDashboardStats(req, res) {
        try {
            const { role, departmentId } = req.user;

            // Base queries for different roles
            let departmentFilter = {};
            let classFilter = {};
            let studentFilter = {};
            let userFilter = {};

            // Apply role-based filtering
            if (role === 'phan_doan_truong') {
                departmentFilter = { id: departmentId };
                classFilter = { departmentId: departmentId };
                studentFilter = { class: { departmentId: departmentId } };
                userFilter = {
                    OR: [
                        { departmentId: departmentId },
                        { role: 'giao_ly_vien', classTeachers: { some: { class: { departmentId } } } }
                    ]
                };
            }

            // Execute all count queries in parallel for performance
            const [
                totalDepartments,
                totalClasses,
                totalStudents,
                totalTeachers,
                departmentStats
            ] = await Promise.all([
                // Count departments
                prisma.department.count({
                    where: { isActive: true, ...departmentFilter }
                }),

                // Count classes
                prisma.class.count({
                    where: { isActive: true, ...classFilter }
                }),

                // Count students
                prisma.student.count({
                    where: { isActive: true, ...studentFilter }
                }),

                // Count teachers
                prisma.user.count({
                    where: {
                        role: 'giao_ly_vien',
                        isActive: true,
                        ...userFilter
                    }
                }),

                // Department detailed stats
                prisma.department.findMany({
                    where: { isActive: true, ...departmentFilter },
                    select: {
                        id: true,
                        name: true,
                        displayName: true,
                        _count: {
                            select: {
                                classes: { where: { isActive: true } },
                                users: {
                                    where: {
                                        role: 'giao_ly_vien',
                                        isActive: true
                                    }
                                }
                            }
                        }
                    }
                })
            ]);

            // Get student count for each department separately (more efficient)
            const departmentStudentCounts = await Promise.all(
                departmentStats.map(async (dept) => {
                    const studentCount = await prisma.student.count({
                        where: {
                            isActive: true,
                            class: {
                                departmentId: dept.id,
                                isActive: true
                            }
                        }
                    });
                    return { departmentId: dept.id, studentCount };
                })
            );

            // Format department stats with student counts
            const formattedDepartmentStats = departmentStats.map(dept => {
                const studentData = departmentStudentCounts.find(s => s.departmentId === dept.id);
                return {
                    id: dept.id,
                    name: dept.name,
                    displayName: dept.displayName,
                    totalClasses: dept._count.classes,
                    totalTeachers: dept._count.users,
                    totalStudents: studentData?.studentCount || 0
                };
            });

            // Additional stats for ban_dieu_hanh role
            let additionalStats = {};
            if (role === 'ban_dieu_hanh') {
                const [recentAttendance, activeUsers, totalActiveStudents] = await Promise.all([
                    // Recent attendance stats (last 7 days)
                    prisma.attendance.groupBy({
                        by: ['attendanceType', 'isPresent'],
                        where: {
                            attendanceDate: {
                                gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000)
                            }
                        },
                        _count: { id: true }
                    }),

                    // Active users by role
                    prisma.user.groupBy({
                        by: ['role'],
                        where: { isActive: true },
                        _count: { id: true }
                    }),

                    // Tổng số học sinh active để tính notMarked
                    prisma.student.count({
                        where: { isActive: true }
                    })
                ]);

                const thursdayPresent = recentAttendance.find(a => a.attendanceType === 'thursday' && a.isPresent)?._count.id || 0;
                const thursdayAbsent = recentAttendance.find(a => a.attendanceType === 'thursday' && !a.isPresent)?._count.id || 0;
                const sundayPresent = recentAttendance.find(a => a.attendanceType === 'sunday' && a.isPresent)?._count.id || 0;
                const sundayAbsent = recentAttendance.find(a => a.attendanceType === 'sunday' && !a.isPresent)?._count.id || 0;

                additionalStats = {
                    recentAttendance: {
                        thursday: {
                            present: thursdayPresent,
                            notMarked: Math.max(0, totalActiveStudents - thursdayPresent - thursdayAbsent)
                        },
                        sunday: {
                            present: sundayPresent,
                            notMarked: Math.max(0, totalActiveStudents - sundayPresent - sundayAbsent)
                        }
                    },
                    usersByRole: {
                        ban_dieu_hanh: activeUsers.find(u => u.role === 'ban_dieu_hanh')?._count.id || 0,
                        phan_doan_truong: activeUsers.find(u => u.role === 'phan_doan_truong')?._count.id || 0,
                        giao_ly_vien: activeUsers.find(u => u.role === 'giao_ly_vien')?._count.id || 0
                    }
                };
            }

            res.json({
                summary: {
                    totalDepartments,
                    totalClasses,
                    totalStudents,
                    totalTeachers
                },
                departmentStats: formattedDepartmentStats,
                ...additionalStats,
                lastUpdated: new Date().toISOString()
            });

        } catch (error) {
            console.error('Get dashboard stats error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get quick counts only (for real-time updates)
    async getQuickCounts(req, res) {
        try {
            const { role, departmentId } = req.user;

            let classFilter = {};
            let studentFilter = {};

            if (role === 'phan_doan_truong') {
                classFilter = { departmentId: departmentId };
                studentFilter = { class: { departmentId: departmentId } };
            }

            const [totalClasses, totalStudents] = await Promise.all([
                prisma.class.count({
                    where: { isActive: true, ...classFilter }
                }),
                prisma.student.count({
                    where: { isActive: true, ...studentFilter }
                })
            ]);

            res.json({
                totalClasses,
                totalStudents,
                timestamp: new Date().toISOString()
            });

        } catch (error) {
            console.error('Get quick counts error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get weekly attendance trend (4 weeks)
    async getWeeklyAttendanceTrend(req, res) {
        try {
            const { attendanceType = 'sunday' } = req.query; // default sunday
            const { role, departmentId: userDepartmentId } = req.user;

            // Calculate date range for last 4 weeks
            const endDate = new Date();
            const startDate = new Date(endDate);
            startDate.setDate(startDate.getDate() - 21); // 3 weeks = 21 days

            // Base filters
            let attendanceWhere = {
                attendanceDate: {
                    gte: startDate,
                    lte: endDate
                },
                attendanceType: attendanceType,
                isPresent: true
            };

            let studentWhere = { isActive: true };

            // Role-based filtering
            if (role === 'phan_doan_truong') {
                attendanceWhere.student = {
                    class: { departmentId: userDepartmentId }
                };
                studentWhere.class = { departmentId: userDepartmentId };
            }

            // Get attendance data for the period - optimized query
            const attendanceData = await prisma.attendance.findMany({
                where: attendanceWhere,
                select: {
                    studentId: true,
                    attendanceDate: true,
                    student: {
                        select: {
                            class: {
                                select: {
                                    department: {
                                        select: {
                                            name: true,
                                            displayName: true
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            });

            // Get department totals separately
            const deptTotals = await prisma.student.findMany({
                where: studentWhere,
                select: {
                    class: {
                        select: {
                            department: {
                                select: {
                                    name: true,
                                    displayName: true
                                }
                            }
                        }
                    }
                }
            });

            const departmentStudentCounts = {};
            deptTotals.forEach(student => {
                const deptName = student.class.department.name;
                departmentStudentCounts[deptName] = (departmentStudentCounts[deptName] || 0) + 1;
            });

            // Process attendance data by week and department
            const weeklyData = {};

            // Group attendance by week and department
            attendanceData.forEach(record => {
                const { startDate: weekStart } = getWeekRange(record.attendanceDate);
                const weekKey = weekStart.toISOString().split('T')[0];
                const deptName = record.student.class.department.name;

                if (!weeklyData[weekKey]) {
                    weeklyData[weekKey] = {};
                }

                if (!weeklyData[weekKey][deptName]) {
                    weeklyData[weekKey][deptName] = 0;
                }

                weeklyData[weekKey][deptName]++;
            });

            // Get last 3 weeks in chronological order
            const weeks = Object.keys(weeklyData)
                .sort()
                .slice(-3);

            // If we don't have 3 weeks, fill with empty weeks
            const today = new Date();
            const allWeeks = [];
            for (let i = 2; i >= 0; i--) {
                const weekDate = new Date(today);
                weekDate.setDate(today.getDate() - (i * 7));
                const { startDate: weekStart } = getWeekRange(weekDate);
                const weekKey = weekStart.toISOString().split('T')[0];
                allWeeks.push(weekKey);
            }

            // Build response data
            const responseWeeks = allWeeks.map(weekKey => {
                const weekData = weeklyData[weekKey] || {};
                const weekDate = new Date(weekKey);

                // Calculate correct date for display
                let displayDate, displayPrefix;
                if (attendanceType === 'thursday') {
                    // Thu 5 = ngay thu 4 cua tuan (0=CN, 1=T2, ..., 4=T5)
                    const thursdayDate = new Date(weekDate);
                    thursdayDate.setDate(weekDate.getDate() + 4);
                    displayDate = thursdayDate;
                    displayPrefix = 'T5';
                } else {
                    // Chu nhat = ngay thu 6 cua tuan (tuan bat dau tu T2)
                    const sundayDate = new Date(weekDate);
                    sundayDate.setDate(weekDate.getDate() + 6);
                    displayDate = sundayDate;
                    displayPrefix = 'CN';
                }

                return {
                    week: weekKey,
                    displayWeek: `${displayPrefix} ${displayDate.getDate()}/${displayDate.getMonth() + 1}`,
                    data: {
                        NGHIA: weekData.NGHIA || 0,
                        THIEU: weekData.THIEU || 0,
                        AU: weekData.AU || 0,
                        CHIEN: weekData.CHIEN || 0
                    }
                };
            });

            // Calculate total for each week (for overall trend line)
            const totalTrend = responseWeeks.map(week => ({
                week: week.displayWeek,
                total: Object.values(week.data).reduce((sum, count) => sum + count, 0)
            }));

            // Format for line chart with colors - theo dung mau trong anh
            const chartData = {
                weeks: responseWeeks.map(w => w.displayWeek),
                datasets: [
                    {
                        name: 'Nghĩa sĩ',
                        data: responseWeeks.map(w => w.data.NGHIA),
                        color: '#FCD34D' // vàng
                    },
                    {
                        name: 'Thiếu nhi',
                        data: responseWeeks.map(w => w.data.THIEU),
                        color: '#3B82F6' // xanh dương
                    },
                    {
                        name: 'Ấu nhi',
                        data: responseWeeks.map(w => w.data.AU),
                        color: '#10B981' // xanh lá
                    },
                    {
                        name: 'Chiên con',
                        data: responseWeeks.map(w => w.data.CHIEN),
                        color: '#EC4899' // hồng
                    }
                ]
            };

            // Thống kê tổng hợp
            const summary = {
                totalStudents: Object.values(departmentStudentCounts).reduce((sum, count) => sum + count, 0),
                departmentTotals: departmentStudentCounts,
                attendanceType: attendanceType === 'sunday' ? 'Chủ nhật' : 'Thứ 5',
                period: '3 tuần gần nhất'
            };

            res.json({
                chartData,
                totalTrend,
                summary,
                rawData: responseWeeks,
                lastUpdated: new Date().toISOString()
            });

        } catch (error) {
            console.error('Get weekly attendance trend error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Cập nhật method trong dashboardController.js

    async getDepartmentClassesAttendance(req, res) {
        try {
            const { department, attendanceType = 'sunday', date } = req.query;
            const { role, departmentId: userDepartmentId } = req.user;

            if (!department || !date) {
                return res.status(400).json({ error: 'Department và date là bắt buộc' });
            }

            // Role-based filtering
            let departmentFilter = { name: department };
            if (role === 'phan_doan_truong') {
                const userDept = await prisma.department.findUnique({
                    where: { id: userDepartmentId }
                });
                if (!userDept || userDept.name !== department) {
                    return res.status(403).json({ error: 'Không có quyền xem ngành này' });
                }
            }

            // Parse selected date và tính tuần
            const selectedDate = new Date(date);
            const { startDate: weekStart, endDate: weekEnd } = getWeekRange(selectedDate);

            // Tính ngày chính xác để hiển thị
            let displayDate;
            if (attendanceType === 'thursday') {
                // Thứ 5 = ngày thứ 4 của tuần (0=CN, 1=T2, ..., 4=T5)
                displayDate = new Date(weekStart);
                displayDate.setDate(weekStart.getDate() + 4);
            } else if (attendanceType === 'sunday') {
                // Chủ nhật = ngày thứ 6 của tuần (tuần bắt đầu từ T2)
                displayDate = new Date(weekStart);
                displayDate.setDate(weekStart.getDate() + 6);
            }

            // Get all classes in the department
            const classes = await prisma.class.findMany({
                where: {
                    isActive: true,
                    department: departmentFilter
                },
                include: {
                    department: true,
                    _count: {
                        select: {
                            students: { where: { isActive: true } }
                        }
                    }
                },
                orderBy: { name: 'asc' }
            });

            // Get attendance data for the entire week
            let attendanceWhereClause = {
                attendanceDate: {
                    gte: weekStart,
                    lte: weekEnd
                },
                isPresent: true,
                student: {
                    isActive: true,
                    class: {
                        department: departmentFilter
                    }
                }
            };

            // Filter attendance type
            if (attendanceType === 'thursday') {
                // Lấy tất cả điểm danh T2-T6 (trừ CN)
                attendanceWhereClause.attendanceType = 'thursday';
            } else if (attendanceType === 'sunday') {
                // Chỉ lấy điểm danh CN
                attendanceWhereClause.attendanceType = 'sunday';
            }

            const attendanceData = await prisma.attendance.findMany({
                where: attendanceWhereClause,
                include: {
                    student: {
                        include: {
                            class: true
                        }
                    }
                }
            });

            // Group attendance by class và aggregate theo tuần
            const attendanceByClass = {};
            attendanceData.forEach(attendance => {
                const classId = attendance.student.classId;
                const studentId = attendance.studentId;

                if (!attendanceByClass[classId]) {
                    attendanceByClass[classId] = new Set();
                }

                // Aggregate: một học sinh chỉ tính 1 lần dù có nhiều ngày điểm danh trong tuần
                attendanceByClass[classId].add(studentId);
            });

            // Build response data
            const classAttendance = classes.map(cls => {
                const presentStudents = attendanceByClass[cls.id] || new Set();
                const presentCount = presentStudents.size;
                const totalStudents = cls._count.students;

                return {
                    classId: cls.id,
                    className: cls.name,
                    presentCount,
                    totalStudents,
                    attendanceRate: totalStudents > 0 ?
                        parseFloat(((presentCount / totalStudents) * 100).toFixed(1)) : 0
                };
            });

            // Calculate summary statistics
            const summary = {
                department: department,
                departmentDisplayName: classes[0]?.department?.displayName || department,
                totalClasses: classes.length,
                totalStudents: classAttendance.reduce((sum, cls) => sum + cls.totalStudents, 0),
                totalPresent: classAttendance.reduce((sum, cls) => sum + cls.presentCount, 0),
                averageAttendanceRate: classAttendance.length > 0 ?
                    parseFloat((classAttendance.reduce((sum, cls) => sum + cls.attendanceRate, 0) / classAttendance.length).toFixed(1)) : 0,
                attendanceType: attendanceType === 'sunday' ? 'Chủ nhật' : 'Thứ 5',
                weekRange: `${weekStart.toLocaleDateString('vi-VN')} - ${weekEnd.toLocaleDateString('vi-VN')}`,
                displayDate: displayDate.toISOString().split('T')[0]
            };

            res.json({
                classAttendance,
                summary,
                filters: { department, attendanceType, date },
                lastUpdated: new Date().toISOString()
            });

        } catch (error) {
            console.error('Get department classes attendance error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    }
};

module.exports = dashboardController;