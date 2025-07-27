const XLSX = require('xlsx');

class ExcelUtils {
    static parseExcelFile(buffer) {
        const workbook = XLSX.read(buffer, { type: 'buffer', cellDates: true });
        const sheetName = workbook.SheetNames[0];
        const worksheet = workbook.Sheets[sheetName];
        const jsonData = XLSX.utils.sheet_to_json(worksheet, { header: 1, blankrows: false });

        if (jsonData.length < 2) {
            throw new Error('File Excel phải có ít nhất 2 dòng (header + data)');
        }

        return {
            headers: jsonData[0],
            data: jsonData.slice(1).map((row, index) => {
                const rowData = {};
                jsonData[0].forEach((header, colIndex) => {
                    rowData[header] = row[colIndex] || '';
                });
                rowData._rowIndex = index + 2;
                return rowData;
            })
        };
    }

    static createWorkbook(sheets) {
        const workbook = XLSX.utils.book_new();

        sheets.forEach(({ name, data, cols }) => {
            const worksheet = XLSX.utils.aoa_to_sheet(data);
            if (cols) worksheet['!cols'] = cols;
            XLSX.utils.book_append_sheet(workbook, worksheet, name);
        });

        return XLSX.write(workbook, { type: 'buffer', bookType: 'xlsx' });
    }
}

module.exports = ExcelUtils;