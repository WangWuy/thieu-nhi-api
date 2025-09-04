const express = require('express');
const authController = require('../controllers/authController');
const studentController = require('../controllers/studentController');
const attendanceController = require('../controllers/attendanceController');
const classController = require('../controllers/classController');
const departmentController = require('../controllers/departmentController');
const userController = require('../controllers/userController');
const importController = require('../controllers/importController');
const dashboardController = require('../controllers/dashboardController');
const academicYearController = require('../controllers/academicYearController');
const ScoreService = require('../services/scoreService');
const reportsController = require('../controllers/reportsController');
const importUserController = require('../controllers/importUserController');

const { verifyToken, requireRole, requireAdmin } = require('../middleware/auth');

// Import validation rules
const {
    authValidation,
    userValidation,
    studentValidation,
    classValidation,
    attendanceValidation,
    queryValidation
} = require('../middleware/validation');

// Import rate limiters
const {
    authLimiter,
    apiLimiter,
    strictLimiter,
    passwordResetLimiter,
    createAccountLimiter,
    attendanceLimiter,
    searchLimiter
} = require('../middleware/rateLimiter');

const router = express.Router();

// ==================== AUTH ROUTES ====================
router.post('/auth/login',
    authLimiter,
    authValidation.login,
    authController.login
);

router.get('/auth/me',
    apiLimiter,
    verifyToken,
    authController.me
);

router.post('/auth/change-password',
    passwordResetLimiter,
    verifyToken,
    authValidation.changePassword,
    authController.changePassword
);

// ==================== USER ROUTES ====================
router.get('/users',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    queryValidation.pagination,
    queryValidation.search,
    userController.getUsers
);

router.get('/users/:id',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    userController.getUserById
);

router.post('/users',
    createAccountLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    userValidation.create,
    userController.createUser
);

router.put('/users/:id',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    userValidation.update,
    userController.updateUser
);

router.post('/users/:id/reset-password',
    strictLimiter,
    verifyToken,
    requireAdmin,
    userValidation.resetPassword,
    userController.resetPassword
);

router.put('/users/:id/deactivate',
    strictLimiter,
    verifyToken,
    requireAdmin,
    userController.deactivateUser
);

router.put('/students/:id/restore',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    studentController.restoreStudent
);

router.get('/teachers',
    apiLimiter,
    verifyToken,
    queryValidation.search,
    userController.getTeachers
);



// ==================== DEPARTMENT ROUTES ====================
router.get('/departments',
    apiLimiter,
    verifyToken,
    departmentController.getDepartments
);

router.get('/departments/stats',
    apiLimiter,
    verifyToken,
    departmentController.getDepartmentStats
);

// ==================== CLASS ROUTES ====================
router.get('/classes',
    apiLimiter,
    verifyToken,
    queryValidation.search,
    classController.getClasses
);

router.get('/classes/:id',
    apiLimiter,
    verifyToken,
    classController.getClassById
);

router.post('/classes',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    classValidation.create,
    classController.createClass
);

router.put('/classes/:id',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    classValidation.update,
    classController.updateClass
);

router.delete('/classes/:id',
    strictLimiter,
    verifyToken,
    requireAdmin,
    classController.deleteClass
);

router.post('/classes/:classId/teachers',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    classValidation.assignTeacher,
    classController.assignTeacher
);

router.delete('/classes/:classId/teachers/:userId',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    classController.removeTeacher
);

// ==================== STUDENT ROUTES ====================
router.get('/students',
    searchLimiter, // Có thể search nhiều nên dùng search limiter
    verifyToken,
    queryValidation.pagination,
    queryValidation.search,
    studentController.getStudents
);

router.get('/students/:id',
    apiLimiter,
    verifyToken,
    studentController.getStudentById
);

router.post('/students',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    studentValidation.create,
    studentController.createStudent
);

router.put('/students/:id',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    studentValidation.update,
    studentController.updateStudent
);

router.delete('/students/:id',
    strictLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    studentController.deleteStudent
);

router.get('/classes/:classId/students',
    apiLimiter,
    verifyToken,
    studentController.getStudentsByClass
);


// ==================== ATTENDANCE ROUTES ====================
// // LEGACY: Single attendance (not used)
// router.post('/attendance',
//     attendanceLimiter,
//     verifyToken,
//     requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
//     attendanceValidation.mark,
//     attendanceController.markAttendance
// );

router.get('/classes/:classId/attendance',
    apiLimiter,
    verifyToken,
    attendanceValidation.getByClass,
    attendanceController.getAttendanceByClass
);

router.get('/attendance/stats',
    apiLimiter,
    verifyToken,
    queryValidation.dateRange,
    attendanceController.getAttendanceStats
);

// // LEGACY: Batch attendance (not used)  
// router.post('/classes/:classId/attendance/batch',
//     attendanceLimiter, // Batch operations cần limit chặt
//     verifyToken,
//     requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
//     attendanceValidation.batchMark,
//     attendanceController.batchMarkAttendance
// );

router.get('/attendance/trend',
    apiLimiter,
    verifyToken,
    queryValidation.dateRange,
    attendanceController.getAttendanceTrend
);

router.post('/attendance/universal',
    attendanceLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    attendanceValidation.universal,
    attendanceController.universalAttendance
);

router.get('/students/:id/attendance/history',
    apiLimiter,
    verifyToken,
    attendanceValidation.getStudentHistory,
    attendanceController.getStudentAttendanceHistory
);

router.get('/students/:id/attendance/stats',
    apiLimiter,
    verifyToken,
    attendanceValidation.getStudentStats,
    attendanceController.getStudentAttendanceStats
);

