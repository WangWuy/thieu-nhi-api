const { spawn } = require('child_process');
const { prisma } = require('../../prisma/client');
const ExcelUtils = require('../utils/excelUtils');

const parseDatabaseUrl = () => {
    const dbUrl = process.env.DATABASE_URL;
    if (!dbUrl) {
        throw new Error('DATABASE_URL chưa được cấu hình');
    }

    const url = new URL(dbUrl);
    return {
        host: url.hostname,
        port: url.port || '5432',
        database: url.pathname.replace('/', ''),
        user: decodeURIComponent(url.username),
        password: decodeURIComponent(url.password || '')
    };
};

const buildSheet = (headers, rows) => {
    return [headers, ...rows];
};

const formatDate = (date) => date ? new Date(date).toISOString().split('T')[0] : '';
const formatNumber = (value) => value === null || value === undefined ? '' : Number(value);

const backupController = {
    // Export dữ liệu chính sang Excel (đa sheet)
    async exportExcel(req, res) {
        try {
            const [
                departments,
                classes,
                users,
                academicYears,
                students,
                attendance
            ] = await Promise.all([
                prisma.department.findMany(),
                prisma.class.findMany({ include: { department: true } }),
                prisma.user.findMany({ include: { department: true } }),
                prisma.academicYear.findMany(),
                prisma.student.findMany({
                    include: {
                        class: { include: { department: true } },
                        academicYear: true
                    }
                }),
                prisma.attendance.findMany({
                    include: {
                        student: { select: { studentCode: true, fullName: true, classId: true } },
                        marker: { select: { fullName: true } }
                    },
                    orderBy: [{ attendanceDate: 'desc' }]
                })
            ]);

            const departmentSheet = buildSheet(
                ['ID', 'Tên', 'Tên hiển thị', 'Mô tả', 'Hoạt động', 'Tạo lúc'],
                departments.map(d => [
                    d.id,
                    d.name,
                    d.displayName,
                    d.description || '',
                    d.isActive ? 'active' : 'inactive',
                    formatDate(d.createdAt)
                ])
            );

            const classSheet = buildSheet(
                ['ID', 'Tên lớp', 'Ngành', 'Ngành ID', 'Giáo viên chính ID', 'Hoạt động', 'Tạo lúc', 'Cập nhật'],
                classes.map(c => [
                    c.id,
                    c.name,
                    c.department?.displayName || '',
                    c.departmentId,
                    c.teacherId || '',
                    c.isActive ? 'active' : 'inactive',
                    formatDate(c.createdAt),
                    formatDate(c.updatedAt)
                ])
            );

            const userSheet = buildSheet(
                ['ID', 'Username', 'Họ tên', 'Tên Thánh', 'Role', 'Ngành', 'Ngành ID', 'SĐT', 'Địa chỉ', 'Hoạt động', 'Tạo lúc', 'Cập nhật'],
                users.map(u => [
                    u.id,
                    u.username,
                    u.fullName,
                    u.saintName || '',
                    u.role,
                    u.department?.displayName || '',
                    u.departmentId || '',
                    u.phoneNumber || '',
                    u.address || '',
                    u.isActive ? 'active' : 'inactive',
                    formatDate(u.createdAt),
                    formatDate(u.updatedAt)
                ])
            );

            const academicYearSheet = buildSheet(
                ['ID', 'Tên', 'Bắt đầu', 'Kết thúc', 'Tổng số tuần', 'Đang hoạt động', 'Hiện hành'],
                academicYears.map(a => [
                    a.id,
                    a.name,
                    formatDate(a.startDate),
                    formatDate(a.endDate),
                    a.totalWeeks,
                    a.isActive ? 'active' : 'inactive',
                    a.isCurrent ? 'current' : ''
                ])
            );

            const studentSheet = buildSheet(
                [
                    'ID', 'Mã', 'Tên Thánh', 'Họ tên', 'Ngành', 'Lớp', 'Lớp ID', 'Năm học', 'Năm học ID',
                    'Ngày sinh', 'SĐT', 'SĐT PH 1', 'SĐT PH 2', 'Địa chỉ', 'Ghi chú', 'Hoạt động',
                    'Thứ 5', 'Chủ nhật', 'Điểm CC', 'HK1 45p', 'HK1 Thi', 'HK2 45p', 'HK2 Thi', 'TB học', 'TB cuối',
                    'Tạo lúc', 'Cập nhật'
                ],
                students.map(s => [
                    s.id,
                    s.studentCode,
                    s.saintName || '',
                    s.fullName,
                    s.class?.department?.displayName || '',
                    s.class?.name || '',
                    s.classId,
                    s.academicYear?.name || '',
                    s.academicYearId || '',
                    formatDate(s.birthDate),
                    s.phoneNumber || '',
                    s.parentPhone1 || '',
                    s.parentPhone2 || '',
                    s.address || '',
                    s.note || '',
                    s.isActive ? 'active' : 'inactive',
                    s.thursdayAttendanceCount,
                    s.sundayAttendanceCount,
                    formatNumber(s.attendanceAverage),
                    formatNumber(s.study45Hk1),
                    formatNumber(s.examHk1),
                    formatNumber(s.study45Hk2),
                    formatNumber(s.examHk2),
                    formatNumber(s.studyAverage),
                    formatNumber(s.finalAverage),
                    formatDate(s.createdAt),
                    formatDate(s.updatedAt)
                ])
            );

            const attendanceSheet = buildSheet(
                ['ID', 'Mã HS', 'Họ tên', 'Lớp ID', 'Ngày', 'Loại', 'Có mặt', 'Ghi chú', 'Điểm danh bởi', 'Điểm danh lúc'],
                attendance.map(a => [
                    a.id,
                    a.student?.studentCode || '',
                    a.student?.fullName || '',
                    a.student?.classId || '',
                    formatDate(a.attendanceDate),
                    a.attendanceType,
                    a.isPresent ? 'present' : 'absent',
                    a.note || '',
                    a.marker?.fullName || '',
                    formatDate(a.markedAt)
                ])
            );

            const workbookBuffer = ExcelUtils.createWorkbook([
                { name: 'Departments', data: departmentSheet },
                { name: 'Classes', data: classSheet },
                { name: 'Users', data: userSheet },
                { name: 'AcademicYears', data: academicYearSheet },
                { name: 'Students', data: studentSheet },
                { name: 'Attendance', data: attendanceSheet },
            ]);

            const filename = `backup_${new Date().toISOString().replace(/[:.]/g, '-')}.xlsx`;
            res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
            res.send(workbookBuffer);
        } catch (error) {
            console.error('Export Excel error:', error);
            res.status(500).json({
                error: 'Không thể xuất Excel',
                message: error.message
            });
        }
    },

    // Xuất file dump PostgreSQL (dạng SQL)
    async exportDump(req, res) {
        try {
            const { host, port, database, user, password } = parseDatabaseUrl();

            const dumpArgs = [
                '--no-owner',
                '--no-privileges',
                '-h', host,
                '-p', port,
                '-U', user,
                database
            ];

            const dumpProcess = spawn('pg_dump', dumpArgs, {
                env: { ...process.env, PGPASSWORD: password }
            });

            const chunks = [];
            let stderr = '';
            let responded = false;

            dumpProcess.stdout.on('data', (data) => chunks.push(data));
            dumpProcess.stderr.on('data', (data) => {
                stderr += data.toString();
            });

            dumpProcess.on('error', (err) => {
                console.error('pg_dump spawn error:', err);
                if (!responded) {
                    responded = true;
                    return res.status(500).json({
                        error: 'Không thể chạy pg_dump',
                        message: err.message
                    });
                }
            });

            dumpProcess.on('close', (code) => {
                if (responded) return;

                if (code !== 0) {
                    console.error('pg_dump failed:', stderr);
                    return res.status(500).json({
                        error: 'Không thể tạo file dump',
                        message: stderr || 'pg_dump exited with error'
                    });
                }

                const buffer = Buffer.concat(chunks);
                const filename = `database_dump_${new Date().toISOString().replace(/[:.]/g, '-')}.sql`;
                res.setHeader('Content-Type', 'application/sql');
                res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
                res.send(buffer);
                responded = true;
            });
        } catch (error) {
            console.error('Export dump error:', error);
            res.status(500).json({
                error: 'Không thể tạo file dump',
                message: error.message
            });
        }
    }
};

module.exports = backupController;