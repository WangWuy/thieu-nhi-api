const { body, param, query, validationResult } = require('express-validator');

// Middleware để check kết quả validation
const handleValidationErrors = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({
            error: 'Dữ liệu không hợp lệ',
            details: errors.array().map(err => ({
                field: err.path,
                message: err.msg,
                value: err.value
            }))
        });
    }
    next();
};

// Auth validation rules
const authValidation = {
    login: [
        body('username')
            .notEmpty()
            .withMessage('Username là bắt buộc')
            .isLength({ min: 3 })
            .withMessage('Username phải ít nhất 3 ký tự'),
        body('password')
            .notEmpty()
            .withMessage('Password là bắt buộc')
            .isLength({ min: 6 })
            .withMessage('Password phải ít nhất 6 ký tự'),
        handleValidationErrors
    ],

    changePassword: [
        body('currentPassword')
            .notEmpty()
            .withMessage('Mật khẩu hiện tại là bắt buộc'),
        body('newPassword')
            .isLength({ min: 6 })
            .withMessage('Mật khẩu mới phải ít nhất 6 ký tự')
            .matches(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/)
            .withMessage('Mật khẩu mới phải chứa ít nhất 1 chữ thường, 1 chữ hoa và 1 số'),
        handleValidationErrors
    ]
};

// User validation rules
const userValidation = {
    create: [
        body('username')
            .notEmpty()
            .withMessage('Username là bắt buộc')
            .isLength({ min: 3, max: 50 })
            .withMessage('Username phải từ 3-50 ký tự')
            .matches(/^[a-zA-Z0-9_]+$/)
            .withMessage('Username chỉ được chứa chữ, số và dấu gạch dưới'),
        body('password')
            .isLength({ min: 6 })
            .withMessage('Password phải ít nhất 6 ký tự'),
        body('role')
            .isIn(['ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien'])
            .withMessage('Role không hợp lệ'),
        body('fullName')
            .notEmpty()
            .withMessage('Họ tên là bắt buộc')
            .isLength({ min: 2, max: 100 })
            .withMessage('Họ tên phải từ 2-100 ký tự'),
        body('saintName')
            .optional()
            .isLength({ max: 50 })
            .withMessage('Tên thánh không được quá 50 ký tự'),
        body('phoneNumber')
            .optional()
            .matches(/^(\+84|0)[3|5|7|8|9][0-9]{8}$/)
            .withMessage('Số điện thoại không hợp lệ (VN format)'),
        body('birthDate')
            .optional()
            .isISO8601()
            .withMessage('Ngày sinh không hợp lệ')
            .custom((value) => {
                const birthDate = new Date(value);
                const today = new Date();
                const age = today.getFullYear() - birthDate.getFullYear();
                if (age < 16 || age > 80) {
                    throw new Error('Tuổi phải từ 16-80');
                }
                return true;
            }),
        body('departmentId')
            .optional()
            .isInt({ min: 1 })
            .withMessage('Department ID không hợp lệ'),
        handleValidationErrors
    ],

    update: [
        param('id')
            .isInt({ min: 1 })
            .withMessage('User ID không hợp lệ'),
        body('fullName')
            .optional()
            .isLength({ min: 2, max: 100 })
            .withMessage('Họ tên phải từ 2-100 ký tự'),
        body('saintName')
            .optional()
            .isLength({ max: 50 })
            .withMessage('Tên thánh không được quá 50 ký tự'),
        body('phoneNumber')
            .optional()
            .matches(/^(\+84|0)[3|5|7|8|9][0-9]{8}$/)
            .withMessage('Số điện thoại không hợp lệ'),
        body('birthDate')
            .optional()
            .isISO8601()
            .withMessage('Ngày sinh không hợp lệ'),
        handleValidationErrors
    ],

    resetPassword: [
        param('id')
            .isInt({ min: 1 })
            .withMessage('User ID không hợp lệ'),
        body('newPassword')
            .isLength({ min: 6 })
            .withMessage('Mật khẩu mới phải ít nhất 6 ký tự'),
        handleValidationErrors
    ]
};

