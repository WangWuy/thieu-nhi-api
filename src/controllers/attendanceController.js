const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const cloudinary = require('../config/cloudinary');

// @desc    Check-in with face recognition
// @route   POST /api/attendance/check-in
// @access  Private
exports.checkIn = async (req, res) => {
  try {
    const { employeeId, location, deviceId } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng chụp ảnh khuôn mặt'
      });
    }

    // Check if employee exists and has face registered
    const employee = await prisma.employee.findUnique({
      where: { id: parseInt(employeeId) },
      include: {
        employeeShifts: {
          where: {
            isActive: true,
            effectiveFrom: {
              lte: new Date()
            },
            OR: [
              { effectiveTo: null },
              { effectiveTo: { gte: new Date() } }
            ]
          },
          include: {
            shift: true
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

    if (!employee.faceDescriptor) {
      return res.status(400).json({
        success: false,
        message: 'Nhân viên chưa đăng ký khuôn mặt. Vui lòng đăng ký trước khi chấm công.'
      });
    }

    // TODO: Implement face verification
    // 1. Extract face descriptor from uploaded photo
    // 2. Compare with stored face descriptor
    // 3. Calculate confidence score
    // For now, we'll assume verification is successful
    const confidence = 95.5; // Mock confidence score

    if (confidence < 80) {
      return res.status(400).json({
        success: false,
        message: 'Không nhận diện được khuôn mặt. Vui lòng thử lại.'
      });
    }

    // Get today's date
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Check if already checked in today
    const existingAttendance = await prisma.attendance.findUnique({
      where: {
        employeeId_date: {
          employeeId: parseInt(employeeId),
          date: today
        }
      }
    });

    if (existingAttendance && existingAttendance.checkInTime) {
      return res.status(400).json({
        success: false,
        message: 'Bạn đã chấm công vào hôm nay',
        data: existingAttendance
      });
    }

    // Get current shift
    const currentShift = employee.employeeShifts[0]?.shift;

    // Check if late
    const checkInTime = new Date();
    let isLate = false;

    if (currentShift) {
      const shiftStartTime = new Date(currentShift.startTime);
      const gracePeriod = currentShift.lateGracePeriod || 15; // minutes

      const lateThreshold = new Date(today);
      lateThreshold.setHours(shiftStartTime.getHours(), shiftStartTime.getMinutes() + gracePeriod);

      isLate = checkInTime > lateThreshold;
    }

    // Parse location if provided
    let checkInLocation = null;
    let checkInAddress = null;

    if (location) {
      const { latitude, longitude } = JSON.parse(location);
      checkInLocation = `${latitude},${longitude}`;

      // TODO: Implement reverse geocoding
      // checkInAddress = await reverseGeocode(latitude, longitude);
      checkInAddress = 'Địa chỉ sẽ được cập nhật sau'; // Mock address
    }

    // Create or update attendance
    const attendance = existingAttendance
      ? await prisma.attendance.update({
          where: { id: existingAttendance.id },
          data: {
            checkInTime,
            checkInPhotoUrl: req.file.path,
            checkInPhotoPublicId: req.file.filename,
            checkInLocation,
            checkInAddress,
            checkInConfidence: confidence,
            checkInMethod: 'face_recognition',
            isLate,
            status: isLate ? 'late' : 'present',
            deviceId: deviceId ? parseInt(deviceId) : null,
            shiftId: currentShift?.id || null
          },
          include: {
            employee: {
              select: {
                id: true,
                employeeCode: true,
                fullName: true
              }
            },
            shift: true
          }
        })
      : await prisma.attendance.create({
          data: {
            employeeId: parseInt(employeeId),
            date: today,
            checkInTime,
            checkInPhotoUrl: req.file.path,
            checkInPhotoPublicId: req.file.filename,
            checkInLocation,
            checkInAddress,
            checkInConfidence: confidence,
            checkInMethod: 'face_recognition',
            isLate,
            status: isLate ? 'late' : 'present',
            deviceId: deviceId ? parseInt(deviceId) : null,
            shiftId: currentShift?.id || null
          },
          include: {
            employee: {
              select: {
                id: true,
                employeeCode: true,
                fullName: true
              }
            },
            shift: true
          }
        });

    res.json({
      success: true,
      message: `Chấm công vào thành công${isLate ? ' (Đi muộn)' : ''}`,
      data: {
        attendance,
        confidence,
        isLate
      }
    });
  } catch (error) {
    console.error('Error in checkIn:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi chấm công vào',
      error: error.message
    });
  }
};

// @desc    Check-out with face recognition
// @route   POST /api/attendance/check-out
// @access  Private
exports.checkOut = async (req, res) => {
  try {
    const { employeeId, location, deviceId } = req.body;

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Vui lòng chụp ảnh khuôn mặt'
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

    if (!employee.faceDescriptor) {
      return res.status(400).json({
        success: false,
        message: 'Nhân viên chưa đăng ký khuôn mặt'
      });
    }

    // TODO: Implement face verification
    const confidence = 96.2; // Mock confidence score

    if (confidence < 80) {
      return res.status(400).json({
        success: false,
        message: 'Không nhận diện được khuôn mặt. Vui lòng thử lại.'
      });
    }

    // Get today's attendance
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const attendance = await prisma.attendance.findUnique({
      where: {
        employeeId_date: {
          employeeId: parseInt(employeeId),
          date: today
        }
      },
      include: {
        shift: true
      }
    });

    if (!attendance) {
      return res.status(400).json({
        success: false,
        message: 'Bạn chưa chấm công vào hôm nay'
      });
    }

    if (attendance.checkOutTime) {
      return res.status(400).json({
        success: false,
        message: 'Bạn đã chấm công ra hôm nay',
        data: attendance
      });
    }

    if (!attendance.checkInTime) {
      return res.status(400).json({
        success: false,
        message: 'Bạn chưa chấm công vào. Vui lòng chấm công vào trước.'
      });
    }

    // Check if early leave
    const checkOutTime = new Date();
    let isEarlyLeave = false;

    if (attendance.shift) {
      const shiftEndTime = new Date(attendance.shift.endTime);
      const gracePeriod = attendance.shift.earlyLeaveGracePeriod || 15; // minutes

      const earlyLeaveThreshold = new Date(today);
      earlyLeaveThreshold.setHours(shiftEndTime.getHours(), shiftEndTime.getMinutes() - gracePeriod);

      isEarlyLeave = checkOutTime < earlyLeaveThreshold;
    }

    // Calculate working hours
    const workingMilliseconds = checkOutTime - new Date(attendance.checkInTime);
    let workingHours = workingMilliseconds / (1000 * 60 * 60);

    // Subtract break duration if shift exists
    if (attendance.shift && attendance.shift.breakDuration) {
      workingHours -= attendance.shift.breakDuration / 60;
    }

    workingHours = Math.max(0, workingHours); // Ensure non-negative

    // Calculate overtime (if working hours > 8)
    const standardHours = 8;
    const overtimeHours = Math.max(0, workingHours - standardHours);

    // Parse location
    let checkOutLocation = null;
    let checkOutAddress = null;

    if (location) {
      const { latitude, longitude } = JSON.parse(location);
      checkOutLocation = `${latitude},${longitude}`;

      // TODO: Implement reverse geocoding
      checkOutAddress = 'Địa chỉ sẽ được cập nhật sau';
    }

    // Update attendance
    const updatedAttendance = await prisma.attendance.update({
      where: { id: attendance.id },
      data: {
        checkOutTime,
        checkOutPhotoUrl: req.file.path,
        checkOutPhotoPublicId: req.file.filename,
        checkOutLocation,
        checkOutAddress,
        checkOutConfidence: confidence,
        checkOutMethod: 'face_recognition',
        isEarlyLeave,
        workingHours,
        overtimeHours,
        status: isEarlyLeave ? 'early_leave' : attendance.status,
        deviceId: deviceId ? parseInt(deviceId) : attendance.deviceId
      },
      include: {
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true
          }
        },
        shift: true
      }
    });

    res.json({
      success: true,
      message: `Chấm công ra thành công${isEarlyLeave ? ' (Về sớm)' : ''}`,
      data: {
        attendance: updatedAttendance,
        confidence,
        workingHours: workingHours.toFixed(2),
        overtimeHours: overtimeHours.toFixed(2),
        isEarlyLeave
      }
    });
  } catch (error) {
    console.error('Error in checkOut:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi chấm công ra',
      error: error.message
    });
  }
};

