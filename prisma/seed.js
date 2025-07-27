const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Seeding database...');

    // 1. Tạo 4 ngành
    const departments = await Promise.all([
        prisma.department.create({
            data: {
                name: 'CHIEN',
                displayName: 'Chiên',
                description: 'Ngành Chiên (6-8 tuổi)'
            }
        }),
        prisma.department.create({
            data: {
                name: 'AU',
                displayName: 'Ấu',
                description: 'Ngành Ấu (9-11 tuổi)'
            }
        }),
        prisma.department.create({
            data: {
                name: 'THIEU',
                displayName: 'Thiếu',
                description: 'Ngành Thiếu (12-14 tuổi)'
            }
        }),
        prisma.department.create({
            data: {
                name: 'NGHIA',
                displayName: 'Nghĩa',
                description: 'Ngành Nghĩa (15-17 tuổi)'
            }
        })
    ]);

    console.log('✅ Created departments:', departments.map(d => d.displayName));

    // 2. Tạo user Ban điều hành
    const adminUser = await prisma.user.create({
        data: {
            username: 'admin',
            passwordHash: await bcrypt.hash('admin123', 10),
            role: 'ban_dieu_hanh',
            saintName: 'Phêrô',
            fullName: 'Trần Thành Trung',
            phoneNumber: '0901234567',
            address: 'TP.HCM'
        }
    });

    console.log('✅ Created admin user:', adminUser.fullName);

    // 3. Tạo Phân đoàn trưởng cho từng ngành
    const phanDoanTruongs = await Promise.all(
        departments.map(async (dept, index) => {
            return prisma.user.create({
                data: {
                    username: `pdt_${dept.name.toLowerCase()}`,
                    passwordHash: await bcrypt.hash('123456', 10),
                    role: 'phan_doan_truong',
                    saintName: ['Maria', 'Giuse', 'Anna', 'Phao-lô'][index],
                    fullName: `Phân Đoàn Trưởng ${dept.displayName}`,
                    departmentId: dept.id,
                    phoneNumber: `090123456${index}`,
                    address: 'TP.HCM'
                }
            });
        })
    );

    console.log('✅ Created phân đoàn trưởng:', phanDoanTruongs.map(p => p.fullName));

    // 4. Tạo lớp cho từng ngành
    const classes = [];
    for (const dept of departments) {
        for (let i = 1; i <= 3; i++) {
            const classData = await prisma.class.create({
                data: {
                    name: `${dept.displayName} ${i}`,
                    departmentId: dept.id
                }
            });
            classes.push(classData);
        }
    }

    console.log('✅ Created classes:', classes.map(c => c.name));

    // 5. Tạo giáo lý viên cho từng lớp
    const teachers = await Promise.all(
        classes.map(async (cls, index) => {
            const teacher = await prisma.user.create({
                data: {
                    username: `glv_${cls.name.toLowerCase().replace(/\s/g, '_')}`,
                    passwordHash: await bcrypt.hash('123456', 10),
                    role: 'giao_ly_vien',
                    saintName: ['Teresa', 'Thêrêsa', 'Antôn', 'Phanxicô', 'Rosa', 'Lucia', 'Bernadette', 'Rita', 'Cecilia', 'Agnes', 'Monica', 'Clara'][index] || 'Maria',
                    fullName: `Giáo lý viên ${cls.name}`,
                    phoneNumber: `091234567${index.toString().padStart(2, '0')}`,
                    address: 'TP.HCM'
                }
            });

            // Gán giáo viên làm giáo viên chính của lớp
            await prisma.classTeacher.create({
                data: {
                    classId: cls.id,
                    userId: teacher.id,
                    isPrimary: true
                }
            });

            return teacher;
        })
    );

    console.log('✅ Created teachers:', teachers.map(t => t.fullName));

    // 6. Tạo học sinh mẫu
    let studentCount = 1;
    for (const cls of classes) {
        for (let i = 1; i <= 5; i++) {
            await prisma.student.create({
                data: {
                    studentCode: `TN${studentCount.toString().padStart(4, '0')}`,
                    qrCode: `QR${studentCount.toString().padStart(4, '0')}`,
                    saintName: ['Anna', 'Maria', 'Giuse', 'Phao-lô', 'Teresa'][i - 1],
                    fullName: `Học sinh ${studentCount} - ${cls.name}`,
                    birthDate: new Date(2010 + Math.floor(Math.random() * 8), Math.floor(Math.random() * 12), Math.floor(Math.random() * 28) + 1),
                    phoneNumber: `092345678${(studentCount % 10)}`,
                    parentPhone1: `093456789${(studentCount % 10)}`,
                    parentPhone2: `094567890${(studentCount % 10)}`,
                    address: `Địa chỉ học sinh ${studentCount}`,
                    classId: cls.id
                }
            });
            studentCount++;
        }
    }

    console.log(`✅ Created ${studentCount - 1} students`);

    console.log('🎉 Seed completed successfully!');
    console.log('\n📋 Login credentials:');
    console.log('Admin: admin / admin123');
    console.log('Phân đoàn trưởng: pdt_chien / 123456 (tương tự cho au, thieu, nghia)');
    console.log('Giáo lý viên: glv_chien_1 / 123456 (tương tự cho các lớp khác)');
}

main()
    .catch((e) => {
        console.error('❌ Seed failed:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });