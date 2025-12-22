# HR Management & Attendance System API

> **Hệ thống quản lý nhân sự và chấm công với Face Recognition**

## Tổng quan

API backend cho hệ thống quản lý nhân sự (HR) và chấm công, hỗ trợ nhận diện khuôn mặt, quản lý ca làm việc, nghỉ phép, và báo cáo chi tiết.

### Tính năng chính

- **👥 Quản lý nhân viên**: CRUD employees, quản lý thông tin cá nhân, hợp đồng
- **📸 Face Recognition**: Đăng ký và xác thực khuôn mặt cho chấm công
- **⏰ Chấm công thông minh**: Check-in/out với face verification, GPS tracking
- **📅 Quản lý ca làm việc**: Tạo và phân công ca làm việc linh hoạt
- **🏖️ Quản lý nghỉ phép**: Request, approve/reject leave, tính toán số ngày phép
- **🏢 Quản lý phòng ban**: Cấu trúc phân cấp, department managers
- **📱 Quản lý thiết bị**: Face camera, fingerprint, mobile app
- **📊 Dashboard & Reports**: Thống kê, báo cáo chi tiết, export Excel
- **🔐 Role-based Access Control**: Admin, HR Manager, Department Manager, Employee

## Tech Stack

- **Runtime**: Node.js 20.x
- **Framework**: Express.js
- **Database**: PostgreSQL 16
- **ORM**: Prisma
- **Cache**: Redis 7
- **Authentication**: JWT
- **File Storage**: Cloudinary
- **Face Recognition**: face-api.js (mock - ready for integration)
- **Containerization**: Docker & Docker Compose

## Yêu cầu hệ thống

- Node.js >= 20.x
- Docker & Docker Compose
- PostgreSQL 16 (hoặc dùng Docker)
- Redis 7 (hoặc dùng Docker)

## Cài đặt nhanh

### 1. Clone repository

```bash
git clone <repository-url>
cd conaland-api
```

### 2. Environment setup

```bash
cp .env.example .env
```

Cập nhật các biến môi trường trong `.env`:

```env
# Database
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/hr_system"

# JWT
JWT_SECRET="your-super-secret-jwt-key-change-in-production"

# Cloudinary (for file uploads)
CLOUDINARY_CLOUD_NAME="your-cloud-name"
CLOUDINARY_API_KEY="your-api-key"
CLOUDINARY_API_SECRET="your-api-secret"

# Redis
REDIS_URL="redis://localhost:6379"
```

### 3. Khởi động với Docker (Recommended)

```bash
# Start all services (PostgreSQL, Redis, API)
npm run docker:up

# Wait for services to be ready (10 seconds)
sleep 10

# Run database migrations
npm run docker:migrate

# Seed sample data
npm run docker:seed

# View logs
npm run docker:logs
```

### 4. Hoặc chạy local (Development)

```bash
# Install dependencies
npm install

# Start PostgreSQL & Redis with Docker
docker-compose up -d postgres redis

# Generate Prisma client
npm run db:generate

# Run migrations
npx prisma migrate dev

# Seed database
npm run db:seed

# Start development server
npm run dev
```

Server sẽ chạy tại: `http://localhost:3000`

## API Endpoints

### Authentication

```
POST   /api/auth/login              # Login
POST   /api/auth/logout             # Logout
GET    /api/auth/me                 # Get current user info
POST   /api/auth/change-password    # Change password
```

### Employees

```
GET    /api/employees               # List employees (pagination, search, filter)
GET    /api/employees/profile       # Get own profile
GET    /api/employees/:id           # Get employee by ID
POST   /api/employees               # Create employee (HR/Admin)
PUT    /api/employees/:id           # Update employee (HR/Admin)
DELETE /api/employees/:id           # Delete employee (Admin)
POST   /api/employees/:id/restore   # Restore deleted employee

# Avatar & Face
POST   /api/employees/:id/avatar    # Upload avatar
DELETE /api/employees/:id/avatar    # Delete avatar
POST   /api/employees/:id/face/register    # Register face for recognition
PUT    /api/employees/:id/face/update      # Update face data
DELETE /api/employees/:id/face              # Delete face data
GET    /api/employees/:id/face/status      # Get face registration status
```

