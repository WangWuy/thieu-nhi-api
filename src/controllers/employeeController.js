const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const cloudinary = require('../config/cloudinary');

// Helper function to generate employee code
const generateEmployeeCode = async () => {
  const currentYear = new Date().getFullYear();
  const prefix = `EMP${currentYear}`;

  // Find the latest employee code for this year
  const lastEmployee = await prisma.employee.findFirst({
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
  if (lastEmployee) {
    const lastNumber = parseInt(lastEmployee.employeeCode.replace(prefix, ''));
    nextNumber = lastNumber + 1;
  }

  return `${prefix}${nextNumber.toString().padStart(4, '0')}`;
};

// @desc    Get all employees with pagination, search, filter
// @route   GET /api/employees
// @access  Private (HR Manager, Admin)
exports.getEmployees = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      search,
      departmentId,
      employmentStatus,
      contractType,
      isActive,
      sortBy = 'createdAt',
      sortOrder = 'desc'
    } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);

    // Build where clause
    const where = {};

    if (search) {
      where.OR = [
        { employeeCode: { contains: search, mode: 'insensitive' } },
        { firstName: { contains: search, mode: 'insensitive' } },
        { lastName: { contains: search, mode: 'insensitive' } },
        { fullName: { contains: search, mode: 'insensitive' } },
        { email: { contains: search, mode: 'insensitive' } },
        { phoneNumber: { contains: search, mode: 'insensitive' } },
        { position: { contains: search, mode: 'insensitive' } }
      ];
    }

    if (departmentId) {
      where.departmentId = parseInt(departmentId);
    }

    if (employmentStatus) {
      where.employmentStatus = employmentStatus;
    }

    if (contractType) {
      where.contractType = contractType;
    }

    if (isActive !== undefined) {
      where.isActive = isActive === 'true';
    }

    // Execute query
    const [employees, total] = await Promise.all([
      prisma.employee.findMany({
        where,
        skip,
        take: parseInt(limit),
        orderBy: {
          [sortBy]: sortOrder
        },
        include: {
          department: {
            select: {
              id: true,
              code: true,
              name: true
            }
          },
          manager: {
            select: {
              id: true,
              employeeCode: true,
              fullName: true
            }
          },
          user: {
            select: {
              id: true,
              username: true,
              role: true,
              isActive: true
            }
          }
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
    console.error('Error in getEmployees:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách nhân viên',
      error: error.message
    });
  }
};

// @desc    Get employee by ID
// @route   GET /api/employees/:id
// @access  Private
exports.getEmployeeById = async (req, res) => {
  try {
    const { id } = req.params;

    const employee = await prisma.employee.findUnique({
      where: { id: parseInt(id) },
      include: {
        department: true,
        manager: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true,
            position: true
          }
        },
        subordinates: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true,
            position: true
          }
        },
        user: {
          select: {
            id: true,
            username: true,
            role: true,
            isActive: true,
            lastLogin: true
          }
        },
        employeeShifts: {
          where: {
            isActive: true
          },
          include: {
            shift: true
          },
          orderBy: {
            effectiveFrom: 'desc'
          }
        }
      }
    });

    if (!employee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy nhân viên'
      });
    }

    res.json({
      success: true,
      data: employee
    });
  } catch (error) {
    console.error('Error in getEmployeeById:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin nhân viên',
      error: error.message
    });
  }
};

// @desc    Create new employee
// @route   POST /api/employees
// @access  Private (HR Manager, Admin)
exports.createEmployee = async (req, res) => {
  try {
    const {
      firstName,
      lastName,
      email,
      phoneNumber,
      birthDate,
      gender,
      address,
      hireDate,
      contractType,
      contractEndDate,
      position,
      departmentId,
      managerId
    } = req.body;

    // Generate employee code
    const employeeCode = await generateEmployeeCode();

    // Create full name
    const fullName = `${firstName} ${lastName}`;

    // Create employee
    const employee = await prisma.employee.create({
      data: {
        employeeCode,
        firstName,
        lastName,
        fullName,
        email,
        phoneNumber,
        birthDate: birthDate ? new Date(birthDate) : null,
        gender,
        address,
        hireDate: new Date(hireDate),
        contractType,
        contractEndDate: contractEndDate ? new Date(contractEndDate) : null,
        position,
        departmentId: parseInt(departmentId),
        managerId: managerId ? parseInt(managerId) : null
      },
      include: {
        department: true,
        manager: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true
          }
        }
      }
    });

    res.status(201).json({
      success: true,
      message: 'Tạo nhân viên thành công',
      data: employee
    });
  } catch (error) {
    console.error('Error in createEmployee:', error);

    if (error.code === 'P2002') {
      return res.status(400).json({
        success: false,
        message: 'Email hoặc số điện thoại đã tồn tại'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo nhân viên',
      error: error.message
    });
  }
};

