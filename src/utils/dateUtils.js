/**
 * Date Utilities
 * Helper functions for date/time operations
 */

/**
 * Get start of day (00:00:00)
 * @param {Date} date
 * @returns {Date}
 */
const getStartOfDay = (date) => {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    return d;
};

/**
 * Get end of day (23:59:59.999)
 * @param {Date} date
 * @returns {Date}
 */
const getEndOfDay = (date) => {
    const d = new Date(date);
    d.setHours(23, 59, 59, 999);
    return d;
};

/**
 * Get start of week (Monday 00:00:00)
 * @param {Date} date
 * @returns {Date}
 */
const getStartOfWeek = (date) => {
    const d = new Date(date);
    const day = d.getDay();
    const diff = d.getDate() - day + (day === 0 ? -6 : 1); // Adjust for Sunday
    d.setDate(diff);
    d.setHours(0, 0, 0, 0);
    return d;
};

/**
 * Get end of week (Sunday 23:59:59.999)
 * @param {Date} date
 * @returns {Date}
 */
const getEndOfWeek = (date) => {
    const d = new Date(date);
    const day = d.getDay();
    const diff = d.getDate() + (day === 0 ? 0 : 7 - day);
    d.setDate(diff);
    d.setHours(23, 59, 59, 999);
    return d;
};

/**
 * Get start of month
 * @param {Date} date
 * @returns {Date}
 */
const getStartOfMonth = (date) => {
    const d = new Date(date);
    d.setDate(1);
    d.setHours(0, 0, 0, 0);
    return d;
};

/**
 * Get end of month
 * @param {Date} date
 * @returns {Date}
 */
const getEndOfMonth = (date) => {
    const d = new Date(date);
    d.setMonth(d.getMonth() + 1);
    d.setDate(0);
    d.setHours(23, 59, 59, 999);
    return d;
};

/**
 * Get start of year
 * @param {Date} date
 * @returns {Date}
 */
const getStartOfYear = (date) => {
    const d = new Date(date);
    d.setMonth(0);
    d.setDate(1);
    d.setHours(0, 0, 0, 0);
    return d;
};

/**
 * Get end of year
 * @param {Date} date
 * @returns {Date}
 */
const getEndOfYear = (date) => {
    const d = new Date(date);
    d.setMonth(11);
    d.setDate(31);
    d.setHours(23, 59, 59, 999);
    return d;
};

/**
 * Check if date is weekend
 * @param {Date} date
 * @returns {boolean}
 */
const isWeekend = (date) => {
    const day = new Date(date).getDay();
    return day === 0 || day === 6; // Sunday or Saturday
};

/**
 * Check if date is weekday
 * @param {Date} date
 * @returns {boolean}
 */
const isWeekday = (date) => {
    return !isWeekend(date);
};

/**
 * Get weekday name
 * @param {Date} date
 * @param {string} locale - Default 'vi-VN'
 * @returns {string}
 */
const getWeekdayName = (date, locale = 'vi-VN') => {
    return new Date(date).toLocaleDateString(locale, { weekday: 'long' });
};

/**
 * Get month name
 * @param {Date} date
 * @param {string} locale - Default 'vi-VN'
 * @returns {string}
 */
const getMonthName = (date, locale = 'vi-VN') => {
    return new Date(date).toLocaleDateString(locale, { month: 'long' });
};

/**
 * Format date to string
 * @param {Date} date
 * @param {string} format - 'YYYY-MM-DD', 'DD/MM/YYYY', 'DD-MM-YYYY HH:mm:ss'
 * @returns {string}
 */
const formatDate = (date, format = 'YYYY-MM-DD') => {
    const d = new Date(date);
    const year = d.getFullYear();
    const month = String(d.getMonth() + 1).padStart(2, '0');
    const day = String(d.getDate()).padStart(2, '0');
    const hours = String(d.getHours()).padStart(2, '0');
    const minutes = String(d.getMinutes()).padStart(2, '0');
    const seconds = String(d.getSeconds()).padStart(2, '0');

    switch (format) {
        case 'YYYY-MM-DD':
            return `${year}-${month}-${day}`;
        case 'DD/MM/YYYY':
            return `${day}/${month}/${year}`;
        case 'DD-MM-YYYY':
            return `${day}-${month}-${year}`;
        case 'YYYY-MM-DD HH:mm:ss':
            return `${year}-${month}-${day} ${hours}:${minutes}:${seconds}`;
        case 'DD/MM/YYYY HH:mm':
            return `${day}/${month}/${year} ${hours}:${minutes}`;
        default:
            return d.toISOString();
    }
};

/**
 * Add days to date
 * @param {Date} date
 * @param {number} days
 * @returns {Date}
 */
const addDays = (date, days) => {
    const d = new Date(date);
    d.setDate(d.getDate() + days);
    return d;
};

