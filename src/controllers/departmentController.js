const { prisma } = require('../../prisma/client');

const departmentController = {
    // Get all departments
    async getDepartments(req, res) {
        try {
            const departments = await prisma.department.findMany({
                where: { isActive: true },
                include: {
                    _count: {
                        select: {
                            classes: { where: { isActive: true } },
                            users: { where: { isActive: true } }
                        }
                    }
                },
                orderBy: { name: 'asc' }
            });

            res.json(departments);
        } catch (error) {
            console.error('Get departments error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get department statistics
    async getDepartmentStats(req, res) {
        try {
            const stats = await prisma.department.findMany({
                where: { isActive: true },
                include: {
                    _count: {
                        select: {
                            classes: { where: { isActive: true } },
                            users: { where: { isActive: true, role: 'giao_ly_vien' } }
                        }
                    },
                    classes: {
                        where: { isActive: true },
                        include: {
                            _count: {
                                select: { students: { where: { isActive: true } } }
                            }
                        }
                    }
                }
            });

            const formattedStats = stats.map(dept => ({
                id: dept.id,
                name: dept.name,
                displayName: dept.displayName,
                totalClasses: dept._count.classes,
                totalTeachers: dept._count.users,
                totalStudents: dept.classes.reduce((sum, cls) => sum + cls._count.students, 0)
            }));

            res.json(formattedStats);
        } catch (error) {
            console.error('Get department stats error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    }
};

module.exports = departmentController;