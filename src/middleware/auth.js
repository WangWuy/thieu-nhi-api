const jwt = require('jsonwebtoken');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Authentication & Authorization Middleware
 * HR Management System Roles:
 * - ADMIN: Full system access
 * - HR_MANAGER: HR operations, employee management
 * - DEPARTMENT_MANAGER: Department-specific access
 * - EMPLOYEE: Basic employee access
 */

const authMiddleware = {
    /**
     * Verify JWT token
     */
    verifyToken(req, res, next) {
        const authHeader = req.headers.authorization;
        const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

        if (!token) {
            return res.status(401).json({
                error: 'Authentication required',
                message: 'Access token is missing'
            });
        }

        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            req.user = decoded;
            next();
        } catch (error) {
            if (error.name === 'TokenExpiredError') {
                return res.status(401).json({
                    error: 'Token expired',
                    message: 'Please login again'
                });
            }
            return res.status(403).json({
                error: 'Invalid token',
                message: 'Token verification failed'
            });
        }
    },

    /**
     * Check if user has any of the required roles
     * @param {Array<string>} roles - Array of allowed roles
     */
    requireRole(roles) {
        return (req, res, next) => {
            if (!req.user) {
                return res.status(401).json({
                    error: 'Authentication required',
                    message: 'Please login first'
                });
            }

            if (!roles.includes(req.user.role)) {
                return res.status(403).json({
                    error: 'Insufficient permissions',
                    message: `Required role: ${roles.join(' or ')}. Your role: ${req.user.role}`
                });
            }

            next();
        };
    },

    /**
     * Require ADMIN role
     */
    requireAdmin(req, res, next) {
        if (!req.user) {
            return res.status(401).json({
                error: 'Authentication required',
                message: 'Please login first'
            });
        }

        if (req.user.role !== 'ADMIN') {
            return res.status(403).json({
                error: 'Admin access required',
                message: 'Only administrators can access this resource'
            });
        }

        next();
    },

    /**
     * Require HR_MANAGER or ADMIN role
     */
    requireHRManager(req, res, next) {
        if (!req.user) {
            return res.status(401).json({
                error: 'Authentication required',
                message: 'Please login first'
            });
        }

        const allowedRoles = ['ADMIN', 'HR_MANAGER'];
        if (!allowedRoles.includes(req.user.role)) {
            return res.status(403).json({
                error: 'HR Manager access required',
                message: 'Only HR Managers and Admins can access this resource'
            });
        }

        next();
    },

    /**
     * Require DEPARTMENT_MANAGER, HR_MANAGER, or ADMIN role
     */
    requireManager(req, res, next) {
        if (!req.user) {
            return res.status(401).json({
                error: 'Authentication required',
                message: 'Please login first'
            });
        }

        const allowedRoles = ['ADMIN', 'HR_MANAGER', 'DEPARTMENT_MANAGER'];
        if (!allowedRoles.includes(req.user.role)) {
            return res.status(403).json({
                error: 'Manager access required',
                message: 'Only Managers can access this resource'
            });
        }

        next();
    },

    /**
     * Check if user can view employee data
     * Rules:
     * - ADMIN, HR_MANAGER: Can view all employees
     * - DEPARTMENT_MANAGER: Can view employees in their department
     * - EMPLOYEE: Can only view their own data
     */
    async canViewEmployee(req, res, next) {
        if (!req.user) {
            return res.status(401).json({
                error: 'Authentication required',
                message: 'Please login first'
            });
        }

        const targetEmployeeId = req.params.id || req.params.employeeId;

        try {
            // ADMIN and HR_MANAGER can view all employees
            if (['ADMIN', 'HR_MANAGER'].includes(req.user.role)) {
                return next();
            }

            // Get current user's employee record
            const currentUser = await prisma.user.findUnique({
                where: { id: req.user.userId },
                include: { employee: true }
            });

            if (!currentUser || !currentUser.employee) {
                return res.status(403).json({
                    error: 'Forbidden',
                    message: 'Employee record not found'
                });
            }

            // EMPLOYEE can only view their own data
            if (req.user.role === 'EMPLOYEE') {
                if (currentUser.employee.id !== targetEmployeeId) {
                    return res.status(403).json({
                        error: 'Forbidden',
                        message: 'You can only view your own employee data'
                    });
                }
                return next();
            }

            // DEPARTMENT_MANAGER can view employees in their department
            if (req.user.role === 'DEPARTMENT_MANAGER') {
                const targetEmployee = await prisma.employee.findUnique({
                    where: { id: targetEmployeeId },
                    select: { departmentId: true }
                });

                if (!targetEmployee) {
                    return res.status(404).json({
                        error: 'Not found',
                        message: 'Employee not found'
                    });
                }

                if (targetEmployee.departmentId !== currentUser.employee.departmentId) {
                    return res.status(403).json({
                        error: 'Forbidden',
                        message: 'You can only view employees in your department'
                    });
                }

                return next();
            }

            return res.status(403).json({
                error: 'Forbidden',
                message: 'Insufficient permissions'
            });
        } catch (error) {
            console.error('Permission check error:', error);
            return res.status(500).json({
                error: 'Internal server error',
                message: 'Failed to check permissions'
            });
        }
    },

    /**
     * Check if user can edit employee data
     * Rules:
     * - ADMIN, HR_MANAGER: Can edit all employees
     * - DEPARTMENT_MANAGER: Can edit employees in their department
     * - EMPLOYEE: Can only edit their own basic data (not salary, contract, etc.)
     */
    async canEditEmployee(req, res, next) {
        if (!req.user) {
            return res.status(401).json({
                error: 'Authentication required',
                message: 'Please login first'
            });
        }

        const targetEmployeeId = req.params.id || req.params.employeeId;

        try {
            // ADMIN and HR_MANAGER can edit all employees
            if (['ADMIN', 'HR_MANAGER'].includes(req.user.role)) {
                return next();
            }

            // Get current user's employee record
            const currentUser = await prisma.user.findUnique({
                where: { id: req.user.userId },
                include: { employee: true }
            });

            if (!currentUser || !currentUser.employee) {
                return res.status(403).json({
                    error: 'Forbidden',
                    message: 'Employee record not found'
                });
            }

            // EMPLOYEE can only edit their own basic data
            if (req.user.role === 'EMPLOYEE') {
                if (currentUser.employee.id !== targetEmployeeId) {
                    return res.status(403).json({
                        error: 'Forbidden',
                        message: 'You can only edit your own data'
                    });
                }

                // Check if trying to edit restricted fields
                const restrictedFields = ['salary', 'contractType', 'contractEndDate', 'hireDate', 'status', 'departmentId', 'managerId'];
                const hasRestrictedFields = restrictedFields.some(field => req.body[field] !== undefined);

                if (hasRestrictedFields) {
                    return res.status(403).json({
                        error: 'Forbidden',
                        message: 'You cannot edit these fields'
                    });
                }

                return next();
            }

            // DEPARTMENT_MANAGER can edit employees in their department (except sensitive fields)
            if (req.user.role === 'DEPARTMENT_MANAGER') {
                const targetEmployee = await prisma.employee.findUnique({
                    where: { id: targetEmployeeId },
                    select: { departmentId: true }
                });

                if (!targetEmployee) {
                    return res.status(404).json({
                        error: 'Not found',
                        message: 'Employee not found'
                    });
                }

                if (targetEmployee.departmentId !== currentUser.employee.departmentId) {
                    return res.status(403).json({
                        error: 'Forbidden',
                        message: 'You can only edit employees in your department'
                    });
                }

                return next();
            }

            return res.status(403).json({
                error: 'Forbidden',
                message: 'Insufficient permissions'
            });
        } catch (error) {
            console.error('Permission check error:', error);
            return res.status(500).json({
                error: 'Internal server error',
                message: 'Failed to check permissions'
            });
        }
    },

    /**
     * Check if user can approve leave requests
     * Rules:
     * - ADMIN, HR_MANAGER: Can approve all leave requests
     * - DEPARTMENT_MANAGER: Can approve leave requests in their department
     */
    async canApproveLeave(req, res, next) {
        if (!req.user) {
            return res.status(401).json({
                error: 'Authentication required',
                message: 'Please login first'
            });
        }

        try {
            // ADMIN and HR_MANAGER can approve all leaves
            if (['ADMIN', 'HR_MANAGER'].includes(req.user.role)) {
                return next();
            }

            // DEPARTMENT_MANAGER can approve leaves in their department
            if (req.user.role === 'DEPARTMENT_MANAGER') {
                const leaveId = req.params.id || req.params.leaveId;

                const leave = await prisma.leave.findUnique({
                    where: { id: leaveId },
                    include: {
                        employee: {
                            select: { departmentId: true }
                        }
                    }
                });

                if (!leave) {
                    return res.status(404).json({
                        error: 'Not found',
                        message: 'Leave request not found'
                    });
                }

                const currentUser = await prisma.user.findUnique({
                    where: { id: req.user.userId },
                    include: { employee: true }
                });

                if (leave.employee.departmentId !== currentUser.employee?.departmentId) {
                    return res.status(403).json({
                        error: 'Forbidden',
                        message: 'You can only approve leave requests in your department'
                    });
                }

                return next();
            }

            return res.status(403).json({
                error: 'Forbidden',
                message: 'Only managers can approve leave requests'
            });
        } catch (error) {
            console.error('Permission check error:', error);
            return res.status(500).json({
                error: 'Internal server error',
                message: 'Failed to check permissions'
            });
        }
    },

    /**
     * Check if user can view department data
     */
    async canViewDepartment(req, res, next) {
        if (!req.user) {
            return res.status(401).json({
                error: 'Authentication required',
                message: 'Please login first'
            });
        }

        const departmentId = req.params.id || req.params.departmentId;

        try {
            // ADMIN and HR_MANAGER can view all departments
            if (['ADMIN', 'HR_MANAGER'].includes(req.user.role)) {
                return next();
            }

            // DEPARTMENT_MANAGER and EMPLOYEE can only view their department
            const currentUser = await prisma.user.findUnique({
                where: { id: req.user.userId },
                include: { employee: true }
            });

            if (!currentUser || !currentUser.employee) {
                return res.status(403).json({
                    error: 'Forbidden',
                    message: 'Employee record not found'
                });
            }

            if (currentUser.employee.departmentId !== departmentId) {
                return res.status(403).json({
                    error: 'Forbidden',
                    message: 'You can only view your own department'
                });
            }

            return next();
        } catch (error) {
            console.error('Permission check error:', error);
            return res.status(500).json({
                error: 'Internal server error',
                message: 'Failed to check permissions'
            });
        }
    }
};

module.exports = authMiddleware;