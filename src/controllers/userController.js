const { prisma } = require('../../prisma/client');
const bcrypt = require('bcryptjs');
const { deleteAvatar } = require('../config/cloudinary');

const userController = {
    // Get all users (filtered by role)
    async getUsers(req, res) {
        try {
            const { role, departmentId } = req.user;
            const { page = 1, limit = 20, search, roleFilter, departmentFilter, classFilter } = req.query;

            let whereClause = { isActive: true };

            // Role-based filtering
            if (role === 'phan_doan_truong') {
                whereClause.OR = [
                    { departmentId: departmentId },
                    { role: 'giao_ly_vien', classTeachers: { some: { class: { departmentId } } } }
                ];
            }

            // Thêm department filter
            if (departmentFilter) {
                whereClause.OR = [
                    { departmentId: parseInt(departmentFilter) },
                    { classTeachers: { some: { class: { departmentId: parseInt(departmentFilter) } } } }
                ];
            }

            // Thêm class filter
            if (classFilter) {
                whereClause.classTeachers = { some: { classId: parseInt(classFilter) } };
            }

            // Search filter
            if (search) {
                whereClause.OR = [
                    { fullName: { contains: search, mode: 'insensitive' } },
                    { username: { contains: search, mode: 'insensitive' } },
                    { saintName: { contains: search, mode: 'insensitive' } }
                ];
            }

            // Role filter
            if (roleFilter) {
                whereClause.role = roleFilter;
            }

            const skip = (page - 1) * limit;

            const [users, total] = await Promise.all([
                prisma.user.findMany({
                    where: whereClause,
                    select: {
                        id: true,
                        username: true,
                        role: true,
                        saintName: true,
                        fullName: true,
                        birthDate: true,
                        phoneNumber: true,
                        address: true,
                        departmentId: true,
                        avatarUrl: true,
                        avatarPublicId: true,
                        isActive: true,
                        createdAt: true,
                        department: true,
                        classTeachers: {
                            include: {
                                class: {
                                    include: { department: true }
                                }
                            }
                        }
                    },
                    skip,
                    take: parseInt(limit),
                    orderBy: { fullName: 'asc' }
                }),
                prisma.user.count({ where: whereClause })
            ]);

            res.json({
                users,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            });
        } catch (error) {
            console.error('Get users error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get user by ID
    async getUserById(req, res) {
        try {
            const { id } = req.params;

            const user = await prisma.user.findUnique({
                where: { id: parseInt(id) },
                select: {
                    id: true,
                    username: true,
                    role: true,
                    saintName: true,
                    fullName: true,
                    birthDate: true,
                    phoneNumber: true,
                    address: true,
                    departmentId: true,
                    avatarUrl: true,
                    avatarPublicId: true,
                    isActive: true,
                    createdAt: true,
                    department: true,
                    classTeachers: {
                        include: {
                            class: {
                                include: { department: true }
                            }
                        }
                    }
                }
            });

            if (!user) {
                return res.status(404).json({ error: 'Người dùng không tồn tại' });
            }

            res.json(user);
        } catch (error) {
            console.error('Get user error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Create new user
    async createUser(req, res) {
        try {
            const {
                username,
                password,
                role,
                saintName,
                fullName,
                birthDate,
                phoneNumber,
                address,
                departmentId
            } = req.body;

            // Validation
            if (!username || !password || !role || !fullName) {
                return res.status(400).json({ error: 'Username, password, role và họ tên là bắt buộc' });
            }

            if (password.length < 6) {
                return res.status(400).json({ error: 'Mật khẩu phải ít nhất 6 ký tự' });
            }

            // Check username exists
            const existingUser = await prisma.user.findUnique({
                where: { username }
            });

            if (existingUser) {
                return res.status(400).json({ error: 'Username đã tồn tại' });
            }

            // Hash password
            const passwordHash = await bcrypt.hash(password, 10);

            // Create user
            const user = await prisma.user.create({
                data: {
                    username,
                    passwordHash,
                    role,
                    saintName,
                    fullName,
                    birthDate: birthDate ? new Date(birthDate) : null,
                    phoneNumber,
                    address,
                    departmentId: departmentId ? parseInt(departmentId) : null
                },
                select: {
                    id: true,
                    username: true,
                    role: true,
                    saintName: true,
                    fullName: true,
                    birthDate: true,
                    phoneNumber: true,
                    address: true,
                    departmentId: true,
                    avatarUrl: true,
                    avatarPublicId: true,
                    isActive: true,
                    createdAt: true,
                    department: true
                }
            });

            res.status(201).json(user);
        } catch (error) {
            console.error('Create user error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Update user
    async updateUser(req, res) {
        try {
            const { id } = req.params;
            const updateData = { ...req.body };

            // Remove sensitive fields
            delete updateData.password;
            delete updateData.passwordHash;

            // Convert dates
            if (updateData.birthDate) {
                updateData.birthDate = new Date(updateData.birthDate);
            }

            if (updateData.departmentId) {
                updateData.departmentId = parseInt(updateData.departmentId);
            }

            const user = await prisma.user.update({
                where: { id: parseInt(id) },
                data: updateData,
                select: {
                    id: true,
                    username: true,
                    role: true,
                    saintName: true,
                    fullName: true,
                    birthDate: true,
                    phoneNumber: true,
                    address: true,
                    departmentId: true,
                    avatarUrl: true,
                    avatarPublicId: true,
                    isActive: true,
                    createdAt: true,
                    department: true,
                    classTeachers: {
                        include: {
                            class: { include: { department: true } }
                        }
                    }
                }
            });

            res.json(user);
        } catch (error) {
            console.error('Update user error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Reset user password
    async resetPassword(req, res) {
        try {
            const { id } = req.params;
            const { newPassword } = req.body;

            if (!newPassword || newPassword.length < 6) {
                return res.status(400).json({ error: 'Mật khẩu mới phải ít nhất 6 ký tự' });
            }

            const passwordHash = await bcrypt.hash(newPassword, 10);

            await prisma.user.update({
                where: { id: parseInt(id) },
                data: { passwordHash }
            });

            res.json({ message: 'Reset mật khẩu thành công' });
        } catch (error) {
            console.error('Reset password error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Deactivate user
    async deactivateUser(req, res) {
        try {
            const { id } = req.params;

            // Check if user exists
            const user = await prisma.user.findUnique({
                where: { id: parseInt(id) },
                select: { id: true, fullName: true, isActive: true }
            });

            if (!user) {
                return res.status(404).json({ error: 'Người dùng không tồn tại' });
            }

            if (!user.isActive) {
                return res.status(400).json({ error: 'Tài khoản đã bị vô hiệu hóa' });
            }

            await prisma.user.update({
                where: { id: parseInt(id) },
                data: { isActive: false }
            });

            res.json({
                message: 'Vô hiệu hóa tài khoản thành công',
                user: {
                    id: user.id,
                    fullName: user.fullName,
                    isActive: false
                }
            });
        } catch (error) {
            console.error('Deactivate user error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Activate user (kích hoạt lại tài khoản)
    async activateUser(req, res) {
        try {
            const { id } = req.params;

            // Check if user exists
            const user = await prisma.user.findUnique({
                where: { id: parseInt(id) },
                select: { id: true, fullName: true, isActive: true }
            });

            if (!user) {
                return res.status(404).json({ error: 'Người dùng không tồn tại' });
            }

            if (user.isActive) {
                return res.status(400).json({ error: 'Tài khoản đã được kích hoạt' });
            }

            await prisma.user.update({
                where: { id: parseInt(id) },
                data: { isActive: true }
            });

            res.json({
                message: 'Kích hoạt tài khoản thành công',
                user: {
                    id: user.id,
                    fullName: user.fullName,
                    isActive: true
                }
            });
        } catch (error) {
            console.error('Activate user error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Toggle user status (vô hiệu hóa/kích hoạt)
    async toggleUserStatus(req, res) {
        try {
            const { id } = req.params;
            const { action } = req.body; // 'activate' hoặc 'deactivate'

            if (!action || !['activate', 'deactivate'].includes(action)) {
                return res.status(400).json({
                    error: 'Action không hợp lệ. Sử dụng "activate" hoặc "deactivate"'
                });
            }

            // Check if user exists
            const user = await prisma.user.findUnique({
                where: { id: parseInt(id) },
                select: { id: true, fullName: true, isActive: true, role: true }
            });

            if (!user) {
                return res.status(404).json({ error: 'Người dùng không tồn tại' });
            }

            const newStatus = action === 'activate';

            // Check if already in desired status
            if (user.isActive === newStatus) {
                const statusText = newStatus ? 'đã được kích hoạt' : 'đã bị vô hiệu hóa';
                return res.status(400).json({ error: `Tài khoản ${statusText}` });
            }

            await prisma.user.update({
                where: { id: parseInt(id) },
                data: { isActive: newStatus }
            });

            const actionText = newStatus ? 'Kích hoạt' : 'Vô hiệu hóa';
            const statusText = newStatus ? 'được kích hoạt' : 'bị vô hiệu hóa';

            res.json({
                message: `${actionText} tài khoản thành công`,
                user: {
                    id: user.id,
                    fullName: user.fullName,
                    role: user.role,
                    isActive: newStatus
                },
                action: action,
                previousStatus: user.isActive
            });
        } catch (error) {
            console.error('Toggle user status error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get teachers for assignment
    async getTeachers(req, res) {
        try {
            const { departmentId } = req.query;

            let whereClause = {
                role: 'giao_ly_vien',
                isActive: true
            };

            if (departmentId) {
                whereClause.OR = [
                    { departmentId: parseInt(departmentId) },
                    { departmentId: null }
                ];
            }

            const teachers = await prisma.user.findMany({
                where: whereClause,
                select: {
                    id: true,
                    saintName: true,
                    fullName: true,
                    phoneNumber: true,
                    classTeachers: {
                        include: {
                            class: { select: { id: true, name: true } }
                        }
                    }
                },
                orderBy: { fullName: 'asc' }
            });

            res.json(teachers);
        } catch (error) {
            console.error('Get teachers error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    }
};

const avatarMethods = {
    // Upload avatar cho user
    async uploadAvatar(req, res) {
        try {
            const { id } = req.params;
            const userId = parseInt(id);

            // Check quyền: chỉ được upload avatar của mình hoặc admin
            if (req.user.id !== userId && req.user.role !== 'ban_dieu_hanh') {
                return res.status(403).json({ error: 'Không có quyền thực hiện' });
            }

            if (!req.file) {
                return res.status(400).json({ error: 'Vui lòng chọn file ảnh' });
            }

            // Lấy thông tin user hiện tại
            const currentUser = await prisma.user.findUnique({
                where: { id: userId },
                select: { avatarUrl: true, avatarPublicId: true }
            });

            if (!currentUser) {
                return res.status(404).json({ error: 'Người dùng không tồn tại' });
            }

            // Xóa avatar cũ nếu có
            if (currentUser.avatarUrl) {
                await deleteAvatar(currentUser.avatarUrl);
            }

            // Cập nhật avatar mới
            const updatedUser = await prisma.user.update({
                where: { id: userId },
                data: {
                    avatarUrl: req.file.path,
                    avatarPublicId: req.file.filename
                },
                select: {
                    id: true,
                    username: true,
                    fullName: true,
                    avatarUrl: true,
                    role: true
                }
            });

            res.json({
                message: 'Upload avatar thành công',
                user: updatedUser
            });

        } catch (error) {
            console.error('Upload user avatar error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Xóa avatar
    async deleteAvatar(req, res) {
        try {
            const { id } = req.params;
            const userId = parseInt(id);

            // Check quyền
            if (req.user.id !== userId && req.user.role !== 'ban_dieu_hanh') {
                return res.status(403).json({ error: 'Không có quyền thực hiện' });
            }

            const user = await prisma.user.findUnique({
                where: { id: userId },
                select: { avatarUrl: true, avatarPublicId: true }
            });

            if (!user) {
                return res.status(404).json({ error: 'Người dùng không tồn tại' });
            }

            if (!user.avatarUrl) {
                return res.status(400).json({ error: 'Người dùng chưa có avatar' });
            }

            // Xóa trên Cloudinary
            await deleteAvatar(user.avatarUrl);

            // Cập nhật database
            await prisma.user.update({
                where: { id: userId },
                data: {
                    avatarUrl: null,
                    avatarPublicId: null
                }
            });

            res.json({ message: 'Xóa avatar thành công' });

        } catch (error) {
            console.error('Delete user avatar error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    }
};

// Merge vào userController
Object.assign(userController, avatarMethods);

module.exports = userController;