// @desc    Update employee
// @route   PUT /api/employees/:id
// @access  Private (HR Manager, Admin)
exports.updateEmployee = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      firstName,
      lastName,
      email,
      phoneNumber,
      birthDate,
      gender,
      address,
      hireDate,
      contractType,
      contractEndDate,
      position,
      departmentId,
      managerId,
      employmentStatus,
      isActive
    } = req.body;

    // Check if employee exists
    const existingEmployee = await prisma.employee.findUnique({
      where: { id: parseInt(id) }
    });

    if (!existingEmployee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy nhân viên'
      });
    }

    // Prepare update data
    const updateData = {};

    if (firstName) updateData.firstName = firstName;
    if (lastName) updateData.lastName = lastName;
    if (firstName || lastName) {
      updateData.fullName = `${firstName || existingEmployee.firstName} ${lastName || existingEmployee.lastName}`;
    }
    if (email !== undefined) updateData.email = email;
    if (phoneNumber !== undefined) updateData.phoneNumber = phoneNumber;
    if (birthDate !== undefined) updateData.birthDate = birthDate ? new Date(birthDate) : null;
    if (gender !== undefined) updateData.gender = gender;
    if (address !== undefined) updateData.address = address;
    if (hireDate) updateData.hireDate = new Date(hireDate);
    if (contractType) updateData.contractType = contractType;
    if (contractEndDate !== undefined) updateData.contractEndDate = contractEndDate ? new Date(contractEndDate) : null;
    if (position) updateData.position = position;
    if (departmentId) updateData.departmentId = parseInt(departmentId);
    if (managerId !== undefined) updateData.managerId = managerId ? parseInt(managerId) : null;
    if (employmentStatus) updateData.employmentStatus = employmentStatus;
    if (isActive !== undefined) updateData.isActive = isActive;

    // Update employee
    const employee = await prisma.employee.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        department: true,
        manager: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true
          }
        }
      }
    });

    res.json({
      success: true,
      message: 'Cập nhật nhân viên thành công',
      data: employee
    });
  } catch (error) {
    console.error('Error in updateEmployee:', error);

    if (error.code === 'P2002') {
      return res.status(400).json({
        success: false,
        message: 'Email hoặc số điện thoại đã tồn tại'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật nhân viên',
      error: error.message
    });
  }
};

// @desc    Delete employee (soft delete)
// @route   DELETE /api/employees/:id
// @access  Private (Admin only)
exports.deleteEmployee = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if employee exists
    const employee = await prisma.employee.findUnique({
      where: { id: parseInt(id) }
    });

    if (!employee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy nhân viên'
      });
    }

    // Soft delete by setting isActive to false
    await prisma.employee.update({
      where: { id: parseInt(id) },
      data: {
        isActive: false,
        employmentStatus: 'terminated'
      }
    });

    res.json({
      success: true,
      message: 'Xóa nhân viên thành công'
    });
  } catch (error) {
    console.error('Error in deleteEmployee:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa nhân viên',
      error: error.message
    });
  }
};

// @desc    Restore employee
// @route   POST /api/employees/:id/restore
// @access  Private (Admin only)
exports.restoreEmployee = async (req, res) => {
  try {
    const { id } = req.params;

    const employee = await prisma.employee.update({
      where: { id: parseInt(id) },
      data: {
        isActive: true,
        employmentStatus: 'active'
      }
    });

    res.json({
      success: true,
      message: 'Khôi phục nhân viên thành công',
      data: employee
    });
  } catch (error) {
    console.error('Error in restoreEmployee:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi khôi phục nhân viên',
      error: error.message
    });
  }
};

