#!/bin/bash

# MERN Multi-vendor Ecommerce Ubuntu Deployment Script
# Comprehensive deployment with automatic troubleshooting and fixes
# Handles: permissions, port conflicts, missing files, and dependencies

set -e  # Exit on any error

# Script version and info
SCRIPT_VERSION="2.0"
SCRIPT_NAME="MERN Ecommerce Deploy"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output with timestamps
print_status() {
    echo -e "${BLUE}[INFO]${NC} $(date '+%H:%M:%S') $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $(date '+%H:%M:%S') $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $(date '+%H:%M:%S') $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $(date '+%H:%M:%S') $1"
}

# Show script header
show_header() {
    echo "========================================"
    echo "  $SCRIPT_NAME v$SCRIPT_VERSION"
    echo "  Ubuntu MERN Stack Deployment"
    echo "========================================"
    echo ""
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        print_status "Try running: su - ubuntu && ./deploy-ubuntu.sh"
        exit 1
    fi
}

# Resolve port conflicts
resolve_port_conflicts() {
    print_status "Checking for port conflicts..."
    
    # Check ports 3000, 3001, 5001
    local ports_in_use=()
    
    if netstat -tulpn 2>/dev/null | grep -q :3000; then
        ports_in_use+=(3000)
    fi
    if netstat -tulpn 2>/dev/null | grep -q :3001; then
        ports_in_use+=(3001)
    fi
    if netstat -tulpn 2>/dev/null | grep -q :5001; then
        ports_in_use+=(5001)
    fi
    
    if [ ${#ports_in_use[@]} -gt 0 ]; then
        print_warning "Ports in use: ${ports_in_use[*]}"
        print_status "Killing processes on conflicting ports..."
        
        for port in "${ports_in_use[@]}"; do
            if command -v lsof &> /dev/null; then
                local pids=$(lsof -ti :$port 2>/dev/null || true)
                if [ -n "$pids" ]; then
                    print_status "Killing processes on port $port: $pids"
                    echo "$pids" | xargs kill -9 2>/dev/null || true
                fi
            fi
        done
        
        # Stop any PM2 processes
        pm2 stop all 2>/dev/null || true
        pm2 delete all 2>/dev/null || true
        
        sleep 2
        print_success "Port conflicts resolved"
    else
        print_success "No port conflicts detected"
    fi
}

# Create missing React files
create_missing_react_files() {
    local project_dir="$1"
    print_status "Checking and creating missing React files..."
    
    # Create frontend index.html if missing
    if [[ ! -f "$project_dir/frontend/public/index.html" ]]; then
        print_status "Creating frontend/public/index.html..."
        mkdir -p "$project_dir/frontend/public"
        cat > "$project_dir/frontend/public/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="Multi-vendor Ecommerce Frontend" />
    <link rel="apple-touch-icon" href="%PUBLIC_URL%/logo192.png" />
    <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
    <title>Ecommerce Store</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF
        print_success "Created frontend/public/index.html"
    fi
    
    # Create dashboard index.html if missing
    if [[ ! -f "$project_dir/dashboard/public/index.html" ]]; then
        print_status "Creating dashboard/public/index.html..."
        mkdir -p "$project_dir/dashboard/public"
        cat > "$project_dir/dashboard/public/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="Multi-vendor Ecommerce Dashboard" />
    <link rel="apple-touch-icon" href="%PUBLIC_URL%/logo192.png" />
    <link rel="manifest" href="%PUBLIC_URL%/manifest.json" />
    <title>Ecommerce Dashboard</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>
EOF
        print_success "Created dashboard/public/index.html"
    fi
}

# Smart deployment troubleshooting
deployment_troubleshooting() {
    local project_dir="$1"
    print_status "Running deployment diagnostics..."
    
    # Check PM2 status
    if command -v pm2 &> /dev/null; then
        print_status "PM2 Status:"
        pm2 status || true
        
        # Check for failed processes
        local failed_processes=$(pm2 jlist | jq -r '.[] | select(.pm2_env.status != "online") | .name' 2>/dev/null || true)
        if [ -n "$failed_processes" ]; then
            print_warning "Failed processes detected: $failed_processes"
            print_status "Attempting to restart failed processes..."
            echo "$failed_processes" | while read -r process; do
                pm2 restart "$process" 2>/dev/null || true
            done
        fi
    fi
    
    # Test connections
    print_status "Testing application connectivity..."
    local backend_ok=false
    local frontend_ok=false
    local dashboard_ok=false
    
    if curl -s --connect-timeout 5 http://localhost:5001 > /dev/null 2>&1; then
        backend_ok=true
        print_success "Backend (5001): OK"
    else
        print_warning "Backend (5001): FAILED"
    fi
    
    if curl -s --connect-timeout 5 http://localhost:3000 > /dev/null 2>&1; then
        frontend_ok=true
        print_success "Frontend (3000): OK"
    elif curl -s --connect-timeout 5 http://localhost:3002 > /dev/null 2>&1; then
        frontend_ok=true
        print_success "Frontend (3002): OK"
    else
        print_warning "Frontend: FAILED"
    fi
    
    if curl -s --connect-timeout 5 http://localhost:3001 > /dev/null 2>&1; then
        dashboard_ok=true
        print_success "Dashboard (3001): OK"
    else
        print_warning "Dashboard (3001): FAILED"
    fi
    
    # Return status for final summary
    if $backend_ok && $frontend_ok && $dashboard_ok; then
        return 0
    else
        return 1
    fi
}

# Check directory permissions and suggest better location
check_directory() {
    print_status "Checking current directory: $(pwd)"
    
    # Check if current directory is writable
    if [[ ! -w "." ]]; then
        print_warning "Current directory is not writable!"
        print_status "Recommended: Move to your home directory"
        print_status "Run: cd ~ && ./deploy-ubuntu.sh"
        
        # Ask user if they want to continue
        print_status "Do you want to automatically move to home directory? (y/n)"
        read -r AUTO_MOVE
        if [[ $AUTO_MOVE =~ ^[Yy]$ ]]; then
            cd ~
            print_success "Moved to home directory: $(pwd)"
        else
            print_error "Please run the script from a directory where you have write permissions."
            exit 1
        fi
    else
        print_success "Directory is writable: $(pwd)"
    fi
}

# Check Ubuntu version
check_ubuntu() {
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_error "This script is designed for Ubuntu. Other distributions may not work correctly."
        exit 1
    fi
    print_success "Ubuntu detected"
}

# Update system
update_system() {
    print_status "Updating system packages..."
    sudo apt update && sudo apt upgrade -y
    print_success "System updated"
}

# Install Node.js
install_nodejs() {
    print_status "Installing Node.js 18..."
    
    # Check if Node.js is already installed
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        print_warning "Node.js is already installed: $NODE_VERSION"
        
        # Check if version is 16 or higher
        if [[ $(echo $NODE_VERSION | cut -d'v' -f2 | cut -d'.' -f1) -ge 16 ]]; then
            print_success "Node.js version is sufficient"
            return
        else
            print_warning "Node.js version is too old. Installing newer version..."
        fi
    fi
    
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    # Verify installation
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    print_success "Node.js installed: $NODE_VERSION"
    print_success "npm installed: $NPM_VERSION"
}

# Install MongoDB
install_mongodb() {
    print_status "Installing MongoDB..."
    
    # Check if MongoDB is already installed
    if command -v mongod &> /dev/null; then
        print_warning "MongoDB is already installed"
        return
    fi
    
    # Import MongoDB public GPG key
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
    
    # Add MongoDB repository
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    
    # Update package database
    sudo apt-get update
    
    # Install MongoDB
    sudo apt-get install -y mongodb-org
    
    # Start and enable MongoDB
    sudo systemctl start mongod
    sudo systemctl enable mongod
    
    # Wait for MongoDB to start
    sleep 5
    
    # Check if MongoDB is running
    if sudo systemctl is-active --quiet mongod; then
        print_success "MongoDB installed and running"
    else
        print_error "MongoDB installation failed"
        exit 1
    fi
}

# Install Git
install_git() {
    print_status "Installing Git..."
    
    if command -v git &> /dev/null; then
        print_warning "Git is already installed"
        return
    fi
    
    sudo apt install git -y
    print_success "Git installed"
}

# Install PM2 (Process Manager)
install_pm2() {
    print_status "Installing PM2 process manager..."
    
    if command -v pm2 &> /dev/null; then
        print_warning "PM2 is already installed"
        return
    fi
    
    sudo npm install -g pm2
    print_success "PM2 installed"
}

# Setup MongoDB authentication
setup_mongodb() {
    print_status "Setting up MongoDB authentication..."
    
    # Check if admin user already exists
    if mongosh --quiet --eval "db.runCommand({usersInfo: 'admin'})" admin | grep -q '"users" : \[ \]'; then
        print_status "Creating MongoDB admin user..."
        
        mongosh --eval "
        use admin;
        db.createUser({
            user: 'admin',
            pwd: 'password',
            roles: ['userAdminAnyDatabase', 'readWriteAnyDatabase']
        });
        " > /dev/null
        
        print_success "MongoDB admin user created (username: admin, password: password)"
    else
        print_warning "MongoDB admin user already exists"
    fi
}

# Clone repository
clone_repository() {
    print_status "Cloning repository..."
    
    # Check if we're in a directory we can write to
    if [[ ! -w "." ]]; then
        print_warning "Current directory is not writable. Moving to home directory..."
        cd ~
        print_status "Changed to: $(pwd)"
    fi
    
    if [[ -d "ecommerce" ]]; then
        print_warning "Repository directory already exists. Pulling latest changes..."
        cd ecommerce
        git pull origin main || {
            print_warning "Failed to pull changes. Repository might be dirty. Continuing..."
        }
        cd ..
    else
        git clone https://github.com/collinskramp/ecommerce.git || {
            print_error "Failed to clone repository. Check permissions and network connectivity."
            print_status "Current directory: $(pwd)"
            print_status "Directory permissions: $(ls -la . | head -1)"
            exit 1
        }
        print_success "Repository cloned to: $(pwd)/ecommerce"
    fi
}

# Setup environment variables
setup_environment() {
    print_status "Setting up environment variables..."
    
    cd ecommerce/backend
    
    if [[ ! -f ".env" ]]; then
        cp .env.example .env
        print_success ".env file created from template"
        print_warning "Please edit backend/.env file with your actual credentials:"
        print_warning "- Add your Stripe secret key"
        print_warning "- Add your Cloudinary credentials"
        print_warning "- Change the JWT secret"
    else
        print_warning ".env file already exists"
    fi
    
    cd ../..
}

# Install dependencies
install_dependencies() {
    print_status "Installing project dependencies..."
    
    cd ecommerce
    
    # Backend dependencies
    print_status "Installing backend dependencies..."
    cd backend
    npm install
    cd ..
    
    # Frontend dependencies
    print_status "Installing frontend dependencies..."
    cd frontend
    npm install
    cd ..
    
    # Dashboard dependencies
    print_status "Installing dashboard dependencies..."
    cd dashboard
    npm install
    cd ..
    
    cd ..
    print_success "All dependencies installed"
}

# Create PM2 ecosystem file with comprehensive configuration
create_pm2_config() {
    print_status "Creating optimized PM2 ecosystem configuration..."
    
    cd ecommerce
    
    # Get absolute project path
    local project_path=$(pwd)
    
    cat > ecosystem.config.js << EOF
module.exports = {
  apps: [
    {
      name: 'ecommerce-backend',
      cwd: '$project_path/backend',
      script: 'server.js',
      env: {
        NODE_ENV: 'production',
        PORT: 5001
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: '$project_path/logs/backend-error.log',
      out_file: '$project_path/logs/backend-out.log',
      log_file: '$project_path/logs/backend-combined.log',
      time: true
    },
    {
      name: 'ecommerce-frontend',
      cwd: '$project_path/frontend',
      script: 'node_modules/.bin/react-scripts',
      args: 'start',
      env: {
        PORT: 3000,
        BROWSER: 'none',
        CI: 'true',
        HOST: '0.0.0.0',
        FORCE_COLOR: '0'
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: '$project_path/logs/frontend-error.log',
      out_file: '$project_path/logs/frontend-out.log',
      log_file: '$project_path/logs/frontend-combined.log',
      time: true
    },
    {
      name: 'ecommerce-dashboard',
      cwd: '$project_path/dashboard',
      script: 'node_modules/.bin/react-scripts',
      args: 'start',
      env: {
        PORT: 3001,
        BROWSER: 'none',
        CI: 'true',
        HOST: '0.0.0.0',
        FORCE_COLOR: '0'
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: '$project_path/logs/dashboard-error.log',
      out_file: '$project_path/logs/dashboard-out.log',
      log_file: '$project_path/logs/dashboard-combined.log',
      time: true
    }
  ]
};
EOF
    
    # Create logs directory
    mkdir -p logs
    
    cd ..
    print_success "PM2 ecosystem configuration created"
}

# Populate database with comprehensive demo data
populate_database() {
    print_status "Do you want to populate the database with comprehensive demo data? (y/n)"
    read -r POPULATE_DB
    
    if [[ $POPULATE_DB =~ ^[Yy]$ ]]; then
        print_status "Populating database with comprehensive demo data..."
        cd ecommerce
        
        # Make script executable
        chmod +x populate_database.js
        
        # Check if MongoDB is accessible
        print_status "Checking MongoDB connection..."
        if mongosh --quiet --eval "db.runCommand({ping: 1})" ec --authenticationDatabase admin -u admin -p password > /dev/null 2>&1; then
            print_success "MongoDB connection successful"
            
            # Run the comprehensive demo data population
            print_status "Creating comprehensive demo data..."
            node populate_database.js || {
                print_warning "Node.js populate script failed, trying alternative method..."
                
                # Fallback: Create basic data using mongosh directly
                print_status "Creating basic demo data using MongoDB shell..."
                
                # Create categories
                mongosh --quiet ec --authenticationDatabase admin -u admin -p password --eval "
                db.categories.deleteMany({});
                db.categories.insertMany([
                    {name: 'Electronics', image: 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=400', slug: 'electronics', createdAt: new Date()},
                    {name: 'Clothing & Fashion', image: 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=400', slug: 'clothing-fashion', createdAt: new Date()},
                    {name: 'Home & Garden', image: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=400', slug: 'home-garden', createdAt: new Date()}
                ]);
                print('✅ Categories created');
                " > /dev/null 2>&1
                
                # Create products
                mongosh --quiet ec --authenticationDatabase admin -u admin -p password --eval "
                db.products.deleteMany({});
                db.products.insertMany([
                    {name: 'Sample Product 1', category: 'Electronics', price: 99, discount: 10, description: 'Demo product', images: ['https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400'], stock: 50, createdAt: new Date()},
                    {name: 'Sample Product 2', category: 'Clothing & Fashion', price: 49, discount: 15, description: 'Demo product', images: ['https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=400'], stock: 30, createdAt: new Date()}
                ]);
                print('✅ Products created');
                " > /dev/null 2>&1
                
                # Create banners
                mongosh --quiet ec --authenticationDatabase admin -u admin -p password --eval "
                db.banners.deleteMany({});
                db.banners.insertMany([
                    {banner: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=300&fit=crop', link: '/products', createdAt: new Date()},
                    {banner: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=300&fit=crop', link: '/categories/electronics', createdAt: new Date()}
                ]);
                print('✅ Banners created');
                " > /dev/null 2>&1
                
                print_success "Basic demo data created using MongoDB shell"
            }
            
            print_success "Database populated with comprehensive demo data"
            print_status "Demo Login Credentials:"
            print_status "Admin: admin@admin.com / secret"
            print_status "Seller: seller1@techstore.com / secret"
            print_status "Customer: customer@example.com / secret"
        else
            print_warning "Could not connect to MongoDB. Database population skipped."
            print_warning "You can manually populate data later using: node populate_database.js"
        fi
        
        cd ..
    else
        print_warning "Skipping database population"
    fi
}

# Configure firewall
configure_firewall() {
    print_status "Configuring UFW firewall..."
    
    # Check if UFW is installed
    if ! command -v ufw &> /dev/null; then
        sudo apt install ufw -y
    fi
    
    # Configure firewall rules
    sudo ufw allow 22    # SSH
    sudo ufw allow 3000  # Frontend (React development server)
    sudo ufw allow 3001  # Dashboard
    sudo ufw allow 5001  # Backend API
    
    # Enable firewall (only if not already enabled)
    if ! sudo ufw status | grep -q "Status: active"; then
        print_warning "UFW firewall will be enabled. This may temporarily disconnect SSH if you're using it."
        print_status "Continue? (y/n)"
        read -r ENABLE_UFW
        
        if [[ $ENABLE_UFW =~ ^[Yy]$ ]]; then
            sudo ufw --force enable
            print_success "UFW firewall enabled"
        else
            print_warning "UFW firewall not enabled"
        fi
    else
        print_success "UFW firewall already enabled"
    fi
}

# Start services with comprehensive error handling
start_services() {
    print_status "Starting services with PM2..."
    
    cd ecommerce
    
    # Resolve any port conflicts first
    resolve_port_conflicts
    
    # Create missing React files
    create_missing_react_files "$(pwd)"
    
    # Make sure logs directory exists
    mkdir -p logs
    
    # Stop any existing PM2 processes
    pm2 delete all 2>/dev/null || true
    
    # Start all services
    print_status "Launching PM2 processes..."
    pm2 start ecosystem.config.js
    
    # Wait for services to initialize
    print_status "Waiting for services to initialize..."
    sleep 10
    
    # Run deployment troubleshooting
    if deployment_troubleshooting "$(pwd)"; then
        print_success "All services are running correctly"
    else
        print_warning "Some services may need attention - check logs with 'pm2 logs'"
    fi
    
    # Save PM2 configuration
    pm2 save
    
    # Setup PM2 to start on boot
    pm2 startup | grep -E '^sudo ' | sh || true
    
    cd ..
    print_success "Service startup completed"
}

# Display comprehensive service status
show_status() {
    print_success "=== DEPLOYMENT COMPLETE ==="
    echo ""
    print_status "Service Status:"
    pm2 status
    echo ""
    
    # Get public IP for external access
    local public_ip=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "Unable to get public IP")
    
    print_status "Application URLs:"
    echo "🛒 Frontend (Customer):  http://localhost:3000"
    echo "📊 Dashboard (Admin):    http://localhost:3001"
    echo "🔧 Backend API:          http://localhost:5001"
    
    if [ "$public_ip" != "Unable to get public IP" ]; then
        echo ""
        print_status "External Access URLs:"
        echo "🌍 Frontend:  http://$public_ip:3000"
        echo "🌍 Dashboard: http://$public_ip:3001"
        echo "🌍 Backend:   http://$public_ip:5001"
        echo ""
        print_warning "For external access, configure firewall:"
        echo "sudo ufw allow 3000"
        echo "sudo ufw allow 3001"
        echo "sudo ufw allow 5001"
    fi
    
    echo ""
    print_status "Useful Commands:"
    echo "📈 View logs:            pm2 logs"
    echo "🔄 Restart services:     pm2 restart all"
    echo "⏹️  Stop services:        pm2 stop all"
    echo "📋 Service status:       pm2 status"
    echo "🔧 Troubleshoot:         pm2 logs --lines 50"
    echo ""
    print_warning "IMPORTANT: Please edit backend/.env with your actual credentials!"
    print_warning "Default MongoDB credentials: username=admin, password=password"
}

# Main deployment function with comprehensive error handling
main() {
    show_header
    
    print_status "Starting MERN Ecommerce Deployment on Ubuntu..."
    echo ""
    
    # Pre-deployment checks
    check_root
    check_directory
    check_ubuntu
    
    # System preparation
    print_status "Phase 1: System Preparation"
    update_system
    install_git
    install_nodejs
    install_mongodb
    install_pm2
    
    # Database setup
    print_status "Phase 2: Database Configuration"
    setup_mongodb
    
    # Application setup
    print_status "Phase 3: Application Setup"
    clone_repository
    setup_environment
    install_dependencies
    
    # Deployment configuration
    print_status "Phase 4: Deployment Configuration"
    create_pm2_config
    populate_database
    configure_firewall
    
    # Service startup
    print_status "Phase 5: Service Startup"
    start_services
    
    # Final status
    show_status
    
    print_success "🎉 Deployment completed successfully!"
    echo ""
    print_status "Next steps:"
    echo "1. Edit backend/.env with your actual API keys"
    echo "2. Access your applications using the URLs above"
    echo "3. Monitor logs with: pm2 logs"
}

# Run main function
main "$@"
