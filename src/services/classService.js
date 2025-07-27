const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class ClassService {
    static async getClassIdFromName(className) {
        if (!className) return null;

        const normalizedName = className.toLowerCase().trim();
        const classes = await prisma.class.findMany({
            where: { isActive: true },
            include: { department: true }
        });

        // Exact match first
        for (const cls of classes) {
            if (cls.name.toLowerCase() === normalizedName) {
                return cls.id;
            }
        }

        // Partial match
        for (const cls of classes) {
            if (cls.name.toLowerCase().includes(normalizedName) ||
                normalizedName.includes(cls.name.toLowerCase())) {
                return cls.id;
            }
        }

        // Match with department context
        for (const cls of classes) {
            const fullName = `${cls.name.toLowerCase()} ${cls.department.displayName.toLowerCase()}`;
            if (fullName.includes(normalizedName) || normalizedName.includes(cls.name.toLowerCase())) {
                return cls.id;
            }
        }

        return null;
    }

    static async getActiveClasses() {
        return await prisma.class.findMany({
            where: { isActive: true },
            include: { department: true },
            orderBy: { name: 'asc' }
        });
    }
}

module.exports = ClassService;