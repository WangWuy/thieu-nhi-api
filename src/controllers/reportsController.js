const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

const reportsController = {
    // Get attendance report data
    async getAttendanceReport(req, res) {
        try {
            const { startDate, endDate, classId, departmentId } = req.query;
            const { role, departmentId: userDepartmentId } = req.user;

            let whereClause = {};

            // Role-based filtering
            if (role === 'phan_doan_truong') {
                whereClause.student = {
                    class: { departmentId: userDepartmentId }
                };
            } else if (classId) {
                whereClause.student = { classId: parseInt(classId) };
            } else if (departmentId) {
                whereClause.student = {
                    class: { departmentId: parseInt(departmentId) }
                };
            }

            // Date filtering
            if (startDate && endDate) {
                whereClause.attendanceDate = {
                    gte: new Date(startDate),
                    lte: new Date(endDate)
                };
            }

            // Get attendance data with student and class info
            const attendanceData = await prisma.attendance.findMany({
                where: whereClause,
                include: {
                    student: {
                        include: {
                            class: {
                                include: { department: true }
                            }
                        }
                    }
                },
                orderBy: [
                    { attendanceDate: 'desc' },
                    { student: { fullName: 'asc' } }
                ]
            });

            // Get summary stats
            const summaryStats = await prisma.attendance.groupBy({
                by: ['attendanceType', 'isPresent'],
                where: whereClause,
                _count: { id: true }
            });

            // Format summary
            const summary = {
                thursday: {
                    present: summaryStats.find(s => s.attendanceType === 'thursday' && s.isPresent)?._count.id || 0,
                    absent: summaryStats.find(s => s.attendanceType === 'thursday' && !s.isPresent)?._count.id || 0
                },
                sunday: {
                    present: summaryStats.find(s => s.attendanceType === 'sunday' && s.isPresent)?._count.id || 0,
                    absent: summaryStats.find(s => s.attendanceType === 'sunday' && !s.isPresent)?._count.id || 0
                }
            };

            res.json({
                attendanceData,
                summary,
                filters: { startDate, endDate, classId, departmentId },
                totalRecords: attendanceData.length
            });

        } catch (error) {
            console.error('Get attendance report error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get grade distribution report
    async getGradeDistribution(req, res) {
        try {
            const { classId, departmentId, academicYearId } = req.query;
            const { role, departmentId: userDepartmentId } = req.user;

            let whereClause = { isActive: true };

            // Role-based filtering
            if (role === 'phan_doan_truong') {
                whereClause.class = { departmentId: userDepartmentId };
            } else if (classId) {
                whereClause.classId = parseInt(classId);
            } else if (departmentId) {
                whereClause.class = { departmentId: parseInt(departmentId) };
            }

            // Academic year filtering
            if (academicYearId) {
                whereClause.academicYearId = parseInt(academicYearId);
            }

            const students = await prisma.student.findMany({
                where: whereClause,
                include: {
                    class: {
                        include: { department: true }
                    },
                    academicYear: true
                }
            });

            // Calculate grade distribution
            const distribution = {
                attendance: { excellent: 0, good: 0, average: 0, weak: 0 },
                study: { excellent: 0, good: 0, average: 0, weak: 0 },
                final: { excellent: 0, good: 0, average: 0, weak: 0 }
            };

            const departmentStats = {};
            const classStats = {};

            students.forEach(student => {
                const attendanceScore = parseFloat(student.attendanceAverage) || 0;
                const studyScore = parseFloat(student.studyAverage) || 0;
                const finalScore = parseFloat(student.finalAverage) || 0;

                // Attendance distribution
                if (attendanceScore >= 8.5) distribution.attendance.excellent++;
                else if (attendanceScore >= 7.0) distribution.attendance.good++;
                else if (attendanceScore >= 5.5) distribution.attendance.average++;
                else distribution.attendance.weak++;

                // Study distribution
                if (studyScore >= 8.5) distribution.study.excellent++;
                else if (studyScore >= 7.0) distribution.study.good++;
                else if (studyScore >= 5.5) distribution.study.average++;
                else distribution.study.weak++;

                // Final distribution
                if (finalScore >= 8.5) distribution.final.excellent++;
                else if (finalScore >= 7.0) distribution.final.good++;
                else if (finalScore >= 5.5) distribution.final.average++;
                else distribution.final.weak++;

                // Department stats
                const deptName = student.class.department.displayName;
                if (!departmentStats[deptName]) {
                    departmentStats[deptName] = {
                        totalStudents: 0,
                        averageAttendance: 0,
                        averageStudy: 0,
                        averageFinal: 0,
                        attendanceSum: 0,
                        studySum: 0,
                        finalSum: 0
                    };
                }

                departmentStats[deptName].totalStudents++;
                departmentStats[deptName].attendanceSum += attendanceScore;
                departmentStats[deptName].studySum += studyScore;
                departmentStats[deptName].finalSum += finalScore;

                // Class stats
                const className = student.class.name;
                if (!classStats[className]) {
                    classStats[className] = {
                        totalStudents: 0,
                        averageAttendance: 0,
                        averageStudy: 0,
                        averageFinal: 0,
                        attendanceSum: 0,
                        studySum: 0,
                        finalSum: 0,
                        department: deptName
                    };
                }

                classStats[className].totalStudents++;
                classStats[className].attendanceSum += attendanceScore;
                classStats[className].studySum += studyScore;
                classStats[className].finalSum += finalScore;
            });

            // Calculate averages
            Object.keys(departmentStats).forEach(dept => {
                const stat = departmentStats[dept];
                stat.averageAttendance = (stat.attendanceSum / stat.totalStudents).toFixed(1);
                stat.averageStudy = (stat.studySum / stat.totalStudents).toFixed(1);
                stat.averageFinal = (stat.finalSum / stat.totalStudents).toFixed(1);
                delete stat.attendanceSum;
                delete stat.studySum;
                delete stat.finalSum;
            });

            Object.keys(classStats).forEach(cls => {
                const stat = classStats[cls];
                stat.averageAttendance = (stat.attendanceSum / stat.totalStudents).toFixed(1);
                stat.averageStudy = (stat.studySum / stat.totalStudents).toFixed(1);
                stat.averageFinal = (stat.finalSum / stat.totalStudents).toFixed(1);
                delete stat.attendanceSum;
                delete stat.studySum;
                delete stat.finalSum;
            });

            res.json({
                distribution,
                departmentStats,
                classStats,
                totalStudents: students.length,
                filters: { classId, departmentId, academicYearId }
            });

        } catch (error) {
            console.error('Get grade distribution error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get student ranking report
    async getStudentRanking(req, res) {
        try {
            const { classId, departmentId, academicYearId, limit = 50 } = req.query;
            const { role, departmentId: userDepartmentId } = req.user;

            let whereClause = { isActive: true };

            // Role-based filtering
            if (role === 'phan_doan_truong') {
                whereClause.class = { departmentId: userDepartmentId };
            } else if (classId) {
                whereClause.classId = parseInt(classId);
            } else if (departmentId) {
                whereClause.class = { departmentId: parseInt(departmentId) };
            }

            // Academic year filtering
            if (academicYearId) {
                whereClause.academicYearId = parseInt(academicYearId);
            }

            const students = await prisma.student.findMany({
                where: whereClause,
                include: {
                    class: {
                        include: { department: true }
                    },
                    academicYear: true
                },
                orderBy: [
                    { finalAverage: 'desc' },
                    { studyAverage: 'desc' },
                    { attendanceAverage: 'desc' }
                ],
                take: parseInt(limit)
            });

            // Add ranking
            const rankedStudents = students.map((student, index) => ({
                ...student,
                rank: index + 1,
                finalAverage: parseFloat(student.finalAverage),
                studyAverage: parseFloat(student.studyAverage),
                attendanceAverage: parseFloat(student.attendanceAverage)
            }));

            // Get top performers by category
            const topAttendance = [...students]
                .sort((a, b) => parseFloat(b.attendanceAverage) - parseFloat(a.attendanceAverage))
                .slice(0, 10)
                .map((student, index) => ({ ...student, rank: index + 1 }));

            const topStudy = [...students]
                .sort((a, b) => parseFloat(b.studyAverage) - parseFloat(a.studyAverage))
                .slice(0, 10)
                .map((student, index) => ({ ...student, rank: index + 1 }));

            // Calculate percentiles
            const totalStudentsInScope = await prisma.student.count({ where: whereClause });

            res.json({
                ranking: rankedStudents,
                topPerformers: {
                    overall: rankedStudents.slice(0, 10),
                    attendance: topAttendance,
                    study: topStudy
                },
                statistics: {
                    totalStudents: totalStudentsInScope,
                    averageFinalScore: rankedStudents.length > 0
                        ? (rankedStudents.reduce((sum, s) => sum + s.finalAverage, 0) / rankedStudents.length).toFixed(1)
                        : 0,
                    averageStudyScore: rankedStudents.length > 0
                        ? (rankedStudents.reduce((sum, s) => sum + s.studyAverage, 0) / rankedStudents.length).toFixed(1)
                        : 0,
                    averageAttendanceScore: rankedStudents.length > 0
                        ? (rankedStudents.reduce((sum, s) => sum + s.attendanceAverage, 0) / rankedStudents.length).toFixed(1)
                        : 0
                },
                filters: { classId, departmentId, academicYearId, limit }
            });

        } catch (error) {
            console.error('Get student ranking error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get overview report (dashboard for reports)
    async getOverviewReport(req, res) {
        try {
            const { academicYearId } = req.query;
            const { role, departmentId: userDepartmentId } = req.user;

            let studentWhereClause = { isActive: true };
            let attendanceWhereClause = {};

            // Role-based filtering
            if (role === 'phan_doan_truong') {
                studentWhereClause.class = { departmentId: userDepartmentId };
                attendanceWhereClause.student = {
                    class: { departmentId: userDepartmentId }
                };
            }

            // Academic year filtering
            if (academicYearId) {
                studentWhereClause.academicYearId = parseInt(academicYearId);
            }

            // Get basic counts
            const [
                totalStudents,
                totalClasses,
                totalDepartments,
                attendanceStats,
                students
            ] = await Promise.all([
                prisma.student.count({ where: studentWhereClause }),

                prisma.class.count({
                    where: {
                        isActive: true,
                        ...(role === 'phan_doan_truong' ? { departmentId: userDepartmentId } : {})
                    }
                }),

                prisma.department.count({
                    where: {
                        isActive: true,
                        ...(role === 'phan_doan_truong' ? { id: userDepartmentId } : {})
                    }
                }),

                prisma.attendance.groupBy({
                    by: ['attendanceType', 'isPresent'],
                    where: {
                        ...attendanceWhereClause,
                        attendanceDate: {
                            gte: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) // Last 30 days
                        }
                    },
                    _count: { id: true }
                }),

                prisma.student.findMany({
                    where: studentWhereClause,
                    select: {
                        attendanceAverage: true,
                        studyAverage: true,
                        finalAverage: true
                    }
                })
            ]);

            // Calculate score averages
            const scoreAverages = {
                attendance: students.length > 0
                    ? (students.reduce((sum, s) => sum + parseFloat(s.attendanceAverage), 0) / students.length).toFixed(1)
                    : 0,
                study: students.length > 0
                    ? (students.reduce((sum, s) => sum + parseFloat(s.studyAverage), 0) / students.length).toFixed(1)
                    : 0,
                final: students.length > 0
                    ? (students.reduce((sum, s) => sum + parseFloat(s.finalAverage), 0) / students.length).toFixed(1)
                    : 0
            };

            // Format attendance stats
            const recentAttendance = {
                thursday: {
                    present: attendanceStats.find(s => s.attendanceType === 'thursday' && s.isPresent)?._count.id || 0,
                    absent: attendanceStats.find(s => s.attendanceType === 'thursday' && !s.isPresent)?._count.id || 0
                },
                sunday: {
                    present: attendanceStats.find(s => s.attendanceType === 'sunday' && s.isPresent)?._count.id || 0,
                    absent: attendanceStats.find(s => s.attendanceType === 'sunday' && !s.isPresent)?._count.id || 0
                }
            };

            res.json({
                summary: {
                    totalStudents,
                    totalClasses,
                    totalDepartments,
                    scoreAverages
                },
                recentAttendance,
                lastUpdated: new Date().toISOString(),
                filters: { academicYearId }
            });

        } catch (error) {
            console.error('Get overview report error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Export report data
    async exportReport(req, res) {
        try {
            const { type, format = 'xlsx', ...filters } = req.query;

            // Nếu là attendance report, dùng simplified version
            if (type === 'attendance') {
                req.query = { ...filters, format };
                return this.exportSimpleAttendanceReport(req, res);
            }

            let data = [];
            let filename = `report_${type}_${new Date().toISOString().split('T')[0]}`;

            switch (type) {
                case 'ranking':
                    req.query = { ...filters, limit: 1000 };
                    const rankingResult = await this.getStudentRankingData(req);
                    data = rankingResult.ranking.map(student => ({
                        'Xếp hạng': student.rank,
                        'Mã TN': student.studentCode,
                        'Họ tên': student.fullName,
                        'Lớp': student.class.name,
                        'Ngành': student.class.department.displayName,
                        'Điểm điểm danh': student.attendanceAverage,
                        'Điểm học tập': student.studyAverage,
                        'Điểm tổng': student.finalAverage
                    }));
                    break;

                default:
                    return res.status(400).json({ error: 'Loại báo cáo không hợp lệ' });
            }

            if (format === 'xlsx') {
                const XLSX = require('xlsx');

                // Tạo workbook và worksheet
                const workbook = XLSX.utils.book_new();
                const worksheet = XLSX.utils.json_to_sheet(data);

                // Set column widths based on content
                const colWidths = Object.keys(data[0] || {}).map(key => ({ wch: 15 }));
                worksheet['!cols'] = colWidths;

                // Add worksheet to workbook
                XLSX.utils.book_append_sheet(workbook, worksheet, 'Báo cáo');

                // Generate buffer
                const buffer = XLSX.write(workbook, { type: 'buffer', bookType: 'xlsx' });

                // Set headers and send file
                res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
                res.setHeader('Content-Disposition', `attachment; filename="${filename}.xlsx"`);
                res.send(buffer);
            } else {
                res.json({
                    data,
                    metadata: {
                        type,
                        generatedAt: new Date().toISOString(),
                        totalRecords: data.length,
                        filters
                    }
                });
            }

        } catch (error) {
            console.error('Export report error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Helper methods for export
    async getAttendanceReportData(req) {
        // This is a simplified version of getAttendanceReport for internal use
        const { startDate, endDate, classId, departmentId } = req.query;
        const { role, departmentId: userDepartmentId } = req.user;

        let whereClause = {};

        if (role === 'phan_doan_truong') {
            whereClause.student = { class: { departmentId: userDepartmentId } };
        } else if (classId) {
            whereClause.student = { classId: parseInt(classId) };
        } else if (departmentId) {
            whereClause.student = { class: { departmentId: parseInt(departmentId) } };
        }

        if (startDate && endDate) {
            whereClause.attendanceDate = {
                gte: new Date(startDate),
                lte: new Date(endDate)
            };
        }

        const attendanceData = await prisma.attendance.findMany({
            where: whereClause,
            include: {
                student: {
                    include: {
                        class: { include: { department: true } }
                    }
                }
            },
            orderBy: [
                { attendanceDate: 'desc' },
                { student: { fullName: 'asc' } }
            ]
        });

        return { attendanceData };
    },

    async getStudentRankingData(req) {
        // This is a simplified version of getStudentRanking for internal use
        const { classId, departmentId, academicYearId, limit = 1000 } = req.query;
        const { role, departmentId: userDepartmentId } = req.user;

        let whereClause = { isActive: true };

        if (role === 'phan_doan_truong') {
            whereClause.class = { departmentId: userDepartmentId };
        } else if (classId) {
            whereClause.classId = parseInt(classId);
        } else if (departmentId) {
            whereClause.class = { departmentId: parseInt(departmentId) };
        }

        if (academicYearId) {
            whereClause.academicYearId = parseInt(academicYearId);
        }

        const students = await prisma.student.findMany({
            where: whereClause,
            include: {
                class: { include: { department: true } },
                academicYear: true
            },
            orderBy: [
                { finalAverage: 'desc' },
                { studyAverage: 'desc' },
                { attendanceAverage: 'desc' }
            ],
            take: parseInt(limit)
        });

        const ranking = students.map((student, index) => ({
            ...student,
            rank: index + 1,
            finalAverage: parseFloat(student.finalAverage),
            studyAverage: parseFloat(student.studyAverage),
            attendanceAverage: parseFloat(student.attendanceAverage)
        }));

        return { ranking };
    },

    // Export simplified attendance report (chỉ mã thiếu nhi)
    async exportSimpleAttendanceReport(req, res) {
        try {
            const { startDate, endDate, classId, departmentId, format = 'xlsx' } = req.query;
            const { role, departmentId: userDepartmentId } = req.user;

            let whereClause = {
                isPresent: true // Chỉ lấy những người có mặt
            };

            // Role-based filtering  
            if (role === 'phan_doan_truong') {
                whereClause.student = {
                    class: { departmentId: userDepartmentId }
                };
            } else if (classId) {
                whereClause.student = { classId: parseInt(classId) };
            } else if (departmentId) {
                whereClause.student = {
                    class: { departmentId: parseInt(departmentId) }
                };
            }

            // Date filtering
            if (startDate && endDate) {
                whereClause.attendanceDate = {
                    gte: new Date(startDate),
                    lte: new Date(endDate)
                };
            }

            // Get attendance data - chỉ lấy mã thiếu nhi và ngày
            const attendanceData = await prisma.attendance.findMany({
                where: whereClause,
                select: {
                    attendanceDate: true,
                    attendanceType: true,
                    student: {
                        select: {
                            studentCode: true,
                            fullName: true // Để hiển thị trong UI, không export
                        }
                    }
                },
                orderBy: [
                    { attendanceDate: 'desc' },
                    { student: { studentCode: 'asc' } }
                ]
            });

            // Group by date for easier export
            const groupedByDate = {};
            attendanceData.forEach(record => {
                const dateKey = new Date(record.attendanceDate).toISOString().split('T')[0];
                const typeKey = record.attendanceType;
                const key = `${dateKey}_${typeKey}`;

                if (!groupedByDate[key]) {
                    groupedByDate[key] = {
                        date: dateKey,
                        type: typeKey,
                        studentCodes: []
                    };
                }

                groupedByDate[key].studentCodes.push(record.student.studentCode);
            });

            if (format === 'xlsx') {
                const XLSX = require('xlsx');

                // Tạo dữ liệu cho Excel
                const excelData = Object.values(groupedByDate)
                    .sort((a, b) => new Date(b.date) - new Date(a.date))
                    .map(group => ({
                        'Ngày': new Date(group.date).toLocaleDateString('vi-VN'),
                        'Loại điểm danh': group.type === 'thursday' ? 'Thứ 5' : 'Chủ nhật',
                        'Số lượng': group.studentCodes.length,
                        'Mã thiếu nhi có mặt': group.studentCodes.join('; ')
                    }));

                // Tạo workbook và worksheet
                const workbook = XLSX.utils.book_new();
                const worksheet = XLSX.utils.json_to_sheet(excelData);

                // Set column widths
                worksheet['!cols'] = [
                    { wch: 12 }, // Ngày
                    { wch: 15 }, // Loại điểm danh  
                    { wch: 10 }, // Số lượng
                    { wch: 60 }  // Mã thiếu nhi
                ];

                // Add worksheet to workbook
                XLSX.utils.book_append_sheet(workbook, worksheet, 'Điểm danh');

                // Generate filename
                const filename = `diem_danh_${startDate || 'all'}_${endDate || 'all'}.xlsx`;

                // Generate buffer
                const buffer = XLSX.write(workbook, { type: 'buffer', bookType: 'xlsx' });

                // Set headers and send file
                res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
                res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
                res.send(buffer);
            } else {
                // Return JSON
                res.json({
                    attendanceByDate: groupedByDate,
                    summary: {
                        totalDays: Object.keys(groupedByDate).length,
                        totalAttendances: attendanceData.length,
                        dateRange: { startDate, endDate }
                    },
                    metadata: {
                        generatedAt: new Date().toISOString(),
                        filters: { startDate, endDate, classId, departmentId }
                    }
                });
            }

        } catch (error) {
            console.error('Export simple attendance report error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },
};

module.exports = reportsController;