### Attendance

```
POST   /api/attendance/check-in     # Check-in with face & GPS
POST   /api/attendance/check-out    # Check-out with face & GPS
GET    /api/attendance/today        # Today's attendance
GET    /api/attendance/my           # My attendance records
GET    /api/attendance              # All attendance (HR/Manager)
GET    /api/attendance/:id          # Get specific attendance
POST   /api/attendance/manual       # Manual attendance marking (HR)
GET    /api/attendance/stats        # Attendance statistics
```

### Shifts

```
GET    /api/shifts                  # List all shifts
GET    /api/shifts/:id              # Get shift details
POST   /api/shifts                  # Create shift (HR/Admin)
PUT    /api/shifts/:id              # Update shift (HR/Admin)
DELETE /api/shifts/:id              # Delete shift (Admin)
POST   /api/shifts/:id/assign       # Assign shift to employees
GET    /api/shifts/employee/:id     # Get employee's shifts
```

### Leaves

```
GET    /api/leaves                  # List leave requests
GET    /api/leaves/my               # My leave requests
GET    /api/leaves/:id              # Get leave details
POST   /api/leaves/request          # Request leave
POST   /api/leaves/:id/approve      # Approve leave (Manager/HR)
POST   /api/leaves/:id/reject       # Reject leave (Manager/HR)
DELETE /api/leaves/:id              # Cancel leave request
GET    /api/leaves/balance          # Get leave balance
```

### Departments

```
GET    /api/departments             # List departments
GET    /api/departments/:id         # Get department details
POST   /api/departments             # Create department (Admin)
PUT    /api/departments/:id         # Update department (Admin)
DELETE /api/departments/:id         # Delete department (Admin)
GET    /api/departments/:id/employees   # Get department employees
GET    /api/departments/:id/stats       # Department statistics
```

### Devices

```
GET    /api/devices                 # List devices
GET    /api/devices/:id             # Get device details
POST   /api/devices                 # Create device (Admin)
PUT    /api/devices/:id             # Update device (Admin)
DELETE /api/devices/:id             # Delete device (Admin)
POST   /api/devices/:id/assign      # Assign device to employee
POST   /api/devices/:id/sync        # Sync device data
```

### Dashboard

```
GET    /api/dashboard/overview      # Overview statistics
GET    /api/dashboard/attendance    # Attendance summary
GET    /api/dashboard/departments   # Department statistics
GET    /api/dashboard/recent        # Recent activities
```

### Reports

```
GET    /api/reports/attendance      # Attendance reports
GET    /api/reports/leave           # Leave reports
GET    /api/reports/overtime        # Overtime reports
POST   /api/reports/export          # Export to Excel
```

Xem chi tiết tại: [API_DOCUMENTATION.md](API_DOCUMENTATION.md)

## Sample Data

Sau khi chạy seed, bạn có thể login với các tài khoản sau:

### Admin
```
Username: admin
Password: admin123
Role: Full system access
```

### HR Manager
```
Username: hr.manager
Password: hrmanager123
Role: HR operations, employee management
```

### Department Manager
```
Username: it.manager
Password: itmanager123
Role: IT Department manager
```

### Employee
```
Username: emp005
Password: employee123
Role: Regular employee
```

## Database Schema

Hệ thống sử dụng PostgreSQL với Prisma ORM:

### Core Models

- **User**: User accounts với role-based authentication
- **Employee**: Thông tin nhân viên, face descriptor
- **Department**: Phòng ban với hierarchical structure
- **Shift**: Ca làm việc với working days
- **EmployeeShift**: Phân công ca cho nhân viên
- **Attendance**: Records chấm công với face verification
- **Leave**: Đơn nghỉ phép với approval workflow
- **Device**: Thiết bị chấm công
- **DeviceAssignment**: Phân bổ thiết bị

Xem chi tiết schema tại: `prisma/schema.prisma`

## Scripts

### Development
```bash
npm run dev              # Start development server với nodemon
npm run start            # Start production server
```

