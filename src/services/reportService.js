const { PrismaClient } = require('@prisma/client');
const XLSX = require('xlsx');
const prisma = new PrismaClient();

/**
 * Report Service
 * Business logic cho report generation & export
 */

/**
 * Generate monthly attendance report
 * @param {number} year
 * @param {number} month
 * @param {string} departmentId - Optional
 * @returns {Promise<Object>}
 */
const generateMonthlyAttendanceReport = async (year, month, departmentId = null) => {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59);

    const whereClause = {
        checkInTime: {
            gte: startDate,
            lte: endDate
        }
    };

    if (departmentId) {
        whereClause.employee = {
            departmentId
        };
    }

    const attendances = await prisma.attendance.findMany({
        where: whereClause,
        include: {
            employee: {
                select: {
                    id: true,
                    employeeCode: true,
                    firstName: true,
                    lastName: true,
                    department: {
                        select: {
                            name: true
                        }
                    }
                }
            }
        },
        orderBy: [
            { employee: { employeeCode: 'asc' } },
            { checkInTime: 'asc' }
        ]
    });

    // Group by employee
    const employeeData = {};

    attendances.forEach(att => {
        const empId = att.employee.id;

        if (!employeeData[empId]) {
            employeeData[empId] = {
                employee: att.employee,
                totalDays: 0,
                presentDays: 0,
                lateDays: 0,
                earlyLeaveDays: 0,
                totalWorkingHours: 0,
                totalOvertime: 0,
                attendances: []
            };
        }

        employeeData[empId].totalDays++;
        if (att.checkInTime) employeeData[empId].presentDays++;
        if (att.isLate) employeeData[empId].lateDays++;
        if (att.isEarlyLeave) employeeData[empId].earlyLeaveDays++;
        if (att.workingHours) employeeData[empId].totalWorkingHours += att.workingHours;
        if (att.overtimeHours) employeeData[empId].totalOvertime += att.overtimeHours;

        employeeData[empId].attendances.push(att);
    });

    // Calculate summary
    const summary = {
        year,
        month,
        totalEmployees: Object.keys(employeeData).length,
        totalAttendanceRecords: attendances.length,
        averageWorkingHours: 0,
        totalOvertimeHours: 0
    };

    let totalWorkingHours = 0;
    Object.values(employeeData).forEach(data => {
        totalWorkingHours += data.totalWorkingHours;
        summary.totalOvertimeHours += data.totalOvertime;
    });

    summary.averageWorkingHours = summary.totalEmployees > 0
        ? parseFloat((totalWorkingHours / summary.totalEmployees).toFixed(2))
        : 0;

    return {
        summary,
        data: Object.values(employeeData)
    };
};

/**
 * Generate employee attendance report
 * @param {string} employeeId
 * @param {Date} startDate
 * @param {Date} endDate
 * @returns {Promise<Object>}
 */
const generateEmployeeAttendanceReport = async (employeeId, startDate, endDate) => {
    const employee = await prisma.employee.findUnique({
        where: { id: employeeId },
        include: {
            department: {
                select: {
                    name: true
                }
            }
        }
    });

    if (!employee) {
        throw new Error('Employee not found');
    }

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

    const summary = {
        totalDays: attendances.length,
        presentDays: attendances.filter(a => a.checkInTime).length,
        lateDays: attendances.filter(a => a.isLate).length,
        earlyLeaveDays: attendances.filter(a => a.isEarlyLeave).length,
        totalWorkingHours: attendances.reduce((sum, a) => sum + (a.workingHours || 0), 0),
        totalOvertime: attendances.reduce((sum, a) => sum + (a.overtimeHours || 0), 0),
        attendanceRate: 0
    };

    summary.attendanceRate = summary.totalDays > 0
        ? parseFloat(((summary.presentDays / summary.totalDays) * 100).toFixed(2))
        : 0;

    return {
        employee,
        period: {
            startDate,
            endDate
        },
        summary,
        attendances
    };
};

/**
 * Generate leave report
 * @param {number} year
 * @param {string} departmentId - Optional
 * @returns {Promise<Object>}
 */
