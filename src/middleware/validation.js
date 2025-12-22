const { body, param, query, validationResult } = require('express-validator');

/**
 * Validation Middleware for HR Management System
 * Uses express-validator for request validation
 */

/**
 * Handle validation errors
 */
const handleValidationErrors = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({
            error: 'Validation Error',
            message: 'Dữ liệu không hợp lệ',
            errors: errors.array().map(err => ({
                field: err.path || err.param,
                message: err.msg,
                value: err.value
            }))
        });
    }
    next();
};

// ============================================
// Employee Validation
// ============================================

const employeeValidation = {
    create: [
        body('firstName')
            .trim()
            .notEmpty().withMessage('Tên không được để trống')
            .isLength({ min: 2, max: 50 }).withMessage('Tên phải từ 2-50 ký tự'),

        body('lastName')
            .trim()
            .notEmpty().withMessage('Họ không được để trống')
            .isLength({ min: 2, max: 50 }).withMessage('Họ phải từ 2-50 ký tự'),

        body('email')
            .trim()
            .notEmpty().withMessage('Email không được để trống')
            .isEmail().withMessage('Email không hợp lệ')
            .normalizeEmail(),

        body('phone')
            .optional()
            .trim()
            .matches(/^0\d{9,10}$/).withMessage('Số điện thoại không hợp lệ (phải bắt đầu bằng 0 và có 10-11 số)'),

        body('dateOfBirth')
            .optional()
            .isISO8601().withMessage('Ngày sinh không hợp lệ')
            .custom((value) => {
                const age = new Date().getFullYear() - new Date(value).getFullYear();
                if (age < 18 || age > 100) {
                    throw new Error('Tuổi phải từ 18-100');
                }
                return true;
            }),

        body('gender')
            .optional()
            .isIn(['MALE', 'FEMALE', 'OTHER']).withMessage('Giới tính không hợp lệ'),

        body('departmentId')
            .notEmpty().withMessage('Phòng ban không được để trống')
            .isString().withMessage('Department ID phải là chuỗi'),

        body('position')
            .optional()
            .trim()
            .isLength({ max: 100 }).withMessage('Chức vụ không quá 100 ký tự'),

        body('hireDate')
            .notEmpty().withMessage('Ngày vào làm không được để trống')
            .isISO8601().withMessage('Ngày vào làm không hợp lệ'),

        body('contractType')
            .notEmpty().withMessage('Loại hợp đồng không được để trống')
            .isIn(['FULLTIME', 'PARTTIME', 'CONTRACT', 'INTERNSHIP']).withMessage('Loại hợp đồng không hợp lệ'),

        body('contractEndDate')
            .optional()
            .isISO8601().withMessage('Ngày kết thúc hợp đồng không hợp lệ'),

        body('salary')
            .optional()
            .isFloat({ min: 0 }).withMessage('Lương phải là số dương'),

        body('managerId')
            .optional()
            .isString().withMessage('Manager ID phải là chuỗi'),

        handleValidationErrors
    ],

    update: [
        param('id')
            .notEmpty().withMessage('Employee ID không được để trống'),

        body('firstName')
            .optional()
            .trim()
            .isLength({ min: 2, max: 50 }).withMessage('Tên phải từ 2-50 ký tự'),

        body('lastName')
            .optional()
            .trim()
            .isLength({ min: 2, max: 50 }).withMessage('Họ phải từ 2-50 ký tự'),

        body('email')
            .optional()
            .trim()
            .isEmail().withMessage('Email không hợp lệ')
            .normalizeEmail(),

        body('phone')
            .optional()
            .trim()
            .matches(/^0\d{9,10}$/).withMessage('Số điện thoại không hợp lệ'),

        body('dateOfBirth')
            .optional()
            .isISO8601().withMessage('Ngày sinh không hợp lệ'),

        body('gender')
            .optional()
            .isIn(['MALE', 'FEMALE', 'OTHER']).withMessage('Giới tính không hợp lệ'),

        body('position')
            .optional()
            .trim()
            .isLength({ max: 100 }).withMessage('Chức vụ không quá 100 ký tự'),

        body('salary')
            .optional()
            .isFloat({ min: 0 }).withMessage('Lương phải là số dương'),

        body('status')
            .optional()
            .isIn(['ACTIVE', 'ON_LEAVE', 'TERMINATED']).withMessage('Trạng thái không hợp lệ'),

        handleValidationErrors
    ]
};

