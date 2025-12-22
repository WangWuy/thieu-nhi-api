const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Starting HR System Seed...\n');

    // ==================== 1. ADMIN USER ====================
    console.log('👤 Creating Admin User...');
    const adminPassword = await bcrypt.hash('admin123', 12);

    const admin = await prisma.user.upsert({
        where: { username: 'admin' },
        update: {},
        create: {
            username: 'admin',
            passwordHash: adminPassword,
            role: 'admin',
            isActive: true
        }
    });
    console.log('✅ Admin created: admin / admin123\n');

    // ==================== 2. DEPARTMENTS ====================
    console.log('📂 Creating Departments...');

    const departments = [
        // Root departments
        { code: 'HR', name: 'Phòng Nhân Sự', description: 'Quản lý nguồn nhân lực', parentCode: null },
        { code: 'IT', name: 'Phòng Công Nghệ Thông Tin', description: 'Quản lý hệ thống IT', parentCode: null },
        { code: 'FIN', name: 'Phòng Tài Chính Kế Toán', description: 'Quản lý tài chính', parentCode: null },
        { code: 'OPS', name: 'Phòng Vận Hành', description: 'Quản lý vận hành', parentCode: null },
        { code: 'MKT', name: 'Phòng Marketing', description: 'Marketing và truyền thông', parentCode: null },

        // Sub-departments
        { code: 'IT-DEV', name: 'Bộ phận Phát Triển Phần Mềm', description: 'Development team', parentCode: 'IT' },
        { code: 'IT-INF', name: 'Bộ phận Hạ Tầng', description: 'Infrastructure team', parentCode: 'IT' },
        { code: 'HR-REC', name: 'Bộ phận Tuyển Dụng', description: 'Recruitment team', parentCode: 'HR' },
        { code: 'MKT-DIG', name: 'Bộ phận Marketing Số', description: 'Digital marketing', parentCode: 'MKT' },
    ];

    const createdDepartments = {};

    // Create parent departments first
    for (const dept of departments.filter(d => !d.parentCode)) {
        const department = await prisma.department.upsert({
            where: { code: dept.code },
            update: { name: dept.name, description: dept.description },
            create: {
                code: dept.code,
                name: dept.name,
                description: dept.description
            }
        });
        createdDepartments[dept.code] = department;
        console.log(`  ✅ ${dept.name} (${dept.code})`);
    }

    // Create sub-departments
    for (const dept of departments.filter(d => d.parentCode)) {
        const parentDept = createdDepartments[dept.parentCode];
        const department = await prisma.department.upsert({
            where: { code: dept.code },
            update: {
                name: dept.name,
                description: dept.description,
                parentId: parentDept.id
            },
            create: {
                code: dept.code,
                name: dept.name,
                description: dept.description,
                parentId: parentDept.id
            }
        });
        createdDepartments[dept.code] = department;
        console.log(`  ✅ ${dept.name} (${dept.code})`);
    }
    console.log('');

    // ==================== 3. SHIFTS ====================
    console.log('⏰ Creating Shifts...');

    const shifts = [
        {
            code: 'MORNING',
            name: 'Ca Sáng',
            startTime: '08:00',
            endTime: '17:00',
            breakDuration: 60,
            workingDays: [1, 2, 3, 4, 5], // Monday to Friday
            lateGracePeriod: 15,
            earlyLeaveGracePeriod: 15
        },
        {
            code: 'AFTERNOON',
            name: 'Ca Chiều',
            startTime: '13:00',
            endTime: '22:00',
            breakDuration: 60,
            workingDays: [1, 2, 3, 4, 5],
            lateGracePeriod: 10,
            earlyLeaveGracePeriod: 10
        },
        {
            code: 'NIGHT',
            name: 'Ca Đêm',
            startTime: '22:00',
            endTime: '06:00',
            breakDuration: 60,
            workingDays: [0, 1, 2, 3, 4, 5, 6], // All week
            lateGracePeriod: 20,
            earlyLeaveGracePeriod: 20
        },
        {
            code: 'FLEX',
            name: 'Ca Linh Hoạt',
            startTime: '09:00',
            endTime: '18:00',
            breakDuration: 60,
            workingDays: [1, 2, 3, 4, 5],
            lateGracePeriod: 30,
            earlyLeaveGracePeriod: 30
        }
    ];

    const createdShifts = {};
    for (const shift of shifts) {
        const created = await prisma.shift.upsert({
            where: { code: shift.code },
            update: shift,
            create: shift
        });
        createdShifts[shift.code] = created;
        console.log(`  ✅ ${shift.name} (${shift.startTime} - ${shift.endTime})`);
    }
    console.log('');

    // ==================== 4. HR MANAGERS ====================
    console.log('👔 Creating HR Managers...');

    const hrManagers = [
        {
            username: 'hr.manager',
            password: 'hrmanager123',
            role: 'hr_manager',
            employee: {
                employeeCode: 'EMP001',
                firstName: 'Minh',
                lastName: 'Nguyễn Văn',
                fullName: 'Nguyễn Văn Minh',
                email: 'minh.nguyen@company.com',
                phoneNumber: '0901234567',
                birthDate: new Date('1985-03-15'),
                gender: 'male',
                position: 'HR Manager',
                departmentCode: 'HR',
                hireDate: new Date('2020-01-01'),
                contractType: 'full_time'
            }
        },
        {
            username: 'hr.recruit',
            password: 'recruit123',
            role: 'hr_manager',
            employee: {
                employeeCode: 'EMP002',
                firstName: 'Lan',
                lastName: 'Trần Thị',
                fullName: 'Trần Thị Lan',
                email: 'lan.tran@company.com',
                phoneNumber: '0901234568',
                birthDate: new Date('1990-07-20'),
                gender: 'female',
                position: 'Recruitment Specialist',
                departmentCode: 'HR-REC',
                hireDate: new Date('2021-03-15'),
                contractType: 'full_time'
            }
        }
    ];

    const createdHRManagers = [];
    for (const hr of hrManagers) {
        const passwordHash = await bcrypt.hash(hr.password, 12);
        const dept = createdDepartments[hr.employee.departmentCode];

        const employee = await prisma.employee.create({
            data: {
                employeeCode: hr.employee.employeeCode,
                firstName: hr.employee.firstName,
                lastName: hr.employee.lastName,
                fullName: hr.employee.fullName,
                email: hr.employee.email,
                phoneNumber: hr.employee.phoneNumber,
                birthDate: hr.employee.birthDate,
                gender: hr.employee.gender,
                position: hr.employee.position,
                departmentId: dept.id,
                hireDate: hr.employee.hireDate,
                contractType: hr.employee.contractType,
                employmentStatus: 'active'
            }
        });

        await prisma.user.create({
            data: {
                username: hr.username,
                passwordHash: passwordHash,
                role: hr.role,
                employeeId: employee.id,
                isActive: true
            }
        });

        createdHRManagers.push(employee);
        console.log(`  ✅ ${hr.employee.fullName} - ${hr.username} / ${hr.password}`);
    }
    console.log('');

    // ==================== 5. DEPARTMENT MANAGERS ====================
    console.log('👨‍💼 Creating Department Managers...');

    const deptManagers = [
        {
            username: 'it.manager',
            password: 'itmanager123',
            role: 'department_manager',
            employee: {
                employeeCode: 'EMP003',
                firstName: 'Hùng',
                lastName: 'Lê Quốc',
                fullName: 'Lê Quốc Hùng',
                email: 'hung.le@company.com',
                phoneNumber: '0901234569',
                birthDate: new Date('1983-11-05'),
                gender: 'male',
                position: 'IT Director',
                departmentCode: 'IT',
                hireDate: new Date('2019-06-01'),
                contractType: 'full_time'
            }
        },
        {
            username: 'fin.manager',
            password: 'finmanager123',
            role: 'department_manager',
            employee: {
                employeeCode: 'EMP004',
                firstName: 'Hương',
                lastName: 'Phạm Thị',
                fullName: 'Phạm Thị Hương',
                email: 'huong.pham@company.com',
                phoneNumber: '0901234570',
                birthDate: new Date('1987-09-12'),
                gender: 'female',
                position: 'Finance Manager',
                departmentCode: 'FIN',
                hireDate: new Date('2020-08-01'),
                contractType: 'full_time'
            }
        }
    ];

    const createdDeptManagers = [];
    for (const dm of deptManagers) {
        const passwordHash = await bcrypt.hash(dm.password, 12);
        const dept = createdDepartments[dm.employee.departmentCode];

        const employee = await prisma.employee.create({
            data: {
                employeeCode: dm.employee.employeeCode,
                firstName: dm.employee.firstName,
                lastName: dm.employee.lastName,
                fullName: dm.employee.fullName,
                email: dm.employee.email,
                phoneNumber: dm.employee.phoneNumber,
                birthDate: dm.employee.birthDate,
                gender: dm.employee.gender,
                position: dm.employee.position,
                departmentId: dept.id,
                hireDate: dm.employee.hireDate,
                contractType: dm.employee.contractType,
                employmentStatus: 'active'
            }
        });

        await prisma.user.create({
            data: {
                username: dm.username,
                passwordHash: passwordHash,
                role: dm.role,
                employeeId: employee.id,
                isActive: true
            }
        });

        // Set as department manager
        await prisma.department.update({
            where: { id: dept.id },
            data: { managerId: employee.id }
        });

        createdDeptManagers.push(employee);
        console.log(`  ✅ ${dm.employee.fullName} - ${dm.username} / ${dm.password}`);
    }
    console.log('');

    // ==================== 6. EMPLOYEES ====================
    console.log('👥 Creating Employees...');

    const firstNames = ['An', 'Bình', 'Châu', 'Dũng', 'Em', 'Giang', 'Hải', 'Khánh', 'Linh', 'Mai', 'Nam', 'Oanh', 'Phong', 'Quân', 'Sơn', 'Tú', 'Uyên', 'Vân', 'Xuân', 'Yến'];
    const lastNames = ['Nguyễn Văn', 'Trần Thị', 'Lê Minh', 'Phạm Hữu', 'Hoàng Thị', 'Vũ Đức', 'Đặng Thị', 'Bùi Văn', 'Đỗ Thị', 'Ngô Quốc'];
    const positions = {
        'IT': ['Senior Developer', 'Junior Developer', 'DevOps Engineer', 'QA Engineer', 'Tech Lead'],
        'IT-DEV': ['Backend Developer', 'Frontend Developer', 'Fullstack Developer', 'Mobile Developer'],
        'IT-INF': ['System Administrator', 'Network Engineer', 'Database Administrator'],
        'FIN': ['Accountant', 'Financial Analyst', 'Auditor', 'Chief Accountant'],
        'OPS': ['Operations Manager', 'Operations Specialist', 'Project Coordinator'],
        'MKT': ['Marketing Executive', 'Content Creator', 'SEO Specialist', 'Brand Manager'],
        'MKT-DIG': ['Digital Marketing Manager', 'Social Media Specialist', 'Performance Marketing']
    };

    const allDeptCodes = Object.keys(positions);
    const createdEmployees = [];
    let employeeCount = 5; // Start from EMP005

    for (let i = 0; i < 80; i++) {
        const firstName = firstNames[Math.floor(Math.random() * firstNames.length)];
        const lastName = lastNames[Math.floor(Math.random() * lastNames.length)];
        const fullName = `${lastName} ${firstName}`;
        const deptCode = allDeptCodes[Math.floor(Math.random() * allDeptCodes.length)];
        const dept = createdDepartments[deptCode];
        const positionOptions = positions[deptCode];
        const position = positionOptions[Math.floor(Math.random() * positionOptions.length)];
        const gender = Math.random() > 0.5 ? 'male' : 'female';
        const contractTypes = ['full_time', 'full_time', 'full_time', 'part_time', 'contract'];
        const contractType = contractTypes[Math.floor(Math.random() * contractTypes.length)];

        // Random hire date within last 3 years
        const hireDateOffset = Math.floor(Math.random() * 1095); // 3 years in days
        const hireDate = new Date();
        hireDate.setDate(hireDate.getDate() - hireDateOffset);

        // Birth date: 22-50 years old
        const age = 22 + Math.floor(Math.random() * 28);
        const birthDate = new Date();
        birthDate.setFullYear(birthDate.getFullYear() - age);

        const employeeCode = `EMP${String(employeeCount).padStart(3, '0')}`;
        const email = `${firstName.toLowerCase()}.${lastName.split(' ')[1].toLowerCase()}${employeeCount}@company.com`;
        const phone = `090${String(1000000 + employeeCount).slice(-7)}`;

        const employee = await prisma.employee.create({
            data: {
                employeeCode,
                firstName,
                lastName,
                fullName,
                email,
                phoneNumber: phone,
                birthDate,
                gender,
                position,
                departmentId: dept.id,
                hireDate,
                contractType,
                employmentStatus: 'active',
                managerId: deptCode === 'IT' ? createdDeptManagers[0].id :
                          deptCode === 'FIN' ? createdDeptManagers[1].id : null
            }
        });

        createdEmployees.push(employee);
        employeeCount++;

        if ((i + 1) % 20 === 0) {
            console.log(`  ✅ Created ${i + 1} employees...`);
        }
    }
    console.log(`  ✅ Total employees created: ${createdEmployees.length}\n`);

    // ==================== 7. EMPLOYEE USERS ====================
    console.log('🔐 Creating Employee User Accounts (sample)...');

    const sampleEmployeeUsers = createdEmployees.slice(0, 10); // Create users for first 10 employees
    for (const emp of sampleEmployeeUsers) {
        const username = `emp${emp.employeeCode.slice(-3)}`;
        const password = 'employee123';
        const passwordHash = await bcrypt.hash(password, 12);

        await prisma.user.create({
            data: {
                username,
                passwordHash,
                role: 'employee',
                employeeId: emp.id,
                isActive: true
            }
        });
        console.log(`  ✅ ${emp.fullName} - ${username} / ${password}`);
    }
    console.log('');

    // ==================== 8. ASSIGN SHIFTS ====================
    console.log('📅 Assigning Shifts to Employees...');

    const morningShift = createdShifts['MORNING'];
    const afternoonShift = createdShifts['AFTERNOON'];
    const flexShift = createdShifts['FLEX'];

    // Assign shifts: 70% morning, 20% afternoon, 10% flex
    let assignCount = 0;
    for (const emp of createdEmployees) {
        const rand = Math.random();
        let shift;
        if (rand < 0.7) shift = morningShift;
        else if (rand < 0.9) shift = afternoonShift;
        else shift = flexShift;

        const effectiveFrom = emp.hireDate;

        await prisma.employeeShift.create({
            data: {
                employeeId: emp.id,
                shiftId: shift.id,
                effectiveFrom,
                isActive: true
            }
        });
        assignCount++;
    }
    console.log(`  ✅ Assigned shifts to ${assignCount} employees\n`);

    // ==================== 9. DEVICES ====================
    console.log('📱 Creating Devices...');

    const devices = [
        {
            deviceCode: 'DEV001',
            deviceName: 'Face Recognition Camera - Main Entrance',
            deviceType: 'face_recognition',
            location: 'Cổng chính tầng 1',
            ipAddress: '192.168.1.101',
            specs: {
                model: 'FaceID Pro 3000',
                resolution: '1920x1080',
                fps: 30,
                nightVision: true
            }
        },
        {
            deviceCode: 'DEV002',
            deviceName: 'Face Recognition Camera - Office Floor 2',
            deviceType: 'face_recognition',
            location: 'Văn phòng tầng 2',
            ipAddress: '192.168.1.102',
            specs: {
                model: 'FaceID Pro 3000',
                resolution: '1920x1080',
                fps: 30
            }
        },
        {
            deviceCode: 'DEV003',
            deviceName: 'Fingerprint Scanner - HR Department',
            deviceType: 'fingerprint',
            location: 'Phòng Nhân Sự',
            ipAddress: '192.168.1.103'
        },
        {
            deviceCode: 'DEV004',
            deviceName: 'Mobile App',
            deviceType: 'mobile_app',
            location: 'Cloud-based',
            specs: {
                platform: 'iOS/Android',
                version: '1.0.0'
            }
        }
    ];

    const createdDevices = [];
    for (const device of devices) {
        const created = await prisma.device.create({
            data: device
        });
        createdDevices.push(created);
        console.log(`  ✅ ${device.deviceName} (${device.deviceCode})`);
    }
    console.log('');

    // ==================== 10. ATTENDANCE RECORDS (Last 30 days) ====================
    console.log('📊 Creating Attendance Records (last 30 days)...');

    const today = new Date();
    const attendanceCount = { total: 0, present: 0, late: 0, absent: 0 };

    // Create attendance for last 30 days
    for (let dayOffset = 29; dayOffset >= 0; dayOffset--) {
        const date = new Date(today);
        date.setDate(date.getDate() - dayOffset);
        date.setHours(0, 0, 0, 0);

        const dayOfWeek = date.getDay();

        // Skip weekends for most employees
        if (dayOfWeek === 0 || dayOfWeek === 6) continue;

        for (const emp of createdEmployees) {
            // 90% attendance rate
            if (Math.random() > 0.9) {
                // Absent
                await prisma.attendance.create({
                    data: {
                        employeeId: emp.id,
                        date,
                        status: 'absent'
                    }
                });
                attendanceCount.absent++;
            } else {
                // Present
                const empShift = await prisma.employeeShift.findFirst({
                    where: {
                        employeeId: emp.id,
                        isActive: true,
                        effectiveFrom: { lte: date }
                    },
                    include: { shift: true }
                });

                if (!empShift) continue;

                const shift = empShift.shift;
                const [startHour, startMinute] = shift.startTime.split(':').map(Number);

                // Check-in time: 80% on time, 20% late (5-30 mins)
                const isLate = Math.random() < 0.2;
                const lateMinutes = isLate ? Math.floor(Math.random() * 30) + 5 : 0;

                const checkInTime = new Date(date);
                checkInTime.setHours(startHour, startMinute + lateMinutes, 0, 0);

                // Check-out time: 8-9 hours later
                const workHours = 8 + Math.random();
                const checkOutTime = new Date(checkInTime);
                checkOutTime.setHours(checkOutTime.getHours() + workHours);

                const actualWorkHours = (checkOutTime - checkInTime) / (1000 * 60 * 60) - (shift.breakDuration / 60);
                const standardHours = 8;
                const overtimeHours = Math.max(0, actualWorkHours - standardHours);

                await prisma.attendance.create({
                    data: {
                        employeeId: emp.id,
                        date,
                        shiftId: shift.id,
                        checkInTime,
                        checkOutTime,
                        status: isLate ? 'late' : 'present',
                        isLate,
                        workingHours: actualWorkHours.toFixed(2),
                        overtimeHours: overtimeHours > 0 ? overtimeHours.toFixed(2) : null,
                        checkInMethod: 'face_recognition',
                        checkOutMethod: 'face_recognition',
                        checkInConfidence: (85 + Math.random() * 10).toFixed(2),
                        checkOutConfidence: (85 + Math.random() * 10).toFixed(2),
                        deviceId: createdDevices[Math.floor(Math.random() * 2)].id
                    }
                });

                attendanceCount.total++;
                if (isLate) attendanceCount.late++;
                else attendanceCount.present++;
            }
        }
    }
    console.log(`  ✅ Created ${attendanceCount.total} attendance records`);
    console.log(`     - Present: ${attendanceCount.present}`);
    console.log(`     - Late: ${attendanceCount.late}`);
    console.log(`     - Absent: ${attendanceCount.absent}\n`);

    // ==================== 11. LEAVE REQUESTS ====================
    console.log('📝 Creating Leave Requests...');

    const leaveTypes = ['annual', 'sick', 'personal', 'unpaid'];
    const leaveStatuses = ['approved', 'pending', 'rejected'];
    let leaveCount = 0;

    // Create 50 random leave requests
    for (let i = 0; i < 50; i++) {
        const emp = createdEmployees[Math.floor(Math.random() * createdEmployees.length)];
        const leaveType = leaveTypes[Math.floor(Math.random() * leaveTypes.length)];
        const status = leaveStatuses[Math.floor(Math.random() * leaveStatuses.length)];

        // Random date within last 2 months or next 1 month
        const dateOffset = Math.floor(Math.random() * 90) - 60;
        const startDate = new Date(today);
        startDate.setDate(startDate.getDate() + dateOffset);
        startDate.setHours(0, 0, 0, 0);

        // 1-5 days leave
        const totalDays = Math.floor(Math.random() * 5) + 1;
        const endDate = new Date(startDate);
        endDate.setDate(endDate.getDate() + totalDays - 1);

        const leaveData = {
            employeeId: emp.id,
            leaveType,
            startDate,
            endDate,
            totalDays,
            reason: leaveType === 'sick' ? 'Ốm, cần nghỉ dưỡng bệnh' :
                   leaveType === 'annual' ? 'Nghỉ phép năm' :
                   leaveType === 'personal' ? 'Việc gia đình' : 'Nghỉ không lương',
            status
        };

        if (status === 'approved' || status === 'rejected') {
            leaveData.approvedBy = createdHRManagers[0].id;
            leaveData.approvedAt = new Date(startDate);
            leaveData.approvedAt.setDate(leaveData.approvedAt.getDate() - 2);
            if (status === 'rejected') {
                leaveData.rejectedReason = 'Không đủ số ngày phép';
            }
        }

        await prisma.leave.create({ data: leaveData });
        leaveCount++;
    }
    console.log(`  ✅ Created ${leaveCount} leave requests\n`);

    // ==================== SUMMARY ====================
    console.log('🎉 ========================================');
    console.log('🎉 SEED COMPLETED SUCCESSFULLY!');
    console.log('🎉 ========================================\n');

    console.log('📊 SUMMARY:');
    console.log('─────────────────────────────────────────');
    console.log(`✅ Departments:        ${Object.keys(createdDepartments).length}`);
    console.log(`✅ Shifts:             ${Object.keys(createdShifts).length}`);
    console.log(`✅ Employees:          ${createdEmployees.length}`);
    console.log(`   - HR Managers:      ${createdHRManagers.length}`);
    console.log(`   - Dept Managers:    ${createdDeptManagers.length}`);
    console.log(`   - Staff:            ${createdEmployees.length}`);
    console.log(`✅ User Accounts:      ${2 + createdHRManagers.length + createdDeptManagers.length + 10}`);
    console.log(`✅ Devices:            ${createdDevices.length}`);
    console.log(`✅ Attendance Records: ${attendanceCount.total}`);
    console.log(`✅ Leave Requests:     ${leaveCount}`);
    console.log('');

    console.log('🔐 LOGIN CREDENTIALS:');
    console.log('─────────────────────────────────────────');
    console.log('Admin:');
    console.log('  Username: admin');
    console.log('  Password: admin123');
    console.log('');
    console.log('HR Managers:');
    console.log('  Username: hr.manager    | Password: hrmanager123');
    console.log('  Username: hr.recruit    | Password: recruit123');
    console.log('');
    console.log('Department Managers:');
    console.log('  Username: it.manager    | Password: itmanager123');
    console.log('  Username: fin.manager   | Password: finmanager123');
    console.log('');
    console.log('Sample Employees (first 10):');
    console.log('  Username: emp005-emp014 | Password: employee123');
    console.log('─────────────────────────────────────────\n');
}

main()
    .catch((e) => {
        console.error('❌ Seed error:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
