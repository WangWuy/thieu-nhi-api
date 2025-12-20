# KẾ HOẠCH CHUYỂN ĐỔI: HỆ THỐNG QUẢN LÝ THIẾU NHI → HỆ THỐNG QUẢN LÝ NHÂN SỰ & CHẤM CÔNG

## TỔNG QUAN

**Mục tiêu**: Chuyển đổi hoàn toàn từ hệ thống quản lý giáo dục Thiếu Nhi sang hệ thống quản lý nhân sự và chấm công chuyên nghiệp.

**Phạm vi**:
- ✅ Xóa toàn bộ module liên quan đến học sinh/học tập
- ✅ Tạo database schema mới cho quản lý nhân sự
- ✅ Chuyển đổi module chấm công cho nhân viên
- ✅ Nâng cấp Docker configuration
- ✅ Cập nhật toàn bộ API endpoints
- ✅ Refactor authentication & authorization

---

## PHASE 1: CHUẨN BỊ & BACKUP

### 1.1 Backup Database Hiện Tại
- [ ] Export full database dump
- [ ] Backup file .env hiện tại
- [ ] Tạo Git branch mới: `migration/hr-system`
- [ ] Document lại các API endpoints hiện tại (để reference)

### 1.2 Chuẩn Bị Môi Trường
- [ ] Tạo thư mục `archive/` để lưu code cũ
- [ ] Tạo file `CHANGELOG.md` để track changes
- [ ] Update `.gitignore` nếu cần

---

## PHASE 2: DATABASE SCHEMA MỚI

### 2.1 Thiết Kế Schema Mới

#### **Bảng Employees (Nhân viên)**
```prisma
model Employee {
  id              Int       @id @default(autoincrement())
  employeeCode    String    @unique
  firstName       String
  lastName        String
  fullName        String    // Computed field
  email           String?   @unique
  phoneNumber     String?
  birthDate       DateTime?
  gender          Gender?
  address         String?
  avatarUrl       String?
  avatarPublicId  String?

  // Face Recognition Data
  faceDescriptor  Json?     // Vector embeddings for face recognition
  facePhotoUrl    String?   // Reference photo for face recognition
  facePhotoPublicId String?
  faceRegisteredAt DateTime?

  // Employment Info
  hireDate        DateTime
  contractType    ContractType
  position        String
  departmentId    Int
  managerId       Int?      // Manager/Supervisor

  // Status
  employmentStatus EmploymentStatus @default(active)
  isActive        Boolean   @default(true)

  // Timestamps
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  // Relations
  department      Department @relation(fields: [departmentId], references: [id])
  manager         Employee? @relation("EmployeeManager", fields: [managerId], references: [id])
  subordinates    Employee[] @relation("EmployeeManager")
  user            User?
  attendances     Attendance[]
  leaves          Leave[]
  shifts          EmployeeShift[]
  deviceAssignments DeviceAssignment[]
}
```

#### **Bảng Departments (Phòng ban)**
```prisma
model Department {
  id          Int       @id @default(autoincrement())
  code        String    @unique
  name        String
  description String?
  managerId   Int?      // Department Manager
  parentId    Int?      // For hierarchical structure
  isActive    Boolean   @default(true)
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt

  // Relations
  employees   Employee[]
  parent      Department? @relation("DepartmentHierarchy", fields: [parentId], references: [id])
  children    Department[] @relation("DepartmentHierarchy")
  shifts      Shift[]
}
```

