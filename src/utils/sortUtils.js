// Vietnamese sort utility
const vietnameseSort = (a, b, field = 'fullName') => {
    const aValue = a[field] || '';
    const bValue = b[field] || '';
    
    return aValue.localeCompare(bValue, 'vi', {
        sensitivity: 'base',
        numeric: true,
        ignorePunctuation: true
    });
};

// Sort students by last name (tên) using Vietnamese collation
const sortStudentsByLastName = (students) => {
    return students.sort((a, b) => {
        const aLastName = a.fullName.split(' ').pop();
        const bLastName = b.fullName.split(' ').pop();
        return aLastName.localeCompare(bLastName, 'vi', {
            sensitivity: 'base',
            numeric: true,
            ignorePunctuation: true
        });
    });
};

// Sort students by full name (họ) using Vietnamese collation
const sortStudentsByFullName = (students) => {
    return students.sort((a, b) => vietnameseSort(a, b, 'fullName'));
};

// Generic sort function for any array with Vietnamese names
const sortByVietnameseName = (array, field = 'fullName') => {
    return array.sort((a, b) => vietnameseSort(a, b, field));
};

module.exports = {
    vietnameseSort,
    sortStudentsByLastName,
    sortStudentsByFullName,
    sortByVietnameseName
};