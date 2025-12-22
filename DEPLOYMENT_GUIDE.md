# Deployment Guide

> **HR Management & Attendance System - Production Deployment**

## Table of Contents

- [Pre-deployment Checklist](#pre-deployment-checklist)
- [Environment Setup](#environment-setup)
- [Docker Deployment](#docker-deployment)
- [Manual Deployment](#manual-deployment)
- [Cloud Deployment](#cloud-deployment)
- [Post-deployment](#post-deployment)
- [Monitoring & Maintenance](#monitoring--maintenance)
- [Troubleshooting](#troubleshooting)

---

## Pre-deployment Checklist

### Security

- [ ] Change `JWT_SECRET` to a strong random string (min 32 characters)
- [ ] Update all default passwords in seed data
- [ ] Configure Cloudinary credentials
- [ ] Set up SSL/TLS certificates
- [ ] Review and configure CORS allowed origins
- [ ] Enable firewall rules
- [ ] Set up database backups
- [ ] Configure rate limiting appropriately

### Environment

- [ ] Set `NODE_ENV=production`
- [ ] Configure production database URL
- [ ] Set up Redis connection
- [ ] Configure email service (if applicable)
- [ ] Set proper file upload limits
- [ ] Configure logging (Winston/CloudWatch)

### Code

- [ ] Run `npm audit` and fix vulnerabilities
- [ ] Remove all console.log statements
- [ ] Ensure all migrations are up to date
- [ ] Test all critical endpoints
- [ ] Review and optimize database indices

### Infrastructure

- [ ] Provision servers/containers
- [ ] Set up load balancer (if needed)
- [ ] Configure CDN for static assets
- [ ] Set up monitoring (Datadog, New Relic, etc.)
- [ ] Configure log aggregation
- [ ] Set up alerting

---

## Environment Setup

### Required Environment Variables

Create a `.env.production` file:

```env
# Application
NODE_ENV=production
PORT=3000
API_URL=https://api.yourcompany.com

# Database
DATABASE_URL="postgresql://username:password@host:5432/hr_system?schema=public&sslmode=require"

# Redis
REDIS_URL="redis://username:password@host:6379"
REDIS_PASSWORD="your-redis-password"

# JWT
JWT_SECRET="your-super-secret-jwt-key-min-32-characters-change-this"
JWT_EXPIRY="24h"

# Cloudinary
CLOUDINARY_CLOUD_NAME="your-cloud-name"
CLOUDINARY_API_KEY="your-api-key"
CLOUDINARY_API_SECRET="your-api-secret"

# CORS
CORS_ORIGIN="https://app.yourcompany.com,https://admin.yourcompany.com"

# Security
BCRYPT_ROUNDS=12

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=5000

# Logging
LOG_LEVEL="info"
LOG_FILE_PATH="/var/log/hr-api/app.log"

# Email (optional)
SMTP_HOST="smtp.gmail.com"
SMTP_PORT=587
SMTP_USER="noreply@yourcompany.com"
SMTP_PASS="your-smtp-password"
EMAIL_FROM="HR System <noreply@yourcompany.com>"

# Attendance Settings
ATTENDANCE_RADIUS_METERS=100
FACE_CONFIDENCE_THRESHOLD=80
ATTENDANCE_PHOTO_RETENTION_DAYS=90
```

### Generate Strong JWT Secret

```bash
# Using OpenSSL
openssl rand -base64 32

# Using Node
node -e "console.log(require('crypto').randomBytes(32).toString('base64'))"
```

---

## Docker Deployment

### Option 1: Docker Compose (Recommended for single server)

#### 1. Update docker-compose.yml for production

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: hr-postgres-prod
    restart: always
    environment:
      POSTGRES_DB: hr_system
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - hr_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    container_name: hr-redis-prod
    restart: always
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    networks:
      - hr_network
    healthcheck:
      test: ["CMD", "redis-cli", "--raw", "incr", "ping"]
      interval: 10s
      timeout: 3s
      retries: 5

  api:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    container_name: hr-api-prod
    restart: always
    ports:
      - "3000:3000"
    env_file:
      - .env.production
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./logs:/app/logs
      - uploads:/app/uploads
    networks:
      - hr_network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  nginx:
    image: nginx:alpine
    container_name: hr-nginx-prod
    restart: always
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - api
    networks:
      - hr_network

volumes:
  postgres_data:
  redis_data:
  uploads:

networks:
  hr_network:
    driver: bridge
```

#### 2. Deploy

```bash
# Pull latest code
git pull origin main

# Build and start services
docker-compose -f docker-compose.prod.yml up -d --build

# Run migrations
docker-compose -f docker-compose.prod.yml exec api npx prisma migrate deploy

# (Optional) Seed initial data
docker-compose -f docker-compose.prod.yml exec api npm run db:seed

# Check logs
docker-compose -f docker-compose.prod.yml logs -f api
```

#### 3. Update deployment

```bash
# Pull changes
git pull

# Rebuild and restart
docker-compose -f docker-compose.prod.yml up -d --build --force-recreate api

# Run new migrations if any
docker-compose -f docker-compose.prod.yml exec api npx prisma migrate deploy
```

### Option 2: Kubernetes

#### Deployment YAML example

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hr-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hr-api
  template:
    metadata:
      labels:
        app: hr-api
    spec:
      containers:
      - name: hr-api
        image: your-registry/hr-api:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: hr-secrets
              key: database-url
        - name: JWT_SECRET
          valueFrom:
            secretKeyRef:
              name: hr-secrets
              key: jwt-secret
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /api/health
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

---

## Manual Deployment (VPS/Dedicated Server)

### 1. Server Requirements

- Ubuntu 22.04 LTS or newer
- 2+ CPU cores
- 4GB+ RAM
- 20GB+ SSD
- Node.js 20.x
- PostgreSQL 16
- Redis 7
- Nginx

### 2. Install Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install PostgreSQL 16
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt install -y postgresql-16

# Install Redis
sudo apt install -y redis-server

# Install Nginx
sudo apt install -y nginx

# Install PM2 (Process Manager)
sudo npm install -g pm2
```

### 3. Setup Database

```bash
# Switch to postgres user
sudo -u postgres psql

# Create database and user
CREATE DATABASE hr_system;
CREATE USER hr_user WITH ENCRYPTED PASSWORD 'your-password';
GRANT ALL PRIVILEGES ON DATABASE hr_system TO hr_user;
\q
```

### 4. Configure Redis

```bash
# Edit Redis config
sudo nano /etc/redis/redis.conf

# Add/update:
requirepass your-redis-password
maxmemory 256mb
maxmemory-policy allkeys-lru

# Restart Redis
sudo systemctl restart redis
```

### 5. Deploy Application

```bash
# Create app directory
sudo mkdir -p /var/www/hr-api
sudo chown $USER:$USER /var/www/hr-api

# Clone repository
cd /var/www/hr-api
git clone <repository-url> .

# Install dependencies
npm ci --production

# Copy environment file
cp .env.example .env.production
nano .env.production  # Edit with production values

# Generate Prisma client
npx prisma generate

# Run migrations
npx prisma migrate deploy

# Build (if TypeScript)
# npm run build

# Start with PM2
pm2 start server.js --name hr-api --env production

# Save PM2 config
pm2 save
pm2 startup
```

### 6. Configure Nginx

Create `/etc/nginx/sites-available/hr-api`:

```nginx
upstream hr_api {
    server localhost:3000;
    keepalive 64;
}

server {
    listen 80;
    server_name api.yourcompany.com;

    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourcompany.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/api.yourcompany.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourcompany.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Client body size
    client_max_body_size 10M;

    # Gzip
    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;

    # API Proxy
    location /api/ {
        proxy_pass http://hr_api/api/;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Health check (without /api prefix)
    location /health {
        proxy_pass http://hr_api/api/health;
        access_log off;
    }
}
```

Enable site:

```bash
sudo ln -s /etc/nginx/sites-available/hr-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 7. SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d api.yourcompany.com

# Auto-renewal
sudo certbot renew --dry-run
```

---

## Cloud Deployment

### AWS Elastic Beanstalk

1. Install EB CLI:
```bash
pip install awsebcli
```

2. Initialize:
```bash
eb init -p node.js-20 hr-api --region us-east-1
```

3. Create environment:
```bash
eb create hr-api-prod --database.engine postgres
```

4. Configure environment variables:
```bash
eb setenv NODE_ENV=production JWT_SECRET=xxx ...
```

5. Deploy:
```bash
eb deploy
```

### AWS ECS (Docker)

1. Build and push image:
```bash
docker build -t hr-api .
docker tag hr-api:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/hr-api:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/hr-api:latest
```

2. Create ECS task definition with image

3. Create ECS service with load balancer

### Heroku

```bash
# Install Heroku CLI
heroku login

# Create app
heroku create hr-api-prod

# Add PostgreSQL
heroku addons:create heroku-postgresql:standard-0

# Add Redis
heroku addons:create heroku-redis:premium-0

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=xxx
# ... other vars

# Deploy
git push heroku main

# Run migrations
heroku run npx prisma migrate deploy

# Scale
heroku ps:scale web=2
```

### DigitalOcean App Platform

1. Connect GitHub repository
2. Configure environment variables in UI
3. Add PostgreSQL database
4. Add Redis database
5. Deploy automatically on push

---

## Post-deployment

### 1. Verify Deployment

```bash
# Check health endpoint
curl https://api.yourcompany.com/api/health

# Test login
curl -X POST https://api.yourcompany.com/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Check database connection
docker-compose exec api npx prisma db pull
```

### 2. Create Admin Account

If not using seed data:

```bash
# Connect to database
psql $DATABASE_URL

# Or via Docker
docker-compose exec postgres psql -U postgres hr_system

# Create admin user (password: admin123)
INSERT INTO users (username, password_hash, role, is_active)
VALUES ('admin', '$2a$12$...', 'admin', true);
```

### 3. Configure Backups

#### PostgreSQL Backup Script

Create `/usr/local/bin/backup-hr-db.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/var/backups/hr-api"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/hr_db_$TIMESTAMP.sql.gz"

mkdir -p $BACKUP_DIR

pg_dump $DATABASE_URL | gzip > $BACKUP_FILE

# Keep only last 30 days
find $BACKUP_DIR -name "hr_db_*.sql.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_FILE"
```

Schedule with cron:

```bash
# Edit crontab
crontab -e

# Add daily backup at 2 AM
0 2 * * * /usr/local/bin/backup-hr-db.sh
```

### 4. Set Up Log Rotation

Create `/etc/logrotate.d/hr-api`:

```
/var/www/hr-api/logs/*.log {
    daily
    missingok
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
    postrotate
        pm2 reload hr-api
    endscript
}
```

---

## Monitoring & Maintenance

### PM2 Monitoring

```bash
# View status
pm2 status

# View logs
pm2 logs hr-api

# Monitor
pm2 monit

# Restart
pm2 restart hr-api

# Reload (zero-downtime)
pm2 reload hr-api
```

### Health Checks

Set up external monitoring (UptimeRobot, Pingdom, etc.):
- Endpoint: `https://api.yourcompany.com/api/health`
- Interval: 5 minutes
- Alert on: Down, response time > 2000ms

### Database Maintenance

```bash
# Vacuum and analyze
psql $DATABASE_URL -c "VACUUM ANALYZE;"

# Check table sizes
psql $DATABASE_URL -c "
  SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename))
  FROM pg_tables WHERE schemaname = 'public' ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
"

# Check slow queries (enable pg_stat_statements extension first)
psql $DATABASE_URL -c "
  SELECT query, calls, mean_exec_time, total_exec_time
  FROM pg_stat_statements ORDER BY mean_exec_time DESC LIMIT 10;
"
```

### Application Metrics

Consider integrating:
- **Datadog APM**
- **New Relic**
- **Prometheus + Grafana**
- **Sentry** for error tracking

---

## Troubleshooting

### High Memory Usage

```bash
# Check Node memory
pm2 list
pm2 monit

# Increase Node memory limit
pm2 delete hr-api
pm2 start server.js --name hr-api --node-args="--max-old-space-size=2048"
```

### Database Connection Pool Exhausted

Update `prisma/schema.prisma`:

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  // Adjust pool size
  pool_timeout = 30
  connection_limit = 20
}
```

### Slow Queries

Add indices:

```sql
-- Attendance queries
CREATE INDEX idx_attendance_employee_date ON attendances(employee_id, date);
CREATE INDEX idx_attendance_date ON attendances(date);
CREATE INDEX idx_attendance_status ON attendances(status);

-- Employee searches
CREATE INDEX idx_employee_code ON employees(employee_code);
CREATE INDEX idx_employee_fullname ON employees USING gin(to_tsvector('english', full_name));
CREATE INDEX idx_employee_department ON employees(department_id);

-- Leave queries
CREATE INDEX idx_leave_employee_status ON leaves(employee_id, status);
CREATE INDEX idx_leave_dates ON leaves(start_date, end_date);
```

### Redis Connection Issues

```bash
# Check Redis
redis-cli ping

# With auth
redis-cli -a your-password ping

# Check memory
redis-cli info memory

# Clear cache if needed
redis-cli FLUSHALL
```

---

## Rollback Strategy

### Quick Rollback

```bash
# With PM2
pm2 stop hr-api
git checkout <previous-commit>
npm ci --production
npx prisma migrate deploy
pm2 restart hr-api

# With Docker
docker-compose down
git checkout <previous-commit>
docker-compose up -d --build
```

### Database Rollback

```bash
# List migrations
npx prisma migrate status

# Rollback specific migration
npx prisma migrate resolve --rolled-back "<migration-name>"

# Then restore from backup
gunzip < backup.sql.gz | psql $DATABASE_URL
```

---

## Security Hardening

### 1. Firewall (UFW)

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### 2. Fail2Ban

```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 3. Regular Updates

```bash
# Auto-update script
#!/bin/bash
apt update && apt upgrade -y
pm2 update
npm update -g npm
docker system prune -af
```

---

**Version**: 2.0.0
**Last Updated**: 2025-12-22
