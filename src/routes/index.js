const express = require('express');
const router = express.Router();

// Import controllers
const authController = require('../controllers/authController');
const employeeController = require('../controllers/employeeController');
const attendanceController = require('../controllers/attendanceController');
const shiftController = require('../controllers/shiftController');
const leaveController = require('../controllers/leaveController');
const deviceController = require('../controllers/deviceController');
const departmentController = require('../controllers/departmentController');
const dashboardController = require('../controllers/dashboardController');
const reportController = require('../controllers/reportController');
const userController = require('../controllers/userController');
// const backupController = require('../controllers/backupController'); // TODO: Implement backup controller
const alertController = require('../controllers/alertController');

// Import middleware
const { verifyToken, requireRole, requireAdmin } = require('../middleware/auth');

// Import Cloudinary config
const { uploadEmployeeAvatar, uploadFacePhoto, uploadAttendancePhoto } = require('../config/cloudinary');

// Import rate limiters
const {
  authLimiter,
  apiLimiter,
  strictLimiter,
  passwordResetLimiter,
  createAccountLimiter,
  attendanceLimiter
} = require('../middleware/rateLimiter');

// ==================== AUTH ROUTES ====================
router.post('/auth/login', authLimiter, authController.login);
router.post('/auth/logout', apiLimiter, verifyToken, authController.logout);
router.get('/auth/me', apiLimiter, verifyToken, authController.me);
router.post('/auth/change-password', passwordResetLimiter, verifyToken, authController.changePassword);

// ==================== EMPLOYEE ROUTES ====================
router.get('/employees', apiLimiter, verifyToken, employeeController.getEmployees);
router.get('/employees/profile', apiLimiter, verifyToken, employeeController.getEmployeeProfile);
router.put('/employees/profile', apiLimiter, verifyToken, employeeController.updateEmployeeProfile);
router.get('/employees/:id', apiLimiter, verifyToken, employeeController.getEmployeeById);
router.post('/employees', createAccountLimiter, verifyToken, requireRole(['admin', 'hr_manager']), employeeController.createEmployee);
router.put('/employees/:id', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), employeeController.updateEmployee);
router.delete('/employees/:id', strictLimiter, verifyToken, requireAdmin, employeeController.deleteEmployee);
router.post('/employees/:id/restore', strictLimiter, verifyToken, requireAdmin, employeeController.restoreEmployee);

// Employee avatar routes
router.post('/employees/:id/avatar', apiLimiter, verifyToken, uploadEmployeeAvatar.single('avatar'), employeeController.uploadAvatar);
router.delete('/employees/:id/avatar', apiLimiter, verifyToken, employeeController.deleteAvatar);

// Employee face registration routes
router.post('/employees/:id/face/register', apiLimiter, verifyToken, uploadFacePhoto.single('facePhoto'), employeeController.registerFace);
router.put('/employees/:id/face/update', apiLimiter, verifyToken, uploadFacePhoto.single('facePhoto'), employeeController.updateFace);
router.delete('/employees/:id/face', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), employeeController.deleteFaceData);
router.get('/employees/:id/face/status', apiLimiter, verifyToken, employeeController.getFaceStatus);

// ==================== ATTENDANCE ROUTES ====================
router.post('/attendance/check-in', attendanceLimiter, verifyToken, uploadAttendancePhoto.single('photo'), attendanceController.checkIn);
router.post('/attendance/check-out', attendanceLimiter, verifyToken, uploadAttendancePhoto.single('photo'), attendanceController.checkOut);
router.get('/attendance/today', apiLimiter, verifyToken, attendanceController.getTodayAttendance);
router.get('/attendance/employee/:id', apiLimiter, verifyToken, attendanceController.getAttendanceByEmployee);
router.get('/attendance/department/:id', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager', 'department_manager']), attendanceController.getAttendanceByDepartment);
router.get('/attendance/stats', apiLimiter, verifyToken, attendanceController.getAttendanceStats);
router.get('/attendance/:id/photos', apiLimiter, verifyToken, attendanceController.getVerificationPhotos);
router.post('/attendance/manual', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), attendanceController.markManualAttendance);
router.put('/attendance/:id', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), attendanceController.updateAttendance);
router.delete('/attendance/:id', strictLimiter, verifyToken, requireAdmin, attendanceController.deleteAttendance);

// ==================== SHIFT ROUTES ====================
router.get('/shifts', apiLimiter, verifyToken, shiftController.getShifts);
router.get('/shifts/employee/:employeeId', apiLimiter, verifyToken, shiftController.getEmployeeShifts);
router.get('/shifts/:id', apiLimiter, verifyToken, shiftController.getShiftById);
router.post('/shifts', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), shiftController.createShift);
router.put('/shifts/:id', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), shiftController.updateShift);
router.delete('/shifts/:id', strictLimiter, verifyToken, requireAdmin, shiftController.deleteShift);
router.post('/shifts/:id/assign', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), shiftController.assignEmployeeToShift);
router.delete('/shifts/:id/unassign/:employeeId', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), shiftController.removeEmployeeFromShift);

