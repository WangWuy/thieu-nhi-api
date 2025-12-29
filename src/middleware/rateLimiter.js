const rateLimit = require('express-rate-limit');

// Message responses in Vietnamese
const rateLimitMessages = {
    general: {
        message: 'Quá nhiều yêu cầu từ IP này, vui lòng thử lại sau.',
        standardHeaders: true,
        legacyHeaders: false,
    },
    auth: {
        message: 'Quá nhiều lần đăng nhập thất bại, vui lòng thử lại sau 15 phút.',
        standardHeaders: true,
        legacyHeaders: false,
    },
    api: {
        message: 'Quá nhiều yêu cầu API, vui lòng chậm lại.',
        standardHeaders: true,
        legacyHeaders: false,
    }
};

// Helpers để dễ chỉnh quota qua biến môi trường
const parseLimit = (value, fallback) => {
    const parsed = parseInt(value, 10);
    return Number.isFinite(parsed) && parsed > 0 ? parsed : fallback;
};

// Cho phép cấu hình qua env, đặt fallback an toàn cho sản xuất
const GENERAL_LIMIT_PER_15MIN = parseLimit(process.env.GENERAL_LIMIT_PER_15MIN, 5000);
const API_LIMIT_PER_MIN = parseLimit(process.env.API_LIMIT_PER_MIN, 300);
const UPLOAD_LIMIT_PER_15MIN = parseLimit(process.env.UPLOAD_LIMIT_PER_15MIN, 100);
const ATTENDANCE_LIMIT_PER_5MIN = parseLimit(process.env.ATTENDANCE_LIMIT_PER_5MIN, 500);
const SEARCH_LIMIT_PER_MIN = parseLimit(process.env.SEARCH_LIMIT_PER_MIN, 300); // ~5 request/giây mỗi user

// General rate limiter - Áp dụng cho tất cả requests
const generalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 phút
    max: GENERAL_LIMIT_PER_15MIN, // Giới hạn theo user/IP trong 15 phút
    ...rateLimitMessages.general,
    standardHeaders: true,
    legacyHeaders: false,
    // Skip successful requests to allow more requests for normal users
    skipSuccessfulRequests: false,
    // Skip failed requests to prevent attackers from consuming the limit
    skipFailedRequests: false,
    // Custom key generator để có thể bypass cho admin nếu cần
    keyGenerator: (req) => {
        // Ưu tiên userId để tránh chặn cả nhóm chung IP (NAT)
        return req.user?.userId || req.ip;
    },
    // Handler khi reach limit
    handler: (req, res) => {
        res.status(429).json({
            error: 'Too Many Requests',
            message: rateLimitMessages.general.message,
            retryAfter: Math.round(req.rateLimit.resetTime / 1000)
        });
    }
});

// Auth rate limiter - Strict hơn cho login/auth
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 phút
    max: 5, // Chỉ 5 lần login thất bại trong 15 phút
    ...rateLimitMessages.auth,
    // Chỉ count failed requests
    skipSuccessfulRequests: true,
    skipFailedRequests: false,
    keyGenerator: (req) => {
        // Combine IP + username để prevent brute force
        const username = req.body?.username || 'unknown';
        return `${req.ip}-${username}`;
    },
    handler: (req, res) => {
        res.status(429).json({
            error: 'Too Many Login Attempts',
            message: rateLimitMessages.auth.message,
            retryAfter: Math.round(req.rateLimit.resetTime / 1000)
        });
    }
});

// API rate limiter - Cho các API calls thông thường
const apiLimiter = rateLimit({
    windowMs: 1 * 60 * 1000, // 1 phút
    max: API_LIMIT_PER_MIN, // requests per minute
    ...rateLimitMessages.api,
    keyGenerator: (req) => {
        // Nếu có JWT token, dùng userId, không thì dùng IP
        return req.user?.userId || req.ip;
    },
    handler: (req, res) => {
        res.status(429).json({
            error: 'API Rate Limit Exceeded',
            message: rateLimitMessages.api.message,
            retryAfter: Math.round(req.rateLimit.resetTime / 1000)
        });
    }
});

// Strict limiter cho các operations sensitive
const strictLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 giờ
    max: 100, // Chỉ 10 requests per hour
    message: {
        error: 'Strict Rate Limit',
        message: 'Quá nhiều yêu cầu cho chức năng này, vui lòng thử lại sau 1 giờ.'
    },
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req) => {
        return req.user?.userId || req.ip;
    }
});

// Upload limiter cho file uploads (nếu có)
const uploadLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 phút
    max: UPLOAD_LIMIT_PER_15MIN, // uploads per 15 minutes
    message: {
        error: 'Upload Rate Limit',
        message: 'Quá nhiều lần upload, vui lòng thử lại sau.'
    },
    standardHeaders: true,
    legacyHeaders: false,
    keyGenerator: (req) => req.user?.userId || req.ip
});

// Password reset limiter
const passwordResetLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 giờ
    max: 3, // Chỉ 3 lần reset password per hour
    message: {
        error: 'Password Reset Limit',
        message: 'Quá nhiều lần reset mật khẩu, vui lòng thử lại sau 1 giờ.'
    },
    keyGenerator: (req) => {
        // Combine IP + email/username
        const identifier = req.body?.email || req.body?.username || 'unknown';
        return `${req.ip}-${identifier}`;
    }
});

// Create account limiter
const createAccountLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 giờ
    max: 50, // Chỉ 5 accounts per IP per hour
    message: {
        error: 'Account Creation Limit',
        message: 'Quá nhiều tài khoản được tạo từ IP này, vui lòng thử lại sau.'
    }
});

// Attendance limiter - Cho việc điểm danh batch
const attendanceLimiter = rateLimit({
    windowMs: 5 * 60 * 1000, // 5 phút
    max: ATTENDANCE_LIMIT_PER_5MIN, // lần điểm danh trong 5 phút
    message: {
        error: 'Attendance Rate Limit',
        message: 'Quá nhiều lần điểm danh, vui lòng chậm lại.'
    },
    keyGenerator: (req) => {
        return req.user?.userId || req.ip;
    }
});

// Search limiter - Prevent search spam
const searchLimiter = rateLimit({
    windowMs: 1 * 60 * 1000, // 1 phút
    // Đếm theo userId, tránh chặn cả nhóm khi chung IP
    max: () => SEARCH_LIMIT_PER_MIN,
    keyGenerator: (req) => req.user?.userId || req.ip,
    standardHeaders: true,
    legacyHeaders: false,
    message: {
        error: 'Search Rate Limit',
        message: 'Quá nhiều lần tìm kiếm, vui lòng chậm lại.'
    }
});

// Export tất cả limiters
module.exports = {
    generalLimiter,
    authLimiter,
    apiLimiter,
    strictLimiter,
    uploadLimiter,
    passwordResetLimiter,
    createAccountLimiter,
    attendanceLimiter,
    searchLimiter
};
