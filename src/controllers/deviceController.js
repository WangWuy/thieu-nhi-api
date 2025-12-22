const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// @desc    Get all devices
// @route   GET /api/devices
// @access  Private
exports.getDevices = async (req, res) => {
  try {
    const { deviceType, isActive } = req.query;

    const where = {};

    if (deviceType) {
      where.deviceType = deviceType;
    }

    if (isActive !== undefined) {
      where.isActive = isActive === 'true';
    }

    const devices = await prisma.device.findMany({
      where,
      include: {
        _count: {
          select: {
            attendances: true,
            assignments: true
          }
        }
      },
      orderBy: {
        deviceName: 'asc'
      }
    });

    res.json({
      success: true,
      data: devices
    });
  } catch (error) {
    console.error('Error in getDevices:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách thiết bị',
      error: error.message
    });
  }
};

// @desc    Get device by ID
// @route   GET /api/devices/:id
// @access  Private
exports.getDeviceById = async (req, res) => {
  try {
    const { id } = req.params;

    const device = await prisma.device.findUnique({
      where: { id: parseInt(id) },
      include: {
        assignments: {
          take: 10,
          orderBy: {
            assignedDate: 'desc'
          },
          include: {
            employee: {
              select: {
                id: true,
                employeeCode: true,
                fullName: true
              }
            }
          }
        }
      }
    });

    if (!device) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy thiết bị'
      });
    }

    res.json({
      success: true,
      data: device
    });
  } catch (error) {
    console.error('Error in getDeviceById:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thông tin thiết bị',
      error: error.message
    });
  }
};

// @desc    Create device
// @route   POST /api/devices
// @access  Private (HR Manager, Admin)
exports.createDevice = async (req, res) => {
  try {
    const { deviceCode, deviceName, deviceType, location, ipAddress } = req.body;

    // Check if device code exists
    const existing = await prisma.device.findUnique({
      where: { deviceCode }
    });

    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'Mã thiết bị đã tồn tại'
      });
    }

    const device = await prisma.device.create({
      data: {
        deviceCode,
        deviceName,
        deviceType,
        location,
        ipAddress
      }
    });

    res.status(201).json({
      success: true,
      message: 'Tạo thiết bị thành công',
      data: device
    });
  } catch (error) {
    console.error('Error in createDevice:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo thiết bị',
      error: error.message
    });
  }
};

// @desc    Update device
// @route   PUT /api/devices/:id
// @access  Private (HR Manager, Admin)
exports.updateDevice = async (req, res) => {
  try {
    const { id } = req.params;
    const { deviceCode, deviceName, deviceType, location, ipAddress, isActive } = req.body;

    const updateData = {};

    if (deviceCode) updateData.deviceCode = deviceCode;
    if (deviceName) updateData.deviceName = deviceName;
    if (deviceType) updateData.deviceType = deviceType;
    if (location !== undefined) updateData.location = location;
    if (ipAddress !== undefined) updateData.ipAddress = ipAddress;
    if (isActive !== undefined) updateData.isActive = isActive;

    const device = await prisma.device.update({
      where: { id: parseInt(id) },
      data: updateData
    });

    res.json({
      success: true,
      message: 'Cập nhật thiết bị thành công',
      data: device
    });
  } catch (error) {
    console.error('Error in updateDevice:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật thiết bị',
      error: error.message
    });
  }
};

// @desc    Delete device
// @route   DELETE /api/devices/:id
// @access  Private (Admin)
exports.deleteDevice = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.device.update({
      where: { id: parseInt(id) },
      data: { isActive: false }
    });

    res.json({
      success: true,
      message: 'Xóa thiết bị thành công'
    });
  } catch (error) {
    console.error('Error in deleteDevice:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa thiết bị',
      error: error.message
    });
  }
};

// @desc    Sync device
// @route   POST /api/devices/:id/sync
// @access  Private
exports.syncDevice = async (req, res) => {
  try {
    const { id } = req.params;

    const device = await prisma.device.update({
      where: { id: parseInt(id) },
      data: {
        lastSync: new Date()
      }
    });

    res.json({
      success: true,
      message: 'Đồng bộ thiết bị thành công',
      data: device
    });
  } catch (error) {
    console.error('Error in syncDevice:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi đồng bộ thiết bị',
      error: error.message
    });
  }
};

// @desc    Assign device to employee
// @route   POST /api/devices/:id/assign
// @access  Private (HR Manager, Admin)
exports.assignDevice = async (req, res) => {
  try {
    const { id } = req.params;
    const { employeeId, assignedDate, note } = req.body;

    const assignment = await prisma.deviceAssignment.create({
      data: {
        deviceId: parseInt(id),
        employeeId: parseInt(employeeId),
        assignedDate: assignedDate ? new Date(assignedDate) : new Date(),
        note,
        status: 'assigned'
      },
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true
          }
        },
        device: true
      }
    });

    res.status(201).json({
      success: true,
      message: 'Gán thiết bị thành công',
      data: assignment
    });
  } catch (error) {
    console.error('Error in assignDevice:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi gán thiết bị',
      error: error.message
    });
  }
};

// @desc    Return device
// @route   POST /api/devices/:id/return
// @access  Private (HR Manager, Admin)
exports.returnDevice = async (req, res) => {
  try {
    const { id } = req.params;
    const { employeeId, returnDate, note } = req.body;

    // Find active assignment
    const assignment = await prisma.deviceAssignment.findFirst({
      where: {
        deviceId: parseInt(id),
        employeeId: parseInt(employeeId),
        status: 'assigned'
      }
    });

    if (!assignment) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy phân bổ thiết bị'
      });
    }

    const updatedAssignment = await prisma.deviceAssignment.update({
      where: { id: assignment.id },
      data: {
        status: 'returned',
        returnDate: returnDate ? new Date(returnDate) : new Date(),
        note: note || assignment.note
      },
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true
          }
        },
        device: true
      }
    });

    res.json({
      success: true,
      message: 'Thu hồi thiết bị thành công',
      data: updatedAssignment
    });
  } catch (error) {
    console.error('Error in returnDevice:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi thu hồi thiết bị',
      error: error.message
    });
  }
};

// @desc    Get device history
// @route   GET /api/devices/:id/history
// @access  Private
exports.getDeviceHistory = async (req, res) => {
  try {
    const { id } = req.params;

    const history = await prisma.deviceAssignment.findMany({
      where: {
        deviceId: parseInt(id)
      },
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true
          }
        }
      },
      orderBy: {
        assignedDate: 'desc'
      }
    });

    res.json({
      success: true,
      data: history
    });
  } catch (error) {
    console.error('Error in getDeviceHistory:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy lịch sử thiết bị',
      error: error.message
    });
  }
};
