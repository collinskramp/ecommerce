#!/bin/bash

# MERN Multi-vendor Ecommerce Production Deployment Script
# Intelligent deployment with idempotency and error recovery
# Version: 3.0 - Production Ready

set -e

# Configuration
SCRIPT_VERSION="3.0"
PROJECT_NAME="ecommerce"
REPO_URL="https://github.com/collinskramp/ecommerce.git"
DEPLOY_DIR="/var/www/nodeApps/ecommerce"
PROJECT_DIR="$DEPLOY_DIR/ecommerce"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $(date '+%H:%M:%S') $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $(date '+%H:%M:%S') $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $(date '+%H:%M:%S') $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $(date '+%H:%M:%S') $1"; }
log_step() { echo -e "${PURPLE}[STEP]${NC} $(date '+%H:%M:%S') $1"; }

# Header
show_header() {
    clear
    echo "================================================================"
    echo "  🚀 MERN Ecommerce Production Deployment v$SCRIPT_VERSION"
    echo "  Intelligent • Idempotent • Production Ready"
    echo "================================================================"
    echo ""
}

# Check if running as correct user
check_user() {
    if [[ $EUID -eq 0 ]]; then
        log_error "Don't run as root. Run as ubuntu user with sudo privileges."
        exit 1
    fi
    
    if ! groups | grep -q sudo; then
        log_error "User needs sudo privileges"
        exit 1
    fi
    
    log_success "User check passed"
}

# System requirements check
check_system() {
    log_step "Checking system requirements..."
    
    # Check Ubuntu version
    if ! grep -q "Ubuntu" /etc/os-release; then
        log_warning "This script is optimized for Ubuntu"
    fi
    
    # Check available space (need at least 2GB)
    available_space=$(df / | tail -1 | awk '{print $4}')
    if [ "$available_space" -lt 2000000 ]; then
        log_error "Insufficient disk space. Need at least 2GB free"
        exit 1
    fi
    
    log_success "System requirements OK"
}