const generateLeaveReport = async (year, departmentId = null) => {
    const startOfYear = new Date(year, 0, 1);
    const endOfYear = new Date(year, 11, 31, 23, 59, 59);

    const whereClause = {
        startDate: {
            gte: startOfYear,
            lte: endOfYear
        },
        status: 'APPROVED'
    };

    if (departmentId) {
        whereClause.employee = {
            departmentId
        };
    }

    const leaves = await prisma.leave.findMany({
        where: whereClause,
        include: {
            employee: {
                select: {
                    id: true,
                    employeeCode: true,
                    firstName: true,
                    lastName: true,
                    department: {
                        select: {
                            name: true
                        }
                    }
                }
            }
        },
        orderBy: {
            startDate: 'asc'
        }
    });

    // Group by employee
    const employeeData = {};

    leaves.forEach(leave => {
        const empId = leave.employee.id;

        if (!employeeData[empId]) {
            employeeData[empId] = {
                employee: leave.employee,
                totalLeaves: 0,
                byType: {
                    ANNUAL: 0,
                    SICK: 0,
                    UNPAID: 0,
                    MATERNITY: 0,
                    PATERNITY: 0
                },
                leaves: []
            };
        }

        const days = calculateLeaveDays(leave.startDate, leave.endDate);
        employeeData[empId].totalLeaves += days;
        if (employeeData[empId].byType[leave.leaveType] !== undefined) {
            employeeData[empId].byType[leave.leaveType] += days;
        }

        employeeData[empId].leaves.push({ ...leave, days });
    });

    const summary = {
        year,
        totalEmployees: Object.keys(employeeData).length,
        totalLeaves: leaves.length,
        totalDays: Object.values(employeeData).reduce((sum, data) => sum + data.totalLeaves, 0),
        byType: {
            ANNUAL: 0,
            SICK: 0,
            UNPAID: 0,
            MATERNITY: 0,
            PATERNITY: 0
        }
    };

    Object.values(employeeData).forEach(data => {
        Object.keys(summary.byType).forEach(type => {
            summary.byType[type] += data.byType[type] || 0;
        });
    });

    return {
        summary,
        data: Object.values(employeeData)
    };
};

/**
 * Helper: Calculate leave days
 */
const calculateLeaveDays = (startDate, endDate) => {
    const start = new Date(startDate);
    const end = new Date(endDate);
    let count = 0;
    const current = new Date(start);

    while (current <= end) {
        const dayOfWeek = current.getDay();
        if (dayOfWeek !== 0 && dayOfWeek !== 6) {
            count++;
        }
        current.setDate(current.getDate() + 1);
    }

    return count;
};

/**
 * Generate overtime report
 * @param {number} year
 * @param {number} month
 * @param {string} departmentId - Optional
 * @returns {Promise<Object>}
 */
const generateOvertimeReport = async (year, month, departmentId = null) => {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0, 23, 59, 59);

    const whereClause = {
        checkInTime: {
            gte: startDate,
            lte: endDate
        },
        overtimeHours: {
            gt: 0
        }
    };

    if (departmentId) {
        whereClause.employee = {
            departmentId
        };
    }

    const attendances = await prisma.attendance.findMany({
        where: whereClause,
        include: {
            employee: {
                select: {
                    id: true,
                    employeeCode: true,
                    firstName: true,
                    lastName: true,
                    department: {
                        select: {
                            name: true
                        }
                    }
                }
            }
        },
        orderBy: {
            overtimeHours: 'desc'
        }
    });

    // Group by employee
    const employeeData = {};

    attendances.forEach(att => {
        const empId = att.employee.id;

        if (!employeeData[empId]) {
            employeeData[empId] = {
                employee: att.employee,
                totalOvertimeDays: 0,
                totalOvertimeHours: 0,
                records: []
            };
        }

        employeeData[empId].totalOvertimeDays++;
        employeeData[empId].totalOvertimeHours += att.overtimeHours;
        employeeData[empId].records.push(att);
    });

    const summary = {
        year,
        month,
        totalEmployees: Object.keys(employeeData).length,
        totalOvertimeRecords: attendances.length,
        totalOvertimeHours: Object.values(employeeData).reduce((sum, data) => sum + data.totalOvertimeHours, 0)
    };

    return {
        summary,
        data: Object.values(employeeData).sort((a, b) => b.totalOvertimeHours - a.totalOvertimeHours)
    };
};

