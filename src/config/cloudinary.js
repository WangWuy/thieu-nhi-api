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
        resource_type: 'image', // Chỉ accept image
        transformation: [
            { 
                width: 500, 
                height: 500, 
                crop: 'fill', 
                gravity: 'face',
                fetch_format: 'auto' // Auto convert sang format tối ưu
            }
        ],
        public_id: (req, file) => `user_${req.params.id || req.user?.userId}_${Date.now()}`
    }
});

const studentAvatarStorage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: {
        folder: 'avatars/students',
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
        public_id: (req, file) => `student_${req.params.id}_${Date.now()}`
    }
});

const uploadStudentAvatar = multer({
    storage: studentAvatarStorage,
    limits: {
        fileSize: 5 * 1024 * 1024
    }
});

// Multer middleware
const uploadUserAvatar = multer({
    storage: userAvatarStorage,
    limits: {
        fileSize: 5 * 1024 * 1024 // 5MB
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
