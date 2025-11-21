-- CreateEnum
CREATE TYPE "AlertType" AS ENUM ('attendance', 'grades', 'system');

-- CreateEnum
CREATE TYPE "AlertPriority" AS ENUM ('high', 'medium', 'low');

-- CreateEnum
CREATE TYPE "AlertStatus" AS ENUM ('unread', 'read', 'resolved');

-- CreateTable
CREATE TABLE "alert_rules" (
    "id" SERIAL NOT NULL,
    "name" TEXT NOT NULL,
    "type" "AlertType" NOT NULL,
    "condition" TEXT NOT NULL,
    "threshold" DOUBLE PRECISION NOT NULL,
    "priority" "AlertPriority" NOT NULL DEFAULT 'medium',
    "enabled" BOOLEAN NOT NULL DEFAULT true,
    "notification" TEXT[],
    "description" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "alert_rules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "system_alerts" (
    "id" SERIAL NOT NULL,
    "type" "AlertType" NOT NULL,
    "priority" "AlertPriority" NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "status" "AlertStatus" NOT NULL DEFAULT 'unread',
    "source" TEXT NOT NULL DEFAULT 'system',
    "data" JSONB,
    "rule_id" INTEGER,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "system_alerts_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "system_alerts_status_idx" ON "system_alerts"("status");

-- CreateIndex
CREATE INDEX "system_alerts_type_priority_idx" ON "system_alerts"("type", "priority");

-- AddForeignKey
ALTER TABLE "system_alerts" ADD CONSTRAINT "system_alerts_rule_id_fkey" FOREIGN KEY ("rule_id") REFERENCES "alert_rules"("id") ON DELETE SET NULL ON UPDATE CASCADE;