-- AlterTable
ALTER TABLE "students" ADD COLUMN     "avatar_public_id" TEXT,
ADD COLUMN     "avatar_url" TEXT;

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "avatar_public_id" TEXT,
ADD COLUMN     "avatar_url" TEXT;