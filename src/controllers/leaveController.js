const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Helper function to calculate business days
const calculateBusinessDays = (startDate, endDate) => {
  let count = 0;
  const current = new Date(startDate);
  const end = new Date(endDate);

  while (current <= end) {
    const dayOfWeek = current.getDay();
    // Skip weekends (0 = Sunday, 6 = Saturday)
    if (dayOfWeek !== 0 && dayOfWeek !== 6) {
      count++;
    }
    current.setDate(current.getDate() + 1);
  }

  return count;
};

// @desc    Request leave
// @route   POST /api/leaves
// @access  Private
exports.requestLeave = async (req, res) => {
  try {
    const { employeeId, leaveType, startDate, endDate, reason } = req.body;
    const requestorId = req.user.id;

    // Validate employee
    const employee = await prisma.employee.findUnique({
      where: { id: parseInt(employeeId) }
    });

    if (!employee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy nhân viên'
      });
    }

    // Check if user can request leave for this employee
    // Employee can only request leave for themselves
    const user = await prisma.user.findUnique({
      where: { id: requestorId },
      include: { employee: true }
    });

    if (user.role === 'employee' && user.employee.id !== parseInt(employeeId)) {
      return res.status(403).json({
        success: false,
        message: 'Bạn chỉ có thể xin nghỉ phép cho chính mình'
      });
    }

    const start = new Date(startDate);
    const end = new Date(endDate);

    // Validate dates
    if (start > end) {
      return res.status(400).json({
        success: false,
        message: 'Ngày bắt đầu phải trước ngày kết thúc'
      });
    }

    // Calculate total days
    const totalDays = calculateBusinessDays(start, end);

    // Check for overlapping leave requests
    const overlapping = await prisma.leave.findFirst({
      where: {
        employeeId: parseInt(employeeId),
        status: {
          in: ['pending', 'approved']
        },
        startDate: {
          lte: end
        },
        endDate: {
          gte: start
        }
      }
    });

    if (overlapping) {
      return res.status(400).json({
        success: false,
        message: 'Đã có đơn nghỉ phép trong khoảng thời gian này'
      });
    }

    // Create leave request
    const leave = await prisma.leave.create({
      data: {
        employeeId: parseInt(employeeId),
        leaveType,
        startDate: start,
        endDate: end,
        totalDays,
        reason
      },
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true,
            position: true
          }
        }
      }
    });

    res.status(201).json({
      success: true,
      message: 'Tạo đơn nghỉ phép thành công',
      data: leave
    });
  } catch (error) {
    console.error('Error in requestLeave:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo đơn nghỉ phép',
      error: error.message
    });
  }
};

// @desc    Get all leave requests
// @route   GET /api/leaves
// @access  Private
exports.getLeaveRequests = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      employeeId,
      departmentId,
      status,
      leaveType,
      startDate,
      endDate
    } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const where = {};

    if (employeeId) {
      where.employeeId = parseInt(employeeId);
    }

    if (departmentId) {
      where.employee = {
        departmentId: parseInt(departmentId)
      };
    }

    if (status) {
      where.status = status;
    }

    if (leaveType) {
      where.leaveType = leaveType;
    }

    if (startDate && endDate) {
      where.startDate = {
        gte: new Date(startDate),
        lte: new Date(endDate)
      };
    }

    const [leaves, total] = await Promise.all([
      prisma.leave.findMany({
        where,
        skip,
        take: parseInt(limit),
        include: {
          employee: {
            select: {
              id: true,
              employeeCode: true,
              fullName: true,
              position: true,
              avatarUrl: true,
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
              id: true,
              username: true
            }
          }
        },
        orderBy: {
          createdAt: 'desc'
        }
      }),
      prisma.leave.count({ where })
    ]);

    res.json({
      success: true,
      data: leaves,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Error in getLeaveRequests:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách đơn nghỉ phép',
      error: error.message
    });
  }
};

// @desc    Get leave by ID
// @route   GET /api/leaves/:id
// @access  Private
exports.getLeaveById = async (req, res) => {
  try {
    const { id } = req.params;

    const leave = await prisma.leave.findUnique({
      where: { id: parseInt(id) },
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true,
            position: true,
            email: true,
            phoneNumber: true,
            department: true
          }
        },
        approver: {
          select: {
            id: true,
            username: true,
            employee: {
              select: {
                fullName: true
              }
            }
          }
        }
      }
    });

    if (!leave) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đơn nghỉ phép'
      });
    }

    res.json({
      success: true,
      data: leave
    });
  } catch (error) {
    console.error('Error in getLeaveById:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin đơn nghỉ phép',
      error: error.message
    });
  }
};