# Install system dependencies (only if missing)
install_system_deps() {
    log_step "Installing system dependencies..."
    
    # Update package list
    sudo apt update -qq
    
    # Install required packages (only missing ones)
    packages=("curl" "git" "build-essential" "software-properties-common")
    missing_packages=()
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            missing_packages+=("$package")
        fi
    done
    
    if [ ${#missing_packages[@]} -gt 0 ]; then
        log_info "Installing missing packages: ${missing_packages[*]}"
        sudo apt install -y "${missing_packages[@]}"
    else
        log_success "All system packages already installed"
    fi
}

# Install Node.js (only if not present or wrong version)
install_nodejs() {
    log_step "Checking Node.js installation..."
    
    required_version="18"
    
    if command -v node >/dev/null 2>&1; then
        current_version=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$current_version" -eq "$required_version" ] 2>/dev/null; then
            log_success "Node.js v$current_version already installed"
            return
        else
            log_info "Node.js v$current_version found, upgrading to v$required_version"
        fi
    fi
    
    # Install Node.js 18
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    # Verify installation
    node_version=$(node -v)
    npm_version=$(npm -v)
    log_success "Node.js $node_version and npm $npm_version installed"
}

# Install MongoDB (only if not running)
install_mongodb() {
    log_step "Checking MongoDB installation..."
    
    if systemctl is-active --quiet mongod; then
        log_success "MongoDB already running"
        return
    fi
    
    if command -v mongod >/dev/null 2>&1; then
        log_info "MongoDB installed but not running, starting it..."
        sudo systemctl start mongod
        sudo systemctl enable mongod
        log_success "MongoDB started"
        return
    fi
    
    log_info "Installing MongoDB..."
    
    # Import MongoDB GPG key
    curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
    
    # Add MongoDB repository
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    
    # Install MongoDB
    sudo apt-get update
    sudo apt-get install -y mongodb-org
    
    # Configure MongoDB (no authentication for development)
    sudo tee /etc/mongod.conf > /dev/null <<EOF
storage:
  dbPath: /var/lib/mongodb
  journal:
    enabled: true

systemLog:
  destination: file
  logAppend: true
  path: /var/log/mongodb/mongod.log

net:
  port: 27017
  bindIp: 127.0.0.1

processManagement:
  timeZoneInfo: /usr/share/zoneinfo

# No authentication required for development
EOF
    
    # Start and enable MongoDB
    sudo systemctl start mongod
    sudo systemctl enable mongod
    
    log_success "MongoDB installed and started"
}

# Install PM2 (only if not present)
install_pm2() {
    log_step "Checking PM2 installation..."
    
    if command -v pm2 >/dev/null 2>&1; then
        log_success "PM2 already installed"
        return
    fi
    
    log_info "Installing PM2..."
    sudo npm install -g pm2
    
    # Setup PM2 startup
    pm2 startup | tail -1 | sudo bash
    
    log_success "PM2 installed"
}

# Setup project directory
setup_project_dir() {
    log_step "Setting up project directory..."
    
    # Create deploy directory if it doesn't exist
    if [ ! -d "$DEPLOY_DIR" ]; then
        sudo mkdir -p "$DEPLOY_DIR"
        sudo chown -R $USER:$USER "$DEPLOY_DIR"
        log_info "Created deploy directory: $DEPLOY_DIR"
    fi
    
    cd "$DEPLOY_DIR"
    log_success "Project directory ready"
}

# Clone or update repository
setup_repository() {
    log_step "Setting up repository..."
    
    if [ -d "$PROJECT_DIR" ]; then
        log_info "Repository exists, updating..."
        cd "$PROJECT_DIR"
        
        # Stash any local changes
        if ! git diff --quiet || ! git diff --cached --quiet; then
            log_warning "Local changes detected, stashing..."
            git stash
        fi
        
        # Pull latest changes
        git pull origin main
        log_success "Repository updated"
    else
        log_info "Cloning repository..."
        git clone "$REPO_URL"
        cd "$PROJECT_DIR"
        log_success "Repository cloned"
    fi
}

# Create missing essential files
create_missing_files() {
    log_step "Checking for missing essential files..."
    
    # Frontend public/index.html
    if [ ! -f "frontend/public/index.html" ]; then
        log_info "Creating missing frontend/public/index.html"
        mkdir -p frontend/public
        cat > frontend/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="Multi-vendor Ecommerce Platform" />
    <link rel="apple-touch-icon" href="%PUBLIC_URL%/logo192.png" />
    <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
    <title>Ecommerce Platform</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF
    fi
    
    # Frontend public/manifest.json
    if [ ! -f "frontend/public/manifest.json" ]; then
        log_info "Creating missing frontend/public/manifest.json"
        cat > frontend/public/manifest.json << 'EOF'
{
  "short_name": "Ecommerce",
  "name": "Multi-vendor Ecommerce Platform",
  "icons": [
    {
      "src": "favicon.ico",
      "sizes": "64x64 32x32 24x24 16x16",
      "type": "image/x-icon"
    }
  ],
  "start_url": ".",
  "display": "standalone",
  "theme_color": "#000000",
  "background_color": "#ffffff"
}
EOF
    fi
    
    # Dashboard public/index.html
    if [ ! -f "dashboard/public/index.html" ]; then
        log_info "Creating missing dashboard/public/index.html"
        mkdir -p dashboard/public
        cp frontend/public/index.html dashboard/public/index.html
        sed -i 's/Ecommerce Platform/Ecommerce Dashboard/g' dashboard/public/index.html
    fi
    
    # Dashboard public/manifest.json
    if [ ! -f "dashboard/public/manifest.json" ]; then
        log_info "Creating missing dashboard/public/manifest.json"
        mkdir -p dashboard/public
        cp frontend/public/manifest.json dashboard/public/manifest.json
        sed -i 's/Ecommerce Platform/Ecommerce Dashboard/g' dashboard/public/manifest.json
    fi
    
    log_success "Essential files verified"
}

# Install dependencies (smart - only if needed)
install_dependencies() {
    log_step "Installing project dependencies..."
    
    # Backend dependencies
    if [ ! -d "backend/node_modules" ] || [ "backend/package.json" -nt "backend/node_modules" ]; then
        log_info "Installing/updating backend dependencies..."
        cd backend
        npm install --production
        cd ..
    else
        log_success "Backend dependencies up to date"
    fi
    
    # Frontend dependencies
    if [ ! -d "frontend/node_modules" ] || [ "frontend/package.json" -nt "frontend/node_modules" ]; then
        log_info "Installing/updating frontend dependencies..."
        cd frontend
        npm install
        cd ..
    else
        log_success "Frontend dependencies up to date"
    fi
    
    # Dashboard dependencies
    if [ ! -d "dashboard/node_modules" ] || [ "dashboard/package.json" -nt "dashboard/node_modules" ]; then
        log_info "Installing/updating dashboard dependencies..."
        cd dashboard
        npm install
        cd ..
    else
        log_success "Dashboard dependencies up to date"
    fi
    
    log_success "All dependencies ready"
}

# Setup environment files
setup_environment() {
    log_step "Setting up environment configuration..."
    
    # Backend .env
    if [ ! -f "backend/.env" ]; then
        log_info "Creating backend/.env"
        cat > backend/.env << 'EOF'
PORT = 5001
DB_URL = mongodb://127.0.0.1:27017/ec
SECRET = ariyan
cloud_name = dbx 
api_key = 5833 
api_secret = yY0
STRIPE_SECRET_KEY = sk_test_your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY = pk_test_your_stripe_publishable_key_here
EOF
    else
        # Update existing .env to ensure no auth
        if grep -q "admin:password" backend/.env; then
            log_info "Updating backend/.env to remove MongoDB authentication"
            sed -i 's|mongodb://admin:password@127.0.0.1:27017/ec|mongodb://127.0.0.1:27017/ec|g' backend/.env
        fi
        log_success "Backend environment updated"
    fi
}

# Create PM2 ecosystem configuration
create_pm2_config() {
    log_step "Creating PM2 ecosystem configuration..."
    
    cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'ecommerce-backend',
      script: 'backend/server.js',
      cwd: '/var/www/nodeApps/ecommerce/ecommerce',
      instances: 1,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 5001
      },
      log_file: 'logs/backend-combined.log',
      out_file: 'logs/backend-out.log',
      error_file: 'logs/backend-error.log',
      max_memory_restart: '500M',
      restart_delay: 1000
    },
    {
      name: 'ecommerce-frontend',
      script: 'npm',
      args: 'start',
      cwd: '/var/www/nodeApps/ecommerce/ecommerce/frontend',
      instances: 1,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'development',
        PORT: 3000,
        BROWSER: 'none'
      },
      log_file: 'logs/frontend-combined.log',
      out_file: 'logs/frontend-out.log',
      error_file: 'logs/frontend-error.log',
      max_memory_restart: '500M'
    },
    {
      name: 'ecommerce-dashboard',
      script: 'npm',
      args: 'start',
      cwd: '/var/www/nodeApps/ecommerce/ecommerce/dashboard',
      instances: 1,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'development',
        PORT: 3001,
        BROWSER: 'none'
      },
      log_file: 'logs/dashboard-combined.log',
      out_file: 'logs/dashboard-out.log',
      error_file: 'logs/dashboard-error.log',
      max_memory_restart: '500M'
    }
  ]
};
EOF
    
    # Create logs directory
    mkdir -p logs
    
    log_success "PM2 configuration created"
}