// @desc    Upload employee avatar
// @route   POST /api/employees/:id/avatar
// @access  Private
exports.uploadAvatar = async (req, res) => {
  try {
    const { id } = req.params;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng chọn ảnh'
      });
    }

    // Check if employee exists
    const employee = await prisma.employee.findUnique({
      where: { id: parseInt(id) }
    });

    if (!employee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy nhân viên'
      });
    }

    // Delete old avatar if exists
    if (employee.avatarPublicId) {
      try {
        await cloudinary.uploader.destroy(employee.avatarPublicId);
      } catch (err) {
        console.error('Error deleting old avatar:', err);
      }
    }

    // Update employee with new avatar
    const updatedEmployee = await prisma.employee.update({
      where: { id: parseInt(id) },
      data: {
        avatarUrl: req.file.path,
        avatarPublicId: req.file.filename
      }
    });

    res.json({
      success: true,
      message: 'Upload ảnh đại diện thành công',
      data: {
        avatarUrl: updatedEmployee.avatarUrl
      }
    });
  } catch (error) {
    console.error('Error in uploadAvatar:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi upload ảnh',
      error: error.message
    });
  }
};

// @desc    Delete employee avatar
// @route   DELETE /api/employees/:id/avatar
// @access  Private
exports.deleteAvatar = async (req, res) => {
  try {
    const { id } = req.params;

    const employee = await prisma.employee.findUnique({
      where: { id: parseInt(id) }
    });

    if (!employee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy nhân viên'
      });
    }

    if (!employee.avatarPublicId) {
      return res.status(400).json({
        success: false,
        message: 'Nhân viên chưa có ảnh đại diện'
      });
    }

    // Delete from Cloudinary
    await cloudinary.uploader.destroy(employee.avatarPublicId);

    // Update employee
    await prisma.employee.update({
      where: { id: parseInt(id) },
      data: {
        avatarUrl: null,
        avatarPublicId: null
      }
    });

    res.json({
      success: true,
      message: 'Xóa ảnh đại diện thành công'
    });
  } catch (error) {
    console.error('Error in deleteAvatar:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa ảnh',
      error: error.message
    });
  }
};

// @desc    Register face data for employee
// @route   POST /api/employees/:id/face/register
// @access  Private
exports.registerFace = async (req, res) => {
  try {
    const { id } = req.params;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng chọn ảnh khuôn mặt'
      });
    }

    // Check if employee exists
    const employee = await prisma.employee.findUnique({
      where: { id: parseInt(id) }
    });

    if (!employee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy nhân viên'
      });
    }

    // TODO: Process face recognition here
    // This would involve:
    // 1. Detect face in the uploaded image
    // 2. Extract face descriptor (128-D vector)
    // 3. Store descriptor in database

    // For now, we'll just store the photo URL
    // Delete old face photo if exists
    if (employee.facePhotoPublicId) {
      try {
        await cloudinary.uploader.destroy(employee.facePhotoPublicId);
      } catch (err) {
        console.error('Error deleting old face photo:', err);
      }
    }

    // Update employee with face data
    const updatedEmployee = await prisma.employee.update({
      where: { id: parseInt(id) },
      data: {
        facePhotoUrl: req.file.path,
        facePhotoPublicId: req.file.filename,
        faceRegisteredAt: new Date(),
        // faceDescriptor will be updated when we implement face recognition
        faceDescriptor: null
      }
    });

    res.json({
      success: true,
      message: 'Đăng ký khuôn mặt thành công',
      data: {
        facePhotoUrl: updatedEmployee.facePhotoUrl,
        faceRegisteredAt: updatedEmployee.faceRegisteredAt
      }
    });
  } catch (error) {
    console.error('Error in registerFace:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi đăng ký khuôn mặt',
      error: error.message
    });
  }
};

// @desc    Update face data for employee
// @route   PUT /api/employees/:id/face/update
// @access  Private
exports.updateFace = async (req, res) => {
  try {
    const { id } = req.params;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng chọn ảnh khuôn mặt'
      });
    }

    // Reuse the registerFace logic
    return exports.registerFace(req, res);
  } catch (error) {
    console.error('Error in updateFace:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật khuôn mặt',
      error: error.message
    });
  }
};