// Student validation rules
const studentValidation = {
    create: [
        body('studentCode')
            .notEmpty()
            .withMessage('Mã học sinh là bắt buộc')
            .matches(/^TN[0-9]{4}$/)
            .withMessage('Mã học sinh phải có format TNxxxx (4 số)'),
        body('fullName')
            .notEmpty()
            .withMessage('Họ tên là bắt buộc')
            .isLength({ min: 2, max: 100 })
            .withMessage('Họ tên phải từ 2-100 ký tự'),
        body('saintName')
            .optional()
            .isLength({ max: 50 })
            .withMessage('Tên thánh không được quá 50 ký tự'),
        body('classId')
            .isInt({ min: 1 })
            .withMessage('Lớp học là bắt buộc'),
        body('birthDate')
            .optional()
            .isISO8601()
            .withMessage('Ngày sinh không hợp lệ')
            .custom((value) => {
                if (value) {
                    const birthDate = new Date(value);
                    const today = new Date();
                    const age = today.getFullYear() - birthDate.getFullYear();
                    if (age < 5 || age > 18) {
                        throw new Error('Tuổi học sinh phải từ 5-18');
                    }
                }
                return true;
            }),
        body('phoneNumber')
            .optional()
            .matches(/^(\+84|0)[3|5|7|8|9][0-9]{8}$/)
            .withMessage('Số điện thoại không hợp lệ'),
        body('parentPhone1')
            .optional()
            .matches(/^(\+84|0)[3|5|7|8|9][0-9]{8}$/)
            .withMessage('Số điện thoại phụ huynh 1 không hợp lệ'),
        body('parentPhone2')
            .optional()
            .matches(/^(\+84|0)[3|5|7|8|9][0-9]{8}$/)
            .withMessage('Số điện thoại phụ huynh 2 không hợp lệ'),
        handleValidationErrors
    ],

    update: [
        param('id')
            .isInt({ min: 1 })
            .withMessage('Student ID không hợp lệ'),
        body('fullName')
            .optional()
            .isLength({ min: 2, max: 100 })
            .withMessage('Họ tên phải từ 2-100 ký tự'),
        body('classId')
            .optional()
            .isInt({ min: 1 })
            .withMessage('Lớp học không hợp lệ'),
        body('birthDate')
            .optional()
            .isISO8601()
            .withMessage('Ngày sinh không hợp lệ'),
        body('phoneNumber')
            .optional()
            .matches(/^(\+84|0)[3|5|7|8|9][0-9]{8}$/)
            .withMessage('Số điện thoại không hợp lệ'),
        handleValidationErrors
    ]
};

// Class validation rules
const classValidation = {
    create: [
        body('name')
            .notEmpty()
            .withMessage('Tên lớp là bắt buộc')
            .isLength({ min: 2, max: 50 })
            .withMessage('Tên lớp phải từ 2-50 ký tự'),
        body('departmentId')
            .isInt({ min: 1 })
            .withMessage('Ngành là bắt buộc'),
        body('teacherIds')
            .optional()
            .isArray()
            .withMessage('Teacher IDs phải là array'),
        body('teacherIds.*')
            .optional()
            .isInt({ min: 1 })
            .withMessage('Teacher ID không hợp lệ'),
        handleValidationErrors
    ],

    update: [
        param('id')
            .isInt({ min: 1 })
            .withMessage('Class ID không hợp lệ'),
        body('name')
            .optional()
            .isLength({ min: 2, max: 50 })
            .withMessage('Tên lớp phải từ 2-50 ký tự'),
        body('departmentId')
            .optional()
            .isInt({ min: 1 })
            .withMessage('Department ID không hợp lệ'),
        handleValidationErrors
    ],

    assignTeacher: [
        param('classId')
            .isInt({ min: 1 })
            .withMessage('Class ID không hợp lệ'),
        body('userId')
            .isInt({ min: 1 })
            .withMessage('User ID là bắt buộc'),
        body('isPrimary')
            .optional()
            .isBoolean()
            .withMessage('isPrimary phải là boolean'),
        handleValidationErrors
    ]
};

