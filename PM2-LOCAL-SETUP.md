# PM2 Local Development Setup

## Quick Start

Run the project locally with PM2 in one command:

```bash
./quick-start-pm2.sh
```

This script will:
- ✅ Check and install PM2 if needed
- ✅ Install all dependencies (backend, frontend, dashboard)
- ✅ Create environment configuration
- ✅ Start all services with PM2

## What Gets Started

| Service | Port | URL |
|---------|------|-----|
| **Backend API** | 5001 | http://localhost:5001 |
| **Frontend** | 3000 | http://localhost:3000 |
| **Dashboard** | 3001 | http://localhost:3001 |

## PM2 Commands

```bash
# View all processes
pm2 list

# View logs (all services)
pm2 logs

# View specific service logs
pm2 logs ecommerce-backend
pm2 logs ecommerce-frontend
pm2 logs ecommerce-dashboard

# Restart all services
pm2 restart all

# Restart specific service
pm2 restart ecommerce-backend

# Stop all services
pm2 stop all

# Delete all PM2 processes
pm2 delete all

# Monitor (realtime dashboard)
pm2 monit
```

## Prerequisites

### Required
- **Node.js** (v18 or higher) - [Download](https://nodejs.org/)
- **MongoDB** (v4.4 or higher) - [Installation Guide](#mongodb-installation)

### Optional
- PM2 (will be auto-installed if missing)

## MongoDB Installation

### macOS
```bash
brew tap mongodb/brew
brew install mongodb-community@8.0
brew services start mongodb-community@8.0
```

### Linux (Ubuntu/Debian)
```bash
wget -qO - https://www.mongodb.org/static/pgp/server-8.0.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo apt-get update
sudo apt-get install -y mongodb-org
sudo systemctl start mongod
```

### Verify MongoDB
```bash
mongosh
```

## Environment Configuration

The script creates `backend/.env` automatically. Update it with your credentials:

```env
PORT=5001
DB_URL=mongodb://127.0.0.1:27017/ec
SECRET=your_jwt_secret_change_me
cloud_name=your_cloudinary_name
api_key=your_cloudinary_api_key
api_secret=your_cloudinary_api_secret
STRIPE_SECRET_KEY=sk_test_your_stripe_key
```

## Troubleshooting

### MongoDB Connection Error
```bash
# Check if MongoDB is running
brew services list  # macOS
sudo systemctl status mongod  # Linux

# Start MongoDB
brew services start mongodb-community@8.0  # macOS
sudo systemctl start mongod  # Linux
```

### Port Already in Use
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Kill process on port 5001
lsof -ti:5001 | xargs kill -9
```

### PM2 Process Issues
```bash
# Delete all PM2 processes and restart
pm2 delete all
./quick-start-pm2.sh
```

### Clear PM2 Logs
```bash
pm2 flush
```

## Manual Setup (Without Script)

If you prefer manual setup:

```bash
# 1. Install dependencies
cd backend && npm install
cd ../frontend && npm install
cd ../dashboard && npm install

# 2. Create environment file
cp backend/.env.example backend/.env
# Edit backend/.env with your credentials

# 3. Start with PM2
pm2 start ecosystem.config.js

# 4. Save PM2 configuration
pm2 save
```

## Development vs Production

This setup is configured for **local development**. For production deployment:
- Use `deploy-production.sh` script
- Set `NODE_ENV=production`
- Use HTTPS
- Configure proper firewall rules
- Set strong secrets and passwords

## File Structure

```
├── backend/          # Express.js API server
├── frontend/         # React customer app
├── dashboard/        # React admin/seller dashboard
├── ecosystem.config.js       # PM2 configuration
├── quick-start-pm2.sh        # Quick start script
└── setup-local-pm2.sh        # Full setup script
```

## Support

For issues or questions:
1. Check PM2 logs: `pm2 logs`
2. Check MongoDB status: `brew services list` or `systemctl status mongod`
3. Review environment variables in `backend/.env`

---

**Note**: The first time you run the services, the frontend and dashboard may take 1-2 minutes to compile. Watch the logs with `pm2 logs` to see progress.
