const { prisma } = require('../../prisma/client');

const classController = {
    // Get all classes (filtered by role)
    async getClasses(req, res) {
        try {
            const { role, departmentId: userDepartmentId } = req.user;
            const { departmentId, search } = req.query; // Thêm query params
    
            let whereClause = { isActive: true };
    
            // Role-based filtering (giữ nguyên logic cũ)
            if (role === 'phan_doan_truong') {
                whereClause.departmentId = userDepartmentId;
            }
    
            // Thêm department filter cho admin/other roles
            if (departmentId && role !== 'phan_doan_truong') {
                whereClause.departmentId = parseInt(departmentId);
            }
    
            // Thêm search filter (bonus)
            if (search) {
                whereClause.name = {
                    contains: search,
                    mode: 'insensitive'
                };
            }

            const classes = await prisma.class.findMany({
                where: whereClause,
                include: {
                    department: true,
                    classTeachers: {
                        include: {
                            user: {
                                select: { id: true, fullName: true, saintName: true }
                            }
                        }
                    },
                    _count: {
                        select: { students: { where: { isActive: true } } }
                    }
                },
                orderBy: [
                    { department: { id: 'asc' } },
                    { name: 'asc' }
                ]
            });

            res.json(classes);
        } catch (error) {
            console.error('Get classes error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get class by ID
    async getClassById(req, res) {
        try {
            const { id } = req.params;

            const classData = await prisma.class.findUnique({
                where: { id: parseInt(id) },
                include: {
                    department: true,
                    classTeachers: {
                        include: {
                            user: {
                                select: { id: true, fullName: true, saintName: true, phoneNumber: true }
                            }
                        }
                    },
                    students: {
                        where: { isActive: true },
                        orderBy: { fullName: 'asc' }
                    }
                }
            });

            if (!classData) {
                return res.status(404).json({ error: 'Lớp không tồn tại' });
            }

            res.json(classData);
        } catch (error) {
            console.error('Get class error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Create new class
    async createClass(req, res) {
        try {
            const { name, departmentId, teacherIds = [] } = req.body;

            if (!name || !departmentId) {
                return res.status(400).json({ error: 'Tên lớp và ngành là bắt buộc' });
            }

            const newClass = await prisma.class.create({
                data: {
                    name,
                    departmentId: parseInt(departmentId)
                },
                include: {
                    department: true
                }
            });

            // Assign teachers if provided
            if (teacherIds.length > 0) {
                const classTeachers = teacherIds.map((teacherId, index) => ({
                    classId: newClass.id,
                    userId: parseInt(teacherId),
                    isPrimary: index === 0 // First teacher is primary
                }));

                await prisma.classTeacher.createMany({
                    data: classTeachers
                });
            }

            res.status(201).json(newClass);
        } catch (error) {
            console.error('Create class error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Update class
    async updateClass(req, res) {
        try {
            const { id } = req.params;
            const { name, departmentId } = req.body;

            const updatedClass = await prisma.class.update({
                where: { id: parseInt(id) },
                data: {
                    name,
                    departmentId: departmentId ? parseInt(departmentId) : undefined
                },
                include: {
                    department: true,
                    classTeachers: {
                        include: {
                            user: {
                                select: { id: true, fullName: true, saintName: true }
                            }
                        }
                    }
                }
            });

            res.json(updatedClass);
        } catch (error) {
            console.error('Update class error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Delete class (soft delete)
    async deleteClass(req, res) {
        try {
            const { id } = req.params;

            await prisma.class.update({
                where: { id: parseInt(id) },
                data: { isActive: false }
            });

            res.json({ message: 'Xóa lớp thành công' });
        } catch (error) {
            console.error('Delete class error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Assign teacher to class
    async assignTeacher(req, res) {
        try {
            const { classId } = req.params;
            const { userId, isPrimary = false } = req.body;

            const assignment = await prisma.classTeacher.upsert({
                where: {
                    classId_userId: {
                        classId: parseInt(classId),
                        userId: parseInt(userId)
                    }
                },
                update: { isPrimary },
                create: {
                    classId: parseInt(classId),
                    userId: parseInt(userId),
                    isPrimary
                },
                include: {
                    user: {
                        select: { id: true, fullName: true, saintName: true }
                    }
                }
            });

            res.json(assignment);
        } catch (error) {
            console.error('Assign teacher error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Remove teacher from class
    async removeTeacher(req, res) {
        try {
            const { classId, userId } = req.params;

            await prisma.classTeacher.delete({
                where: {
                    classId_userId: {
                        classId: parseInt(classId),
                        userId: parseInt(userId)
                    }
                }
            });

            res.json({ message: 'Gỡ bỏ giáo viên thành công' });
        } catch (error) {
            console.error('Remove teacher error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    }
};

module.exports = classController;