#!/bin/bash

# Quick Fix for Permission Issues
# Run this to fix the current deployment issue

set -e

# Colors
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

print_status "Fixing deployment permission issues..."

# Check current location
print_status "Current directory: $(pwd)"
print_status "Current user: $(whoami)"

# If we're in /var/www, fix permissions or move
if [[ $(pwd) == /var/www* ]]; then
    print_warning "You're in /var/www which requires root permissions."
    print_status "Option 1: Fix directory permissions (recommended)"
    print_status "Option 2: Move to home directory"
    echo ""
    print_status "Choose option (1 or 2): "
    read -r OPTION
    
    case $OPTION in
        1)
            print_status "Fixing /var/www permissions..."
            sudo chown -R $USER:$USER /var/www/nodeApps/ 2>/dev/null || {
                sudo mkdir -p /var/www/nodeApps/
                sudo chown -R $USER:$USER /var/www/nodeApps/
            }
            print_success "Permissions fixed for /var/www/nodeApps/"
            ;;
        2)
            print_status "Moving to home directory..."
            cd ~
            print_success "Now in: $(pwd)"
            ;;
        *)
            print_warning "Invalid option. Moving to home directory..."
            cd ~
            ;;
    esac
else
    print_success "Current directory permissions are OK"
fi

# Clean up any existing ecommerce directory if it's problematic
if [[ -d "ecommerce" ]] && [[ ! -w "ecommerce" ]]; then
    print_warning "Existing ecommerce directory has permission issues"
    print_status "Removing and will re-clone..."
    sudo rm -rf ecommerce 2>/dev/null || rm -rf ecommerce
fi

# Download and run the deployment script
print_status "Downloading latest deployment script..."
wget -O deploy-ubuntu.sh https://raw.githubusercontent.com/collinskramp/ecommerce/main/deploy-ubuntu.sh
chmod +x deploy-ubuntu.sh

print_success "Ready to deploy!"
print_status "Current directory: $(pwd)"
print_status "Run: ./deploy-ubuntu.sh"

echo ""
print_status "Starting deployment automatically in 3 seconds..."
sleep 3

./deploy-ubuntu.sh
