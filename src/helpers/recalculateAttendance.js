const { prisma } = require('../../prisma/client');

// Helper function để tính attendance count theo tuần
const calculateWeeklyAttendanceCount = async (studentId, attendanceType) => {
    const attendanceRecords = await prisma.attendance.findMany({
        where: {
            studentId: studentId,
            attendanceType: attendanceType,
            isPresent: true
        },
        select: {
            attendanceDate: true
        }
    });

    // Group by week
    const uniqueWeeks = new Set();
    
    attendanceRecords.forEach(record => {
        const recordDate = new Date(record.attendanceDate);
        
        // Calculate week start (Monday)
        const day = recordDate.getDay();
        const diff = recordDate.getDate() - day + (day === 0 ? -6 : 1);
        const weekStart = new Date(recordDate);
        weekStart.setDate(diff);
        weekStart.setHours(0, 0, 0, 0);
        
        const weekKey = weekStart.toISOString().split('T')[0];
        uniqueWeeks.add(weekKey);
    });

    return uniqueWeeks.size;
};

// Function để recalculate attendance counts cho 1 student
const recalculateStudentAttendance = async (studentId) => {
    try {
        const thursdayCount = await calculateWeeklyAttendanceCount(studentId, 'thursday');
        const sundayCount = await calculateWeeklyAttendanceCount(studentId, 'sunday');

        // Get current student data for comparison
        const currentStudent = await prisma.student.findUnique({
            where: { id: studentId },
            select: {
                studentCode: true,
                fullName: true,
                thursdayAttendanceCount: true,
                sundayAttendanceCount: true
            }
        });

        // Update student record
        await prisma.student.update({
            where: { id: studentId },
            data: {
                thursdayAttendanceCount: thursdayCount,
                sundayAttendanceCount: sundayCount
            }
        });

        // Log if there were changes
        if (currentStudent.thursdayAttendanceCount !== thursdayCount || 
            currentStudent.sundayAttendanceCount !== sundayCount) {
            console.log(`✅ Updated ${currentStudent.studentCode} - ${currentStudent.fullName}`);
            console.log(`   Thursday: ${currentStudent.thursdayAttendanceCount} → ${thursdayCount}`);
            console.log(`   Sunday: ${currentStudent.sundayAttendanceCount} → ${sundayCount}`);
        }

        return { 
            studentId, 
            thursdayCount, 
            sundayCount,
            changed: currentStudent.thursdayAttendanceCount !== thursdayCount || 
                    currentStudent.sundayAttendanceCount !== sundayCount
        };

    } catch (error) {
        console.error(`❌ Error recalculating student ${studentId}:`, error.message);
        return { studentId, error: error.message };
    }
};

// Function để recalculate students theo batch
const recalculateStudentsBatch = async (batchSize = 20, delayMs = 100) => {
    try {
        console.log(`🚀 Starting attendance recalculation with batch size: ${batchSize}\n`);

        const students = await prisma.student.findMany({
            select: { id: true, studentCode: true, fullName: true },
            where: { isActive: true }
        });

        console.log(`📊 Found ${students.length} active students to process\n`);

        let processedCount = 0;
        let changedCount = 0;
        let errorCount = 0;

        // Process in batches
        for (let i = 0; i < students.length; i += batchSize) {
            const batch = students.slice(i, i + batchSize);
            const batchNumber = Math.floor(i / batchSize) + 1;
            const totalBatches = Math.ceil(students.length / batchSize);

            console.log(`📦 Processing batch ${batchNumber}/${totalBatches} (${batch.length} students)...`);

            // Process batch concurrently
            const batchPromises = batch.map(student => recalculateStudentAttendance(student.id));
            const batchResults = await Promise.all(batchPromises);

            // Update counters
            batchResults.forEach(result => {
                processedCount++;
                if (result.error) {
                    errorCount++;
                } else if (result.changed) {
                    changedCount++;
                }
            });

            console.log(`   ✅ Batch ${batchNumber} completed. Progress: ${processedCount}/${students.length}`);

            // Add delay between batches to prevent overwhelming DB
            if (i + batchSize < students.length && delayMs > 0) {
                console.log(`   ⏳ Waiting ${delayMs}ms before next batch...`);
                await new Promise(resolve => setTimeout(resolve, delayMs));
            }
        }

        console.log('\n✨ Recalculation completed!');
        console.log(`📊 Summary:`);
        console.log(`   • Total processed: ${processedCount}`);
        console.log(`   • Students changed: ${changedCount}`);
        console.log(`   • Errors: ${errorCount}`);
        console.log(`   • Batches processed: ${Math.ceil(students.length / batchSize)}`);

    } catch (error) {
        console.error('❌ Fatal error during recalculation:', error);
    } finally {
        await prisma.$disconnect();
    }
};

// Function để test với 1 student cụ thể
const testSingleStudent = async (studentId) => {
    try {
        console.log(`🔍 Testing recalculation for student ID: ${studentId}\n`);
        
        const result = await recalculateStudentAttendance(studentId);
        
        if (result.error) {
            console.log(`❌ Error: ${result.error}`);
        } else {
            console.log(`✅ Success:`);
            console.log(`   Thursday weeks: ${result.thursdayCount}`);
            console.log(`   Sunday weeks: ${result.sundayCount}`);
            console.log(`   Changed: ${result.changed ? 'Yes' : 'No'}`);
        }

    } catch (error) {
        console.error('❌ Error:', error);
    } finally {
        await prisma.$disconnect();
    }
};

// Main execution
const main = async () => {
    const args = process.argv.slice(2);
    
    if (args.length === 0) {
        console.log('📋 Usage:');
        console.log('  node recalculateAttendance.js all                        # Default batch processing');
        console.log('  node recalculateAttendance.js batch <size> [delay]       # Custom batch processing');
        console.log('  node recalculateAttendance.js test <studentId>           # Test single student');
        console.log('\nExamples:');
        console.log('  node recalculateAttendance.js test 22                    # Test student ID 22');
        console.log('  node recalculateAttendance.js batch 10 200               # Process 10 at a time, 200ms delay');
        console.log('  node recalculateAttendance.js all                        # Default: 20 batch size, 100ms delay');
        return;
    }

    const command = args[0];

    if (command === 'all') {
        await recalculateStudentsBatch();
    } else if (command === 'batch' && args[1]) {
        const batchSize = parseInt(args[1]);
        const delayMs = args[2] ? parseInt(args[2]) : 100;
        
        if (isNaN(batchSize) || batchSize < 1) {
            console.error('❌ Batch size must be a positive number');
            return;
        }
        
        await recalculateStudentsBatch(batchSize, delayMs);
    } else if (command === 'test' && args[1]) {
        const studentId = parseInt(args[1]);
        if (isNaN(studentId)) {
            console.error('❌ Student ID must be a number');
            return;
        }
        await testSingleStudent(studentId);
    } else {
        console.error('❌ Invalid command. Use "all" or "test <studentId>"');
    }
};

// Error handling
process.on('unhandledRejection', (error) => {
    console.error('❌ Unhandled promise rejection:', error);
    process.exit(1);
});

process.on('SIGINT', async () => {
    console.log('\n⏹️  Process interrupted. Cleaning up...');
    await prisma.$disconnect();
    process.exit(0);
});

// Run the script
main().catch(console.error);