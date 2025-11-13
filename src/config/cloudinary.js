const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const multer = require('multer');

// Cấu hình Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

// Storage cho User avatars
const userAvatarStorage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'avatars/users',
        allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
        transformation: [
            { width: 500, height: 500, crop: 'fill', gravity: 'face' }
        ],
        public_id: (req, file) => `user_${req.params.id || req.user.id}_${Date.now()}`
    }
});

// Storage cho Student avatars
const studentAvatarStorage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'avatars/students',
        allowed_formats: ['jpg', 'jpeg', 'png', 'webp'],
        transformation: [
            { width: 500, height: 500, crop: 'fill', gravity: 'face' }
        ],
        public_id: (req, file) => `student_${req.params.id}_${Date.now()}`
    }
});

// Multer middleware
const uploadUserAvatar = multer({
    storage: userAvatarStorage,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB
    },
    fileFilter: (req, file, cb) => {
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('Chỉ chấp nhận file ảnh (jpg, jpeg, png, webp)'), false);
        }
    }
});

const uploadStudentAvatar = multer({
    storage: studentAvatarStorage,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB
    },
    fileFilter: (req, file, cb) => {
        if (file.mimetype.startsWith('image/')) {
            cb(null, true);
        } else {
            cb(new Error('Chỉ chấp nhận file ảnh (jpg, jpeg, png, webp)'), false);
        }
    }
});

// Helper function để xóa ảnh cũ
const deleteAvatar = async (avatarUrl) => {
    try {
        if (!avatarUrl) return;
        
        // Extract public_id từ URL
        const parts = avatarUrl.split('/');
        const filename = parts[parts.length - 1];
        const publicId = `avatars/${parts[parts.length - 2]}/${filename.split('.')[0]}`;
        
        await cloudinary.uploader.destroy(publicId);
    } catch (error) {
        console.error('Error deleting avatar:', error);
    }
};

module.exports = {
    cloudinary,
    uploadUserAvatar,
    uploadStudentAvatar,
    deleteAvatar
};