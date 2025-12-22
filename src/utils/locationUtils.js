/**
 * Location Utilities
 * Helper functions for GPS/location operations
 */

/**
 * Calculate distance between two GPS coordinates using Haversine formula
 * @param {number} lat1 - Latitude 1
 * @param {number} lon1 - Longitude 1
 * @param {number} lat2 - Latitude 2
 * @param {number} lon2 - Longitude 2
 * @returns {number} Distance in meters
 */
const calculateDistance = (lat1, lon1, lat2, lon2) => {
    const R = 6371e3; // Earth radius in meters
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δφ = ((lat2 - lat1) * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;

    const a =
        Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
        Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    const distance = R * c; // Distance in meters

    return Math.round(distance);
};

/**
 * Validate GPS coordinates
 * @param {number} latitude
 * @param {number} longitude
 * @returns {{valid: boolean, message: string}}
 */
const validateCoordinates = (latitude, longitude) => {
    if (typeof latitude !== 'number' || typeof longitude !== 'number') {
        return {
            valid: false,
            message: 'Coordinates must be numbers'
        };
    }

    if (isNaN(latitude) || isNaN(longitude)) {
        return {
            valid: false,
            message: 'Invalid coordinates (NaN)'
        };
    }

    if (latitude < -90 || latitude > 90) {
        return {
            valid: false,
            message: 'Latitude must be between -90 and 90'
        };
    }

    if (longitude < -180 || longitude > 180) {
        return {
            valid: false,
            message: 'Longitude must be between -180 and 180'
        };
    }

    return {
        valid: true,
        message: 'Valid coordinates'
    };
};

/**
 * Check if location is within allowed radius
 * @param {number} userLat - User latitude
 * @param {number} userLon - User longitude
 * @param {number} officeLat - Office latitude
 * @param {number} officeLon - Office longitude
 * @param {number} maxDistance - Maximum allowed distance in meters
 * @returns {{isWithin: boolean, distance: number, message: string}}
 */
const isWithinRadius = (userLat, userLon, officeLat, officeLon, maxDistance = 500) => {
    // Validate coordinates
    const userValidation = validateCoordinates(userLat, userLon);
    if (!userValidation.valid) {
        return {
            isWithin: false,
            distance: 0,
            message: `User coordinates invalid: ${userValidation.message}`
        };
    }

    const officeValidation = validateCoordinates(officeLat, officeLon);
    if (!officeValidation.valid) {
        return {
            isWithin: false,
            distance: 0,
            message: `Office coordinates invalid: ${officeValidation.message}`
        };
    }

    // Calculate distance
    const distance = calculateDistance(userLat, userLon, officeLat, officeLon);

    return {
        isWithin: distance <= maxDistance,
        distance,
        message: distance <= maxDistance
            ? `Within allowed radius (${distance}m / ${maxDistance}m)`
            : `Outside allowed radius (${distance}m / ${maxDistance}m)`
    };
};

/**
 * Format coordinates for display
 * @param {number} latitude
 * @param {number} longitude
 * @param {number} precision - Decimal places, default 6
 * @returns {string}
 */
const formatCoordinates = (latitude, longitude, precision = 6) => {
    return `${latitude.toFixed(precision)}, ${longitude.toFixed(precision)}`;
};

/**
 * Parse coordinates from string
 * @param {string} coordString - Format: "lat, lon" or "lat,lon"
 * @returns {{latitude: number, longitude: number}|null}
 */
const parseCoordinates = (coordString) => {
    if (!coordString) return null;

    const parts = coordString.split(',').map(s => s.trim());
    if (parts.length !== 2) return null;

    const latitude = parseFloat(parts[0]);
    const longitude = parseFloat(parts[1]);

    const validation = validateCoordinates(latitude, longitude);
    if (!validation.valid) return null;

    return { latitude, longitude };
};

/**
 * Get bounding box around a point
 * @param {number} latitude
 * @param {number} longitude
 * @param {number} radiusInMeters - Radius in meters
 * @returns {{minLat: number, maxLat: number, minLon: number, maxLon: number}}
 */
const getBoundingBox = (latitude, longitude, radiusInMeters) => {
    const latDelta = (radiusInMeters / 111320); // 1 degree latitude ≈ 111.32 km
    const lonDelta = (radiusInMeters / (111320 * Math.cos((latitude * Math.PI) / 180)));

    return {
        minLat: latitude - latDelta,
        maxLat: latitude + latDelta,
        minLon: longitude - lonDelta,
        maxLon: longitude + lonDelta
    };
};

/**
 * Check if point is within bounding box
 * @param {number} lat
 * @param {number} lon
 * @param {Object} boundingBox - {minLat, maxLat, minLon, maxLon}
 * @returns {boolean}
 */
const isWithinBoundingBox = (lat, lon, boundingBox) => {
    return (
        lat >= boundingBox.minLat &&
        lat <= boundingBox.maxLat &&
        lon >= boundingBox.minLon &&
        lon <= boundingBox.maxLon
    );
};

/**
 * Convert meters to kilometers
 * @param {number} meters
 * @returns {number}
 */
const metersToKilometers = (meters) => {
    return parseFloat((meters / 1000).toFixed(2));
};

/**
 * Convert kilometers to meters
 * @param {number} kilometers
 * @returns {number}
 */
const kilometersToMeters = (kilometers) => {
    return Math.round(kilometers * 1000);
};

/**
 * Get distance with unit
 * @param {number} meters
 * @returns {string}
 */
const formatDistance = (meters) => {
    if (meters < 1000) {
        return `${meters}m`;
    }
    return `${metersToKilometers(meters)}km`;
};

/**
 * Calculate bearing between two points
 * @param {number} lat1
 * @param {number} lon1
 * @param {number} lat2
 * @param {number} lon2
 * @returns {number} Bearing in degrees (0-360)
 */
const calculateBearing = (lat1, lon1, lat2, lon2) => {
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δλ = ((lon2 - lon1) * Math.PI) / 180;

    const y = Math.sin(Δλ) * Math.cos(φ2);
    const x =
        Math.cos(φ1) * Math.sin(φ2) -
        Math.sin(φ1) * Math.cos(φ2) * Math.cos(Δλ);

    const θ = Math.atan2(y, x);
    const bearing = ((θ * 180) / Math.PI + 360) % 360;

    return Math.round(bearing);
};

/**
 * Get compass direction from bearing
 * @param {number} bearing - Bearing in degrees (0-360)
 * @returns {string} Compass direction (N, NE, E, SE, S, SW, W, NW)
 */
const getCompassDirection = (bearing) => {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    const index = Math.round(bearing / 45) % 8;
    return directions[index];
};

/**
 * Generate Google Maps URL
 * @param {number} latitude
 * @param {number} longitude
 * @param {number} zoom - Default 15
 * @returns {string}
 */
const getGoogleMapsUrl = (latitude, longitude, zoom = 15) => {
    return `https://www.google.com/maps?q=${latitude},${longitude}&z=${zoom}`;
};

/**
 * Mock reverse geocoding (get address from coordinates)
 * Note: For production, integrate with actual geocoding service
 * @param {number} latitude
 * @param {number} longitude
 * @returns {Promise<string>}
 */
const reverseGeocode = async (latitude, longitude) => {
    // TODO: Integrate with actual geocoding service (Google Maps, OpenStreetMap, etc.)
    // Example with Google Maps Geocoding API:
    // const response = await axios.get(
    //     `https://maps.googleapis.com/maps/api/geocode/json?latlng=${latitude},${longitude}&key=${API_KEY}`
    // );
    // return response.data.results[0]?.formatted_address;

    // Mock implementation
    return `${formatCoordinates(latitude, longitude)} (Mock Address)`;
};

/**
 * Validate location data object
 * @param {Object} location - {latitude, longitude}
 * @returns {{valid: boolean, message: string}}
 */
const validateLocationObject = (location) => {
    if (!location || typeof location !== 'object') {
        return {
            valid: false,
            message: 'Location must be an object'
        };
    }

    if (!('latitude' in location) || !('longitude' in location)) {
        return {
            valid: false,
            message: 'Location must have latitude and longitude properties'
        };
    }

    return validateCoordinates(location.latitude, location.longitude);
};

module.exports = {
    calculateDistance,
    validateCoordinates,
    isWithinRadius,
    formatCoordinates,
    parseCoordinates,
    getBoundingBox,
    isWithinBoundingBox,
    metersToKilometers,
    kilometersToMeters,
    formatDistance,
    calculateBearing,
    getCompassDirection,
    getGoogleMapsUrl,
    reverseGeocode,
    validateLocationObject
};