### Database
```bash
npm run db:generate      # Generate Prisma client
npm run db:migrate       # Run migrations
npm run db:seed          # Seed sample data
npm run db:reset         # Reset database
npm run db:studio        # Open Prisma Studio
npm run db:status        # Check migration status
```

### Docker
```bash
npm run docker:up        # Start all containers
npm run docker:down      # Stop all containers
npm run docker:rebuild   # Rebuild and restart
npm run docker:clean     # Remove volumes
npm run docker:logs      # View all logs
npm run docker:logs:api  # View API logs only
npm run docker:migrate   # Run migrations in container
npm run docker:seed      # Seed data in container
```

## Project Structure

```
conaland-api/
├── prisma/
│   ├── schema.prisma           # Database schema
│   ├── seed.js                 # Seed data script
│   └── migrations/             # Migration files
├── src/
│   ├── config/
│   │   └── cloudinary.js       # Cloudinary & multer config
│   ├── controllers/            # Route controllers
│   │   ├── authController.js
│   │   ├── employeeController.js
│   │   ├── attendanceController.js
│   │   ├── shiftController.js
│   │   ├── leaveController.js
│   │   ├── deviceController.js
│   │   ├── departmentController.js
│   │   ├── dashboardController.js
│   │   └── reportController.js
│   ├── middleware/
│   │   ├── auth.js             # JWT & RBAC
│   │   ├── rateLimiter.js      # Rate limiting
│   │   └── validation.js       # Request validation
│   ├── services/               # Business logic
│   │   ├── attendanceService.js
│   │   ├── leaveService.js
│   │   ├── employeeService.js
│   │   ├── shiftService.js
│   │   └── reportService.js
│   ├── utils/                  # Helper functions
│   │   ├── dateUtils.js
│   │   ├── faceRecognitionUtils.js
│   │   ├── imageUtils.js
│   │   ├── locationUtils.js
│   │   └── validationUtils.js
│   └── routes/
│       └── index.js            # API routes
├── uploads/                    # Local file uploads
├── logs/                       # Application logs
├── .env                        # Environment variables
├── .env.example                # Environment template
├── docker-compose.yml          # Docker services
├── Dockerfile                  # API container
├── server.js                   # Entry point
└── package.json
```

## Security Features

- **JWT Authentication**: Secure token-based auth
- **Role-Based Access Control**: Fine-grained permissions
- **Rate Limiting**: Protection against abuse
- **Helmet.js**: Security headers
- **CORS**: Configurable cross-origin requests
- **Input Validation**: express-validator
- **Password Hashing**: bcryptjs
- **SQL Injection Prevention**: Prisma ORM

## Deployment

Xem hướng dẫn chi tiết tại: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

### Production Checklist

- [ ] Update `JWT_SECRET` to strong secret
- [ ] Configure Cloudinary credentials
- [ ] Set `NODE_ENV=production`
- [ ] Enable SSL/HTTPS
- [ ] Configure proper CORS origins
- [ ] Setup monitoring & logging
- [ ] Configure backup strategy
- [ ] Review rate limiting settings

## Development

### Code Style

- Use ES6+ features
- Follow Airbnb style guide
- Use async/await instead of callbacks
- Add JSDoc comments for complex functions

### Git Workflow

```bash
# Feature branch
git checkout -b feature/your-feature

# Commit
git commit -m "feat: add feature description"

# Push
git push origin feature/your-feature
```

### Commit Convention

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `refactor:` Code refactoring
- `test:` Tests
- `chore:` Maintenance

## Troubleshooting

### Database connection error

```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Reset database
npm run docker:down
npm run docker:up
npm run docker:migrate
```

### Port already in use

```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or change port in .env
PORT=3001
```

### Prisma errors

```bash
# Regenerate Prisma client
npm run db:generate

# Reset database
npm run db:reset
```

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

ISC

## Support

For issues and questions:
- Create an issue on GitHub
- Contact: [your-email@example.com]

## Changelog

Xem [CHANGELOG.md](CHANGELOG.md) để biết lịch sử thay đổi.

---

**Version**: 2.0.0
**Last Updated**: 2025-12-22
**Status**: Production Ready
