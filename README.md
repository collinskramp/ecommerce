# MERN Multi-Vendor Ecommerce - Deployment Guide

## 🚀 Quick Deployment

### Ubuntu Server Deployment
```bash
wget https://raw.githubusercontent.com/collinskramp/ecommerce/main/deploy-ubuntu.sh && chmod +x deploy-ubuntu.sh && ./deploy-ubuntu.sh
```

### Local Development
```bash
./dev.sh
```

## 📊 Application URLs

### Production (Ubuntu)
- **Frontend (Customer):** `http://your-server:3000`
- **Dashboard (Admin):** `http://your-server:3001`
- **Backend API:** `http://your-server:5001`

### Development (Local)
- **Frontend (Customer):** `http://localhost:3000`
- **Dashboard (Admin):** `http://localhost:3001`
- **Backend API:** `http://localhost:5001`

## 🔐 Demo Login Credentials

### Admin Dashboard
- **Email:** admin@admin.com
- **Password:** secret

### Seller Account
- **Email:** seller1@techstore.com
- **Password:** secret

### Customer Account
- **Email:** customer@example.com
- **Password:** secret

## 🛠️ Technical Stack

- **Frontend:** React.js (Port 3000)
- **Dashboard:** React.js (Port 3001)
- **Backend:** Node.js/Express (Port 5001)
- **Database:** MongoDB
- **Process Manager:** PM2
- **Authentication:** JWT

## ⚙️ Configuration

### Environment Variables
Edit `backend/.env` with your credentials:
```env
DB_URL=mongodb://admin:password@localhost:27017/ec?authSource=admin
JWT_SECRET=your_jwt_secret
STRIPE_SECRET=your_stripe_secret_key
CLOUDINARY_CLOUD_NAME=your_cloudinary_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret
```

### MongoDB Setup
- **Database:** ec
- **Username:** admin
- **Password:** password
- **Auth Database:** admin

## 🔧 Troubleshooting

### Port Conflicts
The frontend runs on the standard React development port 3000. If you have port conflicts, you can modify the PORT environment variable in the deployment scripts.

### Node.js Dependency Conflicts (Ubuntu 22.04+)
If you encounter Node.js or MongoDB dependency issues:
```bash
./fix-nodejs.sh
```

### PM2 Management
```bash
# View logs
pm2 logs

# Restart all services
pm2 restart all

# Stop all services
pm2 stop all

# Check status
pm2 status
```

### MongoDB Issues
```bash
# Check MongoDB status
sudo systemctl status mongod

# Restart MongoDB
sudo systemctl restart mongod

# View MongoDB logs
sudo journalctl -u mongod
```

### Demo Data
To repopulate the database with demo data:
```bash
cd /path/to/ecommerce
node populate_database.js
```

## 🔥 Firewall Configuration

For external access, configure your firewall:
```bash
sudo ufw allow 3000  # Frontend
sudo ufw allow 3001  # Dashboard
sudo ufw allow 5001  # Backend API
```

## 🏗️ Manual Installation

If you prefer manual installation, follow these steps:

1. **Install Dependencies**
   ```bash
   sudo apt update
   sudo apt install -y nodejs npm mongodb git
   npm install -g pm2
   ```

2. **Clone Repository**
   ```bash
   git clone https://github.com/collinskramp/ecommerce.git
   cd ecommerce
   ```

3. **Install Project Dependencies**
   ```bash
   cd backend && npm install && cd ..
   cd frontend && npm install && cd ..
   cd dashboard && npm install && cd ..
   ```

4. **Configure Environment**
   ```bash
   cp backend/.env.example backend/.env
   # Edit backend/.env with your credentials
   ```

5. **Setup MongoDB**
   ```bash
   sudo systemctl start mongod
   sudo systemctl enable mongod
   ```

6. **Populate Database**
   ```bash
   node populate_database.js
   ```

7. **Start Services**
   ```bash
   pm2 start ecosystem.config.js
   pm2 save
   pm2 startup
   ```

## 📝 Features

- ✅ Multi-vendor marketplace
- ✅ Customer shopping interface
- ✅ Admin management dashboard
- ✅ Seller management system
- ✅ Product catalog with categories
- ✅ Shopping cart and wishlist
- ✅ Order management
- ✅ Payment integration (Stripe)
- ✅ Image upload (Cloudinary)
- ✅ User authentication
- ✅ Real-time chat
- ✅ Review and rating system

## 🆘 Support

If you encounter issues:

1. Check PM2 logs: `pm2 logs`
2. Verify MongoDB is running: `sudo systemctl status mongod`
3. Check firewall settings: `sudo ufw status`
4. Ensure all ports are accessible
5. Verify environment variables in `backend/.env`

## 📄 License

This project is licensed under the MIT License.
