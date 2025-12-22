const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// @desc    Get monthly attendance report
// @route   GET /api/reports/attendance/monthly
// @access  Private (HR Manager, Admin)
exports.getMonthlyAttendanceReport = async (req, res) => {
  try {
    const { year, month, departmentId } = req.query;

    const targetYear = year || new Date().getFullYear();
    const targetMonth = month || new Date().getMonth() + 1;

    const startDate = new Date(targetYear, targetMonth - 1, 1);
    const endDate = new Date(targetYear, targetMonth, 0);
    endDate.setHours(23, 59, 59, 999);

    const where = {
      date: {
        gte: startDate,
        lte: endDate
      }
    };

    if (departmentId) {
      where.employee = {
        departmentId: parseInt(departmentId)
      };
    }

    // Get all attendance records
    const attendances = await prisma.attendance.findMany({
      where,
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true,
            position: true,
            department: {
              select: {
                id: true,
                name: true
              }
            }
          }
        },
        shift: {
          select: {
            name: true
          }
        }
      },
      orderBy: [
        { employee: { fullName: 'asc' } },
        { date: 'asc' }
      ]
    });

    // Group by employee
    const reportData = {};

    attendances.forEach(att => {
      const empId = att.employee.id;

      if (!reportData[empId]) {
        reportData[empId] = {
          employee: att.employee,
          summary: {
            totalDays: 0,
            present: 0,
            late: 0,
            absent: 0,
            onLeave: 0,
            totalWorkingHours: 0,
            totalOvertimeHours: 0
          },
          records: []
        };
      }

      reportData[empId].records.push({
        date: att.date,
        checkInTime: att.checkInTime,
        checkOutTime: att.checkOutTime,
        status: att.status,
        isLate: att.isLate,
        isEarlyLeave: att.isEarlyLeave,
        workingHours: parseFloat(att.workingHours || 0),
        overtimeHours: parseFloat(att.overtimeHours || 0),
        shift: att.shift?.name,
        note: att.note
      });

      // Update summary
      reportData[empId].summary.totalDays++;
      reportData[empId].summary[att.status]++;
      reportData[empId].summary.totalWorkingHours += parseFloat(att.workingHours || 0);
      reportData[empId].summary.totalOvertimeHours += parseFloat(att.overtimeHours || 0);
    });

    const report = Object.values(reportData);

    res.json({
      success: true,
      data: {
        period: {
          year: parseInt(targetYear),
          month: parseInt(targetMonth),
          startDate,
          endDate
        },
        report
      }
    });
  } catch (error) {
    console.error('Error in getMonthlyAttendanceReport:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo báo cáo chấm công tháng',
      error: error.message
    });
  }
};

// @desc    Get department attendance report
// @route   GET /api/reports/attendance/department
// @access  Private (HR Manager, Department Manager, Admin)
exports.getDepartmentAttendanceReport = async (req, res) => {
  try {
    const { departmentId, startDate, endDate } = req.query;

    if (!departmentId) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng chọn phòng ban'
      });
    }

    const start = startDate ? new Date(startDate) : new Date();
    start.setHours(0, 0, 0, 0);

    const end = endDate ? new Date(endDate) : new Date();
    end.setHours(23, 59, 59, 999);

    const department = await prisma.department.findUnique({
      where: { id: parseInt(departmentId) },
      include: {
        employees: {
          where: { isActive: true }
        }
      }
    });

    if (!department) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy phòng ban'
      });
    }

    // Get attendance stats for each employee
    const employeeStats = await Promise.all(
      department.employees.map(async (emp) => {
        const [present, late, absent, onLeave] = await Promise.all([
          prisma.attendance.count({
            where: {
              employeeId: emp.id,
              date: { gte: start, lte: end },
              status: 'present'
            }
          }),
          prisma.attendance.count({
            where: {
              employeeId: emp.id,
              date: { gte: start, lte: end },
              status: 'late'
            }
          }),
          prisma.attendance.count({
            where: {
              employeeId: emp.id,
              date: { gte: start, lte: end },
              status: 'absent'
            }
          }),
          prisma.attendance.count({
            where: {
              employeeId: emp.id,
              date: { gte: start, lte: end },
              status: 'on_leave'
            }
          })
        ]);

        // Get working hours
        const attendances = await prisma.attendance.findMany({
          where: {
            employeeId: emp.id,
            date: { gte: start, lte: end }
          },
          select: {
            workingHours: true,
            overtimeHours: true
          }
        });

        const totalWorkingHours = attendances.reduce(
          (sum, att) => sum + parseFloat(att.workingHours || 0),
          0
        );

        const totalOvertimeHours = attendances.reduce(
          (sum, att) => sum + parseFloat(att.overtimeHours || 0),
          0
        );

        const total = present + late + absent + onLeave;
        const attendanceRate = total > 0 ? ((present + late) / total * 100).toFixed(2) : 0;

        return {
          employee: {
            id: emp.id,
            employeeCode: emp.employeeCode,
            fullName: emp.fullName,
            position: emp.position
          },
          stats: {
            present,
            late,
            absent,
            onLeave,
            total,
            attendanceRate: parseFloat(attendanceRate),
            totalWorkingHours: totalWorkingHours.toFixed(2),
            totalOvertimeHours: totalOvertimeHours.toFixed(2)
          }
        };
      })
    );

    res.json({
      success: true,
      data: {
        department: {
          id: department.id,
          code: department.code,
          name: department.name
        },
        period: {
          startDate: start,
          endDate: end
        },
        employees: employeeStats
      }
    });
  } catch (error) {
    console.error('Error in getDepartmentAttendanceReport:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo báo cáo chấm công phòng ban',
      error: error.message
    });
  }
};

