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
            
            // Data bắt đầu từ row 3 (headers) và row 4 (data)
            const data = XLSX.utils.sheet_to_json(worksheet, { 
                range: 'A3:U1005',
                blankrows: false 
            });

            if (data.length === 0) {
                return res.status(400).json({ error: 'File Excel trống' });
            }

            const results = { success: [], failed: [] };

            // Get all departments for mapping
            const departments = await prisma.department.findMany({
                where: { isActive: true }
            });

            const departmentMap = {};
            departments.forEach(dept => {
                departmentMap[dept.name.toUpperCase()] = dept.id;
            });

            // Default password
            const defaultPassword = '123456';
            const passwordHash = await bcrypt.hash(defaultPassword, 10);

            for (let i = 0; i < data.length; i++) {
                const row = data[i];
                try {
                    // Skip header row và empty rows
                    if (!row['Phân đoàn'] || row['Phân đoàn'] === 'Phân đoàn') {
                        continue;
                    }

                    // Extract data
                    const departmentName = row['Phân đoàn']?.trim().toUpperCase();
                    const lastName = row['Họ']?.trim() || '';
                    const firstName = row['Tên']?.trim() || '';
                    const fullName = `${lastName} ${firstName}`.trim();
                    const saintName = row['Tên thánh']?.trim();
                    const phoneNumber = row['Điện thoại'] ? String(row['Điện thoại']).trim() : null;
                    const address = row['Địa chỉ']?.trim();
                    const roleNote = row['Ghi chú']?.trim();
                    const className = row['LỚP']?.trim(); // Extract class name

                    // Parse birth date
                    let birthDate = row['Năm sinh'];
                    if (birthDate) {
                        if (typeof birthDate === 'number') {
                            birthDate = new Date((birthDate - 25569) * 86400 * 1000);
                        } else if (typeof birthDate === 'string') {
                            birthDate = new Date(birthDate);
                        }
                        if (isNaN(birthDate.getTime())) {
                            birthDate = null;
                        }
                    } else {
                        birthDate = null;
                    }

                    // Validate required fields
                    if (!fullName || !phoneNumber) {
                        throw new Error('Thiếu họ tên hoặc số điện thoại');
                    }

                    // Clean phone number and use as username
                    let username = phoneNumber ? String(phoneNumber).replace(/\D/g, '') : null; // Remove non-digits
                    
                    // Fix missing leading zero for Vietnamese phone numbers
                    if (username && username.length === 9 && !username.startsWith('0')) {
                        username = '0' + username; // Add leading zero
                    }
                    
                    if (!username || username.length < 10) {
                        throw new Error('Số điện thoại không hợp lệ');
                    }

                    // Map department
                    const departmentId = departmentMap[departmentName];
                    if (!departmentId) {
                        throw new Error(`Không tìm thấy phân đoàn: ${departmentName}`);
                    }

                    // Determine role
                    let role = 'giao_ly_vien'; // Default
                    if (roleNote) {
                        if (roleNote.includes('trưởng')) {
                            role = 'giao_ly_vien';
                        }
                        // Có thể thêm logic khác cho role khác
                    }

                    // Check if username (phone) already exists
                    const existingUser = await prisma.user.findUnique({
                        where: { username }
                    });

                    if (existingUser) {
                        throw new Error('Số điện thoại đã được sử dụng');
                    }

                    // Create user
                    const user = await prisma.user.create({
                        data: {
                            username,
                            passwordHash,
                            role,
                            saintName,
                            fullName,
                            birthDate: birthDate ? new Date(birthDate) : null,
                            phoneNumber: username,
                            address,
                            departmentId
                        },
                        include: { department: true }
                    });

                    // Assign to class if className is provided
                    let assignedClass = null;
                    if (className) {
                        const classId = await ClassService.getClassIdFromName(className);
                        if (classId) {
                            // Check if class already has a primary teacher
                            const existingPrimary = await prisma.classTeacher.findFirst({
                                where: { 
                                    classId,
                                    isPrimary: true 
                                }
                            });

                            await prisma.classTeacher.create({
                                data: {
                                    classId,
                                    userId: user.id,
                                    isPrimary: !existingPrimary // First teacher becomes primary
                                }
                            });
                            
                            // Get class info for response
                            assignedClass = await prisma.class.findUnique({
                                where: { id: classId },
                                select: { id: true, name: true }
                            });
                        }
                    }

                    results.success.push({
                        row: i + 4, // Adjust for Excel row number
                        username,
                        fullName,
                        departmentName,
                        role,
                        className: assignedClass?.name || 'Không có lớp'
                    });

                } catch (error) {
                    results.failed.push({
                        row: i + 4,
                        fullName: row['Họ'] && row['Tên'] ? `${row['Họ']} ${row['Tên']}` : `Dòng ${i + 4}`,
                        phone: row['Điện thoại'] || 'N/A',
                        className: row['LỚP'] || 'N/A',
                        error: error.message
                    });
                }
            }

            res.json({
                message: `Import hoàn thành: ${results.success.length} thành công, ${results.failed.length} thất bại`,
                defaultPassword: defaultPassword,
                results
            });

        } catch (error) {
            console.error('Import users error:', error);
            res.status(500).json({ error: 'Lỗi import: ' + error.message });
        }
    }
};

module.exports = importUserController;