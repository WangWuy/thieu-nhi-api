const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// @desc    Get all shifts
// @route   GET /api/shifts
// @access  Private
exports.getShifts = async (req, res) => {
  try {
    const { departmentId, isActive } = req.query;

    const where = {};

    if (departmentId) {
      where.departmentId = parseInt(departmentId);
    }

    if (isActive !== undefined) {
      where.isActive = isActive === 'true';
    }

    const shifts = await prisma.shift.findMany({
      where,
      include: {
        department: {
          select: {
            id: true,
            code: true,
            name: true
          }
        },
        _count: {
          select: {
            employeeShifts: true,
            attendances: true
          }
        }
      },
      orderBy: {
        name: 'asc'
      }
    });

    res.json({
      success: true,
      data: shifts
    });
  } catch (error) {
    console.error('Error in getShifts:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách ca làm việc',
      error: error.message
    });
  }
};

// @desc    Get shift by ID
// @route   GET /api/shifts/:id
// @access  Private
exports.getShiftById = async (req, res) => {
  try {
    const { id } = req.params;

    const shift = await prisma.shift.findUnique({
      where: { id: parseInt(id) },
      include: {
        department: true,
        employeeShifts: {
          where: {
            isActive: true
          },
          include: {
            employee: {
              select: {
                id: true,
                employeeCode: true,
                fullName: true,
                position: true,
                avatarUrl: true
              }
            }
          }
        }
      }
    });

    if (!shift) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy ca làm việc'
      });
    }

    res.json({
      success: true,
      data: shift
    });
  } catch (error) {
    console.error('Error in getShiftById:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin ca làm việc',
      error: error.message
    });
  }
};

// @desc    Create new shift
// @route   POST /api/shifts
// @access  Private (HR Manager, Admin)
exports.createShift = async (req, res) => {
  try {
    const {
      name,
      code,
      departmentId,
      startTime,
      endTime,
      breakDuration,
      workingDays,
      lateGracePeriod,
      earlyLeaveGracePeriod
    } = req.body;

    // Check if code already exists
    const existingShift = await prisma.shift.findUnique({
      where: { code }
    });

    if (existingShift) {
      return res.status(400).json({
        success: false,
        message: 'Mã ca làm việc đã tồn tại'
      });
    }

    // Parse time strings to Time format
    // Expecting format like "08:00:00" or "08:00"
    const shift = await prisma.shift.create({
      data: {
        name,
        code,
        departmentId: departmentId ? parseInt(departmentId) : null,
        startTime: new Date(`1970-01-01T${startTime}`),
        endTime: new Date(`1970-01-01T${endTime}`),
        breakDuration: parseInt(breakDuration) || 60,
        workingDays: workingDays || [1, 2, 3, 4, 5], // Default: Mon-Fri
        lateGracePeriod: parseInt(lateGracePeriod) || 15,
        earlyLeaveGracePeriod: parseInt(earlyLeaveGracePeriod) || 15
      },
      include: {
        department: true
      }
    });

    res.status(201).json({
      success: true,
      message: 'Tạo ca làm việc thành công',
      data: shift
    });
  } catch (error) {
    console.error('Error in createShift:', error);

    if (error.code === 'P2002') {
      return res.status(400).json({
        success: false,
        message: 'Mã ca làm việc đã tồn tại'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo ca làm việc',
      error: error.message
    });
  }
};

// @desc    Update shift
// @route   PUT /api/shifts/:id
// @access  Private (HR Manager, Admin)
exports.updateShift = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name,
      code,
      departmentId,
      startTime,
      endTime,
      breakDuration,
      workingDays,
      lateGracePeriod,
      earlyLeaveGracePeriod,
      isActive
    } = req.body;

    // Check if shift exists
    const existingShift = await prisma.shift.findUnique({
      where: { id: parseInt(id) }
    });

    if (!existingShift) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy ca làm việc'
      });
    }

    // Prepare update data
    const updateData = {};

    if (name) updateData.name = name;
    if (code) updateData.code = code;
    if (departmentId !== undefined) {
      updateData.departmentId = departmentId ? parseInt(departmentId) : null;
    }
    if (startTime) updateData.startTime = new Date(`1970-01-01T${startTime}`);
    if (endTime) updateData.endTime = new Date(`1970-01-01T${endTime}`);
    if (breakDuration !== undefined) updateData.breakDuration = parseInt(breakDuration);
    if (workingDays) updateData.workingDays = workingDays;
    if (lateGracePeriod !== undefined) updateData.lateGracePeriod = parseInt(lateGracePeriod);
    if (earlyLeaveGracePeriod !== undefined) {
      updateData.earlyLeaveGracePeriod = parseInt(earlyLeaveGracePeriod);
    }
    if (isActive !== undefined) updateData.isActive = isActive;

    // Update shift
    const shift = await prisma.shift.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        department: true
      }
    });

    res.json({
      success: true,
      message: 'Cập nhật ca làm việc thành công',
      data: shift
    });
  } catch (error) {
    console.error('Error in updateShift:', error);

    if (error.code === 'P2002') {
      return res.status(400).json({
        success: false,
        message: 'Mã ca làm việc đã tồn tại'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật ca làm việc',
      error: error.message
    });
  }
};