#### **Bảng Attendance (Chấm công)**
```prisma
model Attendance {
  id            Int           @id @default(autoincrement())
  employeeId    Int
  checkInTime   DateTime?
  checkOutTime  DateTime?
  date          DateTime      @db.Date
  shiftId       Int?

  // Status
  status        AttendanceStatus @default(present)
  isLate        Boolean       @default(false)
  isEarlyLeave  Boolean       @default(false)

  // Working hours
  workingHours  Decimal?      @db.Decimal(5,2)
  overtimeHours Decimal?      @db.Decimal(5,2)

  // Face Recognition Check-in
  checkInPhotoUrl      String?
  checkInPhotoPublicId String?
  checkInLocation      String?    // GPS coordinates: "lat,lng"
  checkInAddress       String?    // Reverse geocoded address
  checkInConfidence    Decimal?   @db.Decimal(5,2) // Face match confidence (0-100)
  checkInMethod        VerificationMethod @default(face_recognition)

  // Face Recognition Check-out
  checkOutPhotoUrl      String?
  checkOutPhotoPublicId String?
  checkOutLocation      String?   // GPS coordinates
  checkOutAddress       String?   // Reverse geocoded address
  checkOutConfidence    Decimal?  @db.Decimal(5,2)
  checkOutMethod        VerificationMethod @default(face_recognition)

  // Device tracking
  deviceId         Int?

  // Notes
  note          String?
  markedBy      Int?      // For manual attendance
  markedAt      DateTime?

  createdAt     DateTime      @default(now())
  updatedAt     DateTime      @updatedAt

  // Relations
  employee      Employee      @relation(fields: [employeeId], references: [id])
  shift         Shift?        @relation(fields: [shiftId], references: [id])
  device        Device?       @relation(fields: [deviceId], references: [id])

  @@unique([employeeId, date])
}
```

#### **Bảng Shifts (Ca làm việc)**
```prisma
model Shift {
  id              Int       @id @default(autoincrement())
  name            String
  code            String    @unique
  departmentId    Int?

  // Time
  startTime       DateTime  @db.Time
  endTime         DateTime  @db.Time
  breakDuration   Int       // minutes

  // Working days
  workingDays     Int[]     // [1,2,3,4,5] = Mon-Fri

  // Grace periods
  lateGracePeriod Int       @default(15) // minutes
  earlyLeaveGracePeriod Int @default(15)

  isActive        Boolean   @default(true)
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt

  // Relations
  department      Department? @relation(fields: [departmentId], references: [id])
  attendances     Attendance[]
  employeeShifts  EmployeeShift[]
}
```

#### **Bảng EmployeeShift (Phân ca)**
```prisma
model EmployeeShift {
  id          Int       @id @default(autoincrement())
  employeeId  Int
  shiftId     Int
  effectiveFrom DateTime @db.Date
  effectiveTo   DateTime? @db.Date
  isActive    Boolean   @default(true)
  createdAt   DateTime  @default(now())

  // Relations
  employee    Employee  @relation(fields: [employeeId], references: [id])
  shift       Shift     @relation(fields: [shiftId], references: [id])

  @@unique([employeeId, shiftId, effectiveFrom])
}
```

#### **Bảng Leaves (Nghỉ phép)**
```prisma
model Leave {
  id          Int         @id @default(autoincrement())
  employeeId  Int
  leaveType   LeaveType
  startDate   DateTime    @db.Date
  endDate     DateTime    @db.Date
  totalDays   Decimal     @db.Decimal(4,1)
  reason      String
  status      LeaveStatus @default(pending)

  // Approval
  approvedBy  Int?
  approvedAt  DateTime?
  rejectedReason String?

  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt

  // Relations
  employee    Employee    @relation(fields: [employeeId], references: [id])
  approver    User?       @relation(fields: [approvedBy], references: [id])
}
```

#### **Bảng Devices (Thiết bị)**
```prisma
model Device {
  id            Int       @id @default(autoincrement())
  deviceCode    String    @unique
  deviceName    String
  deviceType    DeviceType
  location      String?
  ipAddress     String?
  isActive      Boolean   @default(true)
  lastSync      DateTime?
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt

  // Relations
  attendances   Attendance[]
  assignments   DeviceAssignment[]
}
```

#### **Bảng DeviceAssignment (Phân bổ thiết bị)**
```prisma
model DeviceAssignment {
  id          Int       @id @default(autoincrement())
  employeeId  Int
  deviceId    Int
  assignedDate DateTime @db.Date
  returnDate   DateTime? @db.Date
  status      AssignmentStatus @default(assigned)
  note        String?
  createdAt   DateTime  @default(now())

  // Relations
  employee    Employee  @relation(fields: [employeeId], references: [id])
  device      Device    @relation(fields: [deviceId], references: [id])
}
```