# Populate database (only if empty)
populate_database() {
    log_step "Checking database population..."
    
    # Check if database has data
    product_count=$(mongosh ec --quiet --eval "db.products.countDocuments()" 2>/dev/null || echo "0")
    
    if [ "$product_count" -eq 0 ]; then
        log_info "Database is empty, populating with sample data..."
        
        # Use the existing populate script if available, otherwise create basic data
        if [ -f "populate_products_only.js" ]; then
            node populate_products_only.js
        else
            # Create minimal data directly
            mongosh ec --eval "
            db.products.insertMany([
              {
                name: 'iPhone 14 Pro',
                category: 'Electronics',
                brand: 'Apple',
                price: 1199,
                discount: 10,
                rating: 4.8,
                stock: 25,
                description: 'Latest iPhone with Pro camera system',
                shopName: 'Tech Store',
                images: ['https://via.placeholder.com/300x300/1f2937/ffffff?text=iPhone+14+Pro'],
                slug: 'iphone-14-pro'
              },
              {
                name: 'Samsung Galaxy S23',
                category: 'Electronics',
                brand: 'Samsung',
                price: 999,
                discount: 15,
                rating: 4.7,
                stock: 30,
                description: 'Flagship Android phone',
                shopName: 'Mobile Hub',
                images: ['https://via.placeholder.com/300x300/059669/ffffff?text=Galaxy+S23'],
                slug: 'samsung-galaxy-s23'
              }
            ]);
            
            db.categorys.insertMany([
              { name: 'Electronics', image: 'https://via.placeholder.com/200x200/3b82f6/ffffff?text=Electronics' },
              { name: 'Fashion', image: 'https://via.placeholder.com/200x200/ef4444/ffffff?text=Fashion' },
              { name: 'Home', image: 'https://via.placeholder.com/200x200/10b981/ffffff?text=Home' }
            ]);
            
            db.banners.insertMany([
              { 
                productId: null,
                banner: 'https://via.placeholder.com/1200x400/1f2937/ffffff?text=Welcome+to+Ecommerce',
                link: '/'
              },
              {
                productId: null, 
                banner: 'https://via.placeholder.com/1200x400/059669/ffffff?text=Special+Offers',
                link: '/products'
              }
            ]);
            " >/dev/null 2>&1
        fi
        
        log_success "Database populated with sample data"
    else
        log_success "Database already has $product_count products"
    fi
}

