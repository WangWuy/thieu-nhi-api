const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

const authController = {
    // Login vá»›i improved error handling
    async login(req, res) {
        try {
            const { username, password } = req.body;

            // TÃ¬m user vá»›i lowercase username Ä‘á»ƒ case-insensitive
            const user = await prisma.user.findFirst({
                where: {
                    username: {
                        equals: username,
                        mode: 'insensitive'
                    }
                },
                include: {
                    department: true,
                    classTeachers: {
                        include: {
                            class: {
                                include: {
                                    department: true
                                }
                            }
                        }
                    }
                }
            });

            // Check user existence vÃ  active status
            if (!user) {
                return res.status(401).json({
                    error: 'Invalid Credentials',
                    message: 'Tên đăng nhập hoặc mật khẩu không đúng'
                });
            }

            if (!user.isActive) {
                return res.status(403).json({
                    error: 'Account Disabled',
                    message: 'Tài khoản đã bị khóa. Vui lòng liên hệ quản trị viên.'
                });
            }

            // Verify password
            const isValidPassword = await bcrypt.compare(password, user.passwordHash);
            if (!isValidPassword) {
                return res.status(401).json({
                    error: 'Invalid Credentials',
                    message: 'Tên đăng nhập hoặc mật khẩu không đúng'
                });
            }

            // Create JWT payload
            const tokenPayload = {
                userId: user.id,
                username: user.username,
                role: user.role,
                departmentId: user.departmentId,
                fullName: user.fullName
            };

            // Generate JWT token
            const token = jwt.sign(
                tokenPayload,
                process.env.JWT_SECRET,
                {
                    expiresIn: '24h',
                    issuer: 'thieu-nhi-api',
                    audience: 'thieu-nhi-app'
                }
            );

            // Remove sensitive data
            const { passwordHash, ...userWithoutPassword } = user;

            // Log successful login
            console.log(`Login successful: ${user.username} (${user.role}) from IP: ${req.ip}`);

            res.json({
                success: true,
                message: 'Đăng nhập thành công',
                token,
                user: userWithoutPassword,
                expiresIn: '24h'
            });

        } catch (error) {
            console.error('Get user info error:', error);
            res.status(500).json({
                error: 'Internal Server Error',
                message: 'Lỗi server, vui lòng thử lại sau'
            });
        }
    },

    // Get current user info vá»›i caching
    async me(req, res) {
        try {
            const user = await prisma.user.findUnique({
                where: { id: req.user.userId },
                include: {
                    department: true,
                    classTeachers: {
                        include: {
                            class: {
                                include: {
                                    department: true,
                                    _count: {
                                        select: {
                                            students: { where: { isActive: true } }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            });

            if (!user) {
                return res.status(404).json({
                    error: 'User Not Found',
                    message: 'Người dùng không tồn tại'
                });
            }

            if (!user.isActive) {
                return res.status(403).json({
                    error: 'Account Disabled',
                    message: 'Tài khoản đã bị khóa'
                });
            }

            const { passwordHash, ...userWithoutPassword } = user;

            // Fix: Gá»i function thay vÃ¬ this.getUserPermissions
            const permissions = getUserPermissions(user.role);

            res.json({
                ...userWithoutPassword,
                permissions
            });

        } catch (error) {
            console.error('Get user info error:', error);
            res.status(500).json({
                error: 'Internal Server Error',
                message: 'Lỗi server, vui lòng thử lại sau'
            });
        }
    },

    // Change password vá»›i security improvements
    async changePassword(req, res) {
        try {
            console.log('Change password request:', {
                userId: req.user.userId,
                hasCurrentPassword: !!req.body.currentPassword,
                hasNewPassword: !!req.body.newPassword
            });
            const { currentPassword, newPassword } = req.body;

            // Get current user
            const user = await prisma.user.findUnique({
                where: { id: req.user.userId }
            });

            if (!user) {
                return res.status(404).json({
                    error: 'User Not Found',
                    message: 'Người dùng không tồn tại'
                });
            }

            // Verify current password
            const isValidPassword = await bcrypt.compare(currentPassword, user.passwordHash);
            if (!isValidPassword) {
                return res.status(401).json({
                    error: 'Invalid Current Password',
                    message: 'Mật khẩu hiện tại không đúng'
                });
            }

            // Check if new password is different from current
            const isSamePassword = await bcrypt.compare(newPassword, user.passwordHash);
            if (isSamePassword) {
                return res.status(400).json({
                    error: 'Same Password',
                    message: 'Mật khẩu mới phải khác mật khẩu hiện tại'
                });
            }

            // Hash new password vá»›i higher rounds cho security
            const saltRounds = parseInt(process.env.BCRYPT_ROUNDS) || 12;
            const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

            // Update password
            await prisma.user.update({
                where: { id: req.user.userId },
                data: {
                    passwordHash: hashedNewPassword,
                    updatedAt: new Date()
                }
            });

            // Log password change
            console.log(`Password changed for user: ${user.username} from IP: ${req.ip}`);

            res.json({
                success: true,
                message: 'Đổi mật khẩu thành công'
            });

        } catch (error) {
            console.error('Change password error:', error);
            res.status(500).json({
                error: 'Internal Server Error',
                message: 'Lỗi server, vui lòng thử lại sau'
            });
        }
    },
};

const getUserPermissions = (role) => {
    const permissions = {
        ban_dieu_hanh: [
            'read:all',
            'write:all',
            'delete:all',
            'manage:users',
            'manage:departments',
            'manage:classes',
            'manage:students',
            'manage:attendance',
            'view:stats'
        ],
        phan_doan_truong: [
            'read:department',
            'write:department',
            'manage:classes',
            'manage:students',
            'manage:attendance',
            'view:department_stats'
        ],
        giao_ly_vien: [
            'read:class',
            'write:class',
            'manage:students',
            'manage:attendance'
        ]
    };

    return permissions[role] || [];
};

module.exports = authController;