const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const apiRoutes = require('./src/routes');
const { generalLimiter } = require('./src/middleware/rateLimiter');

const app = express();
const PORT = process.env.PORT || 3000;

// Trust proxy to allow correct IP detection behind reverse proxies (for rate limiting)
app.set('trust proxy', 1);

// Security middlewares
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            defaultSrc: ["'self'"],
            styleSrc: ["'self'", "'unsafe-inline'"],
            scriptSrc: ["'self'"],
            imgSrc: ["'self'", "data:", "https:"],
        },
    },
    crossOriginEmbedderPolicy: false
}));

// Rate limiting - Áp dụng general limiter cho tất cả requests
app.use(generalLimiter);

// CORS configuration
const corsOptions = {
    origin: process.env.NODE_ENV === 'production'
        ? process.env.FRONTEND_URL?.split(',') || ['https://thienan-admin.vercel.app']
        : process.env.FRONTEND_URL?.split(',') || ['http://localhost:3000', 'http://localhost:5173', 'http://127.0.0.1:3000'],
    credentials: true,
    optionsSuccessStatus: 200,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With']
};

app.use(cors(corsOptions));

// Body parsing middleware
app.use(express.json({
    limit: '10mb',
    verify: (req, res, buf) => {
        // Log large payloads for monitoring
        if (buf.length > 1024 * 1024) { // > 1MB
            console.warn(`Large payload detected: ${buf.length} bytes from ${req.ip}`);
        }
    }
}));

app.use(express.urlencoded({
    extended: true,
    limit: '10mb'
}));

// Request logging middleware
app.use((req, res, next) => {
    const start = Date.now();

    // Log request
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.url} - IP: ${req.ip}`);

    // Log response when finished
    res.on('finish', () => {
        const duration = Date.now() - start;
        const logLevel = res.statusCode >= 400 ? 'ERROR' : 'INFO';
        console.log(`[${logLevel}] ${req.method} ${req.url} - ${res.statusCode} - ${duration}ms`);

        // Log slow requests
        if (duration > 5000) {
            console.warn(`Slow request detected: ${req.method} ${req.url} took ${duration}ms`);
        }
    });

    next();
});

// Health check endpoints (không rate limit)
app.get('/health', (req, res) => {
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV || 'development'
    });
});

app.get('/api/health', (req, res) => {
    res.json({
        status: 'OK',
        timestamp: new Date().toISOString(),
        uptime: process.uptime(),
        environment: process.env.NODE_ENV || 'development',
        service: 'hr-management-api',
        version: '2.0.0'
    });
});

// API routes
app.use('/api', apiRoutes);

// Root endpoint
app.get('/', (req, res) => {
    res.json({
        message: 'Thiếu Nhi API Server đang chạy!',
        version: '1.0.0',
        docs: '/api/test'
    });
});

// 404 handler
app.use('*', (req, res) => {
    res.status(404).json({
        error: 'Endpoint not found',
        message: `Route ${req.method} ${req.originalUrl} not found`,
        availableRoutes: [
            'GET /',
            'GET /health',
            'GET /api/test',
            'POST /api/auth/login'
        ]
    });
});

// Global error handler
app.use((err, req, res, next) => {
    console.error('Global error handler:', err);

    // Prisma errors
    if (err.code === 'P2002') {
        return res.status(409).json({
            error: 'Conflict',
            message: 'Dữ liệu đã tồn tại (duplicate constraint)',
            field: err.meta?.target
        });
    }

    if (err.code === 'P2025') {
        return res.status(404).json({
            error: 'Not Found',
            message: 'Không tìm thấy dữ liệu'
        });
    }

    // JWT errors
    if (err.name === 'JsonWebTokenError') {
        return res.status(401).json({
            error: 'Invalid Token',
            message: 'Token không hợp lệ'
        });
    }

    if (err.name === 'TokenExpiredError') {
        return res.status(401).json({
            error: 'Token Expired',
            message: 'Token đã hết hạn'
        });
    }

    // Validation errors
    if (err.name === 'ValidationError') {
        return res.status(400).json({
            error: 'Validation Error',
            message: err.message,
            details: err.details
        });
    }

    // Rate limit errors
    if (err.status === 429) {
        return res.status(429).json({
            error: 'Too Many Requests',
            message: err.message || 'Quá nhiều yêu cầu, vui lòng thử lại sau'
        });
    }

    // Default server error
    const status = err.status || err.statusCode || 500;
    const message = process.env.NODE_ENV === 'production'
        ? 'Lỗi server nội bộ'
        : err.message;

    res.status(status).json({
        error: 'Internal Server Error',
        message,
        ...(process.env.NODE_ENV !== 'production' && { stack: err.stack })
    });
});

// Multer error handler
app.use((err, req, res, next) => {
    if (err instanceof multer.MulterError) {
        if (err.code === 'LIMIT_FILE_SIZE') {
            return res.status(400).json({ error: 'File quá lớn. Kích thước tối đa 5MB' });
        }
        return res.status(400).json({ error: err.message });
    }

    if (err.message.includes('Chỉ chấp nhận file ảnh')) {
        return res.status(400).json({ error: err.message });
    }

    next(err);
});

// Start server
const server = app.listen(PORT, () => {
    console.log(`🚀 Server đang chạy tại http://localhost:${PORT}`);
    console.log(`📚 API docs: http://localhost:${PORT}/api/test`);
    console.log(`🛡️  Security: Helmet + Rate Limiting enabled`);
    console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
});

// Graceful shutdown
const gracefulShutdown = (signal) => {
    console.log(`\n📡 Received ${signal}. Starting graceful shutdown...`);

    server.close((err) => {
        console.log('🔴 HTTP server closed');

        if (err) {
            console.error('❌ Error during server shutdown:', err);
            process.exit(1);
        }

        // Close database connections
        // prisma.$disconnect() if needed

        console.log('✅ Graceful shutdown completed');
        process.exit(0);
    });

    // Force shutdown after 30 seconds
    setTimeout(() => {
        console.error('⏰ Forced shutdown after 30s timeout');
        process.exit(1);
    }, 30000);
};

// Handle shutdown signals
process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
process.on('SIGINT', () => gracefulShutdown('SIGINT'));

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
    console.error('💥 Uncaught Exception:', err);
    gracefulShutdown('uncaughtException');
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('💥 Unhandled Rejection at:', promise, 'reason:', reason);
    gracefulShutdown('unhandledRejection');
});
