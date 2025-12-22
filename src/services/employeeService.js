const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Employee Service
 * Business logic cho employee management
 */

/**
 * Generate employee code
 * Format: EMP-YYYYMM-XXX (e.g., EMP-202512-001)
 * @param {string} departmentCode - Optional department prefix
 * @returns {Promise<string>}
 */
const generateEmployeeCode = async (departmentCode = null) => {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const prefix = departmentCode ? `${departmentCode}-${year}${month}` : `EMP-${year}${month}`;

    // Get latest employee with this prefix
    const latestEmployee = await prisma.employee.findFirst({
        where: {
            employeeCode: {
                startsWith: prefix
            }
        },
        orderBy: {
            employeeCode: 'desc'
        }
    });

    let nextNumber = 1;
    if (latestEmployee) {
        const lastCode = latestEmployee.employeeCode;
        const lastNumber = parseInt(lastCode.split('-').pop());
        nextNumber = lastNumber + 1;
    }

    const code = `${prefix}-${String(nextNumber).padStart(3, '0')}`;
    return code;
};

/**
 * Calculate years of service
 * @param {Date} hireDate
 * @returns {number}
 */
const calculateServiceYears = (hireDate) => {
    if (!hireDate) return 0;

    const now = new Date();
    const hire = new Date(hireDate);
    const diffMs = now - hire;
    const years = diffMs / (1000 * 60 * 60 * 24 * 365.25);

    return parseFloat(years.toFixed(1));
};

/**
 * Calculate age from date of birth
 * @param {Date} dateOfBirth
 * @returns {number}
 */
const calculateAge = (dateOfBirth) => {
    if (!dateOfBirth) return 0;

    const today = new Date();
    const birth = new Date(dateOfBirth);
    let age = today.getFullYear() - birth.getFullYear();
    const monthDiff = today.getMonth() - birth.getMonth();

    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birth.getDate())) {
        age--;
    }

    return age;
};

/**
 * Get upcoming birthdays in department
 * @param {string} departmentId - Optional, null for all employees
 * @param {number} daysAhead - Number of days to look ahead (default: 30)
 * @returns {Promise<Array>}
 */
const getUpcomingBirthdays = async (departmentId = null, daysAhead = 30) => {
    const today = new Date();
    const futureDate = new Date();
    futureDate.setDate(today.getDate() + daysAhead);

    const whereClause = {
        status: 'ACTIVE',
        dateOfBirth: {
            not: null
        }
    };

    if (departmentId) {
        whereClause.departmentId = departmentId;
    }

    const employees = await prisma.employee.findMany({
        where: whereClause,
        select: {
            id: true,
            employeeCode: true,
            firstName: true,
            lastName: true,
            dateOfBirth: true,
            email: true,
            department: {
                select: {
                    id: true,
                    name: true
                }
            }
        }
    });

    // Filter employees with birthdays in the next X days
    const upcomingBirthdays = employees
        .map(emp => {
            const birth = new Date(emp.dateOfBirth);
            const thisYearBirthday = new Date(today.getFullYear(), birth.getMonth(), birth.getDate());

            // If birthday already passed this year, check next year
            if (thisYearBirthday < today) {
                thisYearBirthday.setFullYear(today.getFullYear() + 1);
            }

            const daysUntil = Math.ceil((thisYearBirthday - today) / (1000 * 60 * 60 * 24));

            return {
                ...emp,
                upcomingBirthday: thisYearBirthday,
                daysUntilBirthday: daysUntil,
                age: calculateAge(emp.dateOfBirth) + 1 // Age they will turn
            };
        })
        .filter(emp => emp.daysUntilBirthday >= 0 && emp.daysUntilBirthday <= daysAhead)
        .sort((a, b) => a.daysUntilBirthday - b.daysUntilBirthday);

    return upcomingBirthdays;
};

/**
 * Get employees with expiring contracts
 * @param {number} daysAhead - Number of days to look ahead (default: 90)
 * @returns {Promise<Array>}
 */