/**
 * Export report to Excel
 * @param {Object} reportData
 * @param {string} reportType - 'attendance', 'leave', 'overtime'
 * @returns {Buffer}
 */
const exportToExcel = (reportData, reportType) => {
    const workbook = XLSX.utils.book_new();

    if (reportType === 'attendance') {
        // Summary sheet
        const summaryData = [
            ['Monthly Attendance Report'],
            ['Year', reportData.summary.year],
            ['Month', reportData.summary.month],
            ['Total Employees', reportData.summary.totalEmployees],
            ['Total Records', reportData.summary.totalAttendanceRecords],
            ['Average Working Hours', reportData.summary.averageWorkingHours],
            ['Total Overtime', reportData.summary.totalOvertimeHours],
            [],
            ['Employee Code', 'Name', 'Department', 'Present Days', 'Late Days', 'Early Leave', 'Working Hours', 'Overtime']
        ];

        reportData.data.forEach(item => {
            summaryData.push([
                item.employee.employeeCode,
                `${item.employee.firstName} ${item.employee.lastName}`,
                item.employee.department.name,
                item.presentDays,
                item.lateDays,
                item.earlyLeaveDays,
                item.totalWorkingHours.toFixed(2),
                item.totalOvertime.toFixed(2)
            ]);
        });

        const ws = XLSX.utils.aoa_to_sheet(summaryData);
        XLSX.utils.book_append_sheet(workbook, ws, 'Summary');
    }

    if (reportType === 'leave') {
        const summaryData = [
            ['Annual Leave Report'],
            ['Year', reportData.summary.year],
            ['Total Employees', reportData.summary.totalEmployees],
            ['Total Leaves', reportData.summary.totalLeaves],
            ['Total Days', reportData.summary.totalDays],
            [],
            ['By Type'],
            ['Annual', reportData.summary.byType.ANNUAL],
            ['Sick', reportData.summary.byType.SICK],
            ['Unpaid', reportData.summary.byType.UNPAID],
            ['Maternity', reportData.summary.byType.MATERNITY],
            ['Paternity', reportData.summary.byType.PATERNITY],
            [],
            ['Employee Code', 'Name', 'Department', 'Total Days', 'Annual', 'Sick', 'Unpaid', 'Maternity', 'Paternity']
        ];

        reportData.data.forEach(item => {
            summaryData.push([
                item.employee.employeeCode,
                `${item.employee.firstName} ${item.employee.lastName}`,
                item.employee.department.name,
                item.totalLeaves,
                item.byType.ANNUAL,
                item.byType.SICK,
                item.byType.UNPAID,
                item.byType.MATERNITY,
                item.byType.PATERNITY
            ]);
        });

        const ws = XLSX.utils.aoa_to_sheet(summaryData);
        XLSX.utils.book_append_sheet(workbook, ws, 'Leave Report');
    }

    if (reportType === 'overtime') {
        const summaryData = [
            ['Overtime Report'],
            ['Year', reportData.summary.year],
            ['Month', reportData.summary.month],
            ['Total Employees', reportData.summary.totalEmployees],
            ['Total Records', reportData.summary.totalOvertimeRecords],
            ['Total Overtime Hours', reportData.summary.totalOvertimeHours.toFixed(2)],
            [],
            ['Employee Code', 'Name', 'Department', 'OT Days', 'Total OT Hours']
        ];

        reportData.data.forEach(item => {
            summaryData.push([
                item.employee.employeeCode,
                `${item.employee.firstName} ${item.employee.lastName}`,
                item.employee.department.name,
                item.totalOvertimeDays,
                item.totalOvertimeHours.toFixed(2)
            ]);
        });

        const ws = XLSX.utils.aoa_to_sheet(summaryData);
        XLSX.utils.book_append_sheet(workbook, ws, 'Overtime');
    }

    return XLSX.write(workbook, { type: 'buffer', bookType: 'xlsx' });
};

module.exports = {
    generateMonthlyAttendanceReport,
    generateEmployeeAttendanceReport,
    generateLeaveReport,
    generateOvertimeReport,
    exportToExcel
};
