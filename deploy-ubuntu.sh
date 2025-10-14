#!/bin/bash

# MERN Multi-vendor Ecommerce Ubuntu Deployment Script
# This script automatically sets up and runs the complete MERN stack on Ubuntu

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root. Please run as a regular user with sudo privileges."
        print_status "Try running: su - ubuntu && ./deploy-ubuntu.sh"
        exit 1
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

# Create PM2 ecosystem file
create_pm2_config() {
    print_status "Creating PM2 ecosystem configuration..."
    
    cd ecommerce
    
    cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'ecommerce-backend',
      cwd: './backend',
      script: 'npm',
      args: 'start',
      env: {
        NODE_ENV: 'production',
        PORT: 5001
      },
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      log_file: './logs/backend-combined.log',
      time: true
    },
    {
      name: 'ecommerce-frontend',
      cwd: './frontend',
      script: 'npm',
      args: 'start',
      env: {
        PORT: 3000,
        BROWSER: 'none'
      },
      error_file: './logs/frontend-error.log',
      out_file: './logs/frontend-out.log',
      log_file: './logs/frontend-combined.log',
      time: true
    },
    {
      name: 'ecommerce-dashboard',
      cwd: './dashboard',
      script: 'npm',
      args: 'start',
      env: {
        PORT: 3001,
        BROWSER: 'none'
      },
      error_file: './logs/dashboard-error.log',
      out_file: './logs/dashboard-out.log',
      log_file: './logs/dashboard-combined.log',
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

# Populate database with sample data
populate_database() {
    print_status "Do you want to populate the database with sample data? (y/n)"
    read -r POPULATE_DB
    
    if [[ $POPULATE_DB =~ ^[Yy]$ ]]; then
        print_status "Populating database with sample data..."
        cd ecommerce
        chmod +x populate_database.js
        node populate_database.js
        cd ..
        print_success "Database populated with sample data"
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
    sudo ufw allow 3000  # Frontend
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

# Start services
start_services() {
    print_status "Starting services with PM2..."
    
    cd ecommerce
    
    # Stop any existing PM2 processes
    pm2 delete all 2>/dev/null || true
    
    # Start all services
    pm2 start ecosystem.config.js
    
    # Save PM2 configuration
    pm2 save
    
    # Setup PM2 to start on boot
    pm2 startup | grep -E '^sudo ' | sh
    
    cd ..
    print_success "All services started with PM2"
}

# Display service status
show_status() {
    print_success "=== DEPLOYMENT COMPLETE ==="
    echo ""
    print_status "Service Status:"
    pm2 status
    echo ""
    print_status "Application URLs:"
    echo "🛒 Frontend (Customer):  http://localhost:3000"
    echo "📊 Dashboard (Admin):    http://localhost:3001"
    echo "🔧 Backend API:          http://localhost:5001"
    echo ""
    print_status "Useful Commands:"
    echo "📈 View logs:            pm2 logs"
    echo "🔄 Restart services:     pm2 restart all"
    echo "⏹️  Stop services:        pm2 stop all"
    echo "📋 Service status:       pm2 status"
    echo ""
    print_warning "IMPORTANT: Please edit backend/.env with your actual credentials!"
    print_warning "Default MongoDB credentials: username=admin, password=password"
}

# Main deployment function
main() {
    print_status "Starting MERN Ecommerce Deployment on Ubuntu..."
    echo ""
    
    check_root
    check_directory
    check_ubuntu
    update_system
    install_git
    install_nodejs
    install_mongodb
    install_pm2
    setup_mongodb
    clone_repository
    setup_environment
    install_dependencies
    create_pm2_config
    populate_database
    configure_firewall
    start_services
    show_status
    
    print_success "🎉 Deployment completed successfully!"
}

# Run main function
main "$@"
