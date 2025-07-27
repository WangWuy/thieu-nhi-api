const { PrismaClient } = require('@prisma/client');
const multer = require('multer');
const XLSX = require('xlsx');

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

const importController = {
    uploadExcel: upload.single('file'),

    async importStudents(req, res) {
        try {
            if (!req.file) {
                return res.status(400).json({ error: 'Vui lòng chọn file Excel' });
            }

            // Parse Excel
            const workbook = XLSX.read(req.file.buffer, { type: 'buffer' });
            const sheet = workbook.Sheets[workbook.SheetNames[0]];
            const data = XLSX.utils.sheet_to_json(sheet);

            if (data.length === 0) {
                return res.status(400).json({ error: 'File Excel trống' });
            }

            const results = { success: [], failed: [] };

            for (let i = 0; i < data.length; i++) {
                const row = data[i];
                try {
                    // Extract data từ Excel format của bạn - 2 cột riêng biệt
                    const studentCode = row['MÃ TN'] || row['Mã TN'];
                    const saintName = row['TÊN THÁNH'] || row['Tên thánh'];
                    
                    // 2 cột riêng biệt
                    const lastName = row['HỌ'] || row['Họ'] || '';
                    const firstName = row['TÊN'] || row['Tên'] || '';
                    const fullName = `${lastName} ${firstName}`.trim();
                    
                    // Xử lý ngày sinh đơn giản
                    let birthDate = row['NGÀY SINH'] || row['Ngày sinh'];
                    if (birthDate) {
                        if (typeof birthDate === 'number') {
                            birthDate = new Date((birthDate - 25569) * 86400 * 1000);
                        } else {
                            birthDate = new Date(birthDate);
                        }
                        if (isNaN(birthDate.getTime())) {
                            birthDate = null;
                        }
                    } else {
                        birthDate = null;
                    }
                    
                    const address = row['ĐỊA CHỈ'] || row['Địa chỉ'];
                    
                    // Convert phone numbers to string
                    const parentPhone1 = row['SĐT 1'] || row['SDT 1'] ? String(row['SĐT 1'] || row['SDT 1']) : null;
                    const parentPhone2 = row['SĐT 2'] || row['SDT 2'] ? String(row['SĐT 2'] || row['SDT 2']) : null;
                    
                    const className = row['LỚP MỚI'] || row['Lớp mới'] || row['LỚP CŨ'] || row['Lớp cũ'];

                    // Validate required fields
                    if (!studentCode || !fullName || !className) {
                        throw new Error('Thiếu mã TN, họ tên hoặc lớp');
                    }

                    // Find class
                    const classObj = await prisma.class.findFirst({
                        where: {
                            name: { contains: className, mode: 'insensitive' },
                            isActive: true
                        }
                    });

                    if (!classObj) {
                        throw new Error(`Không tìm thấy lớp: ${className}`);
                    }

                    // Check duplicate
                    const existing = await prisma.student.findUnique({
                        where: { studentCode }
                    });

                    if (existing) {
                        throw new Error('Mã TN đã tồn tại');
                    }

                    // Create student
                    const student = await prisma.student.create({
                        data: {
                            studentCode,
                            fullName,
                            saintName,
                            birthDate: birthDate ? new Date(birthDate) : null,
                            address,
                            parentPhone1,
                            parentPhone2,
                            classId: classObj.id,
                            // Bỏ qrCode vì không cần thiết
                            attendanceScore: 0,
                            studyScore: 0
                        },
                        include: { class: true }
                    });

                    results.success.push({
                        row: i + 2,
                        studentCode,
                        fullName,
                        className: student.class.name
                    });

                } catch (error) {
                    results.failed.push({
                        row: i + 2,
                        studentCode: row['MÃ TN'] || row['Mã TN'] || `Dòng ${i + 2}`,
                        error: error.message
                    });
                }
            }

            res.json({
                message: `Import hoàn thành: ${results.success.length} thành công, ${results.failed.length} thất bại`,
                results
            });

        } catch (error) {
            console.error('Import error:', error);
            res.status(500).json({ error: 'Lỗi import: ' + error.message });
        }
    }
};

module.exports = importController;