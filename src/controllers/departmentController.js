const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// @desc    Get all departments
// @route   GET /api/departments
// @access  Private
exports.getDepartments = async (req, res) => {
  try {
    const { includeInactive } = req.query;

    const where = {};

    if (!includeInactive) {
      where.isActive = true;
    }

    const departments = await prisma.department.findMany({
      where,
      include: {
        parent: {
          select: {
            id: true,
            code: true,
            name: true
          }
        },
        _count: {
          select: {
            employees: {
              where: { isActive: true }
            },
            children: true,
            shifts: true
          }
        }
      },
      orderBy: {
        name: 'asc'
      }
    });

    res.json({
      success: true,
      data: departments
    });
  } catch (error) {
    console.error('Error in getDepartments:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách phòng ban',
      error: error.message
    });
  }
};

// @desc    Get department by ID
// @route   GET /api/departments/:id
// @access  Private
exports.getDepartmentById = async (req, res) => {
  try {
    const { id } = req.params;

    const department = await prisma.department.findUnique({
      where: { id: parseInt(id) },
      include: {
        parent: true,
        children: {
          include: {
            _count: {
              select: {
                employees: true
              }
            }
          }
        },
        employees: {
          where: { isActive: true },
          select: {
            id: true,
            employeeCode: true,
            fullName: true,
            position: true,
            email: true,
            phoneNumber: true,
            avatarUrl: true,
            employmentStatus: true
          }
        },
        shifts: {
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

    res.json({
      success: true,
      data: department
    });
  } catch (error) {
    console.error('Error in getDepartmentById:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin phòng ban',
      error: error.message
    });
  }
};

// @desc    Create department
// @route   POST /api/departments
// @access  Private (HR Manager, Admin)
exports.createDepartment = async (req, res) => {
  try {
    const { code, name, description, managerId, parentId } = req.body;

    // Check if code already exists
    const existing = await prisma.department.findUnique({
      where: { code }
    });

    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'Mã phòng ban đã tồn tại'
      });
    }

    const department = await prisma.department.create({
      data: {
        code,
        name,
        description,
        managerId: managerId ? parseInt(managerId) : null,
        parentId: parentId ? parseInt(parentId) : null
      },
      include: {
        parent: true
      }
    });

    res.status(201).json({
      success: true,
      message: 'Tạo phòng ban thành công',
      data: department
    });
  } catch (error) {
    console.error('Error in createDepartment:', error);

    if (error.code === 'P2002') {
      return res.status(400).json({
        success: false,
        message: 'Mã phòng ban đã tồn tại'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo phòng ban',
      error: error.message
    });
  }
};

// @desc    Update department
// @route   PUT /api/departments/:id
// @access  Private (HR Manager, Admin)
exports.updateDepartment = async (req, res) => {
  try {
    const { id } = req.params;
    const { code, name, description, managerId, parentId, isActive } = req.body;

    const updateData = {};

    if (code) updateData.code = code;
    if (name) updateData.name = name;
    if (description !== undefined) updateData.description = description;
    if (managerId !== undefined) {
      updateData.managerId = managerId ? parseInt(managerId) : null;
    }
    if (parentId !== undefined) {
      updateData.parentId = parentId ? parseInt(parentId) : null;
    }
    if (isActive !== undefined) updateData.isActive = isActive;

    const department = await prisma.department.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        parent: true
      }
    });

    res.json({
      success: true,
      message: 'Cập nhật phòng ban thành công',
      data: department
    });
  } catch (error) {
    console.error('Error in updateDepartment:', error);

    if (error.code === 'P2002') {
      return res.status(400).json({
        success: false,
        message: 'Mã phòng ban đã tồn tại'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật phòng ban',
      error: error.message
    });
  }
};

// @desc    Delete department
// @route   DELETE /api/departments/:id
// @access  Private (Admin)
exports.deleteDepartment = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if department has employees
    const employeeCount = await prisma.employee.count({
      where: {
        departmentId: parseInt(id),
        isActive: true
      }
    });

    if (employeeCount > 0) {
      return res.status(400).json({
        success: false,
        message: 'Không thể xóa phòng ban đang có nhân viên'
      });
    }

    // Check if department has children
    const childrenCount = await prisma.department.count({
      where: {
        parentId: parseInt(id),
        isActive: true
      }
    });

    if (childrenCount > 0) {
      return res.status(400).json({
        success: false,
        message: 'Không thể xóa phòng ban đang có phòng ban con'
      });
    }

    // Soft delete
    await prisma.department.update({
      where: { id: parseInt(id) },
      data: { isActive: false }
    });

    res.json({
      success: true,
      message: 'Xóa phòng ban thành công'
    });
  } catch (error) {
    console.error('Error in deleteDepartment:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa phòng ban',
      error: error.message
    });
  }
};

