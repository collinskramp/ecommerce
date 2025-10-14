# 🚀 MERN Multi-vendor Ecommerce Deployment Scripts

This repository contains automated deployment scripts for setting up the MERN multi-vendor ecommerce platform on Ubuntu.

## 📋 Available Scripts

### 1. 🔧 `deploy-ubuntu.sh` - Full Ubuntu Deployment
Complete production setup script that installs all dependencies and configures the system.

### 2. ⚡ `dev.sh` - Development Helper
Quick development setup and management script.

### 3. 🐳 `deploy-docker.sh` - Docker Production Deployment
Production deployment using Docker containers.

---

## 🔧 Script 1: Full Ubuntu Deployment

### Usage:
```bash
# Download and run the deployment script
wget https://raw.githubusercontent.com/collinskramp/ecommerce/main/deploy-ubuntu.sh
chmod +x deploy-ubuntu.sh
./deploy-ubuntu.sh
```

### What it does:
- ✅ Updates Ubuntu system
- ✅ Installs Node.js 18+
- ✅ Installs MongoDB 6.0
- ✅ Installs Git and PM2
- ✅ Sets up MongoDB authentication
- ✅ Clones the repository
- ✅ Installs all dependencies
- ✅ Creates environment configuration
- ✅ Sets up PM2 process management
- ✅ Configures UFW firewall
- ✅ Starts all services
- ✅ Optional database population

### Requirements:
- Ubuntu 18.04+ (tested on Ubuntu 20.04/22.04)
- Non-root user with sudo privileges
- Internet connection

---

## ⚡ Script 2: Development Helper

### Usage:
```bash
# Make script executable
chmod +x dev.sh

# Available commands
./dev.sh setup     # Install dependencies and setup environment
./dev.sh start     # Start all development servers
./dev.sh stop      # Stop all development servers
./dev.sh restart   # Restart all development servers
./dev.sh status    # Check service status
./dev.sh logs      # Show logs (PM2 only)
./dev.sh help      # Show help
```

### What it does:
- 🔧 Installs Node.js dependencies
- 🔧 Creates environment files
- 🚀 Starts development servers
- 📊 Manages service status
- 📈 Shows service logs

### Quick Start:
```bash
git clone https://github.com/collinskramp/ecommerce.git
cd ecommerce
chmod +x dev.sh
./dev.sh start
```

---

## 🐳 Script 3: Docker Production Deployment

### Usage:
```bash
# Make script executable
chmod +x deploy-docker.sh

# Deploy everything
./deploy-docker.sh deploy

# Or use individual commands
./deploy-docker.sh start     # Start services
./deploy-docker.sh stop      # Stop services
./deploy-docker.sh restart   # Restart services
./deploy-docker.sh logs      # View logs
./deploy-docker.sh status    # Check status
./deploy-docker.sh clean     # Remove everything
```

### What it does:
- 🐳 Installs Docker and Docker Compose
- 📦 Creates Docker containers for all services
- 🗄️ Sets up MongoDB container
- 🌐 Configures Nginx reverse proxy
- 🔒 Production-ready configuration
- 📊 Health checks and monitoring

### Services Created:
- **MongoDB**: Database container
- **Backend**: Node.js API container
- **Frontend**: React customer app container
- **Dashboard**: React admin panel container
- **Nginx**: Reverse proxy and load balancer

---

## 🌐 Access Points

After deployment, your applications will be available at:

| Service | URL | Description |
|---------|-----|-------------|
| Frontend | http://localhost:3000 | Customer shopping interface |
| Dashboard | http://localhost:3001 | Admin/Seller management panel |
| Backend API | http://localhost:5001 | REST API endpoints |
| Full App (Docker) | http://localhost | Nginx proxied full application |

---

## ⚙️ Configuration

### Environment Variables

Edit `backend/.env` with your credentials:

```bash
PORT=5001
DB_URL=mongodb://admin:password@127.0.0.1:27017/ec?authSource=admin
SECRET=your_jwt_secret_here
cloud_name=your_cloudinary_cloud_name
api_key=your_cloudinary_api_key
api_secret=your_cloudinary_api_secret
STRIPE_SECRET_KEY=your_stripe_secret_key_here
```

### Required Services:
- **Stripe Account**: For payment processing
- **Cloudinary Account**: For image storage
- **MongoDB**: Database (auto-installed)

---

## 🔍 Monitoring & Management

### PM2 Commands (Ubuntu deployment):
```bash
pm2 status          # View all processes
pm2 logs            # View logs
pm2 restart all     # Restart all services
pm2 stop all        # Stop all services
pm2 delete all      # Remove all processes
```

### Docker Commands (Docker deployment):
```bash
docker-compose ps                 # View containers
docker-compose logs              # View logs
docker-compose restart          # Restart services
docker-compose down              # Stop everything
docker-compose down -v          # Remove data volumes
```

---

## 🔒 Security Considerations

### Production Security:
1. **Change default passwords**:
   - MongoDB: `admin/password`
   - JWT Secret in `.env`

2. **Configure SSL/TLS**:
   - Use Let's Encrypt for HTTPS
   - Update Nginx configuration

3. **Firewall**:
   - Scripts configure UFW automatically
   - Only necessary ports are opened

4. **Environment Variables**:
   - Never commit `.env` files
   - Use secure secret management in production

---

## 🐛 Troubleshooting

### Common Issues:

#### Port conflicts:
```bash
# Check what's using ports
sudo netstat -tlnp | grep :3000
sudo netstat -tlnp | grep :5001
sudo netstat -tlnp | grep :3001
```

#### MongoDB connection issues:
```bash
# Check MongoDB status
sudo systemctl status mongod
# Restart MongoDB
sudo systemctl restart mongod
```

#### Permission issues:
```bash
# Fix npm permissions
sudo chown -R $(whoami) ~/.npm
```

#### Docker issues:
```bash
# Restart Docker
sudo systemctl restart docker
# Check Docker logs
docker-compose logs
```

---

## 📝 Manual Installation

If you prefer manual installation, see the detailed [Ubuntu Installation Guide](UBUNTU_INSTALL.md).

---

## 🤝 Support

For issues and questions:
1. Check the troubleshooting section above
2. Review the logs: `pm2 logs` or `docker-compose logs`
3. Open an issue on GitHub

---

## 📄 License

This project is licensed under the MIT License.

---

**Happy coding! 🚀**
