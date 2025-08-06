/*
  Warnings:

  - You are about to drop the column `attendance_score` on the `students` table. All the data in the column will be lost.
  - You are about to drop the column `study_score` on the `students` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "students" DROP COLUMN "attendance_score",
DROP COLUMN "study_score",
ADD COLUMN     "academic_year_id" INTEGER,
ADD COLUMN     "attendance_average" DECIMAL(4,2) NOT NULL DEFAULT 0,
ADD COLUMN     "exam_hk1" DECIMAL(3,1) NOT NULL DEFAULT 0,
ADD COLUMN     "exam_hk2" DECIMAL(3,1) NOT NULL DEFAULT 0,
ADD COLUMN     "final_average" DECIMAL(4,2) NOT NULL DEFAULT 0,
ADD COLUMN     "study_45_hk1" DECIMAL(3,1) NOT NULL DEFAULT 0,
ADD COLUMN     "study_45_hk2" DECIMAL(3,1) NOT NULL DEFAULT 0,
ADD COLUMN     "study_average" DECIMAL(4,2) NOT NULL DEFAULT 0,
ADD COLUMN     "sunday_attendance_count" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "thursday_attendance_count" INTEGER NOT NULL DEFAULT 0;

-- CreateTable
CREATE TABLE "academic_years" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "total_weeks" INTEGER NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "is_current" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "academic_years_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "academic_years_name_key" ON "academic_years"("name");

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_academic_year_id_fkey" FOREIGN KEY ("academic_year_id") REFERENCES "academic_years"("id") ON DELETE SET NULL ON UPDATE CASCADE;
