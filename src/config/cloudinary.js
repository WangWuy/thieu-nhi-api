const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const multer = require('multer');

// Cấu hình Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

// ==================== STORAGE CONFIGURATIONS ====================

// Storage cho Employee avatars
const employeeAvatarStorage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'hr/avatars/employees',
        resource_type: 'image',
        transformation: [
            {
                width: 500,
                height: 500,
                crop: 'fill',
                gravity: 'face',
                fetch_format: 'auto'
            }
        ],
        public_id: (req, file) => `employee_${req.params.id}_${Date.now()}`
    }
});

// Storage cho Face photos (dùng cho face recognition training)
const facePhotoStorage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'hr/face-data',
        resource_type: 'image',
        transformation: [
            {
                width: 800,
                height: 800,
                crop: 'fill',
                gravity: 'face',
                quality: 'auto:best',
                fetch_format: 'jpg'
            }
        ],
        public_id: (req, file) => `face_${req.params.id}_${Date.now()}`
    }
});

// Storage cho Attendance photos (check-in/check-out verification)
const attendancePhotoStorage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'hr/attendance',
        resource_type: 'image',
        transformation: [
            {
                width: 600,
                height: 600,
                crop: 'fill',
                quality: 'auto',
                fetch_format: 'jpg'
            }
        ],
        public_id: (req, file) => `attendance_${req.user?.employeeId || 'unknown'}_${Date.now()}`
    }
});

// Storage cho User avatars (legacy - for backwards compatibility)
const userAvatarStorage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'avatars/users',
        resource_type: 'image',
        transformation: [
            {
                width: 500,
                height: 500,
                crop: 'fill',
                gravity: 'face',
                fetch_format: 'auto'
            }
        ],
        public_id: (req, file) => `user_${req.params.id || req.user?.userId}_${Date.now()}`
    }
});

// ==================== MULTER MIDDLEWARE ====================

// Upload employee avatar
const uploadEmployeeAvatar = multer({
    storage: employeeAvatarStorage,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB
    },
    fileFilter: (req, file, cb) => {
        // Accept images only
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('Only image files are allowed!'), false);
        }
    }
});

// Upload face photo for face recognition
const uploadFacePhoto = multer({
    storage: facePhotoStorage,
    limits: {
        fileSize: 10 * 1024 * 1024 // 10MB - higher quality for face recognition
    },
    fileFilter: (req, file, cb) => {
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('Only image files are allowed!'), false);
        }
    }
});

// Upload attendance photo
const uploadAttendancePhoto = multer({
    storage: attendancePhotoStorage,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB
    },
    fileFilter: (req, file, cb) => {
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('Only image files are allowed!'), false);
        }
    }
});

// Upload user avatar (legacy)
const uploadUserAvatar = multer({
    storage: userAvatarStorage,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB
    }
});

// ==================== HELPER FUNCTIONS ====================

// Helper function để xóa ảnh cũ từ Cloudinary
const deleteImage = async (imageUrl) => {
    try {
        if (!imageUrl) return;

        // Extract public_id từ URL
        // Example URL: https://res.cloudinary.com/xxx/image/upload/v123/hr/avatars/employee_1_123.jpg
        const parts = imageUrl.split('/');
        const uploadIndex = parts.indexOf('upload');
        if (uploadIndex === -1) return;

        // Get everything after "upload/v{version}/"
        const pathParts = parts.slice(uploadIndex + 2); // Skip 'upload' and version
        const publicIdWithExt = pathParts.join('/');
        const publicId = publicIdWithExt.substring(0, publicIdWithExt.lastIndexOf('.'));

        await cloudinary.uploader.destroy(publicId);
        console.log(`Deleted image from Cloudinary: ${publicId}`);
    } catch (error) {
        console.error('Error deleting image from Cloudinary:', error);
    }
};

// Helper function để xóa ảnh bằng public_id
const deleteImageByPublicId = async (publicId) => {
    try {
        if (!publicId) return;
        await cloudinary.uploader.destroy(publicId);
        console.log(`Deleted image from Cloudinary: ${publicId}`);
    } catch (error) {
        console.error('Error deleting image by public ID:', error);
    }
};

// Legacy function for backwards compatibility
const deleteAvatar = deleteImage;

module.exports = {
    cloudinary,
    // HR System uploads
    uploadEmployeeAvatar,
    uploadFacePhoto,
    uploadAttendancePhoto,
    // Legacy uploads
    uploadUserAvatar,
    // Helper functions
    deleteImage,
    deleteImageByPublicId,
    deleteAvatar
};
