const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Shift Service
 * Business logic cho shift management
 */

/**
 * Get active shift for employee on a specific date
 * @param {string} employeeId
 * @param {Date} date
 * @returns {Promise<Object|null>}
 */
const getEmployeeActiveShift = async (employeeId, date) => {
    const targetDate = new Date(date);
    const dayOfWeek = targetDate.getDay(); // 0 = Sunday, 6 = Saturday

    // Find employee shift assignments
    const employeeShift = await prisma.employeeShift.findFirst({
        where: {
            employeeId,
            effectiveFrom: {
                lte: targetDate
            },
            OR: [
                { effectiveTo: null },
                { effectiveTo: { gte: targetDate } }
            ]
        },
        include: {
            shift: true
        },
        orderBy: {
            effectiveFrom: 'desc'
        }
    });

    if (!employeeShift || !employeeShift.shift) {
        return null;
    }

    const shift = employeeShift.shift;

    // Check if shift applies to this day of week
    const dayMap = {
        0: 'sunday',
        1: 'monday',
        2: 'tuesday',
        3: 'wednesday',
        4: 'thursday',
        5: 'friday',
        6: 'saturday'
    };

    const dayField = dayMap[dayOfWeek];
    if (!shift[dayField]) {
        return null; // Shift doesn't apply to this day
    }

    return {
        ...employeeShift,
        applicableDay: dayField
    };
};

/**
 * Validate shift time (no overlap)
 * @param {string} shiftId - null for new shift
 * @param {Date} startTime
 * @param {Date} endTime
 * @returns {Promise<{valid: boolean, message: string}>}
 */
const validateShiftTime = async (shiftId, startTime, endTime) => {
    const start = new Date(startTime);
    const end = new Date(endTime);

    // Check if end is after start
    if (end <= start) {
        return {
            valid: false,
            message: 'End time phải sau start time'
        };
    }

    // Check for overlapping shifts
    const whereClause = {
        OR: [
            {
                AND: [
                    { startTime: { lte: start } },
                    { endTime: { gt: start } }
                ]
            },
            {
                AND: [
                    { startTime: { lt: end } },
                    { endTime: { gte: end } }
                ]
            },
            {
                AND: [
                    { startTime: { gte: start } },
                    { endTime: { lte: end } }
                ]
            }
        ]
    };

    if (shiftId) {
        whereClause.id = { not: shiftId };
    }

    const overlappingShift = await prisma.shift.findFirst({
        where: whereClause
    });

    if (overlappingShift) {
        return {
            valid: false,
            message: `Shift bị trùng với shift "${overlappingShift.name}"`
        };
    }

    return {
        valid: true,
        message: 'OK'
    };
};

/**
 * Check for shift assignment conflicts
 * @param {string} employeeId
 * @param {Date} effectiveFrom
 * @param {Date} effectiveTo
 * @param {string} employeeShiftId - null for new assignment
 * @returns {Promise<{valid: boolean, message: string}>}
 */
const checkShiftAssignmentConflict = async (employeeId, effectiveFrom, effectiveTo, employeeShiftId = null) => {
    const whereClause = {
        employeeId,
        OR: []
    };

    // Case 1: New assignment starts during existing assignment
    whereClause.OR.push({
        AND: [
            { effectiveFrom: { lte: effectiveFrom } },
            {
                OR: [
                    { effectiveTo: null },
                    { effectiveTo: { gte: effectiveFrom } }
                ]
            }
        ]
    });

    // Case 2: New assignment ends during existing assignment (if has end date)
    if (effectiveTo) {
        whereClause.OR.push({
            AND: [
                { effectiveFrom: { lte: effectiveTo } },
                {
                    OR: [
                        { effectiveTo: null },
                        { effectiveTo: { gte: effectiveTo } }
                    ]
                }
            ]
        });

        // Case 3: New assignment completely contains existing assignment
        whereClause.OR.push({
            AND: [
                { effectiveFrom: { gte: effectiveFrom } },
                { effectiveFrom: { lte: effectiveTo } }
            ]
        });
    }

    if (employeeShiftId) {
        whereClause.id = { not: employeeShiftId };
    }

    const conflict = await prisma.employeeShift.findFirst({
        where: whereClause,
        include: {
            shift: {
                select: {
                    name: true
                }
            }
        }
    });

    if (conflict) {
        return {
            valid: false,
            message: `Shift assignment bị conflict với "${conflict.shift.name}" (${conflict.effectiveFrom.toISOString().split('T')[0]} - ${conflict.effectiveTo ? conflict.effectiveTo.toISOString().split('T')[0] : 'Indefinite'})`
        };
    }

    return {
        valid: true,
        message: 'OK'
    };
};

