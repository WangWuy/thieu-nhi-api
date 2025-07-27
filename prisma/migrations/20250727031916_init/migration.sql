-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('ban_dieu_hanh', 'phan_doan_truong', 'giao_ly_vien');

-- CreateEnum
CREATE TYPE "AttendanceType" AS ENUM ('thursday', 'sunday');

-- CreateTable
CREATE TABLE "departments" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "display_name" TEXT NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "departments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" SERIAL NOT NULL,
    "username" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "role" "UserRole" NOT NULL,
    "saint_name" TEXT,
    "full_name" TEXT NOT NULL,
    "birth_date" TIMESTAMP(3),
    "phone_number" TEXT,
    "address" TEXT,
    "department_id" INTEGER,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "classes" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "department_id" INTEGER NOT NULL,
    "teacher_id" INTEGER,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "classes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "students" (
    "id" SERIAL NOT NULL,
    "student_code" TEXT NOT NULL,
    "qr_code" TEXT,
    "saint_name" TEXT,
    "full_name" TEXT NOT NULL,
    "birth_date" TIMESTAMP(3),
    "phone_number" TEXT,
    "parent_phone_1" TEXT,
    "parent_phone_2" TEXT,
    "address" TEXT,
    "class_id" INTEGER NOT NULL,
    "attendance_score" DECIMAL(3,1) NOT NULL DEFAULT 0,
    "study_score" DECIMAL(3,1) NOT NULL DEFAULT 0,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "students_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendance" (
    "id" SERIAL NOT NULL,
    "student_id" INTEGER NOT NULL,
    "attendance_date" DATE NOT NULL,
    "attendance_type" "AttendanceType" NOT NULL,
    "is_present" BOOLEAN NOT NULL,
    "note" TEXT,
    "marked_by" INTEGER,
    "marked_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "attendance_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "weekly_stats" (
    "id" SERIAL NOT NULL,
    "week_start_date" DATE NOT NULL,
    "week_end_date" DATE NOT NULL,
    "department_id" INTEGER,
    "class_id" INTEGER,
    "total_students" INTEGER NOT NULL,
    "thursday_attendance" INTEGER NOT NULL,
    "sunday_attendance" INTEGER NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "weekly_stats_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "class_teachers" (
    "id" SERIAL NOT NULL,
    "class_id" INTEGER NOT NULL,
    "user_id" INTEGER NOT NULL,
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "class_teachers_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "departments_name_key" ON "departments"("name");

-- CreateIndex
CREATE UNIQUE INDEX "users_username_key" ON "users"("username");

-- CreateIndex
CREATE UNIQUE INDEX "students_student_code_key" ON "students"("student_code");

-- CreateIndex
CREATE UNIQUE INDEX "attendance_student_id_attendance_date_attendance_type_key" ON "attendance"("student_id", "attendance_date", "attendance_type");

-- CreateIndex
CREATE UNIQUE INDEX "class_teachers_class_id_user_id_key" ON "class_teachers"("class_id", "user_id");

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "classes" ADD CONSTRAINT "classes_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "students" ADD CONSTRAINT "students_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "classes"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance" ADD CONSTRAINT "attendance_student_id_fkey" FOREIGN KEY ("student_id") REFERENCES "students"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendance" ADD CONSTRAINT "attendance_marked_by_fkey" FOREIGN KEY ("marked_by") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "weekly_stats" ADD CONSTRAINT "weekly_stats_department_id_fkey" FOREIGN KEY ("department_id") REFERENCES "departments"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "weekly_stats" ADD CONSTRAINT "weekly_stats_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "classes"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_teachers" ADD CONSTRAINT "class_teachers_class_id_fkey" FOREIGN KEY ("class_id") REFERENCES "classes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "class_teachers" ADD CONSTRAINT "class_teachers_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