// @desc    Get today's attendance
// @route   GET /api/attendance/today
// @access  Private
exports.getTodayAttendance = async (req, res) => {
  try {
    const { departmentId, status } = req.query;

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const where = { date: today };

    if (departmentId) {
      where.employee = {
        departmentId: parseInt(departmentId)
      };
    }

    if (status) {
      where.status = status;
    }

    const attendances = await prisma.attendance.findMany({
      where,
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
        shift: {
          select: {
            id: true,
            name: true,
            startTime: true,
            endTime: true
          }
        }
      },
      orderBy: {
        checkInTime: 'asc'
      }
    });

    // Get summary
    const summary = {
      total: attendances.length,
      present: attendances.filter(a => a.status === 'present').length,
      late: attendances.filter(a => a.status === 'late').length,
      earlyLeave: attendances.filter(a => a.isEarlyLeave).length,
      onLeave: attendances.filter(a => a.status === 'on_leave').length
    };

    res.json({
      success: true,
      data: attendances,
      summary
    });
  } catch (error) {
    console.error('Error in getTodayAttendance:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy dữ liệu chấm công hôm nay',
      error: error.message
    });
  }
};

// @desc    Get attendance by employee
// @route   GET /api/attendance/employee/:id
// @access  Private
exports.getAttendanceByEmployee = async (req, res) => {
  try {
    const { id } = req.params;
    const { startDate, endDate, page = 1, limit = 20 } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const where = {
      employeeId: parseInt(id)
    };

    if (startDate && endDate) {
      where.date = {
        gte: new Date(startDate),
        lte: new Date(endDate)
      };
    }

    const [attendances, total] = await Promise.all([
      prisma.attendance.findMany({
        where,
        skip,
        take: parseInt(limit),
        include: {
          shift: {
            select: {
              id: true,
              name: true,
              startTime: true,
              endTime: true
            }
          }
        },
        orderBy: {
          date: 'desc'
        }
      }),
      prisma.attendance.count({ where })
    ]);

    res.json({
      success: true,
      data: attendances,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Error in getAttendanceByEmployee:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy dữ liệu chấm công',
      error: error.message
    });
  }
};

