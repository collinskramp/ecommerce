#!/bin/bash

# Fix Node.js Installation Conflict on Ubuntu
# Also fixes MongoDB libssl1.1 dependency issues
# Run this script to resolve conflicts and continue deployment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

# Detect Ubuntu version
detect_ubuntu_version() {
    UBUNTU_VERSION=$(lsb_release -rs)
    print_status "Detected Ubuntu version: $UBUNTU_VERSION"
}

# Fix libssl1.1 dependency for MongoDB on Ubuntu 22.04+
fix_libssl_dependency() {
    print_status "Fixing libssl1.1 dependency for MongoDB..."
    
    if [[ $(echo "$UBUNTU_VERSION >= 22.04" | bc -l) -eq 1 ]]; then
        print_warning "Ubuntu 22.04+ detected. Installing libssl1.1 for MongoDB compatibility..."
        
        # Download and install libssl1.1
        cd /tmp
        wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb
        sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
        rm libssl1.1_1.1.1f-1ubuntu2_amd64.deb
        
        print_success "libssl1.1 installed successfully"
    else
        print_status "Ubuntu version is compatible with MongoDB dependencies"
    fi
}

# Fix Node.js installation conflict
fix_nodejs_conflict() {
    print_status "Fixing Node.js installation conflict..."
    
    # Remove conflicting packages
    print_status "Removing conflicting Node.js packages..."
    sudo apt-get remove --purge -y nodejs nodejs-doc libnode-dev libnode72 npm 2>/dev/null || true
    
    # Clean up any remaining files
    print_status "Cleaning up remaining files..."
    sudo rm -rf /usr/include/node/ 2>/dev/null || true
    sudo rm -rf /usr/lib/node_modules/ 2>/dev/null || true
    sudo rm -rf /usr/share/nodejs/ 2>/dev/null || true
    
    # Fix broken packages
    print_status "Fixing broken packages..."
    sudo apt-get autoremove -y
    sudo apt-get autoclean
    sudo dpkg --configure -a
    
    # Update package lists
    print_status "Updating package lists..."
    sudo apt-get update
    
    print_success "Node.js conflict resolved!"
}

# Install Node.js 18 cleanly
install_nodejs_clean() {
    print_status "Installing Node.js 18 cleanly..."
    
    # Add NodeSource repository
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    
    # Install Node.js
    sudo apt-get install -y nodejs
    
    # Verify installation
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    
    print_success "Node.js installed successfully: $NODE_VERSION"
    print_success "npm installed successfully: $NPM_VERSION"
}

# Install MongoDB with proper dependencies
install_mongodb_fixed() {
    print_status "Installing MongoDB with fixed dependencies..."
    
    # Remove any existing MongoDB packages
    sudo apt-get remove --purge -y mongodb-org* 2>/dev/null || true
    
    # Import MongoDB public GPG key (using new method, not deprecated apt-key)
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-6.0.gpg
    
    # Add MongoDB repository with proper keyring
    echo "deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    
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

# Setup MongoDB authentication
setup_mongodb_auth() {
    print_status "Setting up MongoDB authentication..."
    
    # Check if admin user already exists
    if mongosh --quiet --eval "db.runCommand({usersInfo: 'admin'})" admin 2>/dev/null | grep -q '"users" : \[ \]'; then
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

# Main function
main() {
    print_status "Starting comprehensive conflict resolution..."
    
    detect_ubuntu_version
    fix_libssl_dependency
    fix_nodejs_conflict
    install_nodejs_clean
    install_mongodb_fixed
    setup_mongodb_auth
    
    print_success "All conflicts resolved! Your system is ready for deployment."
    print_status "Node.js version: $(node --version)"
    print_status "npm version: $(npm --version)"
    print_status "MongoDB status: $(sudo systemctl is-active mongod)"
    echo ""
    print_status "You can now run the deployment script: ./deploy-ubuntu.sh"
}

# Run main function
main "$@"