// ============================================
// Attendance Validation
// ============================================

const attendanceValidation = {
    checkIn: [
        body('latitude')
            .notEmpty().withMessage('Latitude không được để trống')
            .isFloat({ min: -90, max: 90 }).withMessage('Latitude không hợp lệ (-90 đến 90)'),

        body('longitude')
            .notEmpty().withMessage('Longitude không được để trống')
            .isFloat({ min: -180, max: 180 }).withMessage('Longitude không hợp lệ (-180 đến 180)'),

        body('verificationPhoto')
            .optional()
            .isString().withMessage('Verification photo phải là chuỗi'),

        handleValidationErrors
    ],

    checkOut: [
        param('id')
            .notEmpty().withMessage('Attendance ID không được để trống'),

        body('latitude')
            .notEmpty().withMessage('Latitude không được để trống')
            .isFloat({ min: -90, max: 90 }).withMessage('Latitude không hợp lệ'),

        body('longitude')
            .notEmpty().withMessage('Longitude không được để trống')
            .isFloat({ min: -180, max: 180 }).withMessage('Longitude không hợp lệ'),

        body('verificationPhoto')
            .optional()
            .isString().withMessage('Verification photo phải là chuỗi'),

        handleValidationErrors
    ],

    getByDateRange: [
        query('startDate')
            .notEmpty().withMessage('Start date không được để trống')
            .isISO8601().withMessage('Start date không hợp lệ'),

        query('endDate')
            .notEmpty().withMessage('End date không được để trống')
            .isISO8601().withMessage('End date không hợp lệ')
            .custom((endDate, { req }) => {
                if (new Date(endDate) < new Date(req.query.startDate)) {
                    throw new Error('End date phải sau start date');
                }
                return true;
            }),

        handleValidationErrors
    ]
};

// ============================================
// Leave Validation
// ============================================

const leaveValidation = {
    request: [
        body('leaveType')
            .notEmpty().withMessage('Loại nghỉ phép không được để trống')
            .isIn(['ANNUAL', 'SICK', 'UNPAID', 'MATERNITY', 'PATERNITY']).withMessage('Loại nghỉ phép không hợp lệ'),

        body('startDate')
            .notEmpty().withMessage('Ngày bắt đầu không được để trống')
            .isISO8601().withMessage('Ngày bắt đầu không hợp lệ')
            .custom((value) => {
                const startDate = new Date(value);
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                if (startDate < today) {
                    throw new Error('Ngày bắt đầu không được trong quá khứ');
                }
                return true;
            }),

        body('endDate')
            .notEmpty().withMessage('Ngày kết thúc không được để trống')
            .isISO8601().withMessage('Ngày kết thúc không hợp lệ')
            .custom((endDate, { req }) => {
                if (new Date(endDate) < new Date(req.body.startDate)) {
                    throw new Error('Ngày kết thúc phải sau ngày bắt đầu');
                }
                return true;
            }),

        body('reason')
            .notEmpty().withMessage('Lý do không được để trống')
            .trim()
            .isLength({ min: 10, max: 500 }).withMessage('Lý do phải từ 10-500 ký tự'),

        body('notes')
            .optional()
            .trim()
            .isLength({ max: 1000 }).withMessage('Ghi chú không quá 1000 ký tự'),

        handleValidationErrors
    ],

    approve: [
        param('id')
            .notEmpty().withMessage('Leave ID không được để trống'),

        body('status')
            .notEmpty().withMessage('Trạng thái không được để trống')
            .isIn(['APPROVED', 'REJECTED']).withMessage('Trạng thái không hợp lệ'),

        body('reviewerNotes')
            .optional()
            .trim()
            .isLength({ max: 500 }).withMessage('Ghi chú không quá 500 ký tự'),

        handleValidationErrors
    ]
};

// ============================================
// Shift Validation
// ============================================

