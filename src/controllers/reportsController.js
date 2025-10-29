const { prisma } = require('../../prisma/client');
const { sortStudentsByLastName } = require('../utils/sortUtils');

const reportsController = {
    // Get attendance report data
    async getAttendanceReport(req, res) {
        try {
            const { startDate, endDate, classId, departmentId, attendanceType } = req.query;
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
                    lte: new Date(endDate + 'T23:59:59.999Z')
                };
            }

            if (attendanceType && attendanceType !== 'all') {
                whereClause.attendanceType = attendanceType;
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
                    { attendanceDate: 'desc' }
                ]
            });

            // Lấy tất cả students theo filter để có complete list
            let studentWhereClause = { isActive: true };
            if (role === 'phan_doan_truong') {
                studentWhereClause.class = { departmentId: userDepartmentId };
            } else if (classId) {
                studentWhereClause.classId = parseInt(classId);
            } else if (departmentId) {
                studentWhereClause.class = { departmentId: parseInt(departmentId) };
            }

            const allStudents = await prisma.student.findMany({
                where: studentWhereClause,
                include: {
                    class: {
                        include: { department: true }
                    }
                }
            });

            // Group data by student to apply sort
            const studentsMap = new Map();
            attendanceData.forEach(record => {
                if (!studentsMap.has(record.student.id)) {
                    studentsMap.set(record.student.id, record.student);
                }
            });

            // Tìm students chưa có attendance
            const studentsWithoutAttendance = allStudents.filter(student =>
                !studentsMap.has(student.id)
            );

            // Thêm students chưa có attendance vào map để sort
            allStudents.forEach(student => {
                if (!studentsMap.has(student.id)) {
                    studentsMap.set(student.id, student);
                }
            });

            // Sort students using Vietnamese last name utility
            const sortedStudents = sortStudentsByLastName(Array.from(studentsMap.values()));

            // Sort students chưa điểm danh
            const sortedStudentsWithoutAttendance = sortStudentsByLastName(studentsWithoutAttendance);

            // Create lookup for sorted order
            const studentOrderMap = new Map();
            sortedStudents.forEach((student, index) => {
                studentOrderMap.set(student.id, index);
            });

            // Sort attendance data by student name order, then by date
            const sortedAttendanceData = attendanceData.sort((a, b) => {
                const orderA = studentOrderMap.get(a.student.id) || 0;
                const orderB = studentOrderMap.get(b.student.id) || 0;

                if (orderA !== orderB) {
                    return orderA - orderB;
                }

                // Same student, sort by date desc
                return new Date(b.attendanceDate) - new Date(a.attendanceDate);
            });

            // Group by date for summary
            const attendanceByDate = {};
            sortedAttendanceData.forEach(record => {
                if (record.isPresent) {
                    const dateKey = record.attendanceDate.toISOString().split('T')[0];
                    if (!attendanceByDate[dateKey]) {
                        attendanceByDate[dateKey] = {
                            date: dateKey,
                            type: record.attendanceType,
                            studentCodes: []
                        };
                    }
                    attendanceByDate[dateKey].studentCodes.push(record.student.studentCode);
                }
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
                attendanceData: sortedAttendanceData,
                attendanceByDate,
                summary,
                filters: { startDate, endDate, classId, departmentId },
                totalRecords: sortedAttendanceData.length,
                totalStudents: sortedStudents.length,
                studentsWithoutAttendance: studentsWithoutAttendance.length,
                studentsWithoutAttendanceList: sortedStudentsWithoutAttendance.map(student => ({
                    id: student.id,
                    studentCode: student.studentCode,
                    saintName: student.saintName,
                    fullName: student.fullName,
                    classId: student.classId,
                    className: student.class?.name
                }))
            });

        } catch (error) {
            console.error('Get attendance report error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get student scores report (renamed from student ranking)
    async getStudentScores(req, res) {
        try {
            const { classId, departmentId, academicYearId, limit = 100 } = req.query;
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
                take: parseInt(limit)
            });

            // Sort students by Vietnamese last name only
            const sortedStudents = sortStudentsByLastName([...students]);

            // Sort students by final score for ranking (highest first)
            const studentsForRanking = [...students].sort((a, b) => {
                const scoreA = parseFloat(a.finalAverage || 0);
                const scoreB = parseFloat(b.finalAverage || 0);
                return scoreB - scoreA; // Descending order
            });

            // Calculate ranks based on final scores
            const studentsWithRanks = sortedStudents.map(student => {
                const finalScore = parseFloat(student.finalAverage || 0);

                // Find rank by counting students with higher scores
                const rank = studentsForRanking.findIndex(s => s.id === student.id) + 1;

                // Calculate attendance scores
                const totalWeeks = student.academicYear?.totalWeeks || 0;
                const thursdayScore = totalWeeks ?
                    Math.round((student.thursdayAttendanceCount / totalWeeks * 10) * 100) / 100 : 0;
                const sundayScore = totalWeeks ?
                    Math.round((student.sundayAttendanceCount / totalWeeks * 10) * 100) / 100 : 0;

                return {
                    ...student,
                    // Convert Decimal to number
                    finalAverage: parseFloat(student.finalAverage || 0),
                    studyAverage: parseFloat(student.studyAverage || 0),
                    attendanceAverage: parseFloat(student.attendanceAverage || 0),

                    // Study scores - HK1
                    study45Hk1: parseFloat(student.study45Hk1 || 0),
                    examHk1: parseFloat(student.examHk1 || 0),

                    // Study scores - HK2
                    study45Hk2: parseFloat(student.study45Hk2 || 0),
                    examHk2: parseFloat(student.examHk2 || 0),

                    // Attendance counts
                    thursdayAttendanceCount: student.thursdayAttendanceCount || 0,
                    sundayAttendanceCount: student.sundayAttendanceCount || 0,

                    // Attendance scores (calculated)
                    thursdayScore,
                    sundayScore,

                    // Calculated rank
                    calculatedRank: rank,

                    // Kết quả dựa trên điểm tổng
                    result: calculateResult(parseFloat(student.finalAverage || 0))
                };
            });

            // Calculate statistics
            const totalStudentsInScope = await prisma.student.count({ where: whereClause });

            res.json({
                ranking: studentsWithRanks,
                statistics: {
                    totalStudents: totalStudentsInScope,
                    averageFinalScore: studentsWithRanks.length > 0
                        ? (studentsWithRanks.reduce((sum, s) => sum + s.finalAverage, 0) / studentsWithRanks.length).toFixed(1)
                        : 0,
                    averageStudyScore: studentsWithRanks.length > 0
                        ? (studentsWithRanks.reduce((sum, s) => sum + s.studyAverage, 0) / studentsWithRanks.length).toFixed(1)
                        : 0,
                    averageAttendanceScore: studentsWithRanks.length > 0
                        ? (studentsWithRanks.reduce((sum, s) => sum + s.attendanceAverage, 0) / studentsWithRanks.length).toFixed(1)
                        : 0
                },
                filters: { classId, departmentId, academicYearId, limit }
            });

        } catch (error) {
            console.error('Get student scores error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },
};

function calculateResult(finalAverage) {
    if (finalAverage >= 8.5) return 'Giỏi';
    if (finalAverage >= 7.0) return 'Khá';
    if (finalAverage >= 5.5) return 'Trung bình';
    if (finalAverage >= 4.0) return 'Yếu';
    return 'Kém';
}

module.exports = reportsController;