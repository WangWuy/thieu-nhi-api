/**
 * Week utility functions for attendance system
 * Week starts on Monday and ends on Sunday
 */

/**
 * Get week range (Monday to Sunday) for a given date
 * @param {string|Date} date - Input date
 * @returns {Object} { startDate, endDate } - Week start (Monday 00:00) and end (Sunday 23:59)
 */
function getWeekRange(date) {
    const d = new Date(date);
    const day = d.getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
    
    // Calculate days from Monday
    const daysFromMonday = day === 0 ? 6 : day - 1; // If Sunday then -6, else -(day-1)
    
    // Calculate Monday (start of week)
    const startDate = new Date(d);
    startDate.setDate(d.getDate() - daysFromMonday);
    startDate.setHours(0, 0, 0, 0);
    
    // Calculate Sunday (end of week)
    const endDate = new Date(startDate);
    endDate.setDate(startDate.getDate() + 6);
    endDate.setHours(23, 59, 59, 999);
    
    return { startDate, endDate };
}

/**
 * Get specific weekday date within a week
 * @param {string|Date} date - Any date in the week
 * @param {string} weekday - 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
 * @returns {Date} - Date of the specified weekday
 */
function getWeekdayInWeek(date, weekday) {
    const { startDate } = getWeekRange(date);
    const weekdays = {
        'monday': 0,
        'tuesday': 1,
        'wednesday': 2,
        'thursday': 3,
        'friday': 4,
        'saturday': 5,
        'sunday': 6
    };
    
    const dayOffset = weekdays[weekday.toLowerCase()];
    if (dayOffset === undefined) {
        throw new Error('Invalid weekday. Use: monday, tuesday, wednesday, thursday, friday, saturday, sunday');
    }
    
    const targetDate = new Date(startDate);
    targetDate.setDate(startDate.getDate() + dayOffset);
    targetDate.setHours(0, 0, 0, 0);
    
    return targetDate;
}

/**
 * Get attendance target date based on attendance type
 * @param {string|Date} inputDate - Input date from user
 * @param {string} attendanceType - 'thursday' or 'sunday'
 * @returns {Date} - Target date for attendance recording
 */
function getAttendanceTargetDate(inputDate, attendanceType) {
    if (attendanceType === 'thursday') {
        return getWeekdayInWeek(inputDate, 'thursday');
    } else if (attendanceType === 'sunday') {
        return getWeekdayInWeek(inputDate, 'sunday');
    } else {
        throw new Error('Invalid attendance type. Use: thursday or sunday');
    }
}

/**
 * Format week range for display
 * @param {string|Date} date - Any date in the week
 * @param {string} locale - Locale for formatting (default: 'vi-VN')
 * @returns {string} - Formatted week range
 */
function formatWeekRange(date, locale = 'vi-VN') {
    const { startDate, endDate } = getWeekRange(date);
    const startStr = startDate.toLocaleDateString(locale);
    const endStr = endDate.toLocaleDateString(locale);
    return `${startStr} - ${endStr}`;
}

/**
 * Check if two dates are in the same week
 * @param {string|Date} date1 - First date
 * @param {string|Date} date2 - Second date
 * @returns {boolean} - True if both dates are in the same week
 */
function isSameWeek(date1, date2) {
    const week1 = getWeekRange(date1);
    const week2 = getWeekRange(date2);
    
    return week1.startDate.getTime() === week2.startDate.getTime();
}

/**
 * Get week number in year (ISO week)
 * @param {string|Date} date - Input date
 * @returns {number} - Week number (1-53)
 */
function getWeekNumber(date) {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    d.setDate(d.getDate() + 3 - (d.getDay() + 6) % 7);
    const week1 = new Date(d.getFullYear(), 0, 4);
    return 1 + Math.round(((d.getTime() - week1.getTime()) / 86400000 - 3 + (week1.getDay() + 6) % 7) / 7);
}

module.exports = {
    getWeekRange,
    getWeekdayInWeek,
    getAttendanceTargetDate,
    formatWeekRange,
    isSameWeek,
    getWeekNumber
};