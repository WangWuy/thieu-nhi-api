const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const academicYearController = {
    // Get all academic years
    async getAcademicYears(req, res) {
        try {
            const academicYears = await prisma.academicYear.findMany({
                include: {
                    _count: {
                        select: { students: { where: { isActive: true } } }
                    }
                },
                orderBy: { createdAt: 'desc' }
            });

            res.json(academicYears);
        } catch (error) {
            console.error('Get academic years error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get current academic year
    async getCurrentAcademicYear(req, res) {
        try {
            const currentYear = await prisma.academicYear.findFirst({
                where: { isCurrent: true },
                include: {
                    _count: {
                        select: { students: { where: { isActive: true } } }
                    }
                }
            });

            if (!currentYear) {
                return res.status(404).json({ error: 'Chưa có năm học hiện tại' });
            }

            res.json(currentYear);
        } catch (error) {
            console.error('Get current academic year error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Create new academic year
    async createAcademicYear(req, res) {
        try {
            const { name, startDate, endDate } = req.body;

            if (!name || !startDate || !endDate) {
                return res.status(400).json({
                    error: 'Tên năm học, ngày bắt đầu và kết thúc là bắt buộc'
                });
            }

            const start = new Date(startDate);
            const end = new Date(endDate);

            if (start >= end) {
                return res.status(400).json({
                    error: 'Ngày bắt đầu phải trước ngày kết thúc'
                });
            }

            // Calculate total weeks
            const totalWeeks = calculateWeeks(start, end);

            // Check if name already exists
            const existingYear = await prisma.academicYear.findUnique({
                where: { name }
            });

            if (existingYear) {
                return res.status(400).json({ error: 'Tên năm học đã tồn tại' });
            }

            const academicYear = await prisma.academicYear.create({
                data: {
                    name,
                    startDate: start,
                    endDate: end,
                    totalWeeks
                }
            });

            res.status(201).json(academicYear);
        } catch (error) {
            console.error('Create academic year error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Update academic year
    async updateAcademicYear(req, res) {
        try {
            const { id } = req.params;
            const { name, startDate, endDate } = req.body;

            const updateData = {};

            if (name) updateData.name = name;
            if (startDate) updateData.startDate = new Date(startDate);
            if (endDate) updateData.endDate = new Date(endDate);

            // Recalculate weeks if dates changed
            if (startDate && endDate) {
                const start = new Date(startDate);
                const end = new Date(endDate);

                if (start >= end) {
                    return res.status(400).json({
                        error: 'Ngày bắt đầu phải trước ngày kết thúc'
                    });
                }

                updateData.totalWeeks = calculateWeeks(start, end);
            }

            const academicYear = await prisma.academicYear.update({
                where: { id: parseInt(id) },
                data: updateData
            });

            res.json(academicYear);
        } catch (error) {
            console.error('Update academic year error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Set current academic year
    async setCurrentAcademicYear(req, res) {
        try {
            const { id } = req.params;

            // Transaction to ensure only one current year
            await prisma.$transaction([
                // Remove current flag from all years
                prisma.academicYear.updateMany({
                    where: { isCurrent: true },
                    data: { isCurrent: false }
                }),
                // Set new current year
                prisma.academicYear.update({
                    where: { id: parseInt(id) },
                    data: { isCurrent: true }
                })
            ]);

            const currentYear = await prisma.academicYear.findUnique({
                where: { id: parseInt(id) }
            });

            res.json(currentYear);
        } catch (error) {
            console.error('Set current academic year error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Delete academic year (soft delete)
    async deleteAcademicYear(req, res) {
        try {
            const { id } = req.params;

            // Check if this year has students
            const studentCount = await prisma.student.count({
                where: { academicYearId: parseInt(id), isActive: true }
            });

            if (studentCount > 0) {
                return res.status(400).json({
                    error: `Không thể xóa năm học có ${studentCount} học sinh`
                });
            }

            await prisma.academicYear.update({
                where: { id: parseInt(id) },
                data: { isActive: false, isCurrent: false }
            });

            res.json({ message: 'Xóa năm học thành công' });
        } catch (error) {
            console.error('Delete academic year error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get academic year statistics
    async getAcademicYearStats(req, res) {
        try {
            const { id } = req.params;

            const stats = await prisma.academicYear.findUnique({
                where: { id: parseInt(id) },
                include: {
                    students: {
                        where: { isActive: true },
                        include: {
                            class: {
                                include: { department: true }
                            }
                        }
                    }
                }
            });

            if (!stats) {
                return res.status(404).json({ error: 'Năm học không tồn tại' });
            }

            // Group students by department
            const departmentStats = {};
            stats.students.forEach(student => {
                const deptName = student.class.department.name;
                if (!departmentStats[deptName]) {
                    departmentStats[deptName] = {
                        name: deptName,
                        displayName: student.class.department.displayName,
                        studentCount: 0,
                        classes: new Set()
                    };
                }
                departmentStats[deptName].studentCount++;
                departmentStats[deptName].classes.add(student.class.name);
            });

            // Convert Set to array for classes
            Object.values(departmentStats).forEach(dept => {
                dept.classCount = dept.classes.size;
                dept.classes = Array.from(dept.classes);
            });

            res.json({
                academicYear: {
                    id: stats.id,
                    name: stats.name,
                    startDate: stats.startDate,
                    endDate: stats.endDate,
                    totalWeeks: stats.totalWeeks,
                    isCurrent: stats.isCurrent
                },
                summary: {
                    totalStudents: stats.students.length,
                    totalDepartments: Object.keys(departmentStats).length
                },
                departmentStats: Object.values(departmentStats)
            });
        } catch (error) {
            console.error('Get academic year stats error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    }
};

// Helper function to calculate weeks - MOVED outside the object
const calculateWeeks = (startDate, endDate) => {
    const diffTime = Math.abs(endDate - startDate);
    const diffWeeks = Math.ceil(diffTime / (1000 * 60 * 60 * 24 * 7));
    return diffWeeks;
};

module.exports = academicYearController;