// @desc    Approve leave
// @route   PUT /api/leaves/:id/approve
// @access  Private (HR Manager, Department Manager, Admin)
exports.approveLeave = async (req, res) => {
  try {
    const { id } = req.params;
    const approvedBy = req.user.id;

    // Check if leave request exists
    const leave = await prisma.leave.findUnique({
      where: { id: parseInt(id) },
      include: {
        employee: true
      }
    });

    if (!leave) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đơn nghỉ phép'
      });
    }

    if (leave.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Đơn nghỉ phép đã được xử lý'
      });
    }

    // Update leave status
    const updatedLeave = await prisma.leave.update({
      where: { id: parseInt(id) },
      data: {
        status: 'approved',
        approvedBy,
        approvedAt: new Date()
      },
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true
          }
        },
        approver: {
          select: {
            id: true,
            username: true
          }
        }
      }
    });

    // Create attendance records for approved leave
    const attendanceDates = [];
    const current = new Date(leave.startDate);
    const end = new Date(leave.endDate);

    while (current <= end) {
      const dayOfWeek = current.getDay();
      // Skip weekends
      if (dayOfWeek !== 0 && dayOfWeek !== 6) {
        attendanceDates.push(new Date(current));
      }
      current.setDate(current.getDate() + 1);
    }

    // Create attendance records for each day
    const attendancePromises = attendanceDates.map(date => {
      const attendanceDate = new Date(date);
      attendanceDate.setHours(0, 0, 0, 0);

      return prisma.attendance.upsert({
        where: {
          employeeId_date: {
            employeeId: leave.employeeId,
            date: attendanceDate
          }
        },
        update: {
          status: 'on_leave',
          note: `Nghỉ phép: ${leave.reason}`
        },
        create: {
          employeeId: leave.employeeId,
          date: attendanceDate,
          status: 'on_leave',
          note: `Nghỉ phép: ${leave.reason}`,
          checkInMethod: 'manual',
          checkOutMethod: 'manual',
          markedBy: approvedBy,
          markedAt: new Date()
        }
      });
    });

    await Promise.all(attendancePromises);

    res.json({
      success: true,
      message: 'Phê duyệt đơn nghỉ phép thành công',
      data: updatedLeave
    });
  } catch (error) {
    console.error('Error in approveLeave:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi phê duyệt đơn nghỉ phép',
      error: error.message
    });
  }
};

// @desc    Reject leave
// @route   PUT /api/leaves/:id/reject
// @access  Private (HR Manager, Department Manager, Admin)
exports.rejectLeave = async (req, res) => {
  try {
    const { id } = req.params;
    const { rejectedReason } = req.body;
    const approvedBy = req.user.id;

    const leave = await prisma.leave.findUnique({
      where: { id: parseInt(id) }
    });

    if (!leave) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đơn nghỉ phép'
      });
    }

    if (leave.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Đơn nghỉ phép đã được xử lý'
      });
    }

    const updatedLeave = await prisma.leave.update({
      where: { id: parseInt(id) },
      data: {
        status: 'rejected',
        approvedBy,
        approvedAt: new Date(),
        rejectedReason
      },
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true
          }
        },
        approver: {
          select: {
            id: true,
            username: true
          }
        }
      }
    });

    res.json({
      success: true,
      message: 'Từ chối đơn nghỉ phép',
      data: updatedLeave
    });
  } catch (error) {
    console.error('Error in rejectLeave:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi từ chối đơn nghỉ phép',
      error: error.message
    });
  }
};