const getExpiringContracts = async (daysAhead = 90) => {
    const today = new Date();
    const futureDate = new Date();
    futureDate.setDate(today.getDate() + daysAhead);

    const employees = await prisma.employee.findMany({
        where: {
            status: 'ACTIVE',
            contractEndDate: {
                gte: today,
                lte: futureDate
            }
        },
        include: {
            department: {
                select: {
                    id: true,
                    name: true
                }
            }
        },
        orderBy: {
            contractEndDate: 'asc'
        }
    });

    return employees.map(emp => ({
        ...emp,
        daysUntilExpiry: Math.ceil((new Date(emp.contractEndDate) - today) / (1000 * 60 * 60 * 24)),
        serviceYears: calculateServiceYears(emp.hireDate)
    }));
};

/**
 * Get employee statistics for department
 * @param {string} departmentId
 * @returns {Promise<Object>}
 */
const getDepartmentEmployeeStats = async (departmentId) => {
    const employees = await prisma.employee.findMany({
        where: {
            departmentId
        }
    });

    const stats = {
        total: employees.length,
        active: employees.filter(e => e.status === 'ACTIVE').length,
        onLeave: employees.filter(e => e.status === 'ON_LEAVE').length,
        terminated: employees.filter(e => e.status === 'TERMINATED').length,
        byContractType: {
            FULLTIME: employees.filter(e => e.contractType === 'FULLTIME').length,
            PARTTIME: employees.filter(e => e.contractType === 'PARTTIME').length,
            CONTRACT: employees.filter(e => e.contractType === 'CONTRACT').length,
            INTERNSHIP: employees.filter(e => e.contractType === 'INTERNSHIP').length
        },
        byGender: {
            MALE: employees.filter(e => e.gender === 'MALE').length,
            FEMALE: employees.filter(e => e.gender === 'FEMALE').length,
            OTHER: employees.filter(e => e.gender === 'OTHER').length
        },
        averageServiceYears: employees.length > 0
            ? parseFloat((employees.reduce((sum, e) => sum + calculateServiceYears(e.hireDate), 0) / employees.length).toFixed(1))
            : 0
    };

    return stats;
};

/**
 * Search employees with filters
 * @param {Object} filters - Search filters
 * @returns {Promise<Array>}
 */
const searchEmployees = async (filters = {}) => {
    const {
        search,
        departmentId,
        status,
        contractType,
        gender,
        page = 1,
        limit = 20
    } = filters;

    const whereClause = {};

    if (search) {
        whereClause.OR = [
            { employeeCode: { contains: search, mode: 'insensitive' } },
            { firstName: { contains: search, mode: 'insensitive' } },
            { lastName: { contains: search, mode: 'insensitive' } },
            { email: { contains: search, mode: 'insensitive' } },
            { phone: { contains: search, mode: 'insensitive' } }
        ];
    }

    if (departmentId) {
        whereClause.departmentId = departmentId;
    }

    if (status) {
        whereClause.status = status;
    }

    if (contractType) {
        whereClause.contractType = contractType;
    }

    if (gender) {
        whereClause.gender = gender;
    }

    const skip = (page - 1) * limit;

    const [employees, total] = await Promise.all([
        prisma.employee.findMany({
            where: whereClause,
            include: {
                department: {
                    select: {
                        id: true,
                        name: true
                    }
                },
                manager: {
                    select: {
                        id: true,
                        firstName: true,
                        lastName: true
                    }
                }
            },
            skip,
            take: limit,
            orderBy: {
                createdAt: 'desc'
            }
        }),
        prisma.employee.count({ where: whereClause })
    ]);

    return {
        data: employees,
        pagination: {
            page,
            limit,
            total,
            totalPages: Math.ceil(total / limit)
        }
    };
};

/**
 * Validate face registration data
 * @param {string} faceDescriptor - Face descriptor JSON string
 * @returns {boolean}
 */
const validateFaceDescriptor = (faceDescriptor) => {
    if (!faceDescriptor) return false;

    try {
        const descriptor = JSON.parse(faceDescriptor);

        // Face descriptor should be an array of 128 numbers
        if (!Array.isArray(descriptor)) return false;
        if (descriptor.length !== 128) return false;
        if (!descriptor.every(n => typeof n === 'number')) return false;

        return true;
    } catch (error) {
        return false;
    }
};

module.exports = {
    generateEmployeeCode,
    calculateServiceYears,
    calculateAge,
    getUpcomingBirthdays,
    getExpiringContracts,
    getDepartmentEmployeeStats,
    searchEmployees,
    validateFaceDescriptor
};