// @desc    Get attendance by department
// @route   GET /api/attendance/department/:id
// @access  Private
exports.getAttendanceByDepartment = async (req, res) => {
  try {
    const { id } = req.params;
    const { startDate, endDate, page = 1, limit = 20 } = req.query;

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const where = {
      employee: {
        departmentId: parseInt(id)
      }
    };

    if (startDate && endDate) {
      where.date = {
        gte: new Date(startDate),
        lte: new Date(endDate)
      };
    }

    const [attendances, total] = await Promise.all([
      prisma.attendance.findMany({
        where,
        skip,
        take: parseInt(limit),
        include: {
          employee: {
            select: {
              id: true,
              employeeCode: true,
              fullName: true,
              position: true
            }
          },
          shift: {
            select: {
              id: true,
              name: true
            }
          }
        },
        orderBy: {
          date: 'desc'
        }
      }),
      prisma.attendance.count({ where })
    ]);

    res.json({
      success: true,
      data: attendances,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages: Math.ceil(total / parseInt(limit))
      }
    });
  } catch (error) {
    console.error('Error in getAttendanceByDepartment:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy dữ liệu chấm công phòng ban',
      error: error.message
    });
  }
};

// @desc    Mark manual attendance
// @route   POST /api/attendance/manual
// @access  Private (HR Manager, Admin only)
exports.markManualAttendance = async (req, res) => {
  try {
    const { employeeId, date, status, note, checkInTime, checkOutTime } = req.body;
    const markedBy = req.user.id;

    const attendanceDate = new Date(date);
    attendanceDate.setHours(0, 0, 0, 0);

    // Check if attendance already exists
    const existingAttendance = await prisma.attendance.findUnique({
      where: {
        employeeId_date: {
          employeeId: parseInt(employeeId),
          date: attendanceDate
        }
      }
    });

    let attendance;

    if (existingAttendance) {
      attendance = await prisma.attendance.update({
        where: { id: existingAttendance.id },
        data: {
          status,
          note,
          checkInTime: checkInTime ? new Date(checkInTime) : existingAttendance.checkInTime,
          checkOutTime: checkOutTime ? new Date(checkOutTime) : existingAttendance.checkOutTime,
          markedBy,
          markedAt: new Date(),
          checkInMethod: 'manual',
          checkOutMethod: 'manual'
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
      });
    } else {
      attendance = await prisma.attendance.create({
        data: {
          employeeId: parseInt(employeeId),
          date: attendanceDate,
          status,
          note,
          checkInTime: checkInTime ? new Date(checkInTime) : null,
          checkOutTime: checkOutTime ? new Date(checkOutTime) : null,
          markedBy,
          markedAt: new Date(),
          checkInMethod: 'manual',
          checkOutMethod: 'manual'
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
      });
    }

    res.json({
      success: true,
      message: 'Chấm công thủ công thành công',
      data: attendance
    });
  } catch (error) {
    console.error('Error in markManualAttendance:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi chấm công thủ công',
      error: error.message
    });
  }
};

// @desc    Get verification photo
// @route   GET /api/attendance/:id/photos
// @access  Private
exports.getVerificationPhotos = async (req, res) => {
  try {
    const { id } = req.params;

    const attendance = await prisma.attendance.findUnique({
      where: { id: parseInt(id) },
      select: {
        id: true,
        checkInPhotoUrl: true,
        checkOutPhotoUrl: true,
        checkInTime: true,
        checkOutTime: true,
        checkInConfidence: true,
        checkOutConfidence: true,
        checkInLocation: true,
        checkOutLocation: true,
        checkInAddress: true,
        checkOutAddress: true,
        employee: {
          select: {
            id: true,
            employeeCode: true,
            fullName: true
          }
        }
      }
    });

    if (!attendance) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy dữ liệu chấm công'
      });
    }

    res.json({
      success: true,
      data: attendance
    });
  } catch (error) {
    console.error('Error in getVerificationPhotos:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy ảnh xác thực',
      error: error.message
    });
  }
};