// ==================== LEAVE ROUTES ====================
router.get('/leaves', apiLimiter, verifyToken, leaveController.getLeaveRequests);
router.get('/leaves/stats', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), leaveController.getLeaveStats);
router.get('/leaves/:id', apiLimiter, verifyToken, leaveController.getLeaveById);
router.post('/leaves', apiLimiter, verifyToken, leaveController.requestLeave);
router.put('/leaves/:id/approve', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager', 'department_manager']), leaveController.approveLeave);
router.put('/leaves/:id/reject', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager', 'department_manager']), leaveController.rejectLeave);
router.delete('/leaves/:id', apiLimiter, verifyToken, leaveController.cancelLeave);
router.get('/employees/:id/leaves', apiLimiter, verifyToken, leaveController.getEmployeeLeaves);
router.get('/employees/:id/leave-balance', apiLimiter, verifyToken, leaveController.getLeaveBalance);

// ==================== DEVICE ROUTES ====================
router.get('/devices', apiLimiter, verifyToken, deviceController.getDevices);
router.get('/devices/:id', apiLimiter, verifyToken, deviceController.getDeviceById);
router.get('/devices/:id/history', apiLimiter, verifyToken, deviceController.getDeviceHistory);
router.post('/devices', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), deviceController.createDevice);
router.put('/devices/:id', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), deviceController.updateDevice);
router.delete('/devices/:id', strictLimiter, verifyToken, requireAdmin, deviceController.deleteDevice);
router.post('/devices/:id/sync', apiLimiter, verifyToken, deviceController.syncDevice);
router.post('/devices/:id/assign', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), deviceController.assignDevice);
router.post('/devices/:id/return', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), deviceController.returnDevice);

// ==================== DEPARTMENT ROUTES ====================
router.get('/departments', apiLimiter, verifyToken, departmentController.getDepartments);
router.get('/departments/hierarchy', apiLimiter, verifyToken, departmentController.getDepartmentHierarchy);
router.get('/departments/:id', apiLimiter, verifyToken, departmentController.getDepartmentById);
router.get('/departments/:id/employees', apiLimiter, verifyToken, departmentController.getDepartmentEmployees);
router.get('/departments/:id/stats', apiLimiter, verifyToken, departmentController.getDepartmentStats);
router.post('/departments', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), departmentController.createDepartment);
router.put('/departments/:id', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), departmentController.updateDepartment);
router.delete('/departments/:id', strictLimiter, verifyToken, requireAdmin, departmentController.deleteDepartment);

// ==================== DASHBOARD ROUTES ====================
router.get('/dashboard/overview', apiLimiter, verifyToken, dashboardController.getOverviewStats);
router.get('/dashboard/attendance-summary', apiLimiter, verifyToken, dashboardController.getAttendanceSummary);
router.get('/dashboard/department-stats', apiLimiter, verifyToken, dashboardController.getDepartmentStats);
router.get('/dashboard/leave-stats', apiLimiter, verifyToken, dashboardController.getLeaveStats);
router.get('/dashboard/recent-activities', apiLimiter, verifyToken, dashboardController.getRecentActivities);
router.get('/dashboard/upcoming-birthdays', apiLimiter, verifyToken, dashboardController.getUpcomingBirthdays);
router.get('/dashboard/contract-expirations', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), dashboardController.getContractExpirations);

// ==================== REPORT ROUTES ====================
router.get('/reports/attendance/monthly', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), reportController.getMonthlyAttendanceReport);
router.get('/reports/attendance/department', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager', 'department_manager']), reportController.getDepartmentAttendanceReport);
router.get('/reports/attendance/employee/:id', apiLimiter, verifyToken, reportController.getEmployeeAttendanceReport);
router.get('/reports/leave', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), reportController.getLeaveReport);
router.get('/reports/overtime', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), reportController.getOvertimeReport);
router.post('/reports/export', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), reportController.exportReport);

// ==================== USER ROUTES (Keep for account management) ====================
router.get('/users', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), userController.getUsers);
router.get('/users/:id', apiLimiter, verifyToken, userController.getUserById);
router.post('/users', createAccountLimiter, verifyToken, requireAdmin, userController.createUser);
router.put('/users/:id', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), userController.updateUser);
router.put('/users/:id/deactivate', strictLimiter, verifyToken, requireAdmin, userController.deactivateUser);
router.put('/users/:id/activate', strictLimiter, verifyToken, requireAdmin, userController.activateUser);
router.put('/users/:id/reset-password', passwordResetLimiter, verifyToken, requireAdmin, userController.resetPassword);

// ==================== BACKUP ROUTES ====================
// TODO: Implement backup controller methods
// router.post('/backup/create', strictLimiter, verifyToken, requireAdmin, backupController.createBackup);
// router.get('/backup/list', apiLimiter, verifyToken, requireAdmin, backupController.getBackups);
// router.post('/backup/restore', strictLimiter, verifyToken, requireAdmin, backupController.restoreBackup);

// ==================== ALERT ROUTES ====================
router.get('/alerts', apiLimiter, verifyToken, alertController.getAlerts);
router.post('/alerts', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), alertController.createAlert);
router.post('/alerts/:id/read', apiLimiter, verifyToken, alertController.markRead);
router.post('/alerts/:id/resolved', apiLimiter, verifyToken, requireRole(['admin', 'hr_manager']), alertController.markResolved);
router.delete('/alerts/:id', strictLimiter, verifyToken, requireAdmin, alertController.deleteAlert);

// ==================== HEALTH CHECK ====================
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'HR Management System API is running',
    timestamp: new Date().toISOString()
  });
});

// ==================== 404 Handler ====================
router.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'API endpoint not found'
  });
});

module.exports = router;