const shiftValidation = {
    create: [
        body('name')
            .notEmpty().withMessage('Tên ca không được để trống')
            .trim()
            .isLength({ min: 2, max: 100 }).withMessage('Tên ca phải từ 2-100 ký tự'),

        body('startTime')
            .notEmpty().withMessage('Giờ bắt đầu không được để trống')
            .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).withMessage('Giờ bắt đầu không hợp lệ (HH:mm)'),

        body('endTime')
            .notEmpty().withMessage('Giờ kết thúc không được để trống')
            .matches(/^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/).withMessage('Giờ kết thúc không hợp lệ (HH:mm)'),

        body('breakDuration')
            .optional()
            .isInt({ min: 0, max: 480 }).withMessage('Thời gian nghỉ giải lao phải từ 0-480 phút'),

        body('gracePeriodMinutes')
            .optional()
            .isInt({ min: 0, max: 60 }).withMessage('Grace period phải từ 0-60 phút'),

        body('monday').optional().isBoolean().withMessage('Monday phải là boolean'),
        body('tuesday').optional().isBoolean().withMessage('Tuesday phải là boolean'),
        body('wednesday').optional().isBoolean().withMessage('Wednesday phải là boolean'),
        body('thursday').optional().isBoolean().withMessage('Thursday phải là boolean'),
        body('friday').optional().isBoolean().withMessage('Friday phải là boolean'),
        body('saturday').optional().isBoolean().withMessage('Saturday phải là boolean'),
        body('sunday').optional().isBoolean().withMessage('Sunday phải là boolean'),

        handleValidationErrors
    ],

    assign: [
        body('employeeId')
            .notEmpty().withMessage('Employee ID không được để trống'),

        body('shiftId')
            .notEmpty().withMessage('Shift ID không được để trống'),

        body('effectiveFrom')
            .notEmpty().withMessage('Ngày hiệu lực không được để trống')
            .isISO8601().withMessage('Ngày hiệu lực không hợp lệ'),

        body('effectiveTo')
            .optional()
            .isISO8601().withMessage('Ngày kết thúc không hợp lệ')
            .custom((effectiveTo, { req }) => {
                if (effectiveTo && new Date(effectiveTo) < new Date(req.body.effectiveFrom)) {
                    throw new Error('Ngày kết thúc phải sau ngày hiệu lực');
                }
                return true;
            }),

        handleValidationErrors
    ]
};

// ============================================
// Device Validation
// ============================================

const deviceValidation = {
    create: [
        body('deviceName')
            .notEmpty().withMessage('Tên thiết bị không được để trống')
            .trim()
            .isLength({ min: 2, max: 100 }).withMessage('Tên thiết bị phải từ 2-100 ký tự'),

        body('deviceType')
            .notEmpty().withMessage('Loại thiết bị không được để trống')
            .isIn(['FINGERPRINT', 'FACE_RECOGNITION', 'MOBILE_APP']).withMessage('Loại thiết bị không hợp lệ'),

        body('location')
            .optional()
            .trim()
            .isLength({ max: 200 }).withMessage('Địa điểm không quá 200 ký tự'),

        body('ipAddress')
            .optional()
            .trim()
            .isIP().withMessage('IP address không hợp lệ'),

        handleValidationErrors
    ]
};

// ============================================
// Department Validation
// ============================================

const departmentValidation = {
    create: [
        body('name')
            .notEmpty().withMessage('Tên phòng ban không được để trống')
            .trim()
            .isLength({ min: 2, max: 100 }).withMessage('Tên phòng ban phải từ 2-100 ký tự'),

        body('code')
            .optional()
            .trim()
            .isLength({ min: 2, max: 20 }).withMessage('Mã phòng ban phải từ 2-20 ký tự')
            .matches(/^[A-Z0-9_]+$/).withMessage('Mã phòng ban chỉ chứa chữ hoa, số và gạch dưới'),

        body('description')
            .optional()
            .trim()
            .isLength({ max: 500 }).withMessage('Mô tả không quá 500 ký tự'),

        body('parentId')
            .optional()
            .isString().withMessage('Parent ID phải là chuỗi'),

        handleValidationErrors
    ],

    update: [
        param('id')
            .notEmpty().withMessage('Department ID không được để trống'),

        body('name')
            .optional()
            .trim()
            .isLength({ min: 2, max: 100 }).withMessage('Tên phòng ban phải từ 2-100 ký tự'),

        body('description')
            .optional()
            .trim()
            .isLength({ max: 500 }).withMessage('Mô tả không quá 500 ký tự'),

        handleValidationErrors
    ]
};

