/**
 * Validation Utilities
 * Common validation helper functions
 */

/**
 * Validate email format
 * @param {string} email
 * @returns {boolean}
 */
const isValidEmail = (email) => {
    if (!email) return false;
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
};

/**
 * Validate phone number (Vietnam format)
 * @param {string} phone
 * @returns {boolean}
 */
const isValidPhone = (phone) => {
    if (!phone) return false;
    // Vietnam phone: 10-11 digits, starts with 0
    const phoneRegex = /^0\d{9,10}$/;
    return phoneRegex.test(phone.replace(/[\s\-]/g, ''));
};

/**
 * Validate employee code format
 * @param {string} code
 * @returns {boolean}
 */
const isValidEmployeeCode = (code) => {
    if (!code) return false;
    // Format: EMP-YYYYMM-XXX or DEPT-YYYYMM-XXX
    const codeRegex = /^[A-Z]{2,5}-\d{6}-\d{3}$/;
    return codeRegex.test(code);
};

/**
 * Validate password strength
 * @param {string} password
 * @returns {{valid: boolean, message: string, strength: string}}
 */
const validatePassword = (password) => {
    if (!password) {
        return {
            valid: false,
            message: 'Password is required',
            strength: 'none'
        };
    }

    if (password.length < 8) {
        return {
            valid: false,
            message: 'Password must be at least 8 characters',
            strength: 'weak'
        };
    }

    const hasUpperCase = /[A-Z]/.test(password);
    const hasLowerCase = /[a-z]/.test(password);
    const hasNumbers = /\d/.test(password);
    const hasSpecialChar = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password);

    const criteriaMet = [hasUpperCase, hasLowerCase, hasNumbers, hasSpecialChar].filter(Boolean).length;

    if (criteriaMet < 2) {
        return {
            valid: false,
            message: 'Password must contain at least 2 of: uppercase, lowercase, numbers, special characters',
            strength: 'weak'
        };
    }

    let strength = 'medium';
    if (criteriaMet >= 4 && password.length >= 12) {
        strength = 'strong';
    } else if (criteriaMet >= 3 && password.length >= 10) {
        strength = 'medium';
    }

    return {
        valid: true,
        message: 'Password is valid',
        strength
    };
};

/**
 * Validate date string format
 * @param {string} dateString
 * @param {string} format - 'YYYY-MM-DD', 'DD/MM/YYYY', etc.
 * @returns {boolean}
 */
const isValidDateString = (dateString, format = 'YYYY-MM-DD') => {
    if (!dateString) return false;

    let regex;
    switch (format) {
        case 'YYYY-MM-DD':
            regex = /^\d{4}-\d{2}-\d{2}$/;
            break;
        case 'DD/MM/YYYY':
            regex = /^\d{2}\/\d{2}\/\d{4}$/;
            break;
        case 'DD-MM-YYYY':
            regex = /^\d{2}-\d{2}-\d{4}$/;
            break;
        default:
            return false;
    }

    if (!regex.test(dateString)) return false;

    // Check if date is valid
    const date = new Date(dateString);
    return date instanceof Date && !isNaN(date);
};

/**
 * Validate time string format (HH:mm)
 * @param {string} timeString
 * @returns {boolean}
 */
const isValidTimeString = (timeString) => {
    if (!timeString) return false;
    const timeRegex = /^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$/;
    return timeRegex.test(timeString);
};

/**
 * Validate URL format
 * @param {string} url
 * @returns {boolean}
 */
const isValidUrl = (url) => {
    if (!url) return false;

    try {
        new URL(url);
        return true;
    } catch (error) {
        return false;
    }
};

/**
 * Validate UUID format
 * @param {string} uuid
 * @returns {boolean}
 */
const isValidUUID = (uuid) => {
    if (!uuid) return false;
    const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
    return uuidRegex.test(uuid);
};

/**
 * Validate number range
 * @param {number} value
 * @param {number} min
 * @param {number} max
 * @returns {{valid: boolean, message: string}}
 */
const isNumberInRange = (value, min, max) => {
    if (typeof value !== 'number' || isNaN(value)) {
        return {
            valid: false,
            message: 'Value must be a number'
        };
    }

    if (value < min || value > max) {
        return {
            valid: false,
            message: `Value must be between ${min} and ${max}`
        };
    }

    return {
        valid: true,
        message: 'Value is valid'
    };
};

/**
 * Validate string length
 * @param {string} str
 * @param {number} min
 * @param {number} max
 * @returns {{valid: boolean, message: string}}
 */