// @desc    Delete face data
// @route   DELETE /api/employees/:id/face
// @access  Private
exports.deleteFaceData = async (req, res) => {
  try {
    const { id } = req.params;

    const employee = await prisma.employee.findUnique({
      where: { id: parseInt(id) }
    });

    if (!employee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy nhân viên'
      });
    }

    if (!employee.facePhotoPublicId) {
      return res.status(400).json({
        success: false,
        message: 'Nhân viên chưa đăng ký khuôn mặt'
      });
    }

    // Delete from Cloudinary
    await cloudinary.uploader.destroy(employee.facePhotoPublicId);

    // Update employee
    await prisma.employee.update({
      where: { id: parseInt(id) },
      data: {
        facePhotoUrl: null,
        facePhotoPublicId: null,
        faceDescriptor: null,
        faceRegisteredAt: null
      }
    });

    res.json({
      success: true,
      message: 'Xóa dữ liệu khuôn mặt thành công'
    });
  } catch (error) {
    console.error('Error in deleteFaceData:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa dữ liệu khuôn mặt',
      error: error.message
    });
  }
};

// @desc    Get employee profile (for authenticated employee)
// @route   GET /api/employees/profile
// @access  Private
exports.getEmployeeProfile = async (req, res) => {
  try {
    // Assuming req.user contains the authenticated user's info
    const userId = req.user.id;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        employee: {
          include: {
            department: true,
            manager: {
              select: {
                id: true,
                employeeCode: true,
                fullName: true,
                position: true
              }
            },
            employeeShifts: {
              where: {
                isActive: true
              },
              include: {
                shift: true
              }
            }
          }
        }
      }
    });

    if (!user || !user.employee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy thông tin nhân viên'
      });
    }

    res.json({
      success: true,
      data: user.employee
    });
  } catch (error) {
    console.error('Error in getEmployeeProfile:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin profile',
      error: error.message
    });
  }
};

// @desc    Update employee profile (for authenticated employee)
// @route   PUT /api/employees/profile
// @access  Private
exports.updateEmployeeProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const {
      phoneNumber,
      address,
      email
    } = req.body;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        employee: true
      }
    });

    if (!user || !user.employee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy thông tin nhân viên'
      });
    }

    // Update employee profile (limited fields for self-update)
    const updateData = {};
    if (phoneNumber !== undefined) updateData.phoneNumber = phoneNumber;
    if (address !== undefined) updateData.address = address;
    if (email !== undefined) updateData.email = email;

    const employee = await prisma.employee.update({
      where: { id: user.employee.id },
      data: updateData,
      include: {
        department: true,
        manager: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true
          }
        }
      }
    });

    res.json({
      success: true,
      message: 'Cập nhật profile thành công',
      data: employee
    });
  } catch (error) {
    console.error('Error in updateEmployeeProfile:', error);

    if (error.code === 'P2002') {
      return res.status(400).json({
        success: false,
        message: 'Email hoặc số điện thoại đã tồn tại'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật profile',
      error: error.message
    });
  }
};

// @desc    Get face registration status
// @route   GET /api/employees/:id/face/status
// @access  Private
exports.getFaceStatus = async (req, res) => {
  try {
    const { id } = req.params;

    const employee = await prisma.employee.findUnique({
      where: { id: parseInt(id) },
      select: {
        id: true,
        employeeCode: true,
        fullName: true,
        facePhotoUrl: true,
        faceRegisteredAt: true,
        faceDescriptor: true
      }
    });

    if (!employee) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy nhân viên'
      });
    }

    res.json({
      success: true,
      data: {
        employeeId: employee.id,
        employeeCode: employee.employeeCode,
        fullName: employee.fullName,
        faceRegistered: !!employee.facePhotoUrl,
        faceRegisteredAt: employee.faceRegisteredAt,
        hasDescriptor: !!employee.faceDescriptor
      }
    });
  } catch (error) {
    console.error('Error in getFaceStatus:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi kiểm tra trạng thái',
      error: error.message
    });
  }
};