// ============================================
// Report Validation
// ============================================

const reportValidation = {
    monthlyAttendance: [
        query('year')
            .notEmpty().withMessage('Năm không được để trống')
            .isInt({ min: 2000, max: 2100 }).withMessage('Năm không hợp lệ'),

        query('month')
            .notEmpty().withMessage('Tháng không được để trống')
            .isInt({ min: 1, max: 12 }).withMessage('Tháng phải từ 1-12'),

        query('departmentId')
            .optional()
            .isString().withMessage('Department ID phải là chuỗi'),

        handleValidationErrors
    ],

    dateRange: [
        query('startDate')
            .notEmpty().withMessage('Ngày bắt đầu không được để trống')
            .isISO8601().withMessage('Ngày bắt đầu không hợp lệ'),

        query('endDate')
            .notEmpty().withMessage('Ngày kết thúc không được để trống')
            .isISO8601().withMessage('Ngày kết thúc không hợp lệ')
            .custom((endDate, { req }) => {
                if (new Date(endDate) < new Date(req.query.startDate)) {
                    throw new Error('Ngày kết thúc phải sau ngày bắt đầu');
                }
                // Limit to 1 year
                const daysDiff = (new Date(endDate) - new Date(req.query.startDate)) / (1000 * 60 * 60 * 24);
                if (daysDiff > 365) {
                    throw new Error('Khoảng thời gian không quá 1 năm');
                }
                return true;
            }),

        handleValidationErrors
    ]
};

// ============================================
// User/Auth Validation
// ============================================

const authValidation = {
    login: [
        body('username')
            .notEmpty().withMessage('Username không được để trống')
            .trim(),

        body('password')
            .notEmpty().withMessage('Password không được để trống'),

        handleValidationErrors
    ],

    register: [
        body('username')
            .notEmpty().withMessage('Username không được để trống')
            .trim()
            .isLength({ min: 3, max: 50 }).withMessage('Username phải từ 3-50 ký tự')
            .matches(/^[a-zA-Z0-9_]+$/).withMessage('Username chỉ chứa chữ, số và gạch dưới'),

        body('password')
            .notEmpty().withMessage('Password không được để trống')
            .isLength({ min: 8 }).withMessage('Password phải ít nhất 8 ký tự')
            .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).withMessage('Password phải chứa chữ hoa, chữ thường và số'),

        body('email')
            .notEmpty().withMessage('Email không được để trống')
            .isEmail().withMessage('Email không hợp lệ')
            .normalizeEmail(),

        body('role')
            .optional()
            .isIn(['ADMIN', 'HR_MANAGER', 'DEPARTMENT_MANAGER', 'EMPLOYEE']).withMessage('Role không hợp lệ'),

        handleValidationErrors
    ],

    changePassword: [
        body('currentPassword')
            .notEmpty().withMessage('Mật khẩu hiện tại không được để trống'),

        body('newPassword')
            .notEmpty().withMessage('Mật khẩu mới không được để trống')
            .isLength({ min: 8 }).withMessage('Mật khẩu mới phải ít nhất 8 ký tự')
            .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/).withMessage('Mật khẩu mới phải chứa chữ hoa, chữ thường và số')
            .custom((newPassword, { req }) => {
                if (newPassword === req.body.currentPassword) {
                    throw new Error('Mật khẩu mới phải khác mật khẩu hiện tại');
                }
                return true;
            }),

        handleValidationErrors
    ]
};

// ============================================
// Common Validation
// ============================================

const commonValidation = {
    id: [
        param('id')
            .notEmpty().withMessage('ID không được để trống')
            .isString().withMessage('ID phải là chuỗi'),

        handleValidationErrors
    ],

    pagination: [
        query('page')
            .optional()
            .isInt({ min: 1 }).withMessage('Page phải là số nguyên dương'),

        query('limit')
            .optional()
            .isInt({ min: 1, max: 100 }).withMessage('Limit phải từ 1-100'),

        handleValidationErrors
    ]
};

module.exports = {
    handleValidationErrors,
    employeeValidation,
    attendanceValidation,
    leaveValidation,
    shiftValidation,
    deviceValidation,
    departmentValidation,
    reportValidation,
    authValidation,
    commonValidation
};