#### **Bảng Users (Cập nhật)**
```prisma
model User {
  id           Int       @id @default(autoincrement())
  username     String    @unique
  passwordHash String
  role         UserRole
  employeeId   Int?      @unique
  isActive     Boolean   @default(true)
  lastLogin    DateTime?
  createdAt    DateTime  @default(now())
  updatedAt    DateTime  @updatedAt

  // Relations
  employee     Employee? @relation(fields: [employeeId], references: [id])
  leaveApprovals Leave[]
}
```

#### **Enums**
```prisma
enum Gender {
  male
  female
  other
}

enum ContractType {
  full_time
  part_time
  contract
  internship
}

enum EmploymentStatus {
  active
  on_leave
  terminated
  resigned
}

enum UserRole {
  admin
  hr_manager
  department_manager
  employee
}

enum AttendanceStatus {
  present
  absent
  late
  early_leave
  on_leave
  holiday
}

enum LeaveType {
  annual
  sick
  unpaid
  maternity
  paternity
  personal
}

enum LeaveStatus {
  pending
  approved
  rejected
  cancelled
}

enum DeviceType {
  fingerprint
  face_recognition
  mobile_app
}

enum VerificationMethod {
  face_recognition
  manual
}

enum AssignmentStatus {
  assigned
  returned
  lost
  damaged
}
```

### 2.2 Migration Files
- [ ] Xóa tất cả migrations cũ trong `prisma/migrations/`
- [ ] Tạo schema mới trong `prisma/schema.prisma`
- [ ] Chạy `prisma migrate dev --name init_hr_system`
- [ ] Tạo seed data mẫu

---

## PHASE 3: API RESTRUCTURE

### 3.1 Xóa Controllers Cũ
**Files cần xóa**:
- `src/controllers/studentController.js`
- `src/controllers/academicYearController.js`
- `src/controllers/classController.js`
- `src/controllers/reportsController.js` (liên quan học sinh)
- `src/controllers/importController.js` (import students)
- `src/controllers/dashboardController.js` (refactor lại)

### 3.2 Tạo Controllers Mới

#### **employeeController.js**
```javascript
// CRUD nhân viên
- createEmployee
- getEmployees (with pagination, search, filter)
- getEmployeeById
- updateEmployee
- deleteEmployee (soft delete)
- restoreEmployee
- uploadAvatar
- deleteAvatar
- registerFace (upload multiple face photos for training)
- updateFace (update face recognition data)
- deleteFaceData
- getEmployeeProfile
- updateEmployeeProfile
```

#### **attendanceController.js** (Refactor)
```javascript
// Chấm công nhân viên với Face Recognition
- checkIn (upload photo + GPS location, verify face, save verification photo)
- checkOut (upload photo + GPS location, verify face, save verification photo)
- getAttendanceByEmployee
- getAttendanceByDepartment
- getAttendanceByDateRange
- getTodayAttendance
- getVerificationPhoto (view check-in/out photos)
- markManualAttendance (for special cases)
- updateAttendance
- deleteAttendance
- getAttendanceStats
- getAttendanceTrend
- exportAttendanceReport
```

#### **shiftController.js**
```javascript
// Quản lý ca làm việc
- createShift
- getShifts
- getShiftById
- updateShift
- deleteShift
- assignEmployeeToShift
- removeEmployeeFromShift
- getEmployeeShifts
```

#### **leaveController.js**
```javascript
// Quản lý nghỉ phép
- requestLeave
- getLeaveRequests
- getLeaveById
- approveLeave
- rejectLeave
- cancelLeave
- getEmployeeLeaves
- getLeaveBalance
- getLeaveStats
```

#### **deviceController.js**
```javascript
// Quản lý thiết bị
- createDevice
- getDevices
- getDeviceById
- updateDevice
- deleteDevice
- syncDevice
- assignDeviceToEmployee
- returnDevice
- getDeviceHistory
```