// @desc    Delete shift
// @route   DELETE /api/shifts/:id
// @access  Private (Admin only)
exports.deleteShift = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if shift has active assignments
    const activeAssignments = await prisma.employeeShift.count({
      where: {
        shiftId: parseInt(id),
        isActive: true
      }
    });

    if (activeAssignments > 0) {
      return res.status(400).json({
        success: false,
        message: 'Không thể xóa ca làm việc đang có nhân viên được phân công'
      });
    }

    // Soft delete by setting isActive to false
    await prisma.shift.update({
      where: { id: parseInt(id) },
      data: {
        isActive: false
      }
    });

    res.json({
      success: true,
      message: 'Xóa ca làm việc thành công'
    });
  } catch (error) {
    console.error('Error in deleteShift:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa ca làm việc',
      error: error.message
    });
  }
};

// @desc    Assign employee to shift
// @route   POST /api/shifts/:id/assign
// @access  Private (HR Manager, Admin)
exports.assignEmployeeToShift = async (req, res) => {
  try {
    const { id } = req.params;
    const { employeeId, effectiveFrom, effectiveTo } = req.body;

    // Check if shift exists
    const shift = await prisma.shift.findUnique({
      where: { id: parseInt(id) }
    });

    if (!shift) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy ca làm việc'
      });
    }

    // Check if employee exists
    const employee = await prisma.employee.findUnique({
      where: { id: parseInt(employeeId) }
    });

    if (!employee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy nhân viên'
      });
    }

    const effectiveFromDate = new Date(effectiveFrom);
    const effectiveToDate = effectiveTo ? new Date(effectiveTo) : null;

    // Check for overlapping shift assignments
    const overlapping = await prisma.employeeShift.findFirst({
      where: {
        employeeId: parseInt(employeeId),
        isActive: true,
        effectiveFrom: {
          lte: effectiveToDate || new Date('2099-12-31')
        },
        OR: [
          { effectiveTo: null },
          {
            effectiveTo: {
              gte: effectiveFromDate
            }
          }
        ]
      }
    });

    if (overlapping) {
      return res.status(400).json({
        success: false,
        message: 'Nhân viên đã được phân công ca làm việc trong khoảng thời gian này'
      });
    }

    // Create assignment
    const assignment = await prisma.employeeShift.create({
      data: {
        employeeId: parseInt(employeeId),
        shiftId: parseInt(id),
        effectiveFrom: effectiveFromDate,
        effectiveTo: effectiveToDate
      },
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true,
            position: true
          }
        },
        shift: true
      }
    });

    res.status(201).json({
      success: true,
      message: 'Phân công ca làm việc thành công',
      data: assignment
    });
  } catch (error) {
    console.error('Error in assignEmployeeToShift:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi phân công ca làm việc',
      error: error.message
    });
  }
};

// @desc    Remove employee from shift
// @route   DELETE /api/shifts/:id/unassign/:employeeId
// @access  Private (HR Manager, Admin)
exports.removeEmployeeFromShift = async (req, res) => {
  try {
    const { id, employeeId } = req.params;

    // Find active assignment
    const assignment = await prisma.employeeShift.findFirst({
      where: {
        shiftId: parseInt(id),
        employeeId: parseInt(employeeId),
        isActive: true
      }
    });

    if (!assignment) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy phân công ca làm việc'
      });
    }

    // Deactivate assignment
    await prisma.employeeShift.update({
      where: { id: assignment.id },
      data: {
        isActive: false,
        effectiveTo: new Date()
      }
    });

    res.json({
      success: true,
      message: 'Hủy phân công ca làm việc thành công'
    });
  } catch (error) {
    console.error('Error in removeEmployeeFromShift:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi hủy phân công ca làm việc',
      error: error.message
    });
  }
};

// @desc    Get employee shifts
// @route   GET /api/shifts/employee/:employeeId
// @access  Private
exports.getEmployeeShifts = async (req, res) => {
  try {
    const { employeeId } = req.params;
    const { includeInactive } = req.query;

    const where = {
      employeeId: parseInt(employeeId)
    };

    if (!includeInactive) {
      where.isActive = true;
    }

    const shifts = await prisma.employeeShift.findMany({
      where,
      include: {
        shift: {
          include: {
            department: {
              select: {
                id: true,
                name: true
              }
            }
          }
        }
      },
      orderBy: {
        effectiveFrom: 'desc'
      }
    });

    res.json({
      success: true,
      data: shifts
    });
  } catch (error) {
    console.error('Error in getEmployeeShifts:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách ca làm việc của nhân viên',
      error: error.message
    });
  }
};