// Attendance validation rules
const attendanceValidation = {
    mark: [
        body('studentId')
            .isInt({ min: 1 })
            .withMessage('Student ID là bắt buộc'),
        body('attendanceDate')
            .isISO8601()
            .withMessage('Ngày điểm danh không hợp lệ')
            .custom((value) => {
                const date = new Date(value);
                const today = new Date();
                const diffTime = Math.abs(today - date);
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                if (diffDays > 30) {
                    throw new Error('Chỉ được điểm danh trong vòng 30 ngày');
                }
                return true;
            }),
        body('attendanceType')
            .isIn(['thursday', 'sunday'])
            .withMessage('Loại điểm danh phải là thursday hoặc sunday'),
        body('isPresent')
            .isBoolean()
            .withMessage('isPresent phải là boolean'),
        body('note')
            .optional()
            .isLength({ max: 500 })
            .withMessage('Ghi chú không được quá 500 ký tự'),
        handleValidationErrors
    ],

    getByClass: [
        param('classId')
            .isInt({ min: 1 })
            .withMessage('Class ID không hợp lệ'),
        query('date')
            .notEmpty()
            .withMessage('Ngày là bắt buộc')
            .isISO8601()
            .withMessage('Định dạng ngày không hợp lệ'),
        query('type')
            .isIn(['thursday', 'sunday'])
            .withMessage('Loại điểm danh phải là thursday hoặc sunday'),
        handleValidationErrors
    ],

    batchMark: [
        param('classId')
            .isInt({ min: 1 })
            .withMessage('Class ID không hợp lệ'),
        body('attendanceDate')
            .isISO8601()
            .withMessage('Ngày điểm danh không hợp lệ'),
        body('attendanceType')
            .isIn(['thursday', 'sunday'])
            .withMessage('Loại điểm danh không hợp lệ'),
        body('attendanceRecords')
            .isArray({ min: 1 })
            .withMessage('Danh sách điểm danh không được rỗng'),
        body('attendanceRecords.*.studentId')
            .isInt({ min: 1 })
            .withMessage('Student ID không hợp lệ'),
        body('attendanceRecords.*.isPresent')
            .isBoolean()
            .withMessage('isPresent phải là boolean'),
        handleValidationErrors
    ]
};

// Query validation rules
const queryValidation = {
    pagination: [
        query('page')
            .optional()
            .isInt({ min: 1 })
            .withMessage('Page phải là số nguyên dương'),
        query('limit')
            .optional()
            .isInt({ min: 1, max: 1000 })
            .withMessage('Limit phải từ 1-1000'),
        handleValidationErrors
    ],

    search: [
        query('search')
            .optional()
            .isLength({ min: 0, max: 100 })
            .withMessage('Từ khóa tìm kiếm phải từ 0-100 ký tự'),
        handleValidationErrors
    ],

    dateRange: [
        query('startDate')
            .optional()
            .isISO8601()
            .withMessage('Start date không hợp lệ'),
        query('endDate')
            .optional()
            .isISO8601()
            .withMessage('End date không hợp lệ')
            .custom((endDate, { req }) => {
                if (req.query.startDate && endDate) {
                    const start = new Date(req.query.startDate);
                    const end = new Date(endDate);
                    if (end < start) {
                        throw new Error('End date phải sau start date');
                    }
                }
                return true;
            }),
        handleValidationErrors
    ]
};

module.exports = {
    authValidation,
    userValidation,
    studentValidation,
    classValidation,
    attendanceValidation,
    queryValidation,
    handleValidationErrors
};