#### **departmentController.js** (Update)
```javascript
// Quản lý phòng ban - giữ một phần logic cũ
- createDepartment
- getDepartments
- getDepartmentById
- updateDepartment
- deleteDepartment
- getDepartmentEmployees
- getDepartmentStats
- getDepartmentHierarchy
```

#### **dashboardController.js** (Refactor)
```javascript
// Dashboard mới cho HR
- getOverviewStats (total employees, present today, on leave, etc.)
- getAttendanceSummary
- getDepartmentStats
- getLeaveStats
- getRecentActivities
- getUpcomingBirthdays
- getContractExpirations
```

#### **reportController.js** (New)
```javascript
// Báo cáo
- getMonthlyAttendanceReport
- getDepartmentAttendanceReport
- getEmployeeAttendanceReport
- getLeaveReport
- getOvertimeReport
- exportReportToExcel
- exportReportToPDF
```

### 3.3 Update Routes (`src/routes/index.js`)

**Xóa routes**:
- `/students/*`
- `/classes/*`
- `/academic-years/*`
- `/reports/student-scores`

**Thêm routes mới**:
```javascript
// EMPLOYEE ROUTES
GET    /api/employees
GET    /api/employees/:id
POST   /api/employees
PUT    /api/employees/:id
DELETE /api/employees/:id
POST   /api/employees/:id/avatar
DELETE /api/employees/:id/avatar
GET    /api/employees/:id/profile

// ATTENDANCE ROUTES
POST   /api/attendance/check-in
POST   /api/attendance/check-out
GET    /api/attendance/today
GET    /api/attendance/employee/:id
GET    /api/attendance/department/:id
POST   /api/attendance/manual
GET    /api/attendance/stats
GET    /api/attendance/export

// SHIFT ROUTES
GET    /api/shifts
POST   /api/shifts
PUT    /api/shifts/:id
DELETE /api/shifts/:id
POST   /api/shifts/:id/assign
DELETE /api/shifts/:id/unassign/:employeeId

// LEAVE ROUTES
GET    /api/leaves
POST   /api/leaves
GET    /api/leaves/:id
PUT    /api/leaves/:id/approve
PUT    /api/leaves/:id/reject
DELETE /api/leaves/:id
GET    /api/employees/:id/leaves
GET    /api/employees/:id/leave-balance

// DEVICE ROUTES
GET    /api/devices
POST   /api/devices
PUT    /api/devices/:id
DELETE /api/devices/:id
POST   /api/devices/:id/assign
POST   /api/devices/:id/return
POST   /api/devices/:id/sync

// DEPARTMENT ROUTES (Updated)
GET    /api/departments
POST   /api/departments
PUT    /api/departments/:id
DELETE /api/departments/:id
GET    /api/departments/:id/employees
GET    /api/departments/:id/stats

// DASHBOARD ROUTES (Refactored)
GET    /api/dashboard/overview
GET    /api/dashboard/attendance-summary
GET    /api/dashboard/department-stats
GET    /api/dashboard/leave-stats
GET    /api/dashboard/recent-activities

// REPORT ROUTES (New)
GET    /api/reports/attendance/monthly
GET    /api/reports/attendance/department
GET    /api/reports/attendance/employee/:id
GET    /api/reports/leave
GET    /api/reports/overtime
POST   /api/reports/export
```

---

## PHASE 4: DOCKER CONFIGURATION

### 4.1 Tạo Dockerfile cho API Server

**Tạo file**: `Dockerfile`
```dockerfile
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY prisma ./prisma/

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy source code
COPY . .

# Generate Prisma client
RUN npx prisma generate

# Production stage
FROM node:20-alpine

WORKDIR /app

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy from builder
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nodejs:nodejs /app/prisma ./prisma
COPY --chown=nodejs:nodejs . .

# Set user
USER nodejs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Start command
CMD ["node", "server.js"]
```

### 4.2 Update docker-compose.yml

