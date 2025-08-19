const { PrismaClient } = require('@prisma/client');

// Configuration dựa trên environment
const isDevelopment = process.env.NODE_ENV === 'development';

const prisma = new PrismaClient({
    log: isDevelopment
        ? ['query', 'info', 'warn', 'error']
        : ['error', 'warn'],

    errorFormat: isDevelopment ? 'pretty' : 'minimal',

    datasources: {
        db: {
            url: process.env.DATABASE_URL
        }
    }
});

// Development middlewares
if (isDevelopment) {
    // Log performance của queries
    prisma.$use(async (params, next) => {
        const before = Date.now();
        const result = await next(params);
        const after = Date.now();

        const duration = after - before;
        const logLevel = duration > 1000 ? 'WARN' : 'INFO';

        console.log(`[${logLevel}] Query ${params.model}.${params.action} took ${duration}ms`);

        // Log slow queries
        if (duration > 1000) {
            console.log(`🐌 Slow query detected:`, {
                model: params.model,
                action: params.action,
                duration: `${duration}ms`,
                args: params.args
            });
        }

        return result;
    });

    // Log connection events
    console.log('🔗 Prisma client initialized in development mode');
    console.log('📊 Query logging enabled');
}

// Test connection function
async function testConnection() {
    try {
        await prisma.$connect();
        console.log('✅ Database connection successful');

        // Test query
        const userCount = await prisma.user.count();
        console.log(`📈 Found ${userCount} users in database`);

    } catch (error) {
        console.error('❌ Database connection failed:', error.message);

        if (error.code === 'P1001') {
            console.log('💡 Tip: Make sure PostgreSQL is running and DATABASE_URL is correct');
        }

        throw error;
    }
}

// Graceful shutdown
const gracefulShutdown = async () => {
    console.log('🔌 Disconnecting from database...');
    await prisma.$disconnect();
    console.log('✅ Database disconnected');
};

process.on('beforeExit', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);
process.on('SIGTERM', gracefulShutdown);

// Export both prisma client and test function
module.exports = {
    prisma,
    testConnection
};