// @desc    Get department employees
// @route   GET /api/departments/:id/employees
// @access  Private
exports.getDepartmentEmployees = async (req, res) => {
  try {
    const { id } = req.params;
    const { page = 1, limit = 20, position, employmentStatus } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const where = {
      departmentId: parseInt(id),
      isActive: true
    };

    if (position) {
      where.position = {
        contains: position,
        mode: 'insensitive'
      };
    }

    if (employmentStatus) {
      where.employmentStatus = employmentStatus;
    }

    const [employees, total] = await Promise.all([
      prisma.employee.findMany({
        where,
        skip,
        take: parseInt(limit),
        select: {
          id: true,
          employeeCode: true,
          fullName: true,
          position: true,
          email: true,
          phoneNumber: true,
          avatarUrl: true,
          hireDate: true,
          contractType: true,
          employmentStatus: true
        },
        orderBy: {
          fullName: 'asc'
        }
      }),
      prisma.employee.count({ where })
    ]);

    res.json({
      success: true,
      data: employees,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Error in getDepartmentEmployees:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách nhân viên phòng ban',
      error: error.message
    });
  }
};

// @desc    Get department stats
// @route   GET /api/departments/:id/stats
// @access  Private
exports.getDepartmentStats = async (req, res) => {
  try {
    const { id } = req.params;
    const { year, month } = req.query;

    const department = await prisma.department.findUnique({
      where: { id: parseInt(id) }
    });

    if (!department) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy phòng ban'
      });
    }

    // Get employee counts by status
    const [
      totalEmployees,
      activeEmployees,
      onLeaveEmployees,
      terminatedEmployees
    ] = await Promise.all([
      prisma.employee.count({
        where: { departmentId: parseInt(id) }
      }),
      prisma.employee.count({
        where: { departmentId: parseInt(id), employmentStatus: 'active' }
      }),
      prisma.employee.count({
        where: { departmentId: parseInt(id), employmentStatus: 'on_leave' }
      }),
      prisma.employee.count({
        where: { departmentId: parseInt(id), employmentStatus: 'terminated' }
      })
    ]);

    // Get attendance stats for current month
    const currentDate = new Date();
    const targetYear = year || currentDate.getFullYear();
    const targetMonth = month || currentDate.getMonth() + 1;

    const startDate = new Date(targetYear, targetMonth - 1, 1);
    const endDate = new Date(targetYear, targetMonth, 0);

    const attendanceStats = await prisma.attendance.groupBy({
      by: ['status'],
      where: {
        employee: {
          departmentId: parseInt(id)
        },
        date: {
          gte: startDate,
          lte: endDate
        }
      },
      _count: {
        id: true
      }
    });

    const attendanceBreakdown = {};
    attendanceStats.forEach(stat => {
      attendanceBreakdown[stat.status] = stat._count.id;
    });

    // Get leave stats
    const leaveStats = await prisma.leave.groupBy({
      by: ['status'],
      where: {
        employee: {
          departmentId: parseInt(id)
        },
        startDate: {
          gte: startDate,
          lte: endDate
        }
      },
      _count: {
        id: true
      }
    });

    const leaveBreakdown = {};
    leaveStats.forEach(stat => {
      leaveBreakdown[stat.status] = stat._count.id;
    });

    res.json({
      success: true,
      data: {
        departmentInfo: {
          id: department.id,
          code: department.code,
          name: department.name
        },
        employees: {
          total: totalEmployees,
          active: activeEmployees,
          onLeave: onLeaveEmployees,
          terminated: terminatedEmployees
        },
        attendance: {
          period: `${targetYear}-${String(targetMonth).padStart(2, '0')}`,
          breakdown: attendanceBreakdown
        },
        leave: {
          period: `${targetYear}-${String(targetMonth).padStart(2, '0')}`,
          breakdown: leaveBreakdown
        }
      }
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

// @desc    Get department hierarchy
// @route   GET /api/departments/hierarchy
// @access  Private
exports.getDepartmentHierarchy = async (req, res) => {
  try {
    // Get all departments
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

    // Build hierarchy tree
    const buildTree = (parentId = null) => {
      return departments
        .filter(dept => dept.parentId === parentId)
        .map(dept => ({
          id: dept.id,
          code: dept.code,
          name: dept.name,
          description: dept.description,
          managerId: dept.managerId,
          employeeCount: dept._count.employees,
          children: buildTree(dept.id)
        }));
    };

    const hierarchy = buildTree();

    res.json({
      success: true,
      data: hierarchy
    });
  } catch (error) {
    console.error('Error in getDepartmentHierarchy:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy cấu trúc phòng ban',
      error: error.message
    });
  }
};
