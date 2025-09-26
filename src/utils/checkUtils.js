const { prisma } = require('../../prisma/client');

const checkUtils = {
    // Validate điểm của 1 học sinh
    validateStudentScore(student) {
        const errors = [];
        const corrections = {};

        // 1. Check attendance score
        if (student.academicYear?.totalWeeks) {
            const { thursdayAttendanceCount, sundayAttendanceCount, attendanceAverage } = student;
            const totalWeeks = student.academicYear.totalWeeks;
            const pointPerWeek = 10 / totalWeeks;
            const thursdayScore = thursdayAttendanceCount * pointPerWeek;
            const sundayScore = sundayAttendanceCount * pointPerWeek;
            const correctAttendance = (thursdayScore * 0.4) + (sundayScore * 0.6);
            const roundedCorrect = Math.round(correctAttendance * 100) / 100;

            if (Math.abs(parseFloat(attendanceAverage) - roundedCorrect) > 0.01) {
                errors.push(`Điểm danh sai: ${attendanceAverage} → ${roundedCorrect}`);
                corrections.attendanceAverage = roundedCorrect;
            }
        }

        // 2. Check study score
        const { study45Hk1, examHk1, study45Hk2, examHk2, studyAverage } = student;
        const total = parseFloat(study45Hk1) + parseFloat(study45Hk2) + 
                     (parseFloat(examHk1) * 2) + (parseFloat(examHk2) * 2);
        const correctStudy = Math.round((total / 6) * 100) / 100;

        if (Math.abs(parseFloat(studyAverage) - correctStudy) > 0.01) {
            errors.push(`Điểm học sai: ${studyAverage} → ${correctStudy}`);
            corrections.studyAverage = correctStudy;
        }

        // 3. Check final score
        const studyAvg = corrections.studyAverage || parseFloat(studyAverage);
        const attendanceAvg = corrections.attendanceAverage || parseFloat(student.attendanceAverage);
        const correctFinal = Math.round((studyAvg * 0.6 + attendanceAvg * 0.4) * 100) / 100;

        if (Math.abs(parseFloat(student.finalAverage) - correctFinal) > 0.01) {
            errors.push(`Điểm cuối sai: ${student.finalAverage} → ${correctFinal}`);
            corrections.finalAverage = correctFinal;
        }

        return {
            studentId: student.id,
            studentCode: student.studentCode,
            fullName: student.fullName,
            hasErrors: errors.length > 0,
            errors,
            corrections
        };
    },

    // Check điểm cả lớp
    async checkClassScores(classId) {
        const students = await prisma.student.findMany({
            where: { classId: parseInt(classId), isActive: true },
            include: { academicYear: true }
        });

        const results = [];
        for (const student of students) {
            const validation = this.validateStudentScore(student);
            if (validation.hasErrors) {
                results.push(validation);
            }
        }

        return {
            classId,
            totalStudents: students.length,
            studentsWithErrors: results.length,
            errors: results
        };
    },

    // Sửa điểm cả lớp
    async fixClassScores(classId) {
        const validation = await this.checkClassScores(classId);
        
        if (validation.studentsWithErrors === 0) {
            return { message: 'Tất cả điểm đều chính xác' };
        }

        const fixResults = [];
        for (const studentError of validation.errors) {
            try {
                await prisma.student.update({
                    where: { id: studentError.studentId },
                    data: studentError.corrections
                });
                fixResults.push({
                    studentId: studentError.studentId,
                    studentName: studentError.fullName,
                    success: true
                });
            } catch (error) {
                fixResults.push({
                    studentId: studentError.studentId,
                    success: false,
                    error: error.message
                });
            }
        }

        return {
            message: `Đã sửa ${fixResults.filter(r => r.success).length}/${validation.studentsWithErrors} học sinh`,
            results: fixResults
        };
    },

    // Sửa điểm 1 học sinh
    async fixStudentScore(studentId) {
        const student = await prisma.student.findUnique({
            where: { id: studentId },
            include: { academicYear: true }
        });

        if (!student) {
            throw new Error('Không tìm thấy học sinh');
        }

        const validation = this.validateStudentScore(student);
        if (!validation.hasErrors) {
            return { message: 'Điểm đã chính xác' };
        }

        await prisma.student.update({
            where: { id: studentId },
            data: validation.corrections
        });

        return {
            message: 'Đã sửa điểm thành công',
            corrections: validation.corrections
        };
    }
};

module.exports = checkUtils;