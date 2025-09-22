const { prisma } = require('../../prisma/client');

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
                const [recentAttendance, activeUsers] = await Promise.all([
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
                    })
                ]);

                additionalStats = {
                    recentAttendance: {
                        thursday: {
                            present: recentAttendance.find(a => a.attendanceType === 'thursday' && a.isPresent)?._count.id || 0,
                            absent: recentAttendance.find(a => a.attendanceType === 'thursday' && !a.isPresent)?._count.id || 0
                        },
                        sunday: {
                            present: recentAttendance.find(a => a.attendanceType === 'sunday' && a.isPresent)?._count.id || 0,
                            absent: recentAttendance.find(a => a.attendanceType === 'sunday' && !a.isPresent)?._count.id || 0
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
    }
};

module.exports = dashboardController;