// @desc    Get attendance stats
// @route   GET /api/attendance/stats
// @access  Private
exports.getAttendanceStats = async (req, res) => {
  try {
    const { employeeId, startDate, endDate } = req.query;

    const where = {};

    if (employeeId) {
      where.employeeId = parseInt(employeeId);
    }

    if (startDate && endDate) {
      where.date = {
        gte: new Date(startDate),
        lte: new Date(endDate)
      };
    }

    const [total, present, late, absent, onLeave, earlyLeave] = await Promise.all([
      prisma.attendance.count({ where }),
      prisma.attendance.count({ where: { ...where, status: 'present' } }),
      prisma.attendance.count({ where: { ...where, status: 'late' } }),
      prisma.attendance.count({ where: { ...where, status: 'absent' } }),
      prisma.attendance.count({ where: { ...where, status: 'on_leave' } }),
      prisma.attendance.count({ where: { ...where, isEarlyLeave: true } })
    ]);

    // Calculate total working hours and overtime
    const attendances = await prisma.attendance.findMany({
      where,
      select: {
        workingHours: true,
        overtimeHours: true
      }
    });

    const totalWorkingHours = attendances.reduce(
      (sum, a) => sum + (parseFloat(a.workingHours) || 0),
      0
    );

    const totalOvertimeHours = attendances.reduce(
      (sum, a) => sum + (parseFloat(a.overtimeHours) || 0),
      0
    );

    res.json({
      success: true,
      data: {
        total,
        present,
        late,
        absent,
        onLeave,
        earlyLeave,
        attendanceRate: total > 0 ? ((present + late) / total * 100).toFixed(2) : 0,
        totalWorkingHours: totalWorkingHours.toFixed(2),
        totalOvertimeHours: totalOvertimeHours.toFixed(2)
      }
    });
  } catch (error) {
    console.error('Error in getAttendanceStats:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy thống kê chấm công',
      error: error.message
    });
  }
};

// @desc    Update attendance
// @route   PUT /api/attendance/:id
// @access  Private (HR Manager, Admin)
exports.updateAttendance = async (req, res) => {
  try {
    const { id } = req.params;
    const { status, note, checkInTime, checkOutTime } = req.body;

    const updateData = {};

    if (status) updateData.status = status;
    if (note !== undefined) updateData.note = note;
    if (checkInTime) updateData.checkInTime = new Date(checkInTime);
    if (checkOutTime) updateData.checkOutTime = new Date(checkOutTime);

    const attendance = await prisma.attendance.update({
      where: { id: parseInt(id) },
      data: updateData,
      include: {
        employee: {
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
      message: 'Cập nhật chấm công thành công',
      data: attendance
    });
  } catch (error) {
    console.error('Error in updateAttendance:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật chấm công',
      error: error.message
    });
  }
};

// @desc    Delete attendance
// @route   DELETE /api/attendance/:id
// @access  Private (Admin only)
exports.deleteAttendance = async (req, res) => {
  try {
    const { id } = req.params;

    // Get attendance to delete photos from Cloudinary
    const attendance = await prisma.attendance.findUnique({
      where: { id: parseInt(id) }
    });

    if (!attendance) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy dữ liệu chấm công'
      });
    }

    // Delete photos from Cloudinary
    const deletePromises = [];

    if (attendance.checkInPhotoPublicId) {
      deletePromises.push(cloudinary.uploader.destroy(attendance.checkInPhotoPublicId));
    }

    if (attendance.checkOutPhotoPublicId) {
      deletePromises.push(cloudinary.uploader.destroy(attendance.checkOutPhotoPublicId));
    }

    if (deletePromises.length > 0) {
      await Promise.all(deletePromises);
    }

    // Delete attendance record
    await prisma.attendance.delete({
      where: { id: parseInt(id) }
    });

    res.json({
      success: true,
      message: 'Xóa dữ liệu chấm công thành công'
    });
  } catch (error) {
    console.error('Error in deleteAttendance:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa dữ liệu chấm công',
      error: error.message
    });
  }
};
