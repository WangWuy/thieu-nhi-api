/**
 * Image Utilities
 * Helper functions for image processing and validation
 * Note: For production, install 'sharp' package for image processing
 */

/**
 * Validate image file type
 * @param {string} mimetype - File mimetype
 * @returns {boolean}
 */
const isValidImageType = (mimetype) => {
    const validTypes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
    return validTypes.includes(mimetype);
};

/**
 * Validate image file extension
 * @param {string} filename
 * @returns {boolean}
 */
const isValidImageExtension = (filename) => {
    const ext = filename.toLowerCase().split('.').pop();
    const validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
    return validExtensions.includes(ext);
};

/**
 * Get file extension from filename
 * @param {string} filename
 * @returns {string}
 */
const getFileExtension = (filename) => {
    return filename.toLowerCase().split('.').pop();
};

/**
 * Generate unique filename
 * @param {string} originalFilename
 * @param {string} prefix - Optional prefix
 * @returns {string}
 */
const generateUniqueFilename = (originalFilename, prefix = '') => {
    const ext = getFileExtension(originalFilename);
    const timestamp = Date.now();
    const random = Math.random().toString(36).substring(2, 8);
    const prefixPart = prefix ? `${prefix}_` : '';

    return `${prefixPart}${timestamp}_${random}.${ext}`;
};

/**
 * Validate image size
 * @param {number} sizeInBytes
 * @param {number} maxSizeInMB - Default 10MB
 * @returns {{valid: boolean, message: string}}
 */
const validateImageSize = (sizeInBytes, maxSizeInMB = 10) => {
    const maxSizeInBytes = maxSizeInMB * 1024 * 1024;

    if (sizeInBytes > maxSizeInBytes) {
        return {
            valid: false,
            message: `File size ${(sizeInBytes / 1024 / 1024).toFixed(2)}MB exceeds maximum ${maxSizeInMB}MB`
        };
    }

    return {
        valid: true,
        message: 'File size is valid'
    };
};

/**
 * Convert base64 to buffer
 * @param {string} base64String
 * @returns {Buffer}
 */
const base64ToBuffer = (base64String) => {
    // Remove data URL prefix if present
    const base64Data = base64String.replace(/^data:image\/\w+;base64,/, '');
    return Buffer.from(base64Data, 'base64');
};

/**
 * Convert buffer to base64
 * @param {Buffer} buffer
 * @param {string} mimetype - Default 'image/jpeg'
 * @returns {string}
 */
const bufferToBase64 = (buffer, mimetype = 'image/jpeg') => {
    const base64 = buffer.toString('base64');
    return `data:${mimetype};base64,${base64}`;
};

/**
 * Validate base64 image string
 * @param {string} base64String
 * @returns {boolean}
 */
const isValidBase64Image = (base64String) => {
    if (!base64String) return false;

    // Check if it starts with data URL scheme
    const dataUrlPattern = /^data:image\/(jpeg|jpg|png|webp);base64,/;
    if (!dataUrlPattern.test(base64String)) return false;

    try {
        // Try to convert to buffer
        const buffer = base64ToBuffer(base64String);
        return buffer.length > 0;
    } catch (error) {
        return false;
    }
};

/**
 * Get image info from base64
 * @param {string} base64String
 * @returns {{mimetype: string, size: number, base64Length: number}}
 */
const getBase64ImageInfo = (base64String) => {
    const matches = base64String.match(/^data:([^;]+);base64,/);
    const mimetype = matches ? matches[1] : 'unknown';
    const base64Data = base64String.replace(/^data:image\/\w+;base64,/, '');
    const buffer = Buffer.from(base64Data, 'base64');

    return {
        mimetype,
        size: buffer.length,
        base64Length: base64Data.length
    };
};

/**
 * Resize image (requires 'sharp' package)
 * @param {Buffer} imageBuffer
 * @param {number} maxWidth - Default 1920
 * @param {number} maxHeight - Default 1080
 * @returns {Promise<Buffer>}
 */
