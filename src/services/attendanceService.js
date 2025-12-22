const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Attendance Service
 * Business logic cho attendance management
 */

/**
 * Tính số giờ làm việc giữa check-in và check-out
 * @param {Date} checkInTime
 * @param {Date} checkOutTime
 * @returns {number} Số giờ làm việc (decimal)
 */
const calculateWorkingHours = (checkInTime, checkOutTime) => {
    if (!checkInTime || !checkOutTime) return 0;

    const diffMs = new Date(checkOutTime) - new Date(checkInTime);
    const diffHours = diffMs / (1000 * 60 * 60);

    return Math.max(0, parseFloat(diffHours.toFixed(2)));
};

/**
 * Tính overtime hours
 * @param {number} workingHours - Tổng giờ làm việc
 * @param {number} standardHours - Giờ làm việc tiêu chuẩn (default: 8)
 * @returns {number} Số giờ overtime
 */
const calculateOvertime = (workingHours, standardHours = 8) => {
    const overtime = workingHours - standardHours;
    return Math.max(0, parseFloat(overtime.toFixed(2)));
};

/**
 * Kiểm tra check-in có late không
 * @param {Date} checkInTime
 * @param {Date} shiftStartTime
 * @param {number} gracePeriodMinutes - Thời gian cho phép trễ (phút)
 * @returns {boolean}
 */
const isLateCheckIn = (checkInTime, shiftStartTime, gracePeriodMinutes = 15) => {
    if (!checkInTime || !shiftStartTime) return false;

    const checkIn = new Date(checkInTime);
    const shiftStart = new Date(shiftStartTime);

    // Add grace period
    shiftStart.setMinutes(shiftStart.getMinutes() + gracePeriodMinutes);

    return checkIn > shiftStart;
};

/**
 * Kiểm tra check-out có early không
 * @param {Date} checkOutTime
 * @param {Date} shiftEndTime
 * @param {number} gracePeriodMinutes - Thời gian cho phép về sớm (phút)
 * @returns {boolean}
 */
const isEarlyCheckOut = (checkOutTime, shiftEndTime, gracePeriodMinutes = 15) => {
    if (!checkOutTime || !shiftEndTime) return false;

    const checkOut = new Date(checkOutTime);
    const shiftEnd = new Date(shiftEndTime);

    // Subtract grace period
    shiftEnd.setMinutes(shiftEnd.getMinutes() - gracePeriodMinutes);

    return checkOut < shiftEnd;
};

/**
 * Tính số phút late/early
 * @param {Date} actualTime
 * @param {Date} expectedTime
 * @returns {number} Số phút chênh lệch (dương = late/early)
 */
const calculateLateDuration = (actualTime, expectedTime) => {
    if (!actualTime || !expectedTime) return 0;

    const diffMs = new Date(actualTime) - new Date(expectedTime);
    const diffMinutes = Math.abs(diffMs / (1000 * 60));

    return Math.floor(diffMinutes);
};

/**
 * Tính attendance rate cho một employee trong khoảng thời gian
 * @param {string} employeeId
 * @param {Date} startDate
 * @param {Date} endDate
 * @returns {Promise<{total: number, present: number, absent: number, late: number, rate: number}>}
 */
const calculateAttendanceRate = async (employeeId, startDate, endDate) => {
    const attendances = await prisma.attendance.findMany({
        where: {
            employeeId,
            checkInTime: {
                gte: startDate,
                lte: endDate
            }
        }
    });

    const total = attendances.length;
    const present = attendances.filter(a => a.checkInTime).length;
    const late = attendances.filter(a => a.isLate).length;
    const absent = total - present;
    const rate = total > 0 ? parseFloat(((present / total) * 100).toFixed(2)) : 0;

    return {
        total,
        present,
        absent,
        late,
        rate
    };
};

/**
 * Get monthly attendance summary cho employee
 * @param {string} employeeId
 * @param {number} year
 * @param {number} month
 * @returns {Promise<Object>}
 */