// @desc    Get employee attendance report
// @route   GET /api/reports/attendance/employee/:id
// @access  Private
exports.getEmployeeAttendanceReport = async (req, res) => {
  try {
    const { id } = req.params;
    const { startDate, endDate } = req.query;

    const start = startDate ? new Date(startDate) : new Date();
    start.setDate(1);
    start.setHours(0, 0, 0, 0);

    const end = endDate ? new Date(endDate) : new Date();
    end.setHours(23, 59, 59, 999);

    const employee = await prisma.employee.findUnique({
      where: { id: parseInt(id) },
      include: {
        department: true
      }
    });

    if (!employee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy nhân viên'
      });
    }

    const attendances = await prisma.attendance.findMany({
      where: {
        employeeId: parseInt(id),
        date: {
          gte: start,
          lte: end
        }
      },
      include: {
        shift: {
          select: {
            name: true,
            startTime: true,
            endTime: true
          }
        }
      },
      orderBy: {
        date: 'asc'
      }
    });

    // Calculate summary
    const summary = {
      totalDays: attendances.length,
      present: 0,
      late: 0,
      absent: 0,
      onLeave: 0,
      earlyLeave: 0,
      totalWorkingHours: 0,
      totalOvertimeHours: 0
    };

    attendances.forEach(att => {
      summary[att.status]++;
      if (att.isEarlyLeave) summary.earlyLeave++;
      summary.totalWorkingHours += parseFloat(att.workingHours || 0);
      summary.totalOvertimeHours += parseFloat(att.overtimeHours || 0);
    });

    const attendanceRate = summary.totalDays > 0
      ? ((summary.present + summary.late) / summary.totalDays * 100).toFixed(2)
      : 0;

    res.json({
      success: true,
      data: {
        employee: {
          id: employee.id,
          employeeCode: employee.employeeCode,
          fullName: employee.fullName,
          position: employee.position,
          department: employee.department
        },
        period: {
          startDate: start,
          endDate: end
        },
        summary: {
          ...summary,
          attendanceRate: parseFloat(attendanceRate),
          totalWorkingHours: summary.totalWorkingHours.toFixed(2),
          totalOvertimeHours: summary.totalOvertimeHours.toFixed(2)
        },
        records: attendances.map(att => ({
          date: att.date,
          checkInTime: att.checkInTime,
          checkOutTime: att.checkOutTime,
          status: att.status,
          isLate: att.isLate,
          isEarlyLeave: att.isEarlyLeave,
          workingHours: parseFloat(att.workingHours || 0).toFixed(2),
          overtimeHours: parseFloat(att.overtimeHours || 0).toFixed(2),
          shift: att.shift,
          note: att.note
        }))
      }
    });
  } catch (error) {
    console.error('Error in getEmployeeAttendanceReport:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo báo cáo chấm công nhân viên',
      error: error.message
    });
  }
};

