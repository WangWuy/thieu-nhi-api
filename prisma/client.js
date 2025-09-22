const { PrismaClient } = require('@prisma/client');

// Singleton pattern để tránh multiple instances
let prisma;

if (process.env.NODE_ENV === "production") {
    prisma = new PrismaClient();
} else {
    if (!global.prisma) {
        global.prisma = new PrismaClient({
            log: ['query', 'info', 'warn', 'error'],
            errorFormat: 'pretty'
        });
    }
    prisma = global.prisma;
}

// Test connection function
async function testConnection() {
    try {
        await prisma.$connect();
        console.log('✅ Database connection successful');

        const userCount = await prisma.user.count();
        console.log(`📈 Found ${userCount} users in database`);

    } catch (error) {
        console.error('❌ Database connection failed:', error.message);

        if (error.message.includes('too many clients')) {
            console.log('💡 Too many database connections detected');
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

module.exports = {
    prisma,
    testConnection
};