```yaml
version: '3.8'

services:
  # PostgreSQL Database
  postgres:
    image: postgres:16-alpine
    container_name: hr-postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${DB_PASSWORD:-hr_secure_pass_2024}
      POSTGRES_DB: ${DB_NAME:-hr_system}
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=en_US.UTF-8 --lc-ctype=en_US.UTF-8"
      TZ: Asia/Ho_Chi_Minh
    ports:
      - "${DB_PORT:-5432}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./docker/init-scripts:/docker-entrypoint-initdb.d
    networks:
      - hr-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres -d ${DB_NAME:-hr_system}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s

  # Redis Cache (Optional but recommended)
  redis:
    image: redis:7-alpine
    container_name: hr-redis
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD:-redis_pass_2024}
    ports:
      - "${REDIS_PORT:-6379}:6379"
    volumes:
      - redis_data:/data
    networks:
      - hr-network
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  # API Server
  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: hr-api
    restart: unless-stopped
    environment:
      NODE_ENV: ${NODE_ENV:-production}
      DATABASE_URL: postgresql://postgres:${DB_PASSWORD:-hr_secure_pass_2024}@postgres:5432/${DB_NAME:-hr_system}
      REDIS_URL: redis://:${REDIS_PASSWORD:-redis_pass_2024}@redis:6379
      JWT_SECRET: ${JWT_SECRET}
      PORT: 3000
    ports:
      - "${API_PORT:-3000}:3000"
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./uploads:/app/uploads
      - ./logs:/app/logs
    networks:
      - hr-network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # PgAdmin - Web interface
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: hr-pgadmin
    restart: unless-stopped
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_EMAIL:-admin@hr.local}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_PASSWORD:-admin123}
      PGADMIN_CONFIG_SERVER_MODE: 'False'
      PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: 'False'
    ports:
      - "${PGADMIN_PORT:-8081}:80"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
      - ./docker/pgadmin-servers.json:/pgadmin4/servers.json
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - hr-network

volumes:
  postgres_data:
    driver: local
    name: hr_postgres_data
  redis_data:
    driver: local
    name: hr_redis_data
  pgadmin_data:
    driver: local
    name: hr_pgadmin_data

networks:
  hr-network:
    driver: bridge
    name: hr_network
```

### 4.3 Tạo .env Files