// @desc    Cancel leave
// @route   DELETE /api/leaves/:id
// @access  Private
exports.cancelLeave = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const leave = await prisma.leave.findUnique({
      where: { id: parseInt(id) },
      include: {
        employee: {
          include: {
            user: true
          }
        }
      }
    });

    if (!leave) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy đơn nghỉ phép'
      });
    }

    // Only the employee or HR/Admin can cancel
    const user = await prisma.user.findUnique({
      where: { id: userId }
    });

    if (
      leave.employee.user.id !== userId &&
      !['admin', 'hr_manager'].includes(user.role)
    ) {
      return res.status(403).json({
        success: false,
        message: 'Bạn không có quyền hủy đơn nghỉ phép này'
      });
    }

    if (leave.status === 'cancelled') {
      return res.status(400).json({
        success: false,
        message: 'Đơn nghỉ phép đã bị hủy'
      });
    }

    // Update leave status
    await prisma.leave.update({
      where: { id: parseInt(id) },
      data: {
        status: 'cancelled'
      }
    });

    // If leave was approved, remove attendance records
    if (leave.status === 'approved') {
      const attendanceDates = [];
      const current = new Date(leave.startDate);
      const end = new Date(leave.endDate);

      while (current <= end) {
        const dayOfWeek = current.getDay();
        if (dayOfWeek !== 0 && dayOfWeek !== 6) {
          const date = new Date(current);
          date.setHours(0, 0, 0, 0);
          attendanceDates.push(date);
        }
        current.setDate(current.getDate() + 1);
      }

      // Delete attendance records
      await prisma.attendance.deleteMany({
        where: {
          employeeId: leave.employeeId,
          date: {
            in: attendanceDates
          },
          status: 'on_leave'
        }
      });
    }

    res.json({
      success: true,
      message: 'Hủy đơn nghỉ phép thành công'
    });
  } catch (error) {
    console.error('Error in cancelLeave:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi hủy đơn nghỉ phép',
      error: error.message
    });
  }
};

// @desc    Get employee leaves
// @route   GET /api/employees/:id/leaves
// @access  Private
exports.getEmployeeLeaves = async (req, res) => {
  try {
    const { id } = req.params;
    const { year, status } = req.query;

    const where = {
      employeeId: parseInt(id)
    };

    if (status) {
      where.status = status;
    }

    if (year) {
      where.startDate = {
        gte: new Date(`${year}-01-01`),
        lte: new Date(`${year}-12-31`)
      };
    }

    const leaves = await prisma.leave.findMany({
      where,
      include: {
        approver: {
          select: {
            id: true,
            username: true
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    res.json({
      success: true,
      data: leaves
    });
  } catch (error) {
    console.error('Error in getEmployeeLeaves:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách nghỉ phép',
      error: error.message
    });
  }
};

// @desc    Get leave balance
// @route   GET /api/employees/:id/leave-balance
// @access  Private
exports.getLeaveBalance = async (req, res) => {
  try {
    const { id } = req.params;
    const { year = new Date().getFullYear() } = req.query;

    // Calculate total approved leave days in the year
    const leaves = await prisma.leave.findMany({
      where: {
        employeeId: parseInt(id),
        status: 'approved',
        startDate: {
          gte: new Date(`${year}-01-01`),
          lte: new Date(`${year}-12-31`)
        }
      }
    });

    const totalUsed = leaves.reduce((sum, leave) => {
      return sum + parseFloat(leave.totalDays);
    }, 0);

    // TODO: Get annual leave entitlement from employee contract or company policy
    // For now, assume 12 days per year
    const annualEntitlement = 12;

    const balance = {
      year: parseInt(year),
      annualEntitlement,
      totalUsed,
      remaining: annualEntitlement - totalUsed,
      breakdown: {
        annual: 0,
        sick: 0,
        unpaid: 0,
        maternity: 0,
        paternity: 0,
        personal: 0
      }
    };

    // Calculate breakdown by leave type
    leaves.forEach(leave => {
      balance.breakdown[leave.leaveType] += parseFloat(leave.totalDays);
    });

    res.json({
      success: true,
      data: balance
    });
  } catch (error) {
    console.error('Error in getLeaveBalance:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy số ngày phép còn lại',
      error: error.message
    });
  }
};

// @desc    Get leave stats
// @route   GET /api/leaves/stats
// @access  Private (HR Manager, Admin)
exports.getLeaveStats = async (req, res) => {
  try {
    const { departmentId, year = new Date().getFullYear() } = req.query;

    const where = {
      startDate: {
        gte: new Date(`${year}-01-01`),
        lte: new Date(`${year}-12-31`)
      }
    };

    if (departmentId) {
      where.employee = {
        departmentId: parseInt(departmentId)
      };
    }

    const [total, pending, approved, rejected, cancelled] = await Promise.all([
      prisma.leave.count({ where }),
      prisma.leave.count({ where: { ...where, status: 'pending' } }),
      prisma.leave.count({ where: { ...where, status: 'approved' } }),
      prisma.leave.count({ where: { ...where, status: 'rejected' } }),
      prisma.leave.count({ where: { ...where, status: 'cancelled' } })
    ]);

    // Get breakdown by leave type
    const leaveTypes = await prisma.leave.groupBy({
      by: ['leaveType'],
      where: { ...where, status: 'approved' },
      _sum: {
        totalDays: true
      },
      _count: {
        id: true
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
        year: parseInt(year),
        total,
        pending,
        approved,
        rejected,
        cancelled,
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
