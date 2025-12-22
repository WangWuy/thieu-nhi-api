const { prisma } = require('../../prisma/client');
const bcrypt = require('bcryptjs');

const pendingUserController = {
    // Đăng ký tài khoản từ mobile (tạo pending user)
    async registerUser(req, res) {
        try {
            const {
                username,
                email,
                password,
                role,
                saintName,
                fullName,
                birthDate,
                phoneNumber,
                address,
                departmentId
            } = req.body;

            // Validation cơ bản
            if (!username || !password || !role || !fullName) {
                return res.status(400).json({ 
                    error: 'Username, password, role và họ tên là bắt buộc' 
                });
            }

            if (password.length < 6) {
                return res.status(400).json({ 
                    error: 'Mật khẩu phải ít nhất 6 ký tự' 
                });
            }

            // Kiểm tra username đã tồn tại trong users hoặc pending_users
            const [existingUser, existingPendingUser] = await Promise.all([
                prisma.user.findUnique({ where: { username } }),
                prisma.pendingUser.findUnique({ where: { username } })
            ]);

            if (existingUser || existingPendingUser) {
                return res.status(400).json({ 
                    error: 'Tên đăng nhập đã được sử dụng' 
                });
            }

            // Kiểm tra email nếu có
            if (email) {
                const [existingEmailUser, existingEmailPending] = await Promise.all([
                    prisma.user.findUnique({ where: { email } }),
                    prisma.pendingUser.findUnique({ where: { email } })
                ]);

                if (existingEmailUser || existingEmailPending) {
                    return res.status(400).json({ 
                        error: 'Email đã được sử dụng' 
                    });
                }
            }

            // Hash password
            const passwordHash = await bcrypt.hash(password, 10);

            // Tạo pending user
            const pendingUser = await prisma.pendingUser.create({
                data: {
                    username,
                    email,
                    passwordHash,
                    role,
                    saintName,
                    fullName,
                    birthDate: birthDate ? new Date(birthDate) : null,
                    phoneNumber,
                    address,
                    departmentId: departmentId ? parseInt(departmentId) : null,
                    status: 'pending'
                },
                select: {
                    id: true,
                    username: true,
                    email: true,
                    role: true,
                    saintName: true,
                    fullName: true,
                    birthDate: true,
                    phoneNumber: true,
                    address: true,
                    departmentId: true,
                    status: true,
                    createdAt: true,
                    department: {
                        select: {
                            id: true,
                            name: true,
                            displayName: true
                        }
                    }
                }
            });

            res.status(201).json({
                message: 'Đăng ký thành công! Tài khoản của bạn đang chờ phê duyệt từ Ban Điều Hành.',
                data: pendingUser
            });
        } catch (error) {
            console.error('Register user error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Lấy danh sách pending users (chỉ admin)
    async getPendingUsers(req, res) {
        try {
            const { page = 1, limit = 20, status, search } = req.query;

            let whereClause = {};

            // Filter by status
            if (status && ['pending', 'approved', 'rejected'].includes(status)) {
                whereClause.status = status;
            }

            // Search filter
            if (search) {
                whereClause.OR = [
                    { fullName: { contains: search, mode: 'insensitive' } },
                    { username: { contains: search, mode: 'insensitive' } },
                    { email: { contains: search, mode: 'insensitive' } }
                ];
            }

            const skip = (page - 1) * limit;

            const [pendingUsers, total] = await Promise.all([
                prisma.pendingUser.findMany({
                    where: whereClause,
                    select: {
                        id: true,
                        username: true,
                        email: true,
                        role: true,
                        saintName: true,
                        fullName: true,
                        birthDate: true,
                        phoneNumber: true,
                        address: true,
                        departmentId: true,
                        status: true,
                        rejectionReason: true,
                        approvedBy: true,
                        approvedAt: true,
                        createdAt: true,
                        department: {
                            select: {
                                id: true,
                                name: true,
                                displayName: true
                            }
                        },
                        approver: {
                            select: {
                                id: true,
                                fullName: true,
                                username: true
                            }
                        }
                    },
                    skip,
                    take: parseInt(limit),
                    orderBy: { createdAt: 'desc' }
                }),
                prisma.pendingUser.count({ where: whereClause })
            ]);

            res.json({
                pendingUsers,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            });
        } catch (error) {
            console.error('Get pending users error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Lấy chi tiết pending user
    async getPendingUserById(req, res) {
        try {
            const { id } = req.params;

            const pendingUser = await prisma.pendingUser.findUnique({
                where: { id: parseInt(id) },
                select: {
                    id: true,
                    username: true,
                    email: true,
                    role: true,
                    saintName: true,
                    fullName: true,
                    birthDate: true,
                    phoneNumber: true,
                    address: true,
                    departmentId: true,
                    status: true,
                    rejectionReason: true,
                    approvedBy: true,
                    approvedAt: true,
                    createdAt: true,
                    department: {
                        select: {
                            id: true,
                            name: true,
                            displayName: true
                        }
                    },
                    approver: {
                        select: {
                            id: true,
                            fullName: true,
                            username: true
                        }
                    }
                }
            });

            if (!pendingUser) {
                return res.status(404).json({ error: 'Không tìm thấy đăng ký' });
            }

            res.json(pendingUser);
        } catch (error) {
            console.error('Get pending user error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Phê duyệt đăng ký (admin)
    async approveUser(req, res) {
        try {
            const { id } = req.params;
            const { departmentId } = req.body;
            const approverId = req.user.id;

            // Kiểm tra pending user tồn tại và đang pending
            const pendingUser = await prisma.pendingUser.findUnique({
                where: { id: parseInt(id) }
            });

            if (!pendingUser) {
                return res.status(404).json({ error: 'Không tìm thấy đăng ký' });
            }

            if (pendingUser.status !== 'pending') {
                return res.status(400).json({ 
                    error: 'Đăng ký đã được xử lý rồi' 
                });
            }

            // Kiểm tra username và email vẫn còn available
            const [existingUser, existingEmailUser] = await Promise.all([
                prisma.user.findUnique({ where: { username: pendingUser.username } }),
                pendingUser.email ? prisma.user.findUnique({ where: { email: pendingUser.email } }) : null
            ]);

            if (existingUser) {
                return res.status(400).json({ 
                    error: 'Username đã được sử dụng bởi user khác' 
                });
            }

            if (existingEmailUser) {
                return res.status(400).json({ 
                    error: 'Email đã được sử dụng bởi user khác' 
                });
            }

            // Tạo user mới
            const newUser = await prisma.user.create({
                data: {
                    username: pendingUser.username,
                    passwordHash: pendingUser.passwordHash,
                    role: pendingUser.role,
                    saintName: pendingUser.saintName,
                    fullName: pendingUser.fullName,
                    birthDate: pendingUser.birthDate,
                    phoneNumber: pendingUser.phoneNumber,
                    address: pendingUser.address,
                    departmentId: departmentId || pendingUser.departmentId,
                    isActive: true
                },
                select: {
                    id: true,
                    username: true,
                    email: true,
                    role: true,
                    saintName: true,
                    fullName: true,
                    birthDate: true,
                    phoneNumber: true,
                    address: true,
                    departmentId: true,
                    isActive: true,
                    createdAt: true,
                    department: {
                        select: {
                            id: true,
                            name: true,
                            displayName: true
                        }
                    }
                }
            });

            // Cập nhật pending user status
            await prisma.pendingUser.update({
                where: { id: parseInt(id) },
                data: {
                    status: 'approved',
                    approvedBy: approverId,
                    approvedAt: new Date()
                }
            });

            res.json({
                message: 'Phê duyệt đăng ký thành công',
                user: newUser
            });
        } catch (error) {
            console.error('Approve user error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Từ chối đăng ký (admin)
    async rejectUser(req, res) {
        try {
            const { id } = req.params;
            const { rejectionReason } = req.body;
            const approverId = req.user.id;

            // Kiểm tra pending user tồn tại và đang pending
            const pendingUser = await prisma.pendingUser.findUnique({
                where: { id: parseInt(id) }
            });

            if (!pendingUser) {
                return res.status(404).json({ error: 'Không tìm thấy đăng ký' });
            }

            if (pendingUser.status !== 'pending') {
                return res.status(400).json({ 
                    error: 'Đăng ký đã được xử lý rồi' 
                });
            }

            // Cập nhật pending user status
            await prisma.pendingUser.update({
                where: { id: parseInt(id) },
                data: {
                    status: 'rejected',
                    rejectionReason,
                    approvedBy: approverId,
                    approvedAt: new Date()
                }
            });

            res.json({
                message: 'Từ chối đăng ký thành công',
                rejectionReason
            });
        } catch (error) {
            console.error('Reject user error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Xóa pending user (admin)
    async deletePendingUser(req, res) {
        try {
            const { id } = req.params;

            const pendingUser = await prisma.pendingUser.findUnique({
                where: { id: parseInt(id) }
            });

            if (!pendingUser) {
                return res.status(404).json({ error: 'Không tìm thấy đăng ký' });
            }

            await prisma.pendingUser.delete({
                where: { id: parseInt(id) }
            });

            res.json({ message: 'Xóa đăng ký thành công' });
        } catch (error) {
            console.error('Delete pending user error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Thống kê pending users
    async getPendingUserStats(req, res) {
        try {
            const [total, pending, approved, rejected] = await Promise.all([
                prisma.pendingUser.count(),
                prisma.pendingUser.count({ where: { status: 'pending' } }),
                prisma.pendingUser.count({ where: { status: 'approved' } }),
                prisma.pendingUser.count({ where: { status: 'rejected' } })
            ]);

            res.json({
                total,
                pending,
                approved,
                rejected
            });
        } catch (error) {
            console.error('Get pending user stats error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    }
};

module.exports = pendingUserController;