const getMonthlyAttendanceSummary = async (employeeId, year, month) => {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59);

    const attendances = await prisma.attendance.findMany({
        where: {
            employeeId,
            checkInTime: {
                gte: startDate,
                lte: endDate
            }
        },
        orderBy: {
            checkInTime: 'asc'
        }
    });

    let totalWorkingHours = 0;
    let totalOvertime = 0;
    let totalLate = 0;
    let totalEarlyLeave = 0;

    attendances.forEach(att => {
        if (att.workingHours) totalWorkingHours += att.workingHours;
        if (att.overtimeHours) totalOvertime += att.overtimeHours;
        if (att.isLate) totalLate++;
        if (att.isEarlyLeave) totalEarlyLeave++;
    });

    const attendanceRate = await calculateAttendanceRate(employeeId, startDate, endDate);

    return {
        year,
        month,
        totalDays: attendances.length,
        totalWorkingHours: parseFloat(totalWorkingHours.toFixed(2)),
        totalOvertime: parseFloat(totalOvertime.toFixed(2)),
        totalLate,
        totalEarlyLeave,
        attendanceRate: attendanceRate.rate,
        attendances
    };
};

/**
 * Get department attendance summary
 * @param {string} departmentId
 * @param {Date} date
 * @returns {Promise<Object>}
 */
const getDepartmentAttendanceSummary = async (departmentId, date) => {
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);

    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    // Get all employees in department
    const employees = await prisma.employee.findMany({
        where: {
            departmentId,
            status: 'ACTIVE'
        },
        select: {
            id: true,
            firstName: true,
            lastName: true
        }
    });

    // Get attendances for the day
    const attendances = await prisma.attendance.findMany({
        where: {
            employee: {
                departmentId
            },
            checkInTime: {
                gte: startOfDay,
                lte: endOfDay
            }
        },
        include: {
            employee: {
                select: {
                    id: true,
                    firstName: true,
                    lastName: true
                }
            }
        }
    });

    const totalEmployees = employees.length;
    const present = attendances.filter(a => a.checkInTime).length;
    const late = attendances.filter(a => a.isLate).length;
    const absent = totalEmployees - present;

    return {
        date,
        totalEmployees,
        present,
        absent,
        late,
        attendanceRate: totalEmployees > 0 ? parseFloat(((present / totalEmployees) * 100).toFixed(2)) : 0,
        attendances
    };
};

/**
 * Validate check-in time
 * @param {string} employeeId
 * @param {Date} checkInTime
 * @returns {Promise<{valid: boolean, message: string}>}
 */
const validateCheckIn = async (employeeId, checkInTime) => {
    const today = new Date(checkInTime);
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // Check if already checked in today
    const existingAttendance = await prisma.attendance.findFirst({
        where: {
            employeeId,
            checkInTime: {
                gte: today,
                lt: tomorrow
            }
        }
    });

    if (existingAttendance) {
        return {
            valid: false,
            message: 'Bạn đã check-in hôm nay rồi'
        };
    }

    return {
        valid: true,
        message: 'OK'
    };
};

/**
 * Validate check-out time
 * @param {string} attendanceId
 * @param {Date} checkOutTime
 * @returns {Promise<{valid: boolean, message: string}>}
 */
const validateCheckOut = async (attendanceId, checkOutTime) => {
    const attendance = await prisma.attendance.findUnique({
        where: { id: attendanceId }
    });

    if (!attendance) {
        return {
            valid: false,
            message: 'Không tìm thấy attendance record'
        };
    }

    if (attendance.checkOutTime) {
        return {
            valid: false,
            message: 'Đã check-out rồi'
        };
    }

    if (new Date(checkOutTime) < new Date(attendance.checkInTime)) {
        return {
            valid: false,
            message: 'Check-out time phải sau check-in time'
        };
    }

    return {
        valid: true,
        message: 'OK'
    };
};

module.exports = {
    calculateWorkingHours,
    calculateOvertime,
    isLateCheckIn,
    isEarlyCheckOut,
    calculateLateDuration,
    calculateAttendanceRate,
    getMonthlyAttendanceSummary,
    getDepartmentAttendanceSummary,
    validateCheckIn,
    validateCheckOut
};
