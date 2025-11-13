const { prisma } = require('../../prisma/client');
const ScoreService = require('../services/scoreService');
const { sortStudentsByLastName } = require('../utils/sortUtils');
const checkUtils = require('../utils/checkUtils');

const studentController = {
    // Get all students (with filters by role)
    async getStudents(req, res) {
        try {
            const { role, departmentId } = req.user;
            const {
                page = 1,
                limit = 50,
                search,
                classFilter,
                academicYearId,
                isActive
            } = req.query;

            let whereClause = {};

            // Apply isActive filter
            if (isActive !== undefined) {
                whereClause.isActive = isActive === 'true' || isActive === true;
            }

            // Apply role-based filters
            if (role === 'phan_doan_truong') {
                whereClause.class = { departmentId: departmentId };
            }

            // Apply search filter
            if (search) {
                whereClause.OR = [
                    { fullName: { contains: search, mode: 'insensitive' } },
                    { studentCode: { contains: search, mode: 'insensitive' } },
                    { saintName: { contains: search, mode: 'insensitive' } }
                ];
            }

            // Apply class filter
            if (classFilter) {
                whereClause.classId = parseInt(classFilter);
            }

            // Apply academic year filter
            if (academicYearId) {
                whereClause.academicYearId = parseInt(academicYearId);
            }

            // Lấy tất cả students
            const allStudents = await prisma.student.findMany({
                where: whereClause,
                include: {
                    class: {
                        include: {
                            department: true
                        }
                    },
                    academicYear: {
                        select: {
                            id: true,
                            name: true,
                            totalWeeks: true,
                            isCurrent: true
                        }
                    }
                }
            });

            // Sort students by Vietnamese last name
            const sortStudentsByLastName = (students) => {
                return students.sort((a, b) => {
                    const aLastName = a.fullName.split(' ').pop();
                    const bLastName = b.fullName.split(' ').pop();
                    return aLastName.localeCompare(bLastName, 'vi', {
                        sensitivity: 'base',
                        numeric: true,
                        ignorePunctuation: true
                    });
                });
            };

            const sortedStudents = sortStudentsByLastName(allStudents);

            // Calculate attendance scores for each student
            const studentsWithScores = sortedStudents.map(student => {
                const totalWeeks = student.academicYear?.totalWeeks || 0;

                const thursdayScore = totalWeeks ?
                    Math.round((student.thursdayAttendanceCount / totalWeeks * 10) * 100) / 100 : 0;
                const sundayScore = totalWeeks ?
                    Math.round((student.sundayAttendanceCount / totalWeeks * 10) * 100) / 100 : 0;

                return {
                    ...student,
                    thursdayScore,
                    sundayScore
                };
            });

            // Pagination in-memory
            const skip = (page - 1) * limit;
            const students = studentsWithScores.slice(skip, skip + parseInt(limit));
            const total = studentsWithScores.length;

            res.json({
                students,
                pagination: {
                    page: parseInt(page),
                    limit: parseInt(limit),
                    total,
                    pages: Math.ceil(total / limit)
                }
            });

        } catch (error) {
            console.error('Get students error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get student by ID - Updated to include score details
    async getStudentById(req, res) {
        try {
            const { id } = req.params;
    
            const student = await prisma.student.findUnique({
                where: { id: parseInt(id) },
                include: {
                    class: { include: { department: true } },
                    academicYear: true,
                    attendance: {
                        orderBy: { attendanceDate: 'desc' },
                        take: 10,
                        include: {
                            marker: { select: { fullName: true } }
                        }
                    }
                }
            });
    
            if (!student) {
                return res.status(404).json({ error: 'Học sinh không tồn tại' });
            }
    
            const totalWeeks = student.academicYear?.totalWeeks || 0;
            
            // Calculate once and reuse
            const thursdayScore = totalWeeks ? (student.thursdayAttendanceCount * (10 / totalWeeks)) : 0;
            const sundayScore = totalWeeks ? (student.sundayAttendanceCount * (10 / totalWeeks)) : 0;
    
            const enrichedStudent = {
                ...student,
                calculatedStats: {
                    attendanceProgress: {
                        thursday: {
                            attended: student.thursdayAttendanceCount,
                            total: totalWeeks,
                            percentage: totalWeeks ? Math.round((student.thursdayAttendanceCount / totalWeeks) * 100) : 0,
                            score: thursdayScore
                        },
                        sunday: {
                            attended: student.sundayAttendanceCount,
                            total: totalWeeks,
                            percentage: totalWeeks ? Math.round((student.sundayAttendanceCount / totalWeeks) * 100) : 0,
                            score: sundayScore
                        }
                    }
                }
            };
    
            res.json(enrichedStudent);
    
        } catch (error) {
            console.error('Get student error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Create new student - Updated to include academic year
    async createStudent(req, res) {
        try {
            const {
                studentCode,
                saintName,
                fullName,
                birthDate,
                phoneNumber,
                parentPhone1,
                parentPhone2,
                address,
                classId,
                academicYearId
            } = req.body;

            // Validate required fields
            if (!studentCode || !fullName || !classId) {
                return res.status(400).json({
                    error: 'Mã học sinh, họ tên và lớp là bắt buộc'
                });
            }

            // Check if student code already exists
            const existingStudent = await prisma.student.findUnique({
                where: { studentCode }
            });

            if (existingStudent) {
                return res.status(400).json({ error: 'Mã học sinh đã tồn tại' });
            }

            // Get current academic year if not provided
            let finalAcademicYearId = academicYearId;
            if (!finalAcademicYearId) {
                const currentYear = await prisma.academicYear.findFirst({
                    where: { isCurrent: true }
                });
                finalAcademicYearId = currentYear?.id;
            }

            // Create student
            const student = await prisma.student.create({
                data: {
                    studentCode,
                    qrCode: `QR${studentCode}`,
                    saintName,
                    fullName,
                    birthDate: birthDate ? new Date(birthDate) : null,
                    phoneNumber,
                    parentPhone1,
                    parentPhone2,
                    address,
                    classId: parseInt(classId),
                    academicYearId: finalAcademicYearId ? parseInt(finalAcademicYearId) : null,
                    // Initialize score fields with default values
                    thursdayAttendanceCount: 0,
                    sundayAttendanceCount: 0,
                    attendanceAverage: 0,
                    study45Hk1: 0,
                    examHk1: 0,
                    study45Hk2: 0,
                    examHk2: 0,
                    studyAverage: 0,
                    finalAverage: 0
                },
                include: {
                    class: {
                        include: {
                            department: true
                        }
                    },
                    academicYear: true
                }
            });

            res.status(201).json(student);

        } catch (error) {
            console.error('Create student error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Update student - Updated to handle score updates
    async updateStudent(req, res) {
        try {
            const { id } = req.params;
            const updateData = { ...req.body };

            // Convert birthDate if provided
            if (updateData.birthDate) {
                updateData.birthDate = new Date(updateData.birthDate);
            }

            // Convert classId if provided
            if (updateData.classId) {
                updateData.classId = parseInt(updateData.classId);
            }

            // Convert academicYearId if provided
            if (updateData.academicYearId) {
                updateData.academicYearId = parseInt(updateData.academicYearId);
            }

            // Handle score updates separately
            const scoreFields = [
                'thursdayAttendanceCount', 'sundayAttendanceCount',
                'study45Hk1', 'examHk1', 'study45Hk2', 'examHk2'
            ];

            const scoreUpdates = {};
            let hasScoreUpdates = false;

            scoreFields.forEach(field => {
                if (updateData[field] !== undefined) {
                    scoreUpdates[field] = field.includes('Count') ?
                        parseInt(updateData[field]) : parseFloat(updateData[field]);
                    delete updateData[field]; // Remove from regular update
                    hasScoreUpdates = true;
                }
            });

            // Also remove calculated fields from regular update (they should be calculated)
            delete updateData.attendanceAverage;
            delete updateData.studyAverage;
            delete updateData.finalAverage;

            // Update basic student info first
            let student = await prisma.student.update({
                where: { id: parseInt(id) },
                data: updateData,
                include: {
                    class: {
                        include: {
                            department: true
                        }
                    },
                    academicYear: true
                }
            });

            // Update scores if any score fields were provided
            if (hasScoreUpdates) {
                student = await ScoreService.updateStudentScores(parseInt(id), scoreUpdates);
            }

            res.json(student);

        } catch (error) {
            console.error('Update student error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Delete student (soft delete)
    async deleteStudent(req, res) {
        try {
            const { id } = req.params;

            await prisma.student.update({
                where: { id: parseInt(id) },
                data: { isActive: false }
            });

            res.json({ message: 'Xóa học sinh thành công' });

        } catch (error) {
            console.error('Delete student error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // ✅ THÊM ENDPOINT ĐỂ KHÔI PHỤC STUDENT
    async restoreStudent(req, res) {
        try {
            const { id } = req.params;

            await prisma.student.update({
                where: { id: parseInt(id) },
                data: { isActive: true }
            });

            res.json({ message: 'Khôi phục học sinh thành công' });

        } catch (error) {
            console.error('Restore student error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Get students by class - Updated to include scores and isActive filter
    async getStudentsByClass(req, res) {
        try {
            const { classId } = req.params;
            const { includeScores = false, isActive } = req.query;

            const includeOptions = {
                class: {
                    include: {
                        department: true
                    }
                }
            };

            if (includeScores === 'true') {
                includeOptions.academicYear = {
                    select: { name: true, totalWeeks: true }
                };
            }

            // ✅ Apply isActive filter
            let whereClause = { classId: parseInt(classId) };
            if (isActive !== undefined) {
                whereClause.isActive = isActive === 'true' || isActive === true;
            } else {
                whereClause.isActive = true; // Default
            }

            const students = await prisma.student.findMany({
                where: whereClause,
                include: includeOptions,
                orderBy: { fullName: 'asc' }
            });

            res.json(students);

        } catch (error) {
            console.error('Get students by class error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Update student scores (dedicated endpoint)
    async updateStudentScores(req, res) {
        try {
            const { id } = req.params;
            const scoreData = req.body;

            const updatedStudent = await ScoreService.updateStudentScores(parseInt(id), scoreData);

            res.json({
                message: 'Cập nhật điểm thành công',
                student: updatedStudent
            });

        } catch (error) {
            console.error('Update student scores error:', error);
            res.status(500).json({ error: error.message || 'Lỗi server' });
        }
    },

    // Get student score history/details
    async getStudentScoreDetails(req, res) {
        try {
            const { id } = req.params;

            const student = await prisma.student.findUnique({
                where: { id: parseInt(id) },
                include: {
                    academicYear: true,
                    class: {
                        include: { department: true }
                    },
                    attendance: {
                        orderBy: { attendanceDate: 'desc' },
                        select: {
                            attendanceDate: true,
                            attendanceType: true,
                            isPresent: true,
                            note: true
                        }
                    }
                }
            });

            if (!student) {
                return res.status(404).json({ error: 'Học sinh không tồn tại' });
            }

            // Calculate detailed score breakdown
            const scoreDetails = {
                studentInfo: {
                    id: student.id,
                    studentCode: student.studentCode,
                    fullName: student.fullName,
                    saintName: student.saintName
                },
                academicYear: student.academicYear,
                attendanceDetails: {
                    thursdayCount: student.thursdayAttendanceCount,
                    sundayCount: student.sundayAttendanceCount,
                    totalWeeks: student.academicYear?.totalWeeks || 0,
                    attendanceAverage: parseFloat(student.attendanceAverage),
                    calculation: student.academicYear ? {
                        pointPerWeek: 10 / student.academicYear.totalWeeks,
                        thursdayScore: student.thursdayAttendanceCount * (10 / student.academicYear.totalWeeks),
                        sundayScore: student.sundayAttendanceCount * (10 / student.academicYear.totalWeeks),
                        weighted: {
                            thursday: (student.thursdayAttendanceCount * (10 / student.academicYear.totalWeeks)) * 0.4,
                            sunday: (student.sundayAttendanceCount * (10 / student.academicYear.totalWeeks)) * 0.6
                        }
                    } : null
                },
                studyDetails: {
                    study45Hk1: parseFloat(student.study45Hk1),
                    examHk1: parseFloat(student.examHk1),
                    study45Hk2: parseFloat(student.study45Hk2),
                    examHk2: parseFloat(student.examHk2),
                    studyAverage: parseFloat(student.studyAverage),
                    calculation: {
                        formula: '(45HK1 + 45HK2 + ThiHK1*2 + ThiHK2*2) / 6',
                        breakdown: {
                            study45Hk1: parseFloat(student.study45Hk1),
                            study45Hk2: parseFloat(student.study45Hk2),
                            examHk1Weighted: parseFloat(student.examHk1) * 2,
                            examHk2Weighted: parseFloat(student.examHk2) * 2,
                            total: parseFloat(student.study45Hk1) + parseFloat(student.study45Hk2) +
                                (parseFloat(student.examHk1) * 2) + (parseFloat(student.examHk2) * 2)
                        }
                    }
                },
                finalScore: {
                    finalAverage: parseFloat(student.finalAverage),
                    calculation: {
                        formula: 'StudyAverage * 0.6 + AttendanceAverage * 0.4',
                        breakdown: {
                            studyWeighted: parseFloat(student.studyAverage) * 0.6,
                            attendanceWeighted: parseFloat(student.attendanceAverage) * 0.4
                        }
                    }
                },
                recentAttendance: student.attendance.slice(0, 10)
            };

            res.json(scoreDetails);

        } catch (error) {
            console.error('Get student score details error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Bulk update scores for multiple students
    async bulkUpdateScores(req, res) {
        try {
            const { updates } = req.body; // Array of { studentId, scoreData }

            if (!Array.isArray(updates) || updates.length === 0) {
                return res.status(400).json({ error: 'Dữ liệu cập nhật không hợp lệ' });
            }

            const results = [];
            const errors = [];

            for (const update of updates) {
                try {
                    const { studentId, ...scoreData } = update;
                    const updatedStudent = await ScoreService.updateStudentScores(studentId, scoreData);
                    results.push({
                        studentId,
                        success: true,
                        student: updatedStudent
                    });
                } catch (error) {
                    errors.push({
                        studentId: update.studentId,
                        error: error.message
                    });
                }
            }

            res.json({
                message: `Cập nhật thành công ${results.length}/${updates.length} học sinh`,
                results,
                errors
            });

        } catch (error) {
            console.error('Bulk update scores error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    async fixClassScores(req, res) {
        try {
            const { classId } = req.params;
            const result = await checkUtils.fixClassScores(classId);
            res.json(result);
        } catch (error) {
            console.error('Fix class scores error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    }
};

const studentAvatarMethods = {
    // Upload avatar cho student
    async uploadAvatar(req, res) {
        try {
            const { id } = req.params;
            const studentId = parseInt(id);

            if (!req.file) {
                return res.status(400).json({ error: 'Vui lòng chọn file ảnh' });
            }

            // Lấy thông tin student hiện tại
            const currentStudent = await prisma.student.findUnique({
                where: { id: studentId },
                select: { 
                    avatarUrl: true, 
                    avatarPublicId: true,
                    classId: true
                }
            });

            if (!currentStudent) {
                return res.status(404).json({ error: 'Học sinh không tồn tại' });
            }

            // Check quyền: phân đoàn trưởng chỉ upload cho học sinh trong phân đoàn
            if (req.user.role === 'phan_doan_truong') {
                const studentClass = await prisma.class.findUnique({
                    where: { id: currentStudent.classId },
                    select: { departmentId: true }
                });

                if (studentClass.departmentId !== req.user.departmentId) {
                    return res.status(403).json({ error: 'Không có quyền thực hiện' });
                }
            }

            // Xóa avatar cũ nếu có
            if (currentStudent.avatarUrl) {
                await deleteAvatar(currentStudent.avatarUrl);
            }

            // Cập nhật avatar mới
            const updatedStudent = await prisma.student.update({
                where: { id: studentId },
                data: {
                    avatarUrl: req.file.path,
                    avatarPublicId: req.file.filename
                },
                select: {
                    id: true,
                    studentCode: true,
                    fullName: true,
                    avatarUrl: true
                }
            });

            res.json({
                message: 'Upload avatar thành công',
                student: updatedStudent
            });

        } catch (error) {
            console.error('Upload student avatar error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    },

    // Xóa avatar student
    async deleteAvatar(req, res) {
        try {
            const { id } = req.params;
            const studentId = parseInt(id);

            const student = await prisma.student.findUnique({
                where: { id: studentId },
                select: { 
                    avatarUrl: true, 
                    avatarPublicId: true,
                    classId: true
                }
            });

            if (!student) {
                return res.status(404).json({ error: 'Học sinh không tồn tại' });
            }

            // Check quyền
            if (req.user.role === 'phan_doan_truong') {
                const studentClass = await prisma.class.findUnique({
                    where: { id: student.classId },
                    select: { departmentId: true }
                });

                if (studentClass.departmentId !== req.user.departmentId) {
                    return res.status(403).json({ error: 'Không có quyền thực hiện' });
                }
            }

            if (!student.avatarUrl) {
                return res.status(400).json({ error: 'Học sinh chưa có avatar' });
            }

            // Xóa trên Cloudinary
            await deleteAvatar(student.avatarUrl);

            // Cập nhật database
            await prisma.student.update({
                where: { id: studentId },
                data: {
                    avatarUrl: null,
                    avatarPublicId: null
                }
            });

            res.json({ message: 'Xóa avatar thành công' });

        } catch (error) {
            console.error('Delete student avatar error:', error);
            res.status(500).json({ error: 'Lỗi server' });
        }
    }
};

// Merge vào studentController
Object.assign(studentController, studentAvatarMethods);

module.exports = studentController;