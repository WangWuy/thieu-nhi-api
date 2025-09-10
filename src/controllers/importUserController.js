const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const multer = require('multer');
const XLSX = require('xlsx');
const ClassService = require('../services/classService');

const prisma = new PrismaClient();

// Simple multer config
const upload = multer({
    storage: multer.memoryStorage(),
    limits: { fileSize: 10 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const isExcel = file.mimetype.includes('spreadsheet') || file.mimetype.includes('excel');
        cb(null, isExcel);
    }
});

const importUserController = {
    uploadExcel: upload.single('file'),

    async importUsers(req, res) {
        try {
            if (!req.file) {
                return res.status(400).json({ error: 'Vui lòng chọn file Excel' });
            }

            // Parse Excel
            const workbook = XLSX.read(req.file.buffer, { 
                type: 'buffer', 
                cellDates: true 
            });
            const worksheet = workbook.Sheets[workbook.SheetNames[0]];
            const data = XLSX.utils.sheet_to_json(worksheet);

            if (data.length === 0) {
                return res.status(400).json({ error: 'File Excel trống' });
            }

            const results = { success: [], failed: [] };

            // Get all departments and classes
            const departments = await prisma.department.findMany({
                where: { isActive: true }
            });

            // Get all classes để có thể match theo tên
            const classes = await prisma.class.findMany({
                include: {
                    department: true
                }
            });

            // Default password
            const defaultPassword = '123456';
            const passwordHash = await bcrypt.hash(defaultPassword, 10);

            for (let i = 0; i < data.length; i++) {
                const row = data[i];
                try {
                    // Extract data từ format mới (không có MÃ GLV)
                    const saintName = row['Tên thánh'];
                    const lastName = row['Họ'] || row['Họ '] || row['HỌ '] || row['HỌ'] || '';
                    const firstName = row['Tên'] || '';
                    const fullName = `${lastName} ${firstName}`.trim();
                    const className = row['LỚP']; // Đọc tên lớp từ cột LỚP
                    
                    // Parse birth date  
                    let birthDate = row['Năm sinh'];
                    if (birthDate) {
                        if (typeof birthDate === 'number') {
                            // Kiểm tra nếu là Excel date number (như 32745)
                            if (birthDate > 1000 && birthDate < 100000) {
                                // Convert Excel date number to JS Date
                                birthDate = new Date((birthDate - 25569) * 86400 * 1000);
                            } else if (birthDate >= 1900 && birthDate <= 2030) {
                                // Nếu là năm sinh
                                birthDate = new Date(birthDate, 0, 1);
                            } else {
                                birthDate = null;
                            }
                        } else {
                            birthDate = new Date(birthDate);
                            if (isNaN(birthDate.getTime())) {
                                birthDate = null;
                            }
                        }
                    } else {
                        birthDate = null;
                    }

                    const notes = row['Ghi chú'];
                    const address = row['Địa chỉ'];
                    let phoneNumber = row['Điện thoại'] ? String(row['Điện thoại']) : null;

                    // Validate required fields
                    if (!fullName || !phoneNumber) {
                        throw new Error('Thiếu họ tên hoặc số điện thoại');
                    }

                    // Clean phone number and use as username
                    phoneNumber = phoneNumber.replace(/\D/g, '');
                    if (phoneNumber.length === 9 && !phoneNumber.startsWith('0')) {
                        phoneNumber = '0' + phoneNumber;
                    }
                    
                    if (phoneNumber.length < 10) {
                        throw new Error('Số điện thoại không hợp lệ');
                    }

                    // Check if username already exists
                    const existingUser = await prisma.user.findUnique({
                        where: { username: phoneNumber }
                    });

                    if (existingUser) {
                        throw new Error('Số điện thoại đã được sử dụng');
                    }

                    // Mặc định tất cả user import đều là giao_ly_vien
                    const role = 'giao_ly_vien';

                    // Tìm lớp theo tên
                    let assignedClass = null;
                    let classId = null;
                    
                    if (className) {
                        // Tìm kiếm lớp theo tên (không phân biệt hoa thường)
                        assignedClass = classes.find(cls => 
                            cls.name.toLowerCase().trim() === className.toLowerCase().trim()
                        );
                        
                        if (assignedClass) {
                            classId = assignedClass.id;
                        } else {
                            console.log(`Không tìm thấy lớp: "${className}" cho user ${fullName}`);
                            // Có thể tạo lớp mới hoặc để trống
                            // Tạm thời để trống, có thể log để admin biết
                        }
                    }

                    // Create user với departmentId
                    const userData = {
                        username: phoneNumber,
                        passwordHash,
                        role,
                        saintName,
                        fullName,
                        birthDate: birthDate,
                        phoneNumber,
                        address,
                        departmentId: departments[0]?.id || null
                    };

                    const user = await prisma.user.create({
                        data: userData,
                        include: { 
                            department: true
                        }
                    });

                    // Nếu có classId, gán teacher vào lớp đó
                    if (classId && (role === 'phan_doan_truong' || role === 'giao_ly_vien')) {
                        try {
                            await prisma.classTeacher.create({
                                data: {
                                    classId: classId,
                                    userId: user.id,
                                    isPrimary: role === 'phan_doan_truong' // Phân đoàn trưởng là primary teacher
                                }
                            });
                        } catch (classTeacherError) {
                            console.log(`Lỗi gán teacher vào lớp: ${classTeacherError.message}`);
                            // Không throw error, vẫn tạo được user
                        }
                    }

                    results.success.push({
                        row: i + 2,
                        fullName,
                        phone: phoneNumber,
                        role,
                        className: assignedClass?.name || 'Không gán lớp',
                        classFound: !!assignedClass
                    });

                } catch (error) {
                    results.failed.push({
                        row: i + 2,
                        fullName: `${row['Họ'] || ''} ${row['Tên'] || ''}`.trim() || 'N/A',
                        className: row['LỚP'] || 'N/A',
                        error: error.message
                    });
                }
            }

            // Thống kê
            const classAssignmentStats = {
                totalUsers: results.success.length + results.failed.length,
                usersWithClass: results.success.filter(u => u.classFound).length,
                usersWithoutClass: results.success.filter(u => !u.classFound).length,
                failedImports: results.failed.length
            };

            res.json({
                message: `Import hoàn thành: ${results.success.length} thành công, ${results.failed.length} thất bại`,
                defaultPassword: defaultPassword,
                classAssignmentStats,
                availableClasses: classes.map(c => c.name),
                results
            });

        } catch (error) {
            console.error('Import users error:', error);
            res.status(500).json({ error: 'Lỗi import: ' + error.message });
        }
    }
};

module.exports = importUserController;