/**
 * Calculate shift duration (hours)
 * @param {Date} startTime
 * @param {Date} endTime
 * @param {number} breakDuration - Break duration in minutes
 * @returns {number} Shift duration in hours
 */
const calculateShiftDuration = (startTime, endTime, breakDuration = 0) => {
    const start = new Date(startTime);
    const end = new Date(endTime);

    const diffMs = end - start;
    const diffHours = diffMs / (1000 * 60 * 60);
    const breakHours = breakDuration / 60;

    return Math.max(0, parseFloat((diffHours - breakHours).toFixed(2)));
};

/**
 * Get shift schedule for employee (week/month view)
 * @param {string} employeeId
 * @param {Date} startDate
 * @param {Date} endDate
 * @returns {Promise<Array>}
 */
const getEmployeeShiftSchedule = async (employeeId, startDate, endDate) => {
    const schedule = [];
    const current = new Date(startDate);

    while (current <= endDate) {
        const shift = await getEmployeeActiveShift(employeeId, current);

        schedule.push({
            date: new Date(current),
            dayOfWeek: current.getDay(),
            shift: shift ? {
                id: shift.shift.id,
                name: shift.shift.name,
                startTime: shift.shift.startTime,
                endTime: shift.shift.endTime,
                breakDuration: shift.shift.breakDuration,
                duration: calculateShiftDuration(
                    shift.shift.startTime,
                    shift.shift.endTime,
                    shift.shift.breakDuration
                )
            } : null
        });

        current.setDate(current.getDate() + 1);
    }

    return schedule;
};

/**
 * Get department shift coverage
 * @param {string} departmentId
 * @param {Date} date
 * @returns {Promise<Object>}
 */
const getDepartmentShiftCoverage = async (departmentId, date) => {
    const targetDate = new Date(date);

    // Get all active employees in department
    const employees = await prisma.employee.findMany({
        where: {
            departmentId,
            status: 'ACTIVE'
        },
        select: {
            id: true,
            firstName: true,
            lastName: true,
            employeeCode: true
        }
    });

    const coverage = {
        date: targetDate,
        totalEmployees: employees.length,
        assigned: 0,
        unassigned: 0,
        byShift: {},
        details: []
    };

    for (const employee of employees) {
        const shift = await getEmployeeActiveShift(employee.id, targetDate);

        const detail = {
            employee,
            shift: shift ? {
                id: shift.shift.id,
                name: shift.shift.name,
                startTime: shift.shift.startTime,
                endTime: shift.shift.endTime
            } : null
        };

        coverage.details.push(detail);

        if (shift) {
            coverage.assigned++;

            if (!coverage.byShift[shift.shift.name]) {
                coverage.byShift[shift.shift.name] = {
                    count: 0,
                    employees: []
                };
            }

            coverage.byShift[shift.shift.name].count++;
            coverage.byShift[shift.shift.name].employees.push(employee);
        } else {
            coverage.unassigned++;
        }
    }

    return coverage;
};

/**
 * Get shifts requiring employees
 * @returns {Promise<Array>}
 */
const getShiftsNeedingCoverage = async () => {
    const shifts = await prisma.shift.findMany({
        where: {
            isActive: true
        },
        include: {
            _count: {
                select: {
                    employeeShifts: true
                }
            }
        }
    });

    return shifts.map(shift => ({
        ...shift,
        assignedEmployees: shift._count.employeeShifts,
        needsCoverage: shift._count.employeeShifts === 0
    }));
};

module.exports = {
    getEmployeeActiveShift,
    validateShiftTime,
    checkShiftAssignmentConflict,
    calculateShiftDuration,
    getEmployeeShiftSchedule,
    getDepartmentShiftCoverage,
    getShiftsNeedingCoverage
};