const isStringLengthValid = (str, min, max) => {
    if (typeof str !== 'string') {
        return {
            valid: false,
            message: 'Value must be a string'
        };
    }

    if (str.length < min) {
        return {
            valid: false,
            message: `String must be at least ${min} characters`
        };
    }

    if (str.length > max) {
        return {
            valid: false,
            message: `String must not exceed ${max} characters`
        };
    }

    return {
        valid: true,
        message: 'String length is valid'
    };
};

/**
 * Validate required fields in object
 * @param {Object} obj
 * @param {Array<string>} requiredFields
 * @returns {{valid: boolean, missingFields: Array<string>, message: string}}
 */
const validateRequiredFields = (obj, requiredFields) => {
    if (!obj || typeof obj !== 'object') {
        return {
            valid: false,
            missingFields: requiredFields,
            message: 'Invalid object'
        };
    }

    const missingFields = requiredFields.filter(field => {
        const value = obj[field];
        return value === undefined || value === null || value === '';
    });

    return {
        valid: missingFields.length === 0,
        missingFields,
        message: missingFields.length > 0
            ? `Missing required fields: ${missingFields.join(', ')}`
            : 'All required fields are present'
    };
};

/**
 * Sanitize string (remove special characters)
 * @param {string} str
 * @returns {string}
 */
const sanitizeString = (str) => {
    if (!str) return '';
    return str.replace(/[<>]/g, '').trim();
};

/**
 * Validate enum value
 * @param {any} value
 * @param {Array} allowedValues
 * @returns {{valid: boolean, message: string}}
 */
const isValidEnum = (value, allowedValues) => {
    if (!allowedValues.includes(value)) {
        return {
            valid: false,
            message: `Value must be one of: ${allowedValues.join(', ')}`
        };
    }

    return {
        valid: true,
        message: 'Value is valid'
    };
};

/**
 * Validate array
 * @param {any} value
 * @param {number} minLength
 * @param {number} maxLength
 * @returns {{valid: boolean, message: string}}
 */
const validateArray = (value, minLength = 0, maxLength = Infinity) => {
    if (!Array.isArray(value)) {
        return {
            valid: false,
            message: 'Value must be an array'
        };
    }

    if (value.length < minLength) {
        return {
            valid: false,
            message: `Array must have at least ${minLength} items`
        };
    }

    if (value.length > maxLength) {
        return {
            valid: false,
            message: `Array must not exceed ${maxLength} items`
        };
    }

    return {
        valid: true,
        message: 'Array is valid'
    };
};

/**
 * Validate file size
 * @param {number} sizeInBytes
 * @param {number} maxSizeInMB
 * @returns {{valid: boolean, message: string}}
 */
const validateFileSize = (sizeInBytes, maxSizeInMB) => {
    const maxSizeInBytes = maxSizeInMB * 1024 * 1024;

    if (sizeInBytes > maxSizeInBytes) {
        return {
            valid: false,
            message: `File size exceeds maximum ${maxSizeInMB}MB`
        };
    }

    return {
        valid: true,
        message: 'File size is valid'
    };
};

/**
 * Validate Vietnamese ID card number
 * @param {string} idNumber
 * @returns {boolean}
 */
const isValidVietnamID = (idNumber) => {
    if (!idNumber) return false;
    // Old format: 9 digits, New format: 12 digits
    const idRegex = /^(\d{9}|\d{12})$/;
    return idRegex.test(idNumber);
};

/**
 * Check if value is empty
 * @param {any} value
 * @returns {boolean}
 */
const isEmpty = (value) => {
    if (value === null || value === undefined) return true;
    if (typeof value === 'string') return value.trim() === '';
    if (Array.isArray(value)) return value.length === 0;
    if (typeof value === 'object') return Object.keys(value).length === 0;
    return false;
};

/**
 * Validate positive number
 * @param {number} value
 * @returns {{valid: boolean, message: string}}
 */
const isPositiveNumber = (value) => {
    if (typeof value !== 'number' || isNaN(value)) {
        return {
            valid: false,
            message: 'Value must be a number'
        };
    }

    if (value <= 0) {
        return {
            valid: false,
            message: 'Value must be positive'
        };
    }

    return {
        valid: true,
        message: 'Value is valid'
    };
};

module.exports = {
    isValidEmail,
    isValidPhone,
    isValidEmployeeCode,
    validatePassword,
    isValidDateString,
    isValidTimeString,
    isValidUrl,
    isValidUUID,
    isNumberInRange,
    isStringLengthValid,
    validateRequiredFields,
    sanitizeString,
    isValidEnum,
    validateArray,
    validateFileSize,
    isValidVietnamID,
    isEmpty,
    isPositiveNumber
};
