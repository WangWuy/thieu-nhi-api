const jwt = require('jsonwebtoken');

const authMiddleware = {
    // Verify JWT token
    verifyToken(req, res, next) {
        const authHeader = req.headers.authorization;
        const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

        if (!token) {
            return res.status(401).json({ error: 'Access token required' });
        }

        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET);
            req.user = decoded;
            next();
        } catch (error) {
            return res.status(403).json({ error: 'Invalid or expired token' });
        }
    },

    // Check if user has required role
    requireRole(roles) {
        return (req, res, next) => {
            if (!req.user) {
                return res.status(401).json({ error: 'Authentication required' });
            }

            if (!roles.includes(req.user.role)) {
                return res.status(403).json({ error: 'Insufficient permissions' });
            }

            next();
        };
    },

    // Check if user is admin
    requireAdmin(req, res, next) {
        if (!req.user) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        if (req.user.role !== 'ban_dieu_hanh') {
            return res.status(403).json({ error: 'Admin access required' });
        }

        next();
    }
};

module.exports = authMiddleware;