// ✅ Get today's attendance status for multiple students
router.post('/attendance/today-status',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    attendanceValidation.todayStatus, // ✅ Use validation from file
    attendanceController.getTodayAttendanceStatus
);

// ==================== DASHBOARD ROUTES ====================
router.get('/dashboard/stats',
    apiLimiter,
    verifyToken,
    dashboardController.getDashboardStats
);

router.get('/dashboard/quick-counts',
    apiLimiter,
    verifyToken,
    dashboardController.getQuickCounts
);

// ==================== IMPORT/EXPORT ROUTES ====================
// Import students (supports both Excel file and JSON)
router.post('/import/students',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    importController.uploadExcel,
    importController.importStudents
);

// Import users (supports both Excel file and JSON)
router.post('/import/users',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh']),
    importUserController.uploadExcel,
    importUserController.importUsers
);

router.post('/import/validate',
    apiLimiter,
    verifyToken,
    // importController.validateImportData
);

router.get('/import/stats',
    apiLimiter,
    verifyToken,
    // importController.getImportStats
);

// ==================== ACADEMIC YEAR ROUTES ====================
router.get('/academic-years',
    apiLimiter,
    verifyToken,
    academicYearController.getAcademicYears
);

router.get('/academic-years/current',
    apiLimiter,
    verifyToken,
    academicYearController.getCurrentAcademicYear
);

router.post('/academic-years',
    apiLimiter,
    verifyToken,
    requireAdmin,
    // academicYearValidation.create, // Tạo validation sau
    academicYearController.createAcademicYear
);

router.put('/academic-years/:id',
    apiLimiter,
    verifyToken,
    requireAdmin,
    // academicYearValidation.update,
    academicYearController.updateAcademicYear
);

router.post('/academic-years/:id/set-current',
    strictLimiter,
    verifyToken,
    requireAdmin,
    academicYearController.setCurrentAcademicYear
);

router.delete('/academic-years/:id',
    strictLimiter,
    verifyToken,
    requireAdmin,
    academicYearController.deleteAcademicYear
);

router.get('/academic-years/:id/stats',
    apiLimiter,
    verifyToken,
    academicYearController.getAcademicYearStats
);

// ==================== SCORE MANAGEMENT ROUTES ====================
router.put('/students/:id/scores',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    // scoreValidation.update, // Tạo validation sau
    async (req, res) => {
        try {
            const { id } = req.params;
            const updatedStudent = await ScoreService.updateStudentScores(parseInt(id), req.body);
            res.json(updatedStudent);
        } catch (error) {
            console.error('Update scores error:', error);
            res.status(500).json({ error: error.message });
        }
    }
);

router.post('/academic-years/:id/recalculate-scores',
    strictLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    async (req, res) => {
        try {
            const { id } = req.params;
            const result = await ScoreService.recalculateAcademicYearScores(parseInt(id));
            res.json(result);
        } catch (error) {
            console.error('Recalculate scores error:', error);
            res.status(500).json({ error: error.message });
        }
    }
);

router.get('/classes/:id/score-stats',
    apiLimiter,
    verifyToken,
    async (req, res) => {
        try {
            const { id } = req.params;
            const stats = await ScoreService.getClassScoreStats(parseInt(id));
            res.json(stats);
        } catch (error) {
            console.error('Get class score stats error:', error);
            res.status(500).json({ error: error.message });
        }
    }
);

router.get('/students/:id/score-details',
    apiLimiter,
    verifyToken,
    studentController.getStudentScoreDetails
);

router.post('/students/bulk-update-scores',
    strictLimiter, // Bulk operations need stricter limits
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    studentController.bulkUpdateScores
);

// ==================== REPORTS ROUTES ====================
router.get('/reports/attendance',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    queryValidation.dateRange,
    reportsController.getAttendanceReport
);

router.get('/reports/grade-distribution',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    reportsController.getGradeDistribution
);

router.get('/reports/student-ranking',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    reportsController.getStudentRanking
);

router.get('/reports/overview',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    reportsController.getOverviewReport
);

router.get('/reports/export',
    strictLimiter, // Export operations should be limited
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    reportsController.exportReport
);

// ==================== TEST & HEALTH ROUTES ====================
router.get('/test', (req, res) => {
    res.json({
        message: 'API routes working!',
        version: '1.0.0',
        features: [
            '✅ Input Validation (express-validator)',
            '✅ Rate Limiting (express-rate-limit)',
            '✅ Security Headers (helmet)',
            '✅ Error Handling',
            '✅ Request Logging'
        ],
        endpoints: {
            auth: [
                'POST /api/auth/login',
                'GET /api/auth/me',
                'POST /api/auth/change-password'
            ],
            users: [
                'GET /api/users',
                'POST /api/users',
                'PUT /api/users/:id',
                'GET /api/teachers'
            ],
            classes: [
                'GET /api/classes',
                'POST /api/classes',
                'GET /api/classes/:id'
            ],
            students: [
                'GET /api/students',
                'POST /api/students',
                'GET /api/classes/:classId/students'
            ],
            attendance: [
                'POST /api/attendance',
                'GET /api/classes/:classId/attendance',
                'POST /api/classes/:classId/attendance/batch'
            ]
        },
        rateLimits: {
            general: '1000 requests per 15 minutes',
            auth: '5 failed attempts per 15 minutes',
            api: '100 requests per minute',
            strict: '10 requests per hour',
            attendance: '50 requests per 5 minutes'
        }
    });
});

module.exports = router;