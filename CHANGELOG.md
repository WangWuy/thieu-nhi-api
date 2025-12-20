# CHANGELOG - HR System Migration

## [2.0.0] - 2025-12-19

### Major Changes - Complete System Overhaul

#### Removed
- All student management features
- Academic year management
- Class management
- Student scores and grading system
- Student attendance system

#### Added
- **Employee Management System**
  - Complete CRUD for employees
  - Employee profiles with contracts
  - Department hierarchy support
  - Manager-subordinate relationships

- **Face Recognition Attendance**
  - Face-based check-in/check-out
  - GPS location tracking
  - Verification photo storage
  - Confidence score tracking
  - Anti-spoofing measures

- **Shift Management**
  - Multiple shift support
  - Flexible scheduling
  - Employee shift assignments
  - Grace period configuration

- **Leave Management**
  - Leave request workflow
  - Multiple leave types (annual, sick, unpaid, etc.)
  - Approval system
  - Leave balance tracking

- **Device Management**
  - Biometric device support
  - Device assignment tracking
  - Mobile app support

- **Advanced Reporting**
  - Attendance reports with photo evidence
  - Leave reports
  - Overtime tracking
  - Department analytics

#### Changed
- Database schema completely redesigned
- Authentication roles updated (admin, hr_manager, department_manager, employee)
- Docker setup with API container
- Added Redis for caching
- Upgraded PostgreSQL to version 16

#### Technical
- Added face-api.js for face recognition
- Added TensorFlow.js for ML models
- Added sharp for image processing
- Added node-geocoder for reverse geocoding
- Added geolib for GPS calculations

---

## [1.0.0] - Previous Version

Student management system for educational institution.
