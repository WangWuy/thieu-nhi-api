const { PrismaClient } = require('@prisma/client');
const ScoreService = require('../services/scoreService');
const prisma = new PrismaClient();

const studentController = {
    // Get all students (with filters by role) - Updated to include isActive filter
    async getStudents(req, res) {
        try {
            const { role, departmentId, classId } = req.user;
            const {
                page = 1,
                limit = 20,
                search,
                classFilter,
                academicYearId,
                isActive,
                sortBy = 'firstName' // Thêm sortBy parameter
            } = req.query;

            let whereClause = {};

            // Apply isActive filter (dynamic)
            if (isActive !== undefined) {
                whereClause.isActive = isActive === 'true' || isActive === true;
            } else {
                whereClause.isActive = true;
            }

            // Apply role-based filters
            if (role === 'phan_doan_truong') {
                whereClause.class = { departmentId: departmentId };
            } else if (role === 'giao_ly_vien') {
                // Giáo viên có thể xem tất cả (theo yêu cầu)
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

            const skip = (page - 1) * limit;

            // Xây dựng orderBy dựa vào sortBy parameter
            let orderByClause;

            if (sortBy === 'firstName') {
                // Sort by firstName (tên) - cần dùng raw SQL hoặc computed field
                // Vì Prisma không support substring trong orderBy, ta sẽ fetch tất cả rồi sort trong memory
                // Hoặc dùng raw query

                // Cách 1: Dùng Prisma raw query
                const studentsRaw = await prisma.$queryRaw`
                    SELECT s.*, 
                           c.name as class_name,
                           d.display_name as department_display_name,
                           ay.name as academic_year_name,
                           ay.total_weeks as academic_year_total_weeks,
                           ay.is_current as academic_year_is_current,
                           TRIM(SUBSTRING(s.full_name FROM '[^ ]+$')) as first_name
                    FROM students s
                    LEFT JOIN classes c ON s.class_id = c.id
                    LEFT JOIN departments d ON c.department_id = d.id
                    LEFT JOIN academic_years ay ON s.academic_year_id = ay.id
                    WHERE s.is_active = ${whereClause.isActive}
                    ${classFilter ? `AND s.class_id = ${parseInt(classFilter)}` : ''}
                    ${search ? `AND (
                        s.full_name ILIKE '%${search}%' OR 
                        s.student_code ILIKE '%${search}%' OR 
                        s.saint_name ILIKE '%${search}%'
                    )` : ''}
                    ORDER BY TRIM(SUBSTRING(s.full_name FROM '[^ ]+$')) ASC
                    LIMIT ${parseInt(limit)} OFFSET ${skip}
                `;

                const totalRaw = await prisma.$queryRaw`
                    SELECT COUNT(*) as count
                    FROM students s
                    LEFT JOIN classes c ON s.class_id = c.id
                    WHERE s.is_active = ${whereClause.isActive}
                    ${classFilter ? `AND s.class_id = ${parseInt(classFilter)}` : ''}
                    ${search ? `AND (
                        s.full_name ILIKE '%${search}%' OR 
                        s.student_code ILIKE '%${search}%' OR 
                        s.saint_name ILIKE '%${search}%'
                    )` : ''}
                `;

                // Transform raw results to match expected format
                const students = studentsRaw.map(student => ({
                    id: student.id,
                    studentCode: student.student_code,
                    qrCode: student.qr_code,
                    saintName: student.saint_name,
                    fullName: student.full_name,
                    birthDate: student.birth_date,
                    phoneNumber: student.phone_number,
                    parentPhone1: student.parent_phone_1,
                    parentPhone2: student.parent_phone_2,
                    address: student.address,
                    classId: student.class_id,
                    academicYearId: student.academic_year_id,
                    thursdayAttendanceCount: student.thursday_attendance_count,
                    sundayAttendanceCount: student.sunday_attendance_count,
                    attendanceAverage: student.attendance_average,
                    study45Hk1: student.study_45_hk1,
                    examHk1: student.exam_hk1,
                    study45Hk2: student.study_45_hk2,
                    examHk2: student.exam_hk2,
                    studyAverage: student.study_average,
                    finalAverage: student.final_average,
                    isActive: student.is_active,
                    createdAt: student.created_at,
                    updatedAt: student.updated_at,
                    class: {
                        id: student.class_id,
                        name: student.class_name,
                        department: {
                            displayName: student.department_display_name
                        }
                    },
                    academicYear: student.academic_year_id ? {
                        id: student.academic_year_id,
                        name: student.academic_year_name,
                        totalWeeks: student.academic_year_total_weeks,
                        isCurrent: student.academic_year_is_current
                    } : null
                }));

                const total = parseInt(totalRaw[0].count);

                res.json({
                    students,
                    pagination: {
                        page: parseInt(page),
                        limit: parseInt(limit),
                        total,
                        pages: Math.ceil(total / limit)
                    }
                });
            } else {
                // Default sort (fullName)
                orderByClause = { fullName: 'asc' };

                const [students, total] = await Promise.all([
                    prisma.student.findMany({
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
                        },
                        skip,
                        take: parseInt(limit),
                        orderBy: orderByClause
                    }),
                    prisma.student.count({ where: whereClause })
                ]);

                res.json({
                    students,
                    pagination: {
                        page: parseInt(page),
                        limit: parseInt(limit),
                        total,
                        pages: Math.ceil(total / limit)
                    }
                });
            }

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
                    class: {
                        include: {
                            department: true
                        }
                    },
                    academicYear: true,
                    attendance: {
                        orderBy: { attendanceDate: 'desc' },
                        take: 10,
                        include: {
                            marker: {
                                select: { fullName: true }
                            }
                        }
                    }
                }
            });

            if (!student) {
                return res.status(404).json({ error: 'Học sinh không tồn tại' });
            }

            // Calculate additional score statistics
            const scoreStats = {
                attendanceProgress: {
                    thursday: {
                        attended: student.thursdayAttendanceCount,
                        total: student.academicYear?.totalWeeks || 0,
                        percentage: student.academicYear?.totalWeeks ?
                            Math.round((student.thursdayAttendanceCount / student.academicYear.totalWeeks) * 100) : 0
                    },
                    sunday: {
                        attended: student.sundayAttendanceCount,
                        total: student.academicYear?.totalWeeks || 0,
                        percentage: student.academicYear?.totalWeeks ?
                            Math.round((student.sundayAttendanceCount / student.academicYear.totalWeeks) * 100) : 0
                    }
                },
                scoreBreakdown: {
                    attendance: {
                        thursday: student.academicYear?.totalWeeks ?
                            (student.thursdayAttendanceCount * (10 / student.academicYear.totalWeeks)) : 0,
                        sunday: student.academicYear?.totalWeeks ?
                            (student.sundayAttendanceCount * (10 / student.academicYear.totalWeeks)) : 0,
                        average: parseFloat(student.attendanceAverage)
                    },
                    study: {
                        study45Hk1: parseFloat(student.study45Hk1),
                        examHk1: parseFloat(student.examHk1),
                        study45Hk2: parseFloat(student.study45Hk2),
                        examHk2: parseFloat(student.examHk2),
                        average: parseFloat(student.studyAverage)
                    },
                    final: parseFloat(student.finalAverage)
                }
            };

            res.json({ ...student, scoreStats });

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
    }
};

module.exports = studentController;