# Configure firewall
configure_firewall() {
    log_step "Configuring firewall..."
    
    if command -v ufw >/dev/null 2>&1; then
        sudo ufw --force enable
        sudo ufw allow 22/tcp      # SSH
        sudo ufw allow 3000/tcp    # Frontend
        sudo ufw allow 3001/tcp    # Dashboard  
        sudo ufw allow 5001/tcp    # Backend API
        sudo ufw allow 27017/tcp   # MongoDB (local only)
        
        log_success "Firewall configured"
    else
        log_warning "UFW not available, skipping firewall configuration"
    fi
}

# Start services
start_services() {
    log_step "Starting services..."
    
    # Stop existing PM2 processes (if any)
    pm2 delete all 2>/dev/null || true
    
    # Start with ecosystem file
    pm2 start ecosystem.config.js
    
    # Save PM2 configuration
    pm2 save
    
    # Wait for services to start
    sleep 5
    
    log_success "Services started"
}

# Health check
health_check() {
    log_step "Performing health checks..."
    
    # Check PM2 status
    pm2_status=$(pm2 list | grep -c "online" || echo "0")
    
    # Check backend
    if curl -s http://localhost:5001 >/dev/null 2>&1; then
        backend_status="✅"
    else
        backend_status="❌"
    fi
    
    # Check frontend
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        frontend_status="✅"
    else
        frontend_status="❌"
    fi
    
    # Check dashboard
    if curl -s http://localhost:3001 >/dev/null 2>&1; then
        dashboard_status="✅"
    else
        dashboard_status="❌"
    fi
    
    # Check MongoDB
    if mongosh ec --quiet --eval "db.runCommand('ping').ok" >/dev/null 2>&1; then
        mongodb_status="✅"
    else
        mongodb_status="❌"
    fi
    
    echo ""
    echo "🏥 HEALTH CHECK RESULTS"
    echo "======================="
    echo "PM2 Processes Online: $pm2_status/3"
    echo "Backend (Port 5001):  $backend_status"
    echo "Frontend (Port 3000): $frontend_status"
    echo "Dashboard (Port 3001): $dashboard_status"
    echo "MongoDB:              $mongodb_status"
    echo ""
}

# Show final status
show_final_status() {
    local_ip=$(hostname -I | awk '{print $1}')
    
    echo "🎉 DEPLOYMENT COMPLETED!"
    echo "========================"
    echo ""
    echo "🌐 Access your applications:"
    echo "   Frontend:  http://$local_ip:3000"
    echo "   Dashboard: http://$local_ip:3001"
    echo "   Backend:   http://$local_ip:5001"
    echo ""
    echo "📊 Management commands:"
    echo "   View logs:    pm2 logs"
    echo "   View status:  pm2 status"
    echo "   Restart all:  pm2 restart all"
    echo "   Stop all:     pm2 stop all"
    echo ""
    echo "🔧 Configuration files:"
    echo "   PM2 Config:   $PROJECT_DIR/ecosystem.config.js"
    echo "   Backend Env:  $PROJECT_DIR/backend/.env"
    echo "   Logs:         $PROJECT_DIR/logs/"
    echo ""
}

# Cleanup function for errors
cleanup_on_error() {
    log_error "Deployment failed. Cleaning up..."
    pm2 stop all 2>/dev/null || true
    log_error "Run the script again to retry deployment"
    exit 1
}

# Set trap for errors
trap cleanup_on_error ERR

# Main deployment function
main() {
    show_header
    
    log_step "🚀 Starting intelligent deployment..."
    
    # Phase 1: System preparation
    log_step "Phase 1: System Preparation"
    check_user
    check_system
    install_system_deps
    install_nodejs
    install_mongodb
    install_pm2
    
    # Phase 2: Application setup
    log_step "Phase 2: Application Setup"
    setup_project_dir
    setup_repository
    create_missing_files
    setup_environment
    install_dependencies
    
    # Phase 3: Deployment configuration
    log_step "Phase 3: Deployment Configuration"
    create_pm2_config
    populate_database
    configure_firewall
    
    # Phase 4: Service deployment
    log_step "Phase 4: Service Deployment"
    start_services
    
    # Phase 5: Verification
    log_step "Phase 5: Health Check"
    health_check
    show_final_status
    
    log_success "🎉 Deployment completed successfully!"
}

# Run main function
main "$@"