**`.env.example`**:
```bash
# Database Configuration
DB_PASSWORD=hr_secure_pass_2024
DB_NAME=hr_system
DB_PORT=5432
DATABASE_URL=postgresql://postgres:hr_secure_pass_2024@localhost:5432/hr_system

# Redis Configuration
REDIS_PASSWORD=redis_pass_2024
REDIS_PORT=6379
REDIS_URL=redis://:redis_pass_2024@localhost:6379

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRES_IN=24h

# Server Configuration
NODE_ENV=production
API_PORT=3000
PORT=3000

# Frontend URL (CORS)
FRONTEND_URL=http://localhost:5173,http://localhost:3000

# PgAdmin
PGADMIN_EMAIL=admin@hr.local
PGADMIN_PASSWORD=admin123
PGADMIN_PORT=8081

# Cloudinary (for avatars)
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_API_SECRET=

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

### 4.4 Docker Scripts

**Thêm vào `package.json`**:
```json
{
  "scripts": {
    "docker:build": "docker-compose build",
    "docker:up": "docker-compose up -d",
    "docker:down": "docker-compose down",
    "docker:restart": "docker-compose restart",
    "docker:logs": "docker-compose logs -f",
    "docker:logs:api": "docker-compose logs -f api",
    "docker:logs:postgres": "docker-compose logs -f postgres",
    "docker:logs:redis": "docker-compose logs -f redis",
    "docker:clean": "docker-compose down -v --remove-orphans",
    "docker:rebuild": "docker-compose down && docker-compose build --no-cache && docker-compose up -d",
    "docker:migrate": "docker-compose exec api npx prisma migrate deploy",
    "docker:seed": "docker-compose exec api npm run db:seed"
  }
}
```

---

## PHASE 5: SERVICES & UTILITIES

### 5.1 Xóa Services Cũ
- `src/services/scoreService.js` (không cần nữa)
- `src/services/classService.js` (không cần nữa)

### 5.2 Tạo Services Mới

#### **attendanceService.js**
```javascript
- verifyFace(photoBuffer, employeeId) -> returns confidence score
- processCheckIn(employeeId, photo, location)
- processCheckOut(employeeId, photo, location)
- calculateWorkingHours(checkIn, checkOut, breakDuration)
- calculateOvertimeHours(workingHours, standardHours)
- isLate(checkInTime, shiftStartTime, gracePeriod)
- isEarlyLeave(checkOutTime, shiftEndTime, gracePeriod)
- validateLocation(gpsCoordinates, allowedRadius)
- reverseGeocode(lat, lng) -> address
- getMonthlyAttendanceSummary(employeeId, month, year)
- getAttendanceRate(employeeId, startDate, endDate)
```

#### **leaveService.js**
```javascript
- calculateLeaveDays(startDate, endDate, excludeWeekends)
- getLeaveBalance(employeeId, year)
- validateLeaveRequest(employeeId, startDate, endDate)
- getAnnualLeaveEntitlement(employeeId)
```

#### **employeeService.js**
```javascript
- generateEmployeeCode()
- registerFaceData(employeeId, photos) -> extract and save face descriptors
- updateFaceData(employeeId, photos)
- deleteFaceData(employeeId)
- getFaceDescriptor(employeeId)
- calculateServiceYears(hireDate)
- getUpcomingBirthdays(days)
- getContractExpirations(days)
```

#### **shiftService.js**
```javascript
- getActiveShiftForEmployee(employeeId, date)
- validateShiftTime(startTime, endTime)
- checkShiftConflict(employeeId, newShiftId, date)
```

#### **reportService.js**
```javascript
- generateMonthlyReport(month, year, departmentId)
- generateAttendanceExcel(data)
- generateLeaveReport(startDate, endDate)
- generateDepartmentReport(departmentId, month, year)
```

### 5.3 Update Utilities

**Giữ lại**:
- `src/utils/weekUtils.js` (có thể dùng cho tính tuần)
- `src/utils/excelUtils.js` (dùng cho export)

**Xóa**:
- `src/utils/sortUtils.js` (không cần)
- `src/utils/checkUtils.js` (không cần)

**Thêm mới**:
- `src/utils/dateUtils.js` - Helper functions cho date/time
- `src/utils/faceRecognitionUtils.js` - Face recognition (face-api.js hoặc cloud API)
- `src/utils/imageUtils.js` - Image processing, compression, validation
- `src/utils/locationUtils.js` - GPS validation, distance calculation, geocoding
- `src/utils/validationUtils.js` - Common validations

---

## PHASE 6: VALIDATION & MIDDLEWARE

### 6.1 Update Authentication Middleware
**File**: `src/middleware/auth.js`

```javascript
// Update roles
enum UserRole {
  admin           // Full access
  hr_manager      // HR operations
  department_manager  // Department scope
  employee        // Own data only
}

