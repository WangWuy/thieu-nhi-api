KẾ HOẠCH CHUYỂN ĐỔI: HỆ THỐNG QUẢN LÝ THIẾU NHI → HỆ THỐNG QUẢN LÝ NHÂN SỰ & CHẤM CÔNG
TỔNG QUAN
Mục tiêu: Chuyển đổi hoàn toàn từ hệ thống quản lý giáo dục Thiếu Nhi sang hệ thống quản lý nhân sự và chấm công chuyên nghiệp. Phạm vi:
Xóa toàn bộ module liên quan đến học sinh/học tập
Tạo database schema mới cho quản lý nhân sự
Chuyển đổi module chấm công cho nhân viên
Nâng cấp Docker configuration với API server container
Cập nhật toàn bộ API endpoints
Refactor authentication & authorization
CÁC BƯỚC THỰC HIỆN
PHASE 1: CHUẨN BỊ & BACKUP (30 phút)
Export full database dump hiện tại
Backup file .env và .env.production
Tạo Git branch mới: migration/hr-system
Document lại các API endpoints hiện tại
Tạo thư mục archive/ để lưu code cũ
Tạo file CHANGELOG.md
PHASE 2: DATABASE SCHEMA MỚI (2-3 giờ)
Xóa toàn bộ migrations cũ và tạo schema mới với các bảng:
Models chính:
Employee - Thay thế Student
Thông tin cá nhân (tên, email, phone, địa chỉ, avatar)
Thông tin tuyển dụng (ngày vào, loại hợp đồng, vị trí)
Face recognition data (vector embeddings cho nhận diện khuôn mặt)
Relations: Department, Manager, Attendance, Leave, Shift
Department - Update từ Department cũ
Hỗ trợ cấu trúc phân cấp (parent-child)
Department Manager
Relations: Employees, Shifts
Attendance - Refactor hoàn toàn
Check-in/Check-out time với nhận diện khuôn mặt
Working hours & Overtime
Location tracking (GPS coordinates)
Verification photos (ảnh chụp khi check-in/out)
Photo URLs stored in cloud
Face recognition confidence score
Late/Early leave flags
Shift - Ca làm việc (MỚI)
Tên ca, thời gian bắt đầu/kết thúc
Thời gian nghỉ giải lao
Ngày làm việc trong tuần
Grace periods cho late/early leave
EmployeeShift - Phân ca cho nhân viên (MỚI)
Hiệu lực từ ngày/đến ngày
Hỗ trợ thay đổi ca theo thời gian
Leave - Quản lý nghỉ phép (MỚI)
Loại nghỉ (annual, sick, unpaid, etc.)
Ngày bắt đầu/kết thúc
Workflow phê duyệt
Lý do nghỉ và ghi chú
Device - Thiết bị chấm công (MỚI)
Fingerprint, Face recognition camera, Mobile app
Location, IP address
Camera specs & capabilities
Sync status
DeviceAssignment - Phân bổ thiết bị (MỚI)
Gán thiết bị cho nhân viên
Trạng thái: assigned, returned, lost, damaged
User - Update
Link với Employee
Roles mới: admin, hr_manager, department_manager, employee
Xóa các trường không cần thiết
Enums mới:
Gender, ContractType, EmploymentStatus
UserRole (admin, hr_manager, department_manager, employee)
AttendanceStatus (present, absent, late, early_leave, on_leave, holiday)
LeaveType, LeaveStatus
DeviceType (fingerprint, face_recognition, mobile_app)
AssignmentStatus
VerificationMethod (face_recognition, manual)
PHASE 3: API RESTRUCTURE (4-6 giờ)
XÓA Controllers cũ:
studentController.js
academicYearController.js
classController.js
reportsController.js (refactor lại)
importController.js (import students)
TẠO MỚI Controllers:
employeeController.js
CRUD operations (create, read, update, delete, restore)
Avatar upload/delete
Profile management
Search & filter với pagination
attendanceController.js (Refactor hoàn toàn)
checkIn với face recognition (upload ảnh, location, verify khuôn mặt)
checkOut với face recognition (upload ảnh, location, verify khuôn mặt)
Manual attendance marking (cho trường hợp đặc biệt)
Get attendance by employee/department/date range
Today's attendance
View verification photos
Stats & trends
Export reports
shiftController.js (MỚI)
CRUD shifts
Assign/unassign employees to shifts
Get employee shifts
leaveController.js (MỚI)
Request leave
Approve/reject leave
Cancel leave
Get leave balance
Leave history & stats
deviceController.js (MỚI)
CRUD devices
Sync device data
Assign/return device
Device history
departmentController.js (Update)
Giữ logic cơ bản, thêm:
Department hierarchy
Department employees list
Department stats
dashboardController.js (Refactor)
Overview stats (total employees, present today, on leave)
Attendance summary
Department stats
Recent activities
Upcoming birthdays
Contract expirations
reportController.js (MỚI)
Monthly/Department/Employee attendance reports
Leave reports
Overtime reports
Export to Excel/PDF
UPDATE Routes:
XÓA:
/api/students/*
/api/classes/*
/api/academic-years/*
/api/reports/student-scores
THÊM MỚI:
/api/employees/* - CRUD, avatar, profile
/api/attendance/* - check-in/out, stats, reports
/api/shifts/* - CRUD, assign
/api/leaves/* - request, approve, balance
/api/devices/* - CRUD, assign, sync
/api/departments/* - update với features mới
/api/dashboard/* - refactor cho HR
/api/reports/* - attendance, leave, overtime reports
PHASE 4: DOCKER CONFIGURATION (1-2 giờ)
1. Tạo Dockerfile mới:
Multi-stage build (builder + production)
Node 20 alpine
Non-root user
Health check
Optimized layers
2. Update docker-compose.yml:
Services:
postgres (upgrade to PostgreSQL 16)
redis (thêm mới - for caching)
api (container mới cho API server)
pgadmin (giữ nguyên)
Features:
Health checks cho tất cả services
Proper networking
Volume persistence
Environment variables
Service dependencies
3. Environment files:
.env.example với variables mới
Update .env.development
Update .env.production
4. Docker scripts trong package.json:
docker:build, docker:up, docker:down
docker:logs (api, postgres, redis)
docker:migrate, docker:seed
docker:rebuild, docker:clean
PHASE 5: SERVICES & UTILITIES (2-3 giờ)
XÓA Services cũ:
scoreService.js
classService.js
TẠO Services mới:
attendanceService.js
Calculate working hours, overtime
Check late/early leave
Monthly summary & attendance rate
leaveService.js
Calculate leave days
Leave balance calculation
Validate leave requests
Annual leave entitlement
employeeService.js
Generate employee code
Register face (upload & process face photos for training)
Update face data
Calculate service years
Upcoming birthdays
Contract expirations
shiftService.js
Get active shift for employee
Validate shift time
Check shift conflicts
reportService.js
Generate various reports
Export to Excel/PDF
Update Utilities:
Giữ lại:
weekUtils.js
excelUtils.js
Xóa:
sortUtils.js
checkUtils.js
Thêm mới:
dateUtils.js - Date/time helpers
faceRecognitionUtils.js - Face recognition integration (sử dụng thư viện như face-api.js hoặc cloud service)
imageUtils.js - Image processing & optimization
locationUtils.js - GPS validation & distance calculation
validationUtils.js - Common validations
PHASE 6: VALIDATION & MIDDLEWARE (1-2 giờ)
1. Update auth.js:
Update roles mới (admin, hr_manager, department_manager, employee)
Thêm permission checks:
canViewEmployee
canEditEmployee
canApproveLeave
canViewDepartment
2. Update validation.js:
Xóa:
studentValidation
classValidation
academicYearValidation
Thêm:
employeeValidation (create, update)
attendanceValidation (checkIn, checkOut)
shiftValidation (create, assign)
leaveValidation (request, approve)
deviceValidation (create, assign)
3. Update rateLimiter.js:
attendanceCheckInLimiter (stricter)
leaveRequestLimiter
reportExportLimiter
PHASE 7: SEED DATA & TESTING (2-3 giờ)
Seed data (prisma/seed.js):
Admin user
HR Manager users
Sample departments (5-10)
Department managers
Sample employees (50-100)
Sample shifts (Morning, Afternoon, Night)
Sample devices
Sample attendance records (30 days)
Sample leave requests
Testing checklist:
Authentication với roles mới
Employee CRUD
Check-in/check-out flow
Shift assignment
Leave request workflow
Department hierarchy
Device management
Reports generation
Export functionality
Pagination, search, filters
Rate limiting
Docker deployment
PHASE 8: DOCUMENTATION & CLEANUP (1-2 giờ)
Update README.md
Tạo API_DOCUMENTATION.md
Tạo DEPLOYMENT_GUIDE.md
Update .env.example
Tạo DATABASE_SCHEMA.md
Xóa code không dùng
Archive code cũ
Update package.json (name, description)
Code formatting & cleanup
Git commit với message rõ ràng
TIMELINE ƯỚC TÍNH
Total: 14-22 giờ làm việc
RISKS & MITIGATION
Database migration fails → Có full backup
Docker build errors → Test riêng từng phần
Missing features → Review kỹ requirements, có thể thêm sau
Performance issues → Redis cache, indexing, pagination
Data inconsistency → Database constraints, validation
POST-MIGRATION
Setup monitoring & logging
Performance optimization
Security audit
Feature enhancements (mobile app, biometric, notifications)
CÔNG NGHỆ FACE RECOGNITION
Thư viện sử dụng: face-api.js + TensorFlow.js
Nhận diện khuôn mặt từ ảnh
Lưu face descriptors (128-D vectors)
So sánh khuôn mặt với độ chính xác cao
Hỗ trợ multiple faces trong ảnh
Flow chấm công:
Nhân viên chụp ảnh selfie
Gửi ảnh + GPS location lên server
Server detect face và extract descriptor
So sánh với face descriptor đã lưu trong DB
Tính confidence score (0-100%)
Nếu > threshold (80%): Chấm công thành công
Lưu ảnh verification + location vào Cloudinary
Reverse geocode GPS thành địa chỉ
Bảo mật & Privacy:
Face descriptors (vectors) không thể reverse thành ảnh
Ảnh verification tự động xóa sau 90 ngày
GDPR/PDPA compliant
Employee consent required
Dependencies mới:
face-api.js - Face recognition
@tensorflow/tfjs-node - ML models
sharp - Image processing
node-geocoder - Reverse geocoding
geolib - GPS distance calculation
Chi tiết đầy đủ đã được lưu tại: /Users/huynhquanghuy/conaland-api/MIGRATION_PLAN.md
User approved the plan
Tuyệt vời! Kế hoạch đã được phê duyệt. Bây giờ tôi sẽ bắt đầu thực hiện migration theo từng phase. Hãy để tôi tạo todo list và bắt đầu:
Update Todos

PHASE 1: Backup database và tạo Git branch mới

PHASE 2: Tạo Prisma schema mới với Face Recognition

PHASE 3: Xóa controllers cũ và tạo controllers mới

PHASE 4: Cập nhật Docker configuration với API container

PHASE 5: Tạo services và utilities mới

PHASE 6: Cập nhật validation và middleware

PHASE 7: Tạo seed data và testing

PHASE 8: Documentation và cleanup
Bây giờ bắt đầu PHASE 1:
Update Todos

PHASE 1: Backup database và tạo Git branch mới

PHASE 2: Tạo Prisma schema mới với Face Recognition

PHASE 3: Xóa controllers cũ và tạo controllers mới

PHASE 4: Cập nhật Docker configuration với API container

PHASE 5: Tạo services và utilities mới

PHASE 6: Cập nhật validation và middleware

PHASE 7: Tạo seed data và testing

PHASE 8: Documentation và cleanup