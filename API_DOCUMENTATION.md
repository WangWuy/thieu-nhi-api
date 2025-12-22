# API Documentation

> **HR Management & Attendance System API v2.0**

Base URL: `http://localhost:3000/api`

## Table of Contents

- [Authentication](#authentication)
- [Employees](#employees)
- [Attendance](#attendance)
- [Shifts](#shifts)
- [Leaves](#leaves)
- [Departments](#departments)
- [Devices](#devices)
- [Dashboard](#dashboard)
- [Reports](#reports)
- [Users](#users)
- [Error Handling](#error-handling)

---

## Authentication

### Login

```http
POST /auth/login
```

**Request Body:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Đăng nhập thành công",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": "24h",
  "user": {
    "id": 1,
    "username": "admin",
    "role": "admin",
    "employee": {
      "id": 1,
      "employeeCode": "EMP001",
      "fullName": "Nguyễn Văn A",
      "position": "HR Manager",
      "avatarUrl": null,
      "department": {
        "id": 1,
        "code": "HR",
        "name": "Phòng Nhân Sự"
      }
    }
  }
}
```

**Errors:**
- `401`: Invalid credentials
- `403`: Account disabled

### Logout

```http
POST /auth/logout
Headers: Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "success": true,
  "message": "Đăng xuất thành công"
}
```

### Get Current User

```http
GET /auth/me
Headers: Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "id": 1,
  "username": "admin",
  "role": "admin",
  "employee": { ... }
}
```

### Change Password

```http
POST /auth/change-password
Headers: Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "currentPassword": "old123",
  "newPassword": "new123"
}
```

---

## Employees

### List Employees

```http
GET /employees?page=1&limit=20&search=John&department=1&status=active
Headers: Authorization: Bearer {token}
```

**Query Parameters:**
- `page` (number): Page number (default: 1)
- `limit` (number): Items per page (default: 20, max: 100)
- `search` (string): Search by name, code, email
- `department` (number): Filter by department ID
- `status` (string): active | on_leave | terminated | resigned
- `contractType` (string): full_time | part_time | contract | internship

**Response 200:**
```json
{
  "employees": [
    {
      "id": 1,
      "employeeCode": "EMP001",
      "firstName": "Minh",
      "lastName": "Nguyễn Văn",
      "fullName": "Nguyễn Văn Minh",
      "email": "minh.nguyen@company.com",
      "phoneNumber": "0901234567",
      "birthDate": "1985-03-15",
      "gender": "male",
      "position": "HR Manager",
      "department": {
        "id": 1,
        "code": "HR",
        "name": "Phòng Nhân Sự"
      },
      "hireDate": "2020-01-01",
      "contractType": "full_time",
      "employmentStatus": "active",
      "avatarUrl": "https://...",
      "faceRegistered": true
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 84,
    "pages": 5
  }
}
```

### Get Employee by ID

```http
GET /employees/:id
Headers: Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "id": 1,
  "employeeCode": "EMP001",
  "fullName": "Nguyễn Văn Minh",
  "email": "minh.nguyen@company.com",
  "phoneNumber": "0901234567",
  "birthDate": "1985-03-15",
  "gender": "male",
  "address": "123 Đường ABC, Q1, HCM",
  "avatarUrl": "https://...",
  "position": "HR Manager",
  "department": { ... },
  "manager": { ... },
  "hireDate": "2020-01-01",
  "contractType": "full_time",
  "contractEndDate": null,
  "employmentStatus": "active",
  "faceRegistered": true,
  "faceRegisteredAt": "2025-01-15T10:30:00Z",
  "createdAt": "2025-01-01T08:00:00Z",
  "updatedAt": "2025-12-22T10:00:00Z"
}
```

**Permissions:**
- Admin/HR: View all employees
- Department Manager: View department employees only
- Employee: View own profile only

### Create Employee

```http
POST /employees
Headers: Authorization: Bearer {token}
Role Required: admin, hr_manager
```

**Request Body:**
```json
{
  "employeeCode": "EMP085",
  "firstName": "An",
  "lastName": "Lê Văn",
  "fullName": "Lê Văn An",
  "email": "an.le@company.com",
  "phoneNumber": "0901234588",
  "birthDate": "1995-06-20",
  "gender": "male",
  "address": "456 Đường XYZ",
  "position": "Developer",
  "departmentId": 2,
  "managerId": 3,
  "hireDate": "2025-01-01",
  "contractType": "full_time",
  "contractEndDate": null
}
```

**Response 201:**
```json
{
  "success": true,
  "message": "Tạo nhân viên thành công",
  "employee": { ... }
}
```

### Update Employee

```http
PUT /employees/:id
Headers: Authorization: Bearer {token}
Role Required: admin, hr_manager, department_manager (for own dept)
```

**Request Body:** (partial update)
```json
{
  "phoneNumber": "0987654321",
  "address": "New address",
  "position": "Senior Developer"
}
```

**Restricted Fields** (Admin/HR only):
- `employeeCode`
- `departmentId`
- `managerId`
- `hireDate`
- `contractType`
- `contractEndDate`
- `employmentStatus`

### Delete Employee (Soft Delete)

```http
DELETE /employees/:id
Headers: Authorization: Bearer {token}
Role Required: admin
```

**Response 200:**
```json
{
  "success": true,
  "message": "Xóa nhân viên thành công"
}
```

### Upload Avatar

```http
POST /employees/:id/avatar
Headers:
  Authorization: Bearer {token}
  Content-Type: multipart/form-data
```

**Form Data:**
- `avatar`: Image file (max 5MB, jpg/png)

**Response 200:**
```json
{
  "success": true,
  "message": "Upload avatar thành công",
  "avatarUrl": "https://cloudinary.com/..."
}
```

### Register Face

```http
POST /employees/:id/face/register
Headers:
  Authorization: Bearer {token}
  Content-Type: multipart/form-data
```

**Form Data:**
- `facePhoto`: Clear face photo (max 10MB, high quality)

**Response 200:**
```json
{
  "success": true,
  "message": "Đăng ký khuôn mặt thành công",
  "faceRegistered": true,
  "facePhotoUrl": "https://...",
  "registeredAt": "2025-12-22T10:30:00Z"
}
```

**Note**: Face descriptor sẽ được extract và lưu vào database để sử dụng cho attendance verification.

---

## Attendance

### Check In

```http
POST /attendance/check-in
Headers:
  Authorization: Bearer {token}
  Content-Type: multipart/form-data
```

**Form Data:**
- `photo`: Face photo for verification
- `latitude`: GPS latitude (e.g., "10.762622")
- `longitude`: GPS longitude (e.g., "106.660172")

**Response 200:**
```json
{
  "success": true,
  "message": "Check-in thành công",
  "attendance": {
    "id": 1,
    "employeeId": 5,
    "date": "2025-12-22",
    "checkInTime": "2025-12-22T08:05:30Z",
    "checkInLocation": "10.762622,106.660172",
    "checkInAddress": "123 Đường ABC, Q1, HCM",
    "checkInConfidence": 92.5,
    "isLate": false,
    "shift": {
      "id": 1,
      "name": "Ca Sáng",
      "startTime": "08:00",
      "endTime": "17:00"
    }
  }
}
```

**Errors:**
- `400`: Already checked in today
- `400`: Face not registered
- `400`: Face verification failed (confidence < 80%)
- `400`: Location required

### Check Out

```http
POST /attendance/check-out
Headers:
  Authorization: Bearer {token}
  Content-Type: multipart/form-data
```

**Form Data:**
- `photo`: Face photo for verification
- `latitude`: GPS latitude
- `longitude`: GPS longitude

**Response 200:**
```json
{
  "success": true,
  "message": "Check-out thành công",
  "attendance": {
    "id": 1,
    "checkOutTime": "2025-12-22T17:10:00Z",
    "checkOutLocation": "10.762622,106.660172",
    "checkOutConfidence": 91.3,
    "workingHours": 8.5,
    "overtimeHours": 0.5,
    "isEarlyLeave": false
  }
}
```

### Get Today's Attendance

```http
GET /attendance/today
Headers: Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "attendance": {
    "id": 1,
    "date": "2025-12-22",
    "checkInTime": "2025-12-22T08:05:00Z",
    "checkOutTime": null,
    "status": "present",
    "isLate": false,
    "shift": { ... }
  }
}
```

### Get My Attendance Records

```http
GET /attendance/my?startDate=2025-12-01&endDate=2025-12-31
Headers: Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "records": [
    {
      "id": 1,
      "date": "2025-12-22",
      "checkInTime": "08:05:00",
      "checkOutTime": "17:10:00",
      "workingHours": 8.5,
      "overtimeHours": 0.5,
      "status": "present",
      "isLate": false
    }
  ],
  "summary": {
    "totalDays": 30,
    "presentDays": 27,
    "lateDays": 3,
    "absentDays": 0,
    "totalWorkingHours": 216.5,
    "totalOvertimeHours": 12.5,
    "attendanceRate": 90.0
  }
}
```

### Get All Attendance (HR/Manager)

```http
GET /attendance?page=1&limit=20&date=2025-12-22&department=1&status=present
Headers: Authorization: Bearer {token}
Role Required: admin, hr_manager, department_manager
```

**Query Parameters:**
- `page`, `limit`: Pagination
- `date`: Filter by date (YYYY-MM-DD)
- `startDate`, `endDate`: Date range
- `employeeId`: Filter by employee
- `department`: Filter by department
- `status`: present | absent | late | early_leave | on_leave

### Manual Attendance Marking

```http
POST /attendance/manual
Headers: Authorization: Bearer {token}
Role Required: admin, hr_manager
```

**Request Body:**
```json
{
  "employeeId": 5,
  "date": "2025-12-20",
  "status": "absent",
  "note": "Sick leave without documentation"
}
```

---

## Shifts

### List Shifts

```http
GET /shifts
Headers: Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "shifts": [
    {
      "id": 1,
      "code": "MORNING",
      "name": "Ca Sáng",
      "startTime": "08:00",
      "endTime": "17:00",
      "breakDuration": 60,
      "workingDays": [1, 2, 3, 4, 5],
      "lateGracePeriod": 15,
      "earlyLeaveGracePeriod": 15,
      "isActive": true
    }
  ]
}
```

### Create Shift

```http
POST /shifts
Headers: Authorization: Bearer {token}
Role Required: admin, hr_manager
```

**Request Body:**
```json
{
  "code": "EVENING",
  "name": "Ca Tối",
  "startTime": "14:00",
  "endTime": "23:00",
  "breakDuration": 60,
  "workingDays": [1, 2, 3, 4, 5],
  "lateGracePeriod": 10,
  "earlyLeaveGracePeriod": 10,
  "departmentId": 2
}
```

### Assign Shift to Employees

```http
POST /shifts/:id/assign
Headers: Authorization: Bearer {token}
Role Required: admin, hr_manager, department_manager
```

**Request Body:**
```json
{
  "employeeIds": [5, 6, 7],
  "effectiveFrom": "2025-01-01",
  "effectiveTo": null
}
```

---

## Leaves

### Request Leave

```http
POST /leaves/request
Headers: Authorization: Bearer {token}
```

**Request Body:**
```json
{
  "leaveType": "annual",
  "startDate": "2025-12-25",
  "endDate": "2025-12-27",
  "reason": "Family vacation"
}
```

**Leave Types:**
- `annual`: Annual leave
- `sick`: Sick leave
- `unpaid`: Unpaid leave
- `maternity`: Maternity leave
- `paternity`: Paternity leave
- `personal`: Personal leave

**Response 201:**
```json
{
  "success": true,
  "message": "Gửi đơn nghỉ phép thành công",
  "leave": {
    "id": 1,
    "leaveType": "annual",
    "startDate": "2025-12-25",
    "endDate": "2025-12-27",
    "totalDays": 3,
    "status": "pending",
    "createdAt": "2025-12-22T10:00:00Z"
  }
}
```

### Approve Leave

```http
POST /leaves/:id/approve
Headers: Authorization: Bearer {token}
Role Required: admin, hr_manager, department_manager (for own dept)
```

**Response 200:**
```json
{
  "success": true,
  "message": "Phê duyệt đơn nghỉ phép thành công",
  "leave": {
    "id": 1,
    "status": "approved",
    "approvedBy": 2,
    "approvedAt": "2025-12-22T11:00:00Z"
  }
}
```

### Reject Leave

```http
POST /leaves/:id/reject
Headers: Authorization: Bearer {token}
Role Required: admin, hr_manager, department_manager
```

**Request Body:**
```json
{
  "reason": "Không đủ số ngày phép năm"
}
```

### Get Leave Balance

```http
GET /leaves/balance
Headers: Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "annual": {
    "entitled": 12,
    "used": 5,
    "pending": 2,
    "remaining": 5
  },
  "sick": {
    "entitled": 30,
    "used": 3,
    "remaining": 27
  }
}
```

---

## Departments

### List Departments

```http
GET /departments
Headers: Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "departments": [
    {
      "id": 1,
      "code": "HR",
      "name": "Phòng Nhân Sự",
      "description": "Quản lý nguồn nhân lực",
      "parentId": null,
      "managerId": 1,
      "manager": {
        "fullName": "Nguyễn Văn Minh"
      },
      "employeeCount": 15,
      "isActive": true
    }
  ]
}
```

### Get Department Statistics

```http
GET /departments/:id/stats
Headers: Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "department": {
    "id": 1,
    "code": "HR",
    "name": "Phòng Nhân Sự"
  },
  "stats": {
    "totalEmployees": 15,
    "activeEmployees": 14,
    "onLeave": 1,
    "presentToday": 13,
    "absentToday": 1,
    "averageAttendanceRate": 95.5,
    "totalWorkingHours": 1200,
    "totalOvertimeHours": 50
  }
}
```

---

## Devices

### List Devices

```http
GET /devices
Headers: Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "devices": [
    {
      "id": 1,
      "deviceCode": "DEV001",
      "deviceName": "Face Recognition Camera - Main Entrance",
      "deviceType": "face_recognition",
      "location": "Cổng chính tầng 1",
      "ipAddress": "192.168.1.101",
      "isActive": true,
      "lastSync": "2025-12-22T10:00:00Z"
    }
  ]
}
```

### Create Device

```http
POST /devices
Headers: Authorization: Bearer {token}
Role Required: admin
```

**Request Body:**
```json
{
  "deviceCode": "DEV005",
  "deviceName": "Fingerprint Scanner - Floor 3",
  "deviceType": "fingerprint",
  "location": "Tầng 3, phòng 301",
  "ipAddress": "192.168.1.105",
  "specs": {
    "model": "FS-2000",
    "capacity": 5000
  }
}
```

---

## Dashboard

### Overview

```http
GET /dashboard/overview
Headers: Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "totalEmployees": 84,
  "activeEmployees": 80,
  "presentToday": 72,
  "absentToday": 8,
  "onLeaveToday": 3,
  "lateToday": 5,
  "attendanceRate": 90.0,
  "departments": 9,
  "shifts": 4
}
```

### Attendance Summary

```http
GET /dashboard/attendance?period=week
Headers: Authorization: Bearer {token}
```

**Response 200:**
```json
{
  "period": "week",
  "data": [
    {
      "date": "2025-12-16",
      "present": 75,
      "late": 5,
      "absent": 4,
      "onLeave": 0,
      "rate": 93.75
    }
  ]
}
```

---

## Reports

### Generate Attendance Report

```http
GET /reports/attendance?month=12&year=2025&department=1
Headers: Authorization: Bearer {token}
Role Required: admin, hr_manager, department_manager
```

**Response 200:**
```json
{
  "report": {
    "month": 12,
    "year": 2025,
    "department": "Phòng Nhân Sự",
    "employees": [
      {
        "employeeCode": "EMP001",
        "fullName": "Nguyễn Văn Minh",
        "totalDays": 22,
        "presentDays": 20,
        "lateDays": 2,
        "absentDays": 0,
        "workingHours": 176,
        "overtimeHours": 8,
        "attendanceRate": 90.9
      }
    ],
    "summary": {
      "totalEmployees": 15,
      "averageAttendanceRate": 92.5
    }
  }
}
```

### Export Report

```http
POST /reports/export
Headers: Authorization: Bearer {token}
Role Required: admin, hr_manager
```

**Request Body:**
```json
{
  "type": "attendance",
  "format": "excel",
  "month": 12,
  "year": 2025,
  "departmentId": 1
}
```

**Response 200:**
```json
{
  "success": true,
  "downloadUrl": "https://cloudinary.com/report_12_2025.xlsx",
  "expiresAt": "2025-12-23T10:00:00Z"
}
```

---

## Error Handling

### Standard Error Response

```json
{
  "error": "Error Type",
  "message": "Human readable error message",
  "details": {
    "field": "Additional context"
  }
}
```

### HTTP Status Codes

- `200 OK`: Success
- `201 Created`: Resource created
- `400 Bad Request`: Invalid input
- `401 Unauthorized`: Authentication required
- `403 Forbidden`: Insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Duplicate resource
- `422 Unprocessable Entity`: Validation failed
- `429 Too Many Requests`: Rate limit exceeded
- `500 Internal Server Error`: Server error

### Common Errors

**401 Unauthorized**
```json
{
  "error": "Unauthorized",
  "message": "Token không hợp lệ hoặc đã hết hạn"
}
```

**403 Forbidden**
```json
{
  "error": "Forbidden",
  "message": "Không có quyền thực hiện thao tác này"
}
```

**422 Validation Error**
```json
{
  "error": "Validation Error",
  "message": "Dữ liệu không hợp lệ",
  "errors": [
    {
      "field": "email",
      "message": "Email không đúng định dạng"
    }
  ]
}
```

**429 Rate Limit**
```json
{
  "error": "Too Many Requests",
  "message": "Vượt quá giới hạn request. Vui lòng thử lại sau 15 phút"
}
```

---

## Rate Limits

| Endpoint | Limit |
|----------|-------|
| General API | 5000 requests / 15 min |
| Auth Login | 5 attempts / 15 min |
| Attendance Check-in | 5 requests / minute |
| Leave Requests | 10 requests / hour |
| Report Export | 20 exports / 15 min |
| Face Verification | 10 requests / minute |

---

## Pagination

Most list endpoints support pagination:

```http
GET /endpoint?page=1&limit=20
```

**Response:**
```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "pages": 5
  }
}
```

---

## Date Formats

- **Request**: ISO 8601 (YYYY-MM-DD or YYYY-MM-DDTHH:mm:ssZ)
- **Response**: ISO 8601 with timezone (YYYY-MM-DDTHH:mm:ssZ)

---

## File Uploads

Supported formats:
- **Images**: JPG, PNG (max 5MB for avatars, 10MB for face photos)
- **Documents**: PDF, XLSX (max 10MB)

All files are uploaded to Cloudinary CDN.

---

**Version**: 2.0.0
**Last Updated**: 2025-12-22
