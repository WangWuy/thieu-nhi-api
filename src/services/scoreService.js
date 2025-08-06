const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class ScoreService {
    // Calculate attendance average for a student
    static async calculateAttendanceAverage(studentId) {
        try {
            const student = await prisma.student.findUnique({
                where: { id: studentId },
                include: { academicYear: true }
            });

            if (!student || !student.academicYear) {
                throw new Error('Student or academic year not found');
            }

            const totalWeeks = student.academicYear.totalWeeks;
            const pointPerWeek = 10 / totalWeeks; // 10 điểm chia cho tổng số tuần

            // Calculate scores
            const thursdayScore = student.thursdayAttendanceCount * pointPerWeek;
            const sundayScore = student.sundayAttendanceCount * pointPerWeek;

            // Weighted average: Thursday 40%, Sunday 60%
            const attendanceAverage = (thursdayScore * 0.4) + (sundayScore * 0.6);

            return Math.round(attendanceAverage * 100) / 100; // Round to 2 decimal places
        } catch (error) {
            console.error('Calculate attendance average error:', error);
            throw error;
        }
    }

    // Calculate study average for a student
    static calculateStudyAverage(study45Hk1, examHk1, study45Hk2, examHk2) {
        // Formula: (45' HKI + 45' HKII + Thi HKI*2 + thi HKII*2)/6
        const total = parseFloat(study45Hk1) + parseFloat(study45Hk2) +
            (parseFloat(examHk1) * 2) + (parseFloat(examHk2) * 2);

        const average = total / 6;
        return Math.round(average * 100) / 100; // Round to 2 decimal places
    }

    // Calculate final average for a student
    static calculateFinalAverage(studyAverage, attendanceAverage) {
        // Formula: Study Average * 0.6 + Attendance Average * 0.4
        const finalAverage = (parseFloat(studyAverage) * 0.6) + (parseFloat(attendanceAverage) * 0.4);
        return Math.round(finalAverage * 100) / 100; // Round to 2 decimal places
    }

    // Update all scores for a student
    static async updateStudentScores(studentId, scoreData = {}) {
        try {
            const student = await prisma.student.findUnique({
                where: { id: studentId },
                include: { academicYear: true }
            });

            if (!student) {
                throw new Error('Student not found');
            }

            // Prepare update data
            const updateData = {};

            // Update attendance counts if provided
            if (scoreData.thursdayAttendanceCount !== undefined) {
                updateData.thursdayAttendanceCount = parseInt(scoreData.thursdayAttendanceCount);
            }
            if (scoreData.sundayAttendanceCount !== undefined) {
                updateData.sundayAttendanceCount = parseInt(scoreData.sundayAttendanceCount);
            }

            // Update study scores if provided
            if (scoreData.study45Hk1 !== undefined) {
                updateData.study45Hk1 = parseFloat(scoreData.study45Hk1);
            }
            if (scoreData.examHk1 !== undefined) {
                updateData.examHk1 = parseFloat(scoreData.examHk1);
            }
            if (scoreData.study45Hk2 !== undefined) {
                updateData.study45Hk2 = parseFloat(scoreData.study45Hk2);
            }
            if (scoreData.examHk2 !== undefined) {
                updateData.examHk2 = parseFloat(scoreData.examHk2);
            }

            // Get current values (combining existing + new values)
            const currentStudent = await prisma.student.findUnique({
                where: { id: studentId }
            });

            const finalData = {
                thursdayAttendanceCount: updateData.thursdayAttendanceCount ?? currentStudent.thursdayAttendanceCount,
                sundayAttendanceCount: updateData.sundayAttendanceCount ?? currentStudent.sundayAttendanceCount,
                study45Hk1: updateData.study45Hk1 ?? currentStudent.study45Hk1,
                examHk1: updateData.examHk1 ?? currentStudent.examHk1,
                study45Hk2: updateData.study45Hk2 ?? currentStudent.study45Hk2,
                examHk2: updateData.examHk2 ?? currentStudent.examHk2
            };

            // Calculate attendance average
            let attendanceAverage = 0;
            if (student.academicYear) {
                const totalWeeks = student.academicYear.totalWeeks;
                const pointPerWeek = 10 / totalWeeks;
                const thursdayScore = finalData.thursdayAttendanceCount * pointPerWeek;
                const sundayScore = finalData.sundayAttendanceCount * pointPerWeek;
                attendanceAverage = (thursdayScore * 0.4) + (sundayScore * 0.6);
            }

            // Calculate study average
            const studyAverage = this.calculateStudyAverage(
                finalData.study45Hk1,
                finalData.examHk1,
                finalData.study45Hk2,
                finalData.examHk2
            );

            // Calculate final average
            const finalAverage = this.calculateFinalAverage(studyAverage, attendanceAverage);

            // Add calculated averages to update data
            updateData.attendanceAverage = Math.round(attendanceAverage * 100) / 100;
            updateData.studyAverage = studyAverage;
            updateData.finalAverage = finalAverage;

            // Update student
            const updatedStudent = await prisma.student.update({
                where: { id: studentId },
                data: updateData,
                include: {
                    class: { include: { department: true } },
                    academicYear: true
                }
            });

            return updatedStudent;
        } catch (error) {
            console.error('Update student scores error:', error);
            throw error;
        }
    }

    // Recalculate scores for all students in an academic year
    static async recalculateAcademicYearScores(academicYearId) {
        try {
            const students = await prisma.student.findMany({
                where: {
                    academicYearId: academicYearId,
                    isActive: true
                }
            });

            const updatePromises = students.map(student =>
                this.updateStudentScores(student.id)
            );

            await Promise.all(updatePromises);

            return {
                message: `Đã tính lại điểm cho ${students.length} học sinh`,
                count: students.length
            };
        } catch (error) {
            console.error('Recalculate academic year scores error:', error);
            throw error;
        }
    }

    // Get class score statistics
    static async getClassScoreStats(classId) {
        try {
            const students = await prisma.student.findMany({
                where: {
                    classId: classId,
                    isActive: true
                },
                select: {
                    id: true,
                    fullName: true,
                    attendanceAverage: true,
                    studyAverage: true,
                    finalAverage: true
                }
            });

            if (students.length === 0) {
                return {
                    totalStudents: 0,
                    averageScores: { attendance: 0, study: 0, final: 0 },
                    students: []
                };
            }

            // Calculate class averages
            const totals = students.reduce((acc, student) => {
                acc.attendance += parseFloat(student.attendanceAverage);
                acc.study += parseFloat(student.studyAverage);
                acc.final += parseFloat(student.finalAverage);
                return acc;
            }, { attendance: 0, study: 0, final: 0 });

            const averageScores = {
                attendance: Math.round((totals.attendance / students.length) * 100) / 100,
                study: Math.round((totals.study / students.length) * 100) / 100,
                final: Math.round((totals.final / students.length) * 100) / 100
            };

            return {
                totalStudents: students.length,
                averageScores,
                students: students.sort((a, b) => b.finalAverage - a.finalAverage)
            };
        } catch (error) {
            console.error('Get class score stats error:', error);
            throw error;
        }
    }
}

module.exports = ScoreService;