const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// @desc    Get overview stats for HR dashboard
// @route   GET /api/dashboard/overview
// @access  Private
exports.getOverviewStats = async (req, res) => {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [
      totalEmployees,
      activeEmployees,
      presentToday,
      lateToday,
      onLeaveToday,
      absentToday,
      pendingLeaveRequests,
      totalDepartments
    ] = await Promise.all([
      // Total employees
      prisma.employee.count(),

      // Active employees
      prisma.employee.count({
        where: { employmentStatus: 'active', isActive: true }
      }),

      // Present today
      prisma.attendance.count({
        where: {
          date: today,
          status: 'present'
        }
      }),

      // Late today
      prisma.attendance.count({
        where: {
          date: today,
          status: 'late'
        }
      }),

      // On leave today
      prisma.attendance.count({
        where: {
          date: today,
          status: 'on_leave'
        }
      }),

      // Absent today
      prisma.attendance.count({
        where: {
          date: today,
          status: 'absent'
        }
      }),

      // Pending leave requests
      prisma.leave.count({
        where: { status: 'pending' }
      }),

      // Total departments
      prisma.department.count({
        where: { isActive: true }
      })
    ]);

    // Calculate attendance rate
    const totalChecked = presentToday + lateToday + onLeaveToday;
    const attendanceRate = activeEmployees > 0
      ? ((totalChecked / activeEmployees) * 100).toFixed(2)
      : 0;

    res.json({
      success: true,
      data: {
        employees: {
          total: totalEmployees,
          active: activeEmployees,
          inactive: totalEmployees - activeEmployees
        },
        attendance: {
          present: presentToday,
          late: lateToday,
          onLeave: onLeaveToday,
          absent: absentToday,
          rate: parseFloat(attendanceRate)
        },
        leave: {
          pending: pendingLeaveRequests
        },
        departments: {
          total: totalDepartments
        }
      }
    });
  } catch (error) {
    console.error('Error in getOverviewStats:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thống kê tổng quan',
      error: error.message
    });
  }
};

// @desc    Get attendance summary
// @route   GET /api/dashboard/attendance-summary
// @access  Private
exports.getAttendanceSummary = async (req, res) => {
  try {
    const { days = 7 } = req.query;

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - parseInt(days));
    startDate.setHours(0, 0, 0, 0);

    const endDate = new Date();
    endDate.setHours(23, 59, 59, 999);

    // Get attendance data grouped by date and status
    const attendanceData = await prisma.attendance.groupBy({
      by: ['date', 'status'],
      where: {
        date: {
          gte: startDate,
          lte: endDate
        }
      },
      _count: {
        id: true
      },
      orderBy: {
        date: 'asc'
      }
    });

    // Format data for charts
    const summary = {};

    attendanceData.forEach(item => {
      const dateKey = item.date.toISOString().split('T')[0];

      if (!summary[dateKey]) {
        summary[dateKey] = {
          date: dateKey,
          present: 0,
          late: 0,
          absent: 0,
          onLeave: 0,
          total: 0
        };
      }

      summary[dateKey][item.status === 'on_leave' ? 'onLeave' : item.status] = item._count.id;
      summary[dateKey].total += item._count.id;
    });

    const chartData = Object.values(summary);

    res.json({
      success: true,
      data: chartData
    });
  } catch (error) {
    console.error('Error in getAttendanceSummary:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy tóm tắt chấm công',
      error: error.message
    });
  }
};

// @desc    Get department stats
// @route   GET /api/dashboard/department-stats
// @access  Private
exports.getDepartmentStats = async (req, res) => {
  try {
    const departments = await prisma.department.findMany({
      where: { isActive: true },
      include: {
        _count: {
          select: {
            employees: {
              where: { isActive: true }
            }
          }
        }
      },
      orderBy: {
        name: 'asc'
      }
    });

    // Get today's attendance for each department
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const stats = await Promise.all(
      departments.map(async (dept) => {
        const [present, late, absent] = await Promise.all([
          prisma.attendance.count({
            where: {
              date: today,
              status: 'present',
              employee: {
                departmentId: dept.id
              }
            }
          }),
          prisma.attendance.count({
            where: {
              date: today,
              status: 'late',
              employee: {
                departmentId: dept.id
              }
            }
          }),
          prisma.attendance.count({
            where: {
              date: today,
              status: 'absent',
              employee: {
                departmentId: dept.id
              }
            }
          })
        ]);

        const total = dept._count.employees;
        const attendanceRate = total > 0 ? (((present + late) / total) * 100).toFixed(2) : 0;

        return {
          id: dept.id,
          code: dept.code,
          name: dept.name,
          totalEmployees: total,
          present,
          late,
          absent,
          attendanceRate: parseFloat(attendanceRate)
        };
      })
    );

    res.json({
      success: true,
      data: stats
    });
  } catch (error) {
    console.error('Error in getDepartmentStats:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thống kê phòng ban',
      error: error.message
    });
  }
};

