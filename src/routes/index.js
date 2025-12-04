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
const importAttendanceController = require('../controllers/importAttendanceController');
const pendingUserController = require('../controllers/pendingUserController');
const backupController = require('../controllers/backupController');
const alertController = require('../controllers/alertController');
const { uploadUserAvatar, uploadStudentAvatar } = require('../config/cloudinary');

const { verifyToken, requireRole, requireAdmin } = require('../middleware/auth');

// Import validation rules
const {
    authValidation,
    userValidation,
    pendingUserValidation,
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

router.post('/classes/:classId/fix-scores',
    strictLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    studentController.fixClassScores
);

// ==================== AUTH ROUTES ====================
router.post('/auth/login',
    authLimiter,
    authValidation.login,
    authController.login
);

router.post('/auth/logout',
    apiLimiter,
    verifyToken,
    authController.logout
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

router.put('/users/:id/activate',
    strictLimiter,
    verifyToken,
    requireAdmin,
    userController.activateUser
);

router.put('/users/:id/toggle-status',
    strictLimiter,
    verifyToken,
    requireAdmin,
    userValidation.toggleStatus,
    userController.toggleUserStatus
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

// USER AVATAR ROUTES
router.post('/users/:id/avatar',
    apiLimiter,
    verifyToken,
    uploadUserAvatar.single('avatar'),
    userController.uploadAvatar
);

router.delete('/users/:id/avatar',
    apiLimiter,
    verifyToken,
    userController.deleteAvatar
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

// STUDENT AVATAR ROUTES
router.post('/students/:id/avatar',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    uploadStudentAvatar.single('avatar'),
    studentController.uploadAvatar
);

router.delete('/students/:id/avatar',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    studentController.deleteAvatar
);

// ==================== ATTENDANCE ROUTES ====================
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

router.post('/attendance/undo',
    attendanceLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    attendanceValidation.universal, // Có thể dùng lại validation
    attendanceController.undoAttendance
);

router.post('/import/attendance/mark-absent',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    importAttendanceController.markAbsentRemaining
);

router.post('/import/attendance',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    importAttendanceController.uploadExcel,
    importAttendanceController.importAttendance
);

router.post('/import/attendance/preview',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    importAttendanceController.uploadExcel,
    importAttendanceController.previewAttendance
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

router.get('/dashboard/weekly-attendance-trend',
    apiLimiter,
    verifyToken,
    dashboardController.getWeeklyAttendanceTrend
);

router.get('/dashboard/department-classes-attendance',
    apiLimiter,
    verifyToken,
    dashboardController.getDepartmentClassesAttendance
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
    // requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    queryValidation.dateRange,
    reportsController.getAttendanceReport
);

router.get('/reports/student-scores',
    apiLimiter,
    verifyToken,
    // requireRole(['ban_dieu_hanh', 'phan_doan_truong']),
    reportsController.getStudentScores
);

// ==================== PENDING USER ROUTES ====================
// Đăng ký tài khoản từ mobile (public - không cần auth)
router.post('/register',
    createAccountLimiter,
    pendingUserValidation.register,
    pendingUserController.registerUser
);

// Lấy danh sách pending users (chỉ admin)
router.get('/pending-users',
    apiLimiter,
    verifyToken,
    requireAdmin,
    queryValidation.pagination,
    queryValidation.search,
    pendingUserController.getPendingUsers
);

// Lấy chi tiết pending user (chỉ admin)
router.get('/pending-users/:id',
    apiLimiter,
    verifyToken,
    requireAdmin,
    pendingUserController.getPendingUserById
);

// Phê duyệt đăng ký (chỉ admin)
router.put('/pending-users/:id/approve',
    strictLimiter,
    verifyToken,
    requireAdmin,
    pendingUserValidation.approve,
    pendingUserController.approveUser
);

// Từ chối đăng ký (chỉ admin)
router.put('/pending-users/:id/reject',
    strictLimiter,
    verifyToken,
    requireAdmin,
    pendingUserValidation.reject,
    pendingUserController.rejectUser
);

// Xóa pending user (chỉ admin)
router.delete('/pending-users/:id',
    strictLimiter,
    verifyToken,
    requireAdmin,
    pendingUserController.deletePendingUser
);

// Thống kê pending users (chỉ admin)
router.get('/pending-users/stats',
    apiLimiter,
    verifyToken,
    requireAdmin,
    pendingUserController.getPendingUserStats
);

// ==================== BACKUP ROUTES ====================
router.get('/backup/excel',
    strictLimiter,
    verifyToken,
    requireAdmin,
    backupController.exportExcel
);

router.get('/backup/dump',
    strictLimiter,
    verifyToken,
    requireAdmin,
    backupController.exportDump
);

// ==================== ALERT ROUTES ====================
router.get('/alerts',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    alertController.getAlerts
);

router.post('/alerts',
    strictLimiter,
    verifyToken,
    requireAdmin,
    alertController.createAlert
);

router.put('/alerts/:id/read',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    alertController.markRead
);

router.put('/alerts/:id/resolve',
    apiLimiter,
    verifyToken,
    requireRole(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien']),
    alertController.markResolved
);

router.delete('/alerts/:id',
    strictLimiter,
    verifyToken,
    requireAdmin,
    alertController.deleteAlert
);

// Evaluate rules to generate alerts from current data
router.post('/alerts/evaluate',
    strictLimiter,
    verifyToken,
    requireAdmin,
    alertController.evaluateRules
);

// Alert Rules (admin)
router.get('/alert-rules',
    apiLimiter,
    verifyToken,
    requireAdmin,
    alertController.getRules
);

router.post('/alert-rules',
    strictLimiter,
    verifyToken,
    requireAdmin,
    alertController.createRule
);

router.put('/alert-rules/:id',
    strictLimiter,
    verifyToken,
    requireAdmin,
    alertController.updateRule
);

router.put('/alert-rules/:id/toggle',
    strictLimiter,
    verifyToken,
    requireAdmin,
    alertController.toggleRule
);

router.delete('/alert-rules/:id',
    strictLimiter,
    verifyToken,
    requireAdmin,
    alertController.deleteRule
);

module.exports = router;