/**
 * Add months to date
 * @param {Date} date
 * @param {number} months
 * @returns {Date}
 */
const addMonths = (date, months) => {
    const d = new Date(date);
    d.setMonth(d.getMonth() + months);
    return d;
};

/**
 * Add years to date
 * @param {Date} date
 * @param {number} years
 * @returns {Date}
 */
const addYears = (date, years) => {
    const d = new Date(date);
    d.setFullYear(d.getFullYear() + years);
    return d;
};

/**
 * Calculate difference in days
 * @param {Date} date1
 * @param {Date} date2
 * @returns {number}
 */
const diffInDays = (date1, date2) => {
    const d1 = new Date(date1);
    const d2 = new Date(date2);
    const diffTime = Math.abs(d2 - d1);
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
};

/**
 * Calculate difference in hours
 * @param {Date} date1
 * @param {Date} date2
 * @returns {number}
 */
const diffInHours = (date1, date2) => {
    const d1 = new Date(date1);
    const d2 = new Date(date2);
    const diffTime = Math.abs(d2 - d1);
    return Math.floor(diffTime / (1000 * 60 * 60));
};

/**
 * Calculate difference in minutes
 * @param {Date} date1
 * @param {Date} date2
 * @returns {number}
 */
const diffInMinutes = (date1, date2) => {
    const d1 = new Date(date1);
    const d2 = new Date(date2);
    const diffTime = Math.abs(d2 - d1);
    return Math.floor(diffTime / (1000 * 60));
};

/**
 * Check if date is today
 * @param {Date} date
 * @returns {boolean}
 */
const isToday = (date) => {
    const today = new Date();
    const d = new Date(date);
    return d.getDate() === today.getDate() &&
        d.getMonth() === today.getMonth() &&
        d.getFullYear() === today.getFullYear();
};

/**
 * Check if date is in the past
 * @param {Date} date
 * @returns {boolean}
 */
const isPast = (date) => {
    return new Date(date) < new Date();
};

/**
 * Check if date is in the future
 * @param {Date} date
 * @returns {boolean}
 */
const isFuture = (date) => {
    return new Date(date) > new Date();
};

/**
 * Get number of days in month
 * @param {number} year
 * @param {number} month - 1-12
 * @returns {number}
 */
const getDaysInMonth = (year, month) => {
    return new Date(year, month, 0).getDate();
};

/**
 * Get all dates in month
 * @param {number} year
 * @param {number} month - 1-12
 * @returns {Array<Date>}
 */
const getAllDatesInMonth = (year, month) => {
    const dates = [];
    const daysInMonth = getDaysInMonth(year, month);

    for (let day = 1; day <= daysInMonth; day++) {
        dates.push(new Date(year, month - 1, day));
    }

    return dates;
};

/**
 * Get all weekdays in month
 * @param {number} year
 * @param {number} month - 1-12
 * @returns {Array<Date>}
 */
const getAllWeekdaysInMonth = (year, month) => {
    const dates = getAllDatesInMonth(year, month);
    return dates.filter(date => isWeekday(date));
};

/**
 * Parse time string to Date
 * @param {string} timeString - Format: 'HH:mm' or 'HH:mm:ss'
 * @param {Date} baseDate - Optional base date, default today
 * @returns {Date}
 */
const parseTime = (timeString, baseDate = new Date()) => {
    const parts = timeString.split(':');
    const d = new Date(baseDate);
    d.setHours(parseInt(parts[0], 10));
    d.setMinutes(parseInt(parts[1], 10));
    d.setSeconds(parts[2] ? parseInt(parts[2], 10) : 0);
    d.setMilliseconds(0);
    return d;
};

/**
 * Get time string from Date
 * @param {Date} date
 * @param {boolean} includeSeconds
 * @returns {string}
 */
const getTimeString = (date, includeSeconds = false) => {
    const d = new Date(date);
    const hours = String(d.getHours()).padStart(2, '0');
    const minutes = String(d.getMinutes()).padStart(2, '0');

    if (includeSeconds) {
        const seconds = String(d.getSeconds()).padStart(2, '0');
        return `${hours}:${minutes}:${seconds}`;
    }

    return `${hours}:${minutes}`;
};

module.exports = {
    getStartOfDay,
    getEndOfDay,
    getStartOfWeek,
    getEndOfWeek,
    getStartOfMonth,
    getEndOfMonth,
    getStartOfYear,
    getEndOfYear,
    isWeekend,
    isWeekday,
    getWeekdayName,
    getMonthName,
    formatDate,
    addDays,
    addMonths,
    addYears,
    diffInDays,
    diffInHours,
    diffInMinutes,
    isToday,
    isPast,
    isFuture,
    getDaysInMonth,
    getAllDatesInMonth,
    getAllWeekdaysInMonth,
    parseTime,
    getTimeString
};
