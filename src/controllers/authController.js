const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { prisma } = require('../../prisma/client');

const authController = {
    // 🔑 Đăng nhập (có xử lý lỗi rõ ràng)
    async login(req, res) {
        try {
            const { username, password } = req.body;

            // Tìm user không phân biệt hoa/thường
            const user = await prisma.user.findFirst({
                where: {
                    username: { equals: username, mode: 'insensitive' }
                },
                include: {
                    department: true,
                    classTeachers: {
                        include: {
                            class: {
                                include: {
                                    department: true,
                                    students: {
                                        where: { isActive: true },
                                        select: { id: true } // tạm lấy id để đếm, lát bỏ ra
                                    }
                                }
                            }
                        }
                    }
                }
            });

            // Kiểm tra user
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

            // So sánh mật khẩu
            const isValidPassword = await bcrypt.compare(password, user.passwordHash);
            if (!isValidPassword) {
                return res.status(401).json({
                    error: 'Invalid Credentials',
                    message: 'Tên đăng nhập hoặc mật khẩu không đúng'
                });
            }

            // Payload JWT
            const tokenPayload = {
                userId: user.id,
                username: user.username,
                role: user.role,
                departmentId: user.departmentId,
                fullName: user.fullName
            };

            if (!process.env.JWT_SECRET) {
                throw new Error('JWT_SECRET chưa được cấu hình trong môi trường');
            }

            // Tạo token
            const token = jwt.sign(tokenPayload, process.env.JWT_SECRET, {
                expiresIn: '24h',
                issuer: 'thieu-nhi-api',
                audience: 'thieu-nhi-app'
            });

            // ✅ Tính tổng thiếu nhi active cho từng lớp
            const userWithCounts = {
                ...user,
                classTeachers: user.classTeachers.map(ct => {
                    const classInfo = {
                        ...ct.class,
                        totalStudents: ct.class.students.length
                    };
                    return {
                        ...ct,
                        classInfo // 👈 key mới thay cho 'class'
                    };
                })
            };

            // ✅ Xóa trường students (vì chỉ cần tổng)
            userWithCounts.classTeachers.forEach(ct => {
                delete ct.class.students;
            });

            // Xóa mật khẩu hash
            const { passwordHash, ...userWithoutPassword } = userWithCounts;

            // Quyền
            const permissions = getUserPermissions(user.role);

            console.log(`✅ Login: ${user.username} (${user.role}) - IP: ${req.headers['x-forwarded-for'] || req.ip}`);

            // ✅ Trả về tất cả thông tin cần thiết
            res.json({
                success: true,
                message: 'Đăng nhập thành công',
                token,
                expiresIn: '24h',
                user: {
                    id: user.id,
                    username: user.username,
                    fullName: user.fullName,
                    role: user.role,
                    department: user.department,
                    classTeacher: userWithCounts.classTeachers.length > 0
                        ? {
                            id: userWithCounts.classTeachers[0].id,
                            isPrimary: userWithCounts.classTeachers[0].isPrimary,
                            classInfo: {
                                id: userWithCounts.classTeachers[0].classInfo.id,
                                name: userWithCounts.classTeachers[0].classInfo.name,
                                totalStudents: userWithCounts.classTeachers[0].classInfo.totalStudents,
                                department: userWithCounts.classTeachers[0].classInfo.department
                            }
                        }
                        : null,
                    permissions: getUserPermissions(user.role)
                }
            });

        } catch (error) {
            console.error('❌ Lỗi đăng nhập:', error);
            res.status(500).json({
                error: 'Internal Server Error',
                message: 'Lỗi server, vui lòng thử lại sau'
            });
        }
    },

    // 👤 Lấy thông tin user hiện tại (có tổng thiếu nhi theo lớp)
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
                                    students: {
                                        where: { isActive: true },
                                        select: { id: true } // chỉ lấy ID để nhẹ dữ liệu
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

            // Tính tổng thiếu nhi active cho từng lớp
            const userWithCounts = {
                ...user,
                classTeachers: user.classTeachers.map(ct => ({
                    ...ct,
                    class: {
                        ...ct.class,
                        totalStudents: ct.class.students.length
                    }
                }))
            };

            const { passwordHash, ...userWithoutPassword } = userWithCounts;
            const permissions = getUserPermissions(user.role);

            res.json({
                ...userWithoutPassword,
                permissions
            });

        } catch (error) {
            console.error('❌ Lỗi lấy thông tin người dùng:', error);
            res.status(500).json({
                error: 'Internal Server Error',
                message: 'Lỗi server, vui lòng thử lại sau'
            });
        }
    },

    // 🔒 Đổi mật khẩu
    async changePassword(req, res) {
        try {
            console.log('🔧 Change password request:', {
                userId: req.user.userId,
                hasCurrentPassword: !!req.body.currentPassword,
                hasNewPassword: !!req.body.newPassword
            });

            const { currentPassword, newPassword } = req.body;

            const user = await prisma.user.findUnique({
                where: { id: req.user.userId }
            });

            if (!user) {
                return res.status(404).json({
                    error: 'User Not Found',
                    message: 'Người dùng không tồn tại'
                });
            }

            // Xác minh mật khẩu hiện tại
            const isValidPassword = await bcrypt.compare(currentPassword, user.passwordHash);
            if (!isValidPassword) {
                return res.status(401).json({
                    error: 'Invalid Current Password',
                    message: 'Mật khẩu hiện tại không đúng'
                });
            }

            // Kiểm tra mật khẩu mới khác mật khẩu cũ
            const isSamePassword = await bcrypt.compare(newPassword, user.passwordHash);
            if (isSamePassword) {
                return res.status(400).json({
                    error: 'Same Password',
                    message: 'Mật khẩu mới phải khác mật khẩu hiện tại'
                });
            }

            // Hash mật khẩu mới
            const saltRounds = parseInt(process.env.BCRYPT_ROUNDS) || 12;
            const hashedNewPassword = await bcrypt.hash(newPassword, saltRounds);

            await prisma.user.update({
                where: { id: req.user.userId },
                data: {
                    passwordHash: hashedNewPassword,
                    updatedAt: new Date()
                }
            });

            console.log(`🔐 Password changed: ${user.username} - IP: ${req.headers['x-forwarded-for'] || req.ip}`);

            res.json({
                success: true,
                message: 'Đổi mật khẩu thành công'
            });

        } catch (error) {
            console.error('❌ Lỗi đổi mật khẩu:', error);
            res.status(500).json({
                error: 'Internal Server Error',
                message: 'Lỗi server, vui lòng thử lại sau'
            });
        }
    }
};

// 🎯 Phân quyền theo role
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
