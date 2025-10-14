#!/bin/bash

# MongoDB Setup Script for MERN Ecommerce
# This script sets up MongoDB with the required admin user and database

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if MongoDB is running
check_mongodb_running() {
    if ! pgrep mongod > /dev/null; then
        print_error "MongoDB is not running. Starting MongoDB..."
        sudo systemctl start mongod
        sleep 3
        
        if ! pgrep mongod > /dev/null; then
            print_error "Failed to start MongoDB. Check systemctl status mongod"
            exit 1
        fi
        print_success "MongoDB started successfully"
    else
        print_success "MongoDB is already running"
    fi
}

# Test basic MongoDB connection
test_basic_connection() {
    print_status "Testing basic MongoDB connection..."
    if mongosh --eval "db.runCommand({ping: 1})" >/dev/null 2>&1; then
        print_success "Basic MongoDB connection successful"
        return 0
    else
        print_error "Cannot connect to MongoDB"
        return 1
    fi
}

# Check if admin user exists
check_admin_user() {
    print_status "Checking if admin user exists..."
    
    # Try to authenticate with existing credentials
    if mongosh ec --authenticationDatabase admin -u admin -p password --eval "db.runCommand({ping: 1})" >/dev/null 2>&1; then
        print_success "Admin user exists and authentication works"
        return 0
    else
        print_warning "Admin user doesn't exist or authentication failed"
        return 1
    fi
}

# Create admin user
create_admin_user() {
    print_status "Creating admin user..."
    
    # Connect without authentication and create user
    mongosh --eval "
    use admin
    try {
        db.dropUser('admin')
        print('Dropped existing admin user')
    } catch(e) {
        print('No existing admin user to drop')
    }
    
    db.createUser({
        user: 'admin',
        pwd: 'password',
        roles: [
            { role: 'userAdminAnyDatabase', db: 'admin' },
            { role: 'readWriteAnyDatabase', db: 'admin' },
            { role: 'dbAdminAnyDatabase', db: 'admin' }
        ]
    })
    print('Admin user created successfully')
    " 2>/dev/null
    
    if [ $? -eq 0 ]; then
        print_success "Admin user created successfully"
    else
        print_error "Failed to create admin user"
        return 1
    fi
}

# Test authentication
test_authentication() {
    print_status "Testing authentication with admin user..."
    
    if mongosh ec --authenticationDatabase admin -u admin -p password --eval "db.runCommand({ping: 1})" >/dev/null 2>&1; then
        print_success "Authentication test successful"
        return 0
    else
        print_error "Authentication test failed"
        return 1
    fi
}

# Create database and test collection
setup_database() {
    print_status "Setting up 'ec' database..."
    
    mongosh ec --authenticationDatabase admin -u admin -p password --eval "
    db.test.insertOne({setup: 'test'})
    db.test.deleteOne({setup: 'test'})
    print('Database ec is ready')
    " >/dev/null 2>&1
    
    if [ $? -eq 0 ]; then
        print_success "Database 'ec' is ready"
    else
        print_warning "Database setup may have issues, but proceeding..."
    fi
}

# Main setup function
main() {
    echo "======================================="
    echo "    MongoDB Setup for MERN Ecommerce"
    echo "======================================="
    echo ""
    
    # Step 1: Check if MongoDB is running
    check_mongodb_running
    
    # Step 2: Test basic connection
    if ! test_basic_connection; then
        print_error "Cannot establish basic connection to MongoDB"
        print_error "Please check: sudo systemctl status mongod"
        exit 1
    fi
    
    # Step 3: Check if admin user exists and works
    if ! check_admin_user; then
        # Step 4: Create admin user if it doesn't exist or doesn't work
        if ! create_admin_user; then
            print_error "Failed to create admin user"
            exit 1
        fi
    fi
    
    # Step 5: Test authentication
    if ! test_authentication; then
        print_error "Authentication still failing after user creation"
        print_error "This may indicate a MongoDB configuration issue"
        exit 1
    fi
    
    # Step 6: Setup database
    setup_database
    
    echo ""
    print_success "MongoDB setup completed successfully!"
    echo ""
    print_status "You can now run the database population script:"
    echo "node populate_database.js"
    echo ""
    print_status "Connection details:"
    echo "Database: ec"
    echo "Username: admin"
    echo "Password: password"
    echo "Auth Database: admin"
    echo "Connection String: mongodb://admin:password@127.0.0.1:27017/ec?authSource=admin"
}

# Run main function
main