// @desc    Get leave report
// @route   GET /api/reports/leave
// @access  Private (HR Manager, Admin)
exports.getLeaveReport = async (req, res) => {
  try {
    const { year, month, departmentId, leaveType, status } = req.query;

    const targetYear = year || new Date().getFullYear();
    const targetMonth = month || new Date().getMonth() + 1;

    const startDate = new Date(targetYear, targetMonth - 1, 1);
    const endDate = new Date(targetYear, targetMonth, 0);
    endDate.setHours(23, 59, 59, 999);

    const where = {
      startDate: {
        gte: startDate,
        lte: endDate
      }
    };

    if (departmentId) {
      where.employee = {
        departmentId: parseInt(departmentId)
      };
    }

    if (leaveType) {
      where.leaveType = leaveType;
    }

    if (status) {
      where.status = status;
    }

    const leaves = await prisma.leave.findMany({
      where,
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true,
            position: true,
            department: {
              select: {
                id: true,
                name: true
              }
            }
          }
        },
        approver: {
          select: {
            username: true,
            employee: {
              select: {
                fullName: true
              }
            }
          }
        }
      },
      orderBy: {
        startDate: 'asc'
      }
    });

    // Calculate summary
    const summary = {
      total: leaves.length,
      pending: 0,
      approved: 0,
      rejected: 0,
      cancelled: 0,
      totalDays: 0,
      byType: {}
    };

    leaves.forEach(leave => {
      summary[leave.status]++;
      summary.totalDays += parseFloat(leave.totalDays);

      if (!summary.byType[leave.leaveType]) {
        summary.byType[leave.leaveType] = {
          count: 0,
          totalDays: 0
        };
      }

      summary.byType[leave.leaveType].count++;
      summary.byType[leave.leaveType].totalDays += parseFloat(leave.totalDays);
    });

    res.json({
      success: true,
      data: {
        period: {
          year: parseInt(targetYear),
          month: parseInt(targetMonth),
          startDate,
          endDate
        },
        summary,
        leaves: leaves.map(leave => ({
          id: leave.id,
          employee: leave.employee,
          leaveType: leave.leaveType,
          startDate: leave.startDate,
          endDate: leave.endDate,
          totalDays: parseFloat(leave.totalDays),
          reason: leave.reason,
          status: leave.status,
          approver: leave.approver,
          approvedAt: leave.approvedAt,
          rejectedReason: leave.rejectedReason
        }))
      }
    });
  } catch (error) {
    console.error('Error in getLeaveReport:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo báo cáo nghỉ phép',
      error: error.message
    });
  }
};

// @desc    Get overtime report
// @route   GET /api/reports/overtime
// @access  Private (HR Manager, Admin)
exports.getOvertimeReport = async (req, res) => {
  try {
    const { year, month, departmentId } = req.query;

    const targetYear = year || new Date().getFullYear();
    const targetMonth = month || new Date().getMonth() + 1;

    const startDate = new Date(targetYear, targetMonth - 1, 1);
    const endDate = new Date(targetYear, targetMonth, 0);
    endDate.setHours(23, 59, 59, 999);

    const where = {
      date: {
        gte: startDate,
        lte: endDate
      },
      overtimeHours: {
        gt: 0
      }
    };

    if (departmentId) {
      where.employee = {
        departmentId: parseInt(departmentId)
      };
    }

    const overtimeRecords = await prisma.attendance.findMany({
      where,
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true,
            position: true,
            department: {
              select: {
                id: true,
                name: true
              }
            }
          }
        },
        shift: {
          select: {
            name: true
          }
        }
      },
      orderBy: [
        { employee: { fullName: 'asc' } },
        { date: 'asc' }
      ]
    });

    // Group by employee
    const employeeOvertimeMap = {};

    overtimeRecords.forEach(record => {
      const empId = record.employee.id;

      if (!employeeOvertimeMap[empId]) {
        employeeOvertimeMap[empId] = {
          employee: record.employee,
          totalOvertimeHours: 0,
          overtimeDays: 0,
          records: []
        };
      }

      employeeOvertimeMap[empId].totalOvertimeHours += parseFloat(record.overtimeHours);
      employeeOvertimeMap[empId].overtimeDays++;
      employeeOvertimeMap[empId].records.push({
        date: record.date,
        checkInTime: record.checkInTime,
        checkOutTime: record.checkOutTime,
        workingHours: parseFloat(record.workingHours || 0).toFixed(2),
        overtimeHours: parseFloat(record.overtimeHours || 0).toFixed(2),
        shift: record.shift?.name
      });
    });

    const report = Object.values(employeeOvertimeMap).map(emp => ({
      ...emp,
      totalOvertimeHours: emp.totalOvertimeHours.toFixed(2)
    }));

    const totalOvertimeHours = report.reduce((sum, emp) => sum + parseFloat(emp.totalOvertimeHours), 0);

    res.json({
      success: true,
      data: {
        period: {
          year: parseInt(targetYear),
          month: parseInt(targetMonth),
          startDate,
          endDate
        },
        summary: {
          totalEmployees: report.length,
          totalOvertimeHours: totalOvertimeHours.toFixed(2)
        },
        report
      }
    });
  } catch (error) {
    console.error('Error in getOvertimeReport:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo báo cáo làm thêm giờ',
      error: error.message
    });
  }
};

// @desc    Export report (placeholder for Excel/PDF export)
// @route   POST /api/reports/export
// @access  Private (HR Manager, Admin)
exports.exportReport = async (req, res) => {
  try {
    const { reportType, format, filters } = req.body;

    // TODO: Implement Excel/PDF export
    // This would use libraries like exceljs or pdfkit

    res.json({
      success: true,
      message: 'Chức năng export đang được phát triển',
      data: {
        reportType,
        format,
        filters
      }
    });
  } catch (error) {
    console.error('Error in exportReport:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi export báo cáo',
      error: error.message
    });
  }
};