// @desc    Get leave stats
// @route   GET /api/dashboard/leave-stats
// @access  Private
exports.getLeaveStats = async (req, res) => {
  try {
    const currentMonth = new Date();
    currentMonth.setDate(1);
    currentMonth.setHours(0, 0, 0, 0);

    const nextMonth = new Date(currentMonth);
    nextMonth.setMonth(nextMonth.getMonth() + 1);

    const [pending, approved, rejected, cancelled] = await Promise.all([
      prisma.leave.count({
        where: {
          status: 'pending',
          startDate: {
            gte: currentMonth,
            lt: nextMonth
          }
        }
      }),
      prisma.leave.count({
        where: {
          status: 'approved',
          startDate: {
            gte: currentMonth,
            lt: nextMonth
          }
        }
      }),
      prisma.leave.count({
        where: {
          status: 'rejected',
          startDate: {
            gte: currentMonth,
            lt: nextMonth
          }
        }
      }),
      prisma.leave.count({
        where: {
          status: 'cancelled',
          startDate: {
            gte: currentMonth,
            lt: nextMonth
          }
        }
      })
    ]);

    // Get breakdown by leave type
    const leaveTypes = await prisma.leave.groupBy({
      by: ['leaveType'],
      where: {
        status: 'approved',
        startDate: {
          gte: currentMonth,
          lt: nextMonth
        }
      },
      _count: {
        id: true
      },
      _sum: {
        totalDays: true
      }
    });

    const typeBreakdown = {};
    leaveTypes.forEach(type => {
      typeBreakdown[type.leaveType] = {
        count: type._count.id,
        totalDays: parseFloat(type._sum.totalDays || 0)
      };
    });

    res.json({
      success: true,
      data: {
        summary: {
          pending,
          approved,
          rejected,
          cancelled,
          total: pending + approved + rejected + cancelled
        },
        typeBreakdown
      }
    });
  } catch (error) {
    console.error('Error in getLeaveStats:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thống kê nghỉ phép',
      error: error.message
    });
  }
};

// @desc    Get recent activities
// @route   GET /api/dashboard/recent-activities
// @access  Private
exports.getRecentActivities = async (req, res) => {
  try {
    const { limit = 10 } = req.query;

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Get recent check-ins
    const recentCheckIns = await prisma.attendance.findMany({
      where: {
        date: today,
        checkInTime: {
          not: null
        }
      },
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true,
            avatarUrl: true,
            department: {
              select: {
                name: true
              }
            }
          }
        }
      },
      orderBy: {
        checkInTime: 'desc'
      },
      take: parseInt(limit)
    });

    const activities = recentCheckIns.map(att => ({
      type: 'check_in',
      time: att.checkInTime,
      employee: att.employee,
      status: att.status,
      isLate: att.isLate
    }));

    res.json({
      success: true,
      data: activities
    });
  } catch (error) {
    console.error('Error in getRecentActivities:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy hoạt động gần đây',
      error: error.message
    });
  }
};

// @desc    Get upcoming birthdays
// @route   GET /api/dashboard/upcoming-birthdays
// @access  Private
exports.getUpcomingBirthdays = async (req, res) => {
  try {
    const { days = 30 } = req.query;

    const today = new Date();
    const currentMonth = today.getMonth() + 1;
    const currentDay = today.getDate();

    const endDate = new Date();
    endDate.setDate(endDate.getDate() + parseInt(days));
    const endMonth = endDate.getMonth() + 1;
    const endDay = endDate.getDate();

    // Get employees with birthdays in the range
    const employees = await prisma.employee.findMany({
      where: {
        isActive: true,
        birthDate: {
          not: null
        }
      },
      select: {
        id: true,
        employeeCode: true,
        fullName: true,
        birthDate: true,
        position: true,
        avatarUrl: true,
        department: {
          select: {
            name: true
          }
        }
      }
    });

    // Filter employees with birthdays in range
    const upcomingBirthdays = employees
      .filter(emp => {
        if (!emp.birthDate) return false;

        const birthMonth = emp.birthDate.getMonth() + 1;
        const birthDay = emp.birthDate.getDate();

        if (currentMonth === endMonth) {
          return birthMonth === currentMonth && birthDay >= currentDay && birthDay <= endDay;
        } else {
          return (
            (birthMonth === currentMonth && birthDay >= currentDay) ||
            (birthMonth === endMonth && birthDay <= endDay)
          );
        }
      })
      .map(emp => {
        const birthDate = new Date(today.getFullYear(), emp.birthDate.getMonth(), emp.birthDate.getDate());
        if (birthDate < today) {
          birthDate.setFullYear(birthDate.getFullYear() + 1);
        }

        const daysUntil = Math.ceil((birthDate - today) / (1000 * 60 * 60 * 24));

        return {
          ...emp,
          birthDate: emp.birthDate,
          daysUntil
        };
      })
      .sort((a, b) => a.daysUntil - b.daysUntil);

    res.json({
      success: true,
      data: upcomingBirthdays
    });
  } catch (error) {
    console.error('Error in getUpcomingBirthdays:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách sinh nhật',
      error: error.message
    });
  }
};

// @desc    Get contract expirations
// @route   GET /api/dashboard/contract-expirations
// @access  Private (HR Manager, Admin)
exports.getContractExpirations = async (req, res) => {
  try {
    const { days = 60 } = req.query;

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const endDate = new Date();
    endDate.setDate(endDate.getDate() + parseInt(days));

    const expiringContracts = await prisma.employee.findMany({
      where: {
        isActive: true,
        contractEndDate: {
          gte: today,
          lte: endDate
        }
      },
      select: {
        id: true,
        employeeCode: true,
        fullName: true,
        position: true,
        contractType: true,
        contractEndDate: true,
        hireDate: true,
        email: true,
        phoneNumber: true,
        avatarUrl: true,
        department: {
          select: {
            name: true
          }
        }
      },
      orderBy: {
        contractEndDate: 'asc'
      }
    });

    const contracts = expiringContracts.map(emp => {
      const daysUntilExpiration = Math.ceil(
        (emp.contractEndDate - today) / (1000 * 60 * 60 * 24)
      );

      return {
        ...emp,
        daysUntilExpiration
      };
    });

    res.json({
      success: true,
      data: contracts
    });
  } catch (error) {
    console.error('Error in getContractExpirations:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách hợp đồng sắp hết hạn',
      error: error.message
    });
  }
};
