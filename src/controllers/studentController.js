const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const studentController = {
    // Get all students (with filters by role)
    async getStudents(req, res) {
        try {
            const { role, departmentId, classId } = req.user;
            const { page = 1, limit = 20, search, classFilter } = req.query;

            let whereClause = { isActive: true };

            // Apply role-based filters
            if (role === 'phan_doan_truong') {
                whereClause.class = { departmentId: departmentId };
            } else if (role === 'giao_ly_vien') {
                // Giáo viên có thể xem tất cả (theo yêu cầu)
                // Không filter gì thêm
            }

            // Apply search filter
            if (search) {
                whereClause.OR = [
                    { fullName: { contains: search, mode: 'insensitive' } },
                    { studentCode: { contains: search, mode: 'insensitive' } },
                    { saintName: { contains: search, mode: 'insensitive' } }
                ];
            }

            // Apply class filter
            if (classFilter) {
                whereClause.classId = parseInt(classFilter);
            }

            const skip = (page - 1) * limit;

            const [students, total] = await Promise.all([
                prisma.student.findMany({
                    where: whereClause,
                    include: {
                        class: {
                            include: {
                                department: true
                            }
                        }
                    },
                    skip,
                    take: parseInt(limit),
                    orderBy: { fullName: 'asc' }
                }),
                prisma.student.count({ where: whereClause })
            ]);

            res.json({
                students,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            });

        } catch (error) {
            console.error('Get students error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get student by ID
    async getStudentById(req, res) {
        try {
            const { id } = req.params;

            const student = await prisma.student.findUnique({
                where: { id: parseInt(id) },
                include: {
                    class: {
                        include: {
                            department: true
                        }
                    },
                    attendance: {
                        orderBy: { attendanceDate: 'desc' },
                        take: 10
                    }
                }
            });

            if (!student) {
                return res.status(404).json({ error: 'Học sinh không tồn tại' });
            }

            res.json(student);

        } catch (error) {
            console.error('Get student error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Create new student
    async createStudent(req, res) {
        try {
            const {
                studentCode,
                saintName,
                fullName,
                birthDate,
                phoneNumber,
                parentPhone1,
                parentPhone2,
                address,
                classId
            } = req.body;

            // Validate required fields
            if (!studentCode || !fullName || !classId) {
                return res.status(400).json({
                    error: 'Mã học sinh, họ tên và lớp là bắt buộc'
                });
            }

            // Check if student code already exists
            const existingStudent = await prisma.student.findUnique({
                where: { studentCode }
            });

            if (existingStudent) {
                return res.status(400).json({ error: 'Mã học sinh đã tồn tại' });
            }

            // Create student
            const student = await prisma.student.create({
                data: {
                    studentCode,
                    qrCode: `QR${studentCode}`,
                    saintName,
                    fullName,
                    birthDate: birthDate ? new Date(birthDate) : null,
                    phoneNumber,
                    parentPhone1,
                    parentPhone2,
                    address,
                    classId: parseInt(classId)
                },
                include: {
                    class: {
                        include: {
                            department: true
                        }
                    }
                }
            });

            res.status(201).json(student);

        } catch (error) {
            console.error('Create student error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Update student
    async updateStudent(req, res) {
        try {
            const { id } = req.params;
            const updateData = req.body;

            // Convert birthDate if provided
            if (updateData.birthDate) {
                updateData.birthDate = new Date(updateData.birthDate);
            }

            // Convert classId if provided
            if (updateData.classId) {
                updateData.classId = parseInt(updateData.classId);
            }

            const student = await prisma.student.update({
                where: { id: parseInt(id) },
                data: updateData,
                include: {
                    class: {
                        include: {
                            department: true
                        }
                    }
                }
            });

            res.json(student);

        } catch (error) {
            console.error('Update student error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Delete student (soft delete)
    async deleteStudent(req, res) {
        try {
            const { id } = req.params;

            await prisma.student.update({
                where: { id: parseInt(id) },
                data: { isActive: false }
            });

            res.json({ message: 'Xóa học sinh thành công' });

        } catch (error) {
            console.error('Delete student error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get students by class
    async getStudentsByClass(req, res) {
        try {
            const { classId } = req.params;

            const students = await prisma.student.findMany({
                where: {
                    classId: parseInt(classId),
                    isActive: true
                },
                include: {
                    class: {
                        include: {
                            department: true
                        }
                    }
                },
                orderBy: { fullName: 'asc' }
            });

            res.json(students);

        } catch (error) {
            console.error('Get students by class error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    }
};

module.exports = studentController;