// Add permissions check
- canViewEmployee(user, targetEmployeeId)
- canEditEmployee(user, targetEmployeeId)
- canApproveLeave(user, leaveRequest)
- canViewDepartment(user, departmentId)
```

### 6.2 Update Validation Middleware
**File**: `src/middleware/validation.js`

**Xóa**:
- `studentValidation`
- `classValidation`
- `academicYearValidation`

**Thêm**:
```javascript
- employeeValidation.create
- employeeValidation.update
- attendanceValidation.checkIn
- attendanceValidation.checkOut
- shiftValidation.create
- shiftValidation.assign
- leaveValidation.request
- leaveValidation.approve
- deviceValidation.create
- deviceValidation.assign
```

### 6.3 Update Rate Limiting
**File**: `src/middleware/rateLimiter.js`

```javascript
// Thêm limiters mới
- attendanceCheckInLimiter (stricter - prevent spam check-ins)
- leaveRequestLimiter
- reportExportLimiter
```

---

## PHASE 7: SEED DATA & TESTING

### 7.1 Seed Data
**File**: `prisma/seed.js`

```javascript
// Seed data mẫu:
1. Admin user
2. HR Manager users
3. Sample departments (5-10 departments)
4. Department managers
5. Sample employees (50-100)
6. Sample shifts (Morning, Afternoon, Night)
7. Sample devices (fingerprint, QR scanner)
8. Sample attendance records (last 30 days)
9. Sample leave requests
```

### 7.2 Testing Checklist
- [ ] Test authentication với roles mới
- [ ] Test employee CRUD operations
- [ ] Test check-in/check-out flow
- [ ] Test shift assignment
- [ ] Test leave request workflow
- [ ] Test department hierarchy
- [ ] Test device management
- [ ] Test reports generation
- [ ] Test export functionality
- [ ] Test pagination, search, filters
- [ ] Test rate limiting
- [ ] Test Docker deployment

---

## PHASE 8: DOCUMENTATION & CLEANUP

### 8.1 Update Documentation
- [ ] Update README.md với hướng dẫn mới
- [ ] Tạo API_DOCUMENTATION.md
- [ ] Tạo DEPLOYMENT_GUIDE.md
- [ ] Update .env.example
- [ ] Tạo DATABASE_SCHEMA.md

### 8.2 Code Cleanup
- [ ] Xóa tất cả code không dùng
- [ ] Archive code cũ vào thư mục `archive/`
- [ ] Update package.json (name, description)
- [ ] Clean up comments
- [ ] Format code

### 8.3 Final Checklist
- [ ] All tests passing
- [ ] Docker containers running smoothly
- [ ] Database migrations applied
- [ ] Seed data loaded
- [ ] API endpoints tested
- [ ] Documentation complete
- [ ] Code reviewed
- [ ] Git commit với message rõ ràng

---

## TIMELINE ƯỚC TÍNH

| Phase | Công việc | Thời gian ước tính |
|-------|-----------|-------------------|
| Phase 1 | Chuẩn bị & Backup | 30 phút |
| Phase 2 | Database Schema | 2-3 giờ |
| Phase 3 | API Restructure | 4-6 giờ |
| Phase 4 | Docker Configuration | 1-2 giờ |
| Phase 5 | Services & Utilities | 2-3 giờ |
| Phase 6 | Validation & Middleware | 1-2 giờ |
| Phase 7 | Seed Data & Testing | 2-3 giờ |
| Phase 8 | Documentation & Cleanup | 1-2 giờ |
| **TOTAL** | | **14-22 giờ** |

---

## RISK MITIGATION

### Rủi ro có thể gặp:

1. **Database migration fails**
   - Mitigation: Có full backup, test trên local trước

2. **Docker build errors**
   - Mitigation: Test Dockerfile độc lập trước khi integrate

3. **Missing features phát hiện muộn**
   - Mitigation: Review kỹ requirements, có thể thêm features sau

4. **Performance issues**
   - Mitigation: Có Redis cache, database indexing, pagination

5. **Data inconsistency**
   - Mitigation: Database constraints, validation layers

---

## DEPENDENCIES MỚI CẦN THÊM

```json
{
  "dependencies": {
    // Face Recognition
    "@tensorflow/tfjs-node": "^4.x",
    "face-api.js": "^0.22.2",
    "canvas": "^2.11.2",

    // Image Processing
    "sharp": "^0.33.0",

    // Location & Geocoding
    "node-geocoder": "^4.3.0",
    "geolib": "^3.3.4",

    // Existing
    "@prisma/client": "^6.12.0",
    "axios": "^1.11.0",
    "bcryptjs": "^3.0.2",
    "cloudinary": "^1.41.3",
    "cors": "^2.8.5",
    "dotenv": "^17.2.0",
    "express": "^4.21.2",
    "express-rate-limit": "^6.11.2",
    "express-validator": "^7.0.1",
    "form-data": "^4.0.4",
    "helmet": "^7.1.0",
    "jsonwebtoken": "^9.0.2",
    "multer": "^2.0.2",
    "multer-storage-cloudinary": "^4.0.0",
    "redis": "^5.8.2",
    "winston": "^3.17.0",
    "xlsx": "^0.18.5"
  }
}
```

## API ENDPOINTS CHO FACE RECOGNITION

```javascript
// EMPLOYEE FACE REGISTRATION
POST   /api/employees/:id/face/register
  - Body: { photos: [File, File, File] } // Multiple photos for better training
  - Response: { faceRegistered: true, descriptor: [...] }

PUT    /api/employees/:id/face/update
  - Body: { photos: [File, File] }

DELETE /api/employees/:id/face
  - Remove face recognition data

GET    /api/employees/:id/face/status
  - Check if employee has face data registered

// ATTENDANCE WITH FACE RECOGNITION
POST   /api/attendance/check-in
  - Body: {
      employeeId: number,
      photo: File,
      location: { latitude: number, longitude: number },
      deviceId?: number
    }
  - Response: {
      success: true,
      confidence: 95.5,
      checkInTime: "...",
      photoUrl: "...",
      address: "...",
      isLate: false
    }

POST   /api/attendance/check-out
  - Body: {
      employeeId: number,
      photo: File,
      location: { latitude: number, longitude: number },
      deviceId?: number
    }
  - Response: {
      success: true,
      confidence: 96.2,
      checkOutTime: "...",
      photoUrl: "...",
      workingHours: 8.5,
      overtimeHours: 0.5
    }

GET    /api/attendance/:id/photos
  - Get verification photos for an attendance record

GET    /api/attendance/verify/:id
  - View verification details (photos, location, confidence scores)
```

## CLOUDINARY CONFIGURATION UPDATE

```javascript
// src/config/cloudinary.js - Update with new folders

const attendancePhotoStorage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'hr-system/attendance-photos',
    allowed_formats: ['jpg', 'jpeg', 'png'],
    transformation: [
      { width: 800, height: 800, crop: 'limit' },
      { quality: 'auto' }
    ]
  }
});

const faceRegistrationStorage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'hr-system/face-data',
    allowed_formats: ['jpg', 'jpeg', 'png'],
    transformation: [
      { width: 500, height: 500, crop: 'fill', gravity: 'face' },
      { quality: 'auto:best' }
    ]
  }
});
```

## ENVIRONMENT VARIABLES UPDATE

```bash
# Face Recognition Configuration
FACE_RECOGNITION_CONFIDENCE_THRESHOLD=80  # Minimum confidence score (0-100)
FACE_RECOGNITION_MODEL=ssd_mobilenetv1   # or tiny_face_detector

# Location Configuration
ALLOWED_CHECK_IN_RADIUS=100              # meters from office location
OFFICE_LATITUDE=10.762622
OFFICE_LONGITUDE=106.660172
ENABLE_LOCATION_VALIDATION=true
GEOCODING_PROVIDER=google                # google, opencage, mapbox
GEOCODING_API_KEY=your_api_key_here

# Photo Storage
MAX_FACE_PHOTO_SIZE=5242880             # 5MB
MIN_FACE_PHOTO_SIZE=10240               # 10KB
ATTENDANCE_PHOTO_RETENTION_DAYS=90      # Keep photos for 90 days
```

## POST-MIGRATION TASKS

Sau khi migration xong:

1. **Monitoring & Logging**
   - Setup error tracking (Sentry?)
   - Setup performance monitoring
   - Setup database monitoring
   - Log face recognition failures

2. **Optimization**
   - Database query optimization
   - API response time optimization
   - Caching strategy
   - Face recognition model optimization
   - Image compression pipeline

3. **Security Audit**
   - Security review
   - Penetration testing
   - OWASP compliance check
   - Face data privacy compliance (GDPR/PDPA)
   - Secure photo storage

4. **Feature Enhancements**
   - Mobile app integration
   - Real-time face recognition
   - Liveness detection (prevent photo spoofing)
   - Advanced reporting with photo evidence
   - Dashboard widgets
   - Push notifications
   - Export to multiple formats
   - Geofencing alerts
   - Attendance anomaly detection

---

## NOTES

- Toàn bộ code cũ sẽ được archive, không xóa vĩnh viễn
- Database cũ được backup đầy đủ
- Có thể rollback nếu cần
- Development sẽ được thực hiện trên branch riêng
- Merge vào main sau khi test kỹ

---

**Prepared by**: Claude Code
**Date**: 2025-12-19
**Status**: PENDING APPROVAL
