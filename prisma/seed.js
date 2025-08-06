const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Creating departments, admin user, and classes...');

    // Tạo departments trước
    const departments = [
        {
            name: 'CHIEN',
            displayName: 'Chiên Con',
            description: 'Nhóm Chiên Con (6-8 tuổi)'
        },
        {
            name: 'AU',
            displayName: 'Ấu Nhi',
            description: 'Nhóm Ấu Nhi (9-11 tuổi)'
        },
        {
            name: 'THIEU',
            displayName: 'Thiếu Nhi',
            description: 'Nhóm Thiếu Nhi (12-14 tuổi)'
        },
        {
            name: 'NGHIA',
            displayName: 'Nghĩa Sĩ',
            description: 'Nhóm Nghĩa Sĩ (15-17 tuổi)'
        }
    ];

    console.log('📂 Creating departments...');
    
    const createdDepartments = {};
    for (const dept of departments) {
        const department = await prisma.department.upsert({
            where: { name: dept.name },
            update: {
                displayName: dept.displayName,
                description: dept.description
            },
            create: dept
        });
        
        createdDepartments[dept.name] = department;
        console.log(`✅ Department created: ${department.displayName}`);
    }

    // Tạo admin user
    console.log('👤 Creating admin user...');
    const adminPassword = await bcrypt.hash('admin123', 12);

    const admin = await prisma.user.upsert({
        where: { username: 'admin' },
        update: {},
        create: {
            username: 'admin',
            passwordHash: adminPassword,
            role: 'ban_dieu_hanh',
            saintName: 'Giuse',
            fullName: 'Administrator',
            isActive: true
        }
    });

    console.log('✅ Admin user created:', {
        id: admin.id,
        username: admin.username,
        role: admin.role,
        fullName: admin.fullName
    });

    // Tạo classes theo từng ngành
    console.log('🏫 Creating classes...');

    const classData = {
        CHIEN: [
            'Khai Tâm A',
            'Khai Tâm B', 
            'Khai Tâm C',
            'Khai Tâm D'
        ],
        AU: [
            'Ấu 1A', 'Ấu 1B', 'Ấu 1C', 'Ấu 1D', 'Ấu 1E',
            'Ấu 2A', 'Ấu 2B', 'Ấu 2C', 'Ấu 2D', 'Ấu 2E',
            'Ấu 3A', 'Ấu 3B', 'Ấu 3C', 'Ấu 3D', 'Ấu 3E'
        ],
        THIEU: [
            'Thiếu 1A', 'Thiếu 1B', 'Thiếu 1C', 'Thiếu 1D', 'Thiếu 1E',
            'Thiếu 2A', 'Thiếu 2B', 'Thiếu 2C', 'Thiếu 2D', 'Thiếu 2E',
            'Thiếu 3A', 'Thiếu 3B', 'Thiếu 3C', 'Thiếu 3D', 'Thiếu 3E'
        ],
        NGHIA: [
            'Nghĩa 1A', 'Nghĩa 1B', 'Nghĩa 1C', 'Nghĩa 1D',
            'Nghĩa 2A', 'Nghĩa 2B', 'Nghĩa 2C', 'Nghĩa 2D',
            'Nghĩa 3A', 'Nghĩa 3B', 'Nghĩa 3C', 'Nghĩa 3D',
            'Hiệp sĩ 1',
            'Hiệp sĩ 2'
        ]
    };

    let totalClasses = 0;
    for (const [deptName, classes] of Object.entries(classData)) {
        const department = createdDepartments[deptName];
        
        console.log(`\n📚 Creating classes for ${department.displayName}:`);
        
        for (const className of classes) {
            // Check if class already exists
            const existingClass = await prisma.class.findFirst({
                where: {
                    name: className,
                    departmentId: department.id
                }
            });

            if (!existingClass) {
                const classObj = await prisma.class.create({
                    data: {
                        name: className,
                        departmentId: department.id
                    }
                });
                console.log(`  ✅ ${className}`);
            } else {
                console.log(`  📌 ${className} (already exists)`);
            }
            
            totalClasses++;
        }
    }

    console.log('\n🎉 Seed completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`- Departments: ${Object.keys(departments).length}`);
    console.log(`- Classes: ${totalClasses}`);
    console.log(`- Admin user: 1`);
    
    console.log('\n📝 Login credentials:');
    console.log('Username: admin');
    console.log('Password: admin123');

    console.log('\n📂 Classes by Department:');
    for (const [deptName, classes] of Object.entries(classData)) {
        console.log(`\n${createdDepartments[deptName].displayName}: ${classes.length} classes`);
        classes.forEach((className, index) => {
            console.log(`  ${index + 1}. ${className}`);
        });
    }
}

main()
    .catch((e) => {
        console.error('❌ Seed error:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });