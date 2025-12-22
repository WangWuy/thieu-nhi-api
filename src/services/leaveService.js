const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Leave Service
 * Business logic cho leave management
 */

/**
 * Tính số ngày nghỉ (trừ weekend)
 * @param {Date} startDate
 * @param {Date} endDate
 * @returns {number} Số ngày nghỉ (không tính weekend)
 */
const calculateLeaveDays = (startDate, endDate) => {
    if (!startDate || !endDate) return 0;

    const start = new Date(startDate);
    const end = new Date(endDate);

    let count = 0;
    const current = new Date(start);

    while (current <= end) {
        const dayOfWeek = current.getDay();
        // 0 = Sunday, 6 = Saturday
        if (dayOfWeek !== 0 && dayOfWeek !== 6) {
            count++;
        }
        current.setDate(current.getDate() + 1);
    }

    return count;
};

/**
 * Tính leave balance cho employee
 * @param {string} employeeId
 * @param {string} leaveType - ANNUAL, SICK, UNPAID, etc.
 * @returns {Promise<{total: number, used: number, remaining: number}>}
 */
const calculateLeaveBalance = async (employeeId, leaveType) => {
    const employee = await prisma.employee.findUnique({
        where: { id: employeeId },
        select: {
            hireDate: true
        }
    });

    if (!employee) {
        throw new Error('Employee not found');
    }

    // Calculate annual entitlement based on years of service
    const entitlement = calculateAnnualLeaveEntitlement(employee.hireDate, leaveType);

    // Get current year leaves
    const currentYear = new Date().getFullYear();
    const startOfYear = new Date(currentYear, 0, 1);
    const endOfYear = new Date(currentYear, 11, 31, 23, 59, 59);

    const leaves = await prisma.leave.findMany({
        where: {
            employeeId,
            leaveType,
            status: {
                in: ['APPROVED', 'PENDING']
            },
            startDate: {
                gte: startOfYear,
                lte: endOfYear
            }
        }
    });

    let used = 0;
    leaves.forEach(leave => {
        const days = calculateLeaveDays(leave.startDate, leave.endDate);
        used += days;
    });

    const remaining = Math.max(0, entitlement - used);

    return {
        total: entitlement,
        used,
        remaining
    };
};

/**
 * Tính số ngày nghỉ phép được hưởng hàng năm
 * @param {Date} hireDate
 * @param {string} leaveType
 * @returns {number}
 */
const calculateAnnualLeaveEntitlement = (hireDate, leaveType) => {
    if (leaveType === 'SICK') {
        return 30; // 30 ngày phép bệnh/năm
    }

    if (leaveType === 'UNPAID') {
        return 999; // Unlimited unpaid leave
    }

    // Calculate annual leave based on years of service
    const yearsOfService = calculateYearsOfService(hireDate);

    // Base: 12 days, +1 day per year of service (max 20 days)
    let annualLeave = 12;
    annualLeave += Math.min(yearsOfService, 8); // Max +8 days

    return Math.min(annualLeave, 20);
};

/**
 * Tính số năm làm việc
 * @param {Date} hireDate
 * @returns {number}
 */
const calculateYearsOfService = (hireDate) => {
    if (!hireDate) return 0;

    const now = new Date();
    const hire = new Date(hireDate);
    const diffMs = now - hire;
    const years = diffMs / (1000 * 60 * 60 * 24 * 365.25);

    return Math.floor(years);
};

/**
 * Validate leave request
 * @param {string} employeeId
 * @param {Date} startDate
 * @param {Date} endDate
 * @param {string} leaveType
 * @returns {Promise<{valid: boolean, message: string}>}
 */
const validateLeaveRequest = async (employeeId, startDate, endDate, leaveType) => {
    // Check dates
    if (new Date(endDate) < new Date(startDate)) {
        return {
            valid: false,
            message: 'End date phải sau start date'
        };
    }

    // Check if past date
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (new Date(startDate) < today) {
        return {
            valid: false,
            message: 'Không thể đăng ký nghỉ phép cho ngày trong quá khứ'
        };
    }

    // Check for overlapping leaves
    const overlappingLeave = await prisma.leave.findFirst({
        where: {
            employeeId,
            status: {
                in: ['APPROVED', 'PENDING']
            },
            OR: [
                {
                    AND: [
                        { startDate: { lte: startDate } },
                        { endDate: { gte: startDate } }
                    ]
                },
                {
                    AND: [
                        { startDate: { lte: endDate } },
                        { endDate: { gte: endDate } }
                    ]
                },
                {
                    AND: [
                        { startDate: { gte: startDate } },
                        { endDate: { lte: endDate } }
                    ]
                }
            ]
        }
    });

    if (overlappingLeave) {
        return {
            valid: false,
            message: 'Đã có leave request trong khoảng thời gian này'
        };
    }

    // Check leave balance (for ANNUAL and SICK leave)
    if (leaveType === 'ANNUAL' || leaveType === 'SICK') {
        const balance = await calculateLeaveBalance(employeeId, leaveType);
        const requestedDays = calculateLeaveDays(startDate, endDate);

        if (requestedDays > balance.remaining) {
            return {
                valid: false,
                message: `Không đủ phép ${leaveType}. Còn lại: ${balance.remaining} ngày, yêu cầu: ${requestedDays} ngày`
            };
        }
    }

    return {
        valid: true,
        message: 'OK'
    };
};

/**
 * Get leave statistics for employee
 * @param {string} employeeId
 * @param {number} year
 * @returns {Promise<Object>}
 */
const getLeaveStatistics = async (employeeId, year) => {
    const startOfYear = new Date(year, 0, 1);
    const endOfYear = new Date(year, 11, 31, 23, 59, 59);

    const leaves = await prisma.leave.findMany({
        where: {
            employeeId,
            startDate: {
                gte: startOfYear,
                lte: endOfYear
            }
        },
        orderBy: {
            startDate: 'asc'
        }
    });

    const stats = {
        year,
        total: leaves.length,
        approved: 0,
        pending: 0,
        rejected: 0,
        cancelled: 0,
        byType: {
            ANNUAL: { count: 0, days: 0 },
            SICK: { count: 0, days: 0 },
            UNPAID: { count: 0, days: 0 },
            MATERNITY: { count: 0, days: 0 },
            PATERNITY: { count: 0, days: 0 }
        }
    };

    leaves.forEach(leave => {
        // Count by status
        stats[leave.status.toLowerCase()]++;

        // Count by type
        const days = calculateLeaveDays(leave.startDate, leave.endDate);
        if (stats.byType[leave.leaveType]) {
            stats.byType[leave.leaveType].count++;
            stats.byType[leave.leaveType].days += days;
        }
    });

    // Get balances
    const annualBalance = await calculateLeaveBalance(employeeId, 'ANNUAL');
    const sickBalance = await calculateLeaveBalance(employeeId, 'SICK');

    stats.balances = {
        ANNUAL: annualBalance,
        SICK: sickBalance
    };

    return stats;
};

/**
 * Get department leave calendar
 * @param {string} departmentId
 * @param {Date} startDate
 * @param {Date} endDate
 * @returns {Promise<Array>}
 */
const getDepartmentLeaveCalendar = async (departmentId, startDate, endDate) => {
    const leaves = await prisma.leave.findMany({
        where: {
            employee: {
                departmentId
            },
            status: 'APPROVED',
            OR: [
                {
                    AND: [
                        { startDate: { lte: endDate } },
                        { endDate: { gte: startDate } }
                    ]
                }
            ]
        },
        include: {
            employee: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true,
                    position: true
                }
            }
        },
        orderBy: {
            startDate: 'asc'
        }
    });

    return leaves.map(leave => ({
        ...leave,
        duration: calculateLeaveDays(leave.startDate, leave.endDate)
    }));
};

module.exports = {
    calculateLeaveDays,
    calculateLeaveBalance,
    calculateAnnualLeaveEntitlement,
    calculateYearsOfService,
    validateLeaveRequest,
    getLeaveStatistics,
    getDepartmentLeaveCalendar
};