const resizeImage = async (imageBuffer, maxWidth = 1920, maxHeight = 1080) => {
    try {
        // TODO: Install and use 'sharp' package for production
        // const sharp = require('sharp');
        // return await sharp(imageBuffer)
        //     .resize(maxWidth, maxHeight, {
        //         fit: 'inside',
        //         withoutEnlargement: true
        //     })
        //     .jpeg({ quality: 90 })
        //     .toBuffer();

        // Mock: Return original buffer
        console.warn('Image resize not implemented. Install "sharp" package for production.');
        return imageBuffer;
    } catch (error) {
        console.error('Image resize error:', error);
        return imageBuffer;
    }
};

/**
 * Compress image (requires 'sharp' package)
 * @param {Buffer} imageBuffer
 * @param {number} quality - 1-100, default 80
 * @returns {Promise<Buffer>}
 */
const compressImage = async (imageBuffer, quality = 80) => {
    try {
        // TODO: Install and use 'sharp' package for production
        // const sharp = require('sharp');
        // return await sharp(imageBuffer)
        //     .jpeg({ quality })
        //     .toBuffer();

        // Mock: Return original buffer
        console.warn('Image compress not implemented. Install "sharp" package for production.');
        return imageBuffer;
    } catch (error) {
        console.error('Image compress error:', error);
        return imageBuffer;
    }
};

/**
 * Get image metadata (requires 'sharp' package)
 * @param {Buffer} imageBuffer
 * @returns {Promise<Object>}
 */
const getImageMetadata = async (imageBuffer) => {
    try {
        // TODO: Install and use 'sharp' package for production
        // const sharp = require('sharp');
        // const metadata = await sharp(imageBuffer).metadata();
        // return {
        //     width: metadata.width,
        //     height: metadata.height,
        //     format: metadata.format,
        //     size: metadata.size,
        //     space: metadata.space,
        //     channels: metadata.channels,
        //     hasAlpha: metadata.hasAlpha
        // };

        // Mock: Return default metadata
        return {
            width: 0,
            height: 0,
            format: 'unknown',
            size: imageBuffer.length,
            space: 'srgb',
            channels: 3,
            hasAlpha: false
        };
    } catch (error) {
        console.error('Get image metadata error:', error);
        return null;
    }
};

/**
 * Convert image to JPEG (requires 'sharp' package)
 * @param {Buffer} imageBuffer
 * @param {number} quality - Default 90
 * @returns {Promise<Buffer>}
 */
const convertToJPEG = async (imageBuffer, quality = 90) => {
    try {
        // TODO: Install and use 'sharp' package for production
        // const sharp = require('sharp');
        // return await sharp(imageBuffer)
        //     .jpeg({ quality })
        //     .toBuffer();

        // Mock: Return original buffer
        return imageBuffer;
    } catch (error) {
        console.error('Convert to JPEG error:', error);
        return imageBuffer;
    }
};

/**
 * Sanitize filename
 * @param {string} filename
 * @returns {string}
 */
const sanitizeFilename = (filename) => {
    // Remove special characters, keep only alphanumeric, dots, hyphens, underscores
    return filename
        .replace(/[^a-zA-Z0-9._-]/g, '_')
        .replace(/_{2,}/g, '_')
        .toLowerCase();
};

/**
 * Get file size in human readable format
 * @param {number} bytes
 * @returns {string}
 */
const formatFileSize = (bytes) => {
    if (bytes === 0) return '0 Bytes';

    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));

    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
};

module.exports = {
    isValidImageType,
    isValidImageExtension,
    getFileExtension,
    generateUniqueFilename,
    validateImageSize,
    base64ToBuffer,
    bufferToBase64,
    isValidBase64Image,
    getBase64ImageInfo,
    resizeImage,
    compressImage,
    getImageMetadata,
    convertToJPEG,
    sanitizeFilename,
    formatFileSize
};
