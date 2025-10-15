#!/bin/bash

# Local Development Setup Script with PM2
# This script sets up and runs the MERN ecommerce project locally

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "================================================================"
echo "  🚀 MERN Ecommerce Local Development Setup"
echo "================================================================"
echo ""

# Check if we're in the right directory
if [ ! -f "package.json" ] && [ ! -d "backend" ]; then
    echo -e "${RED}Error: Please run this script from the project root directory${NC}"
    exit 1
fi

PROJECT_DIR=$(pwd)

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 1. Check Node.js installation
echo -e "${BLUE}[1/8]${NC} Checking Node.js installation..."
if command_exists node; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}✓${NC} Node.js $NODE_VERSION is installed"
else
    echo -e "${RED}✗${NC} Node.js is not installed"
    echo "Please install Node.js from https://nodejs.org/"
    exit 1
fi

# 2. Check MongoDB installation
echo -e "${BLUE}[2/8]${NC} Checking MongoDB installation..."
if command_exists mongod; then
    echo -e "${GREEN}✓${NC} MongoDB is installed"
    
    # Check if MongoDB is running
    if pgrep -x "mongod" > /dev/null; then
        echo -e "${GREEN}✓${NC} MongoDB is already running"
    else
        echo -e "${YELLOW}⚠${NC} MongoDB is not running. Starting it..."
        # For macOS with Homebrew
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if command_exists brew; then
                brew services start mongodb-community 2>/dev/null || brew services start mongodb/brew/mongodb-community 2>/dev/null || {
                    echo -e "${YELLOW}Starting MongoDB manually...${NC}"
                    mongod --config /usr/local/etc/mongod.conf --fork 2>/dev/null || {
                        echo -e "${YELLOW}Starting MongoDB with default config...${NC}"
                        mongod --dbpath ~/data/db --fork --logpath ~/data/log/mongodb.log
                    }
                }
            fi
        else
            # For Linux
            sudo systemctl start mongod 2>/dev/null || mongod --fork --dbpath ~/data/db --logpath ~/data/log/mongodb.log
        fi
        sleep 2
        echo -e "${GREEN}✓${NC} MongoDB started"
    fi
else
    echo -e "${RED}✗${NC} MongoDB is not installed"
    echo "Please install MongoDB:"
    echo "  macOS: brew tap mongodb/brew && brew install mongodb-community"
    echo "  Linux: https://docs.mongodb.com/manual/administration/install-on-linux/"
    exit 1
fi

# 3. Install PM2
echo -e "${BLUE}[3/8]${NC} Checking PM2 installation..."
if command_exists pm2; then
    echo -e "${GREEN}✓${NC} PM2 is already installed"
else
    echo -e "${YELLOW}⚠${NC} Installing PM2 globally..."
    npm install -g pm2
    echo -e "${GREEN}✓${NC} PM2 installed"
fi

# 4. Install Backend Dependencies
echo -e "${BLUE}[4/8]${NC} Installing backend dependencies..."
cd "$PROJECT_DIR/backend"
if [ ! -d "node_modules" ]; then
    npm install
    echo -e "${GREEN}✓${NC} Backend dependencies installed"
else
    echo -e "${GREEN}✓${NC} Backend dependencies already installed"
fi

# 5. Install Frontend Dependencies
echo -e "${BLUE}[5/8]${NC} Installing frontend dependencies..."
cd "$PROJECT_DIR/frontend"
if [ ! -d "node_modules" ]; then
    npm install
    echo -e "${GREEN}✓${NC} Frontend dependencies installed"
else
    echo -e "${GREEN}✓${NC} Frontend dependencies already installed"
fi

# 6. Install Dashboard Dependencies
echo -e "${BLUE}[6/8]${NC} Installing dashboard dependencies..."
cd "$PROJECT_DIR/dashboard"
if [ ! -d "node_modules" ]; then
    npm install
    echo -e "${GREEN}✓${NC} Dashboard dependencies installed"
else
    echo -e "${GREEN}✓${NC} Dashboard dependencies already installed"
fi

# 7. Setup Environment Variables
echo -e "${BLUE}[7/8]${NC} Setting up environment variables..."
cd "$PROJECT_DIR"
if [ ! -f "backend/.env" ]; then
    echo -e "${YELLOW}⚠${NC} Creating backend/.env file..."
    cat > backend/.env << 'EOF'
PORT=5001
DB_URL=mongodb://127.0.0.1:27017/ec
SECRET=your_jwt_secret_change_in_production
cloud_name=your_cloudinary_cloud_name
api_key=your_cloudinary_api_key
api_secret=your_cloudinary_api_secret
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key_here
EOF
    echo -e "${GREEN}✓${NC} Environment file created"
    echo -e "${YELLOW}⚠${NC} Please update backend/.env with your actual credentials"
else
    echo -e "${GREEN}✓${NC} Environment file already exists"
fi

# 8. Create PM2 Ecosystem Configuration for Local Development
echo -e "${BLUE}[8/8]${NC} Creating PM2 configuration..."
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [
    {
      name: 'ecommerce-backend',
      script: './backend/server.js',
      cwd: '$PROJECT_DIR',
      instances: 1,
      autorestart: true,
      watch: false,
      env: {
        NODE_ENV: 'development',
        PORT: 5001
      },
      error_file: './logs/backend-error.log',
      out_file: './logs/backend-out.log',
      log_file: './logs/backend-combined.log',
      time: true
    },
    {
      name: 'ecommerce-frontend',
      script: 'npm',
      args: 'start',
      cwd: '$PROJECT_DIR/frontend',
      instances: 1,
      autorestart: true,
      watch: false,
      env: {
        NODE_ENV: 'development',
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
      script: 'npm',
      args: 'start',
      cwd: '$PROJECT_DIR/dashboard',
      instances: 1,
      autorestart: true,
      watch: false,
      env: {
        NODE_ENV: 'development',
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

echo -e "${GREEN}✓${NC} PM2 configuration created"
echo ""

# Stop any existing PM2 processes
echo -e "${BLUE}Stopping existing PM2 processes...${NC}"
pm2 delete all 2>/dev/null || true

# Start services with PM2
echo -e "${BLUE}Starting services with PM2...${NC}"
pm2 start ecosystem.config.js

# Save PM2 configuration
pm2 save

# Wait for services to start
echo -e "${YELLOW}Waiting for services to start...${NC}"
sleep 5

echo ""
echo "================================================================"
echo -e "  ${GREEN}🎉 Setup Complete!${NC}"
echo "================================================================"
echo ""
echo "📊 PM2 Status:"
pm2 list
echo ""
echo "🌐 Access your applications:"
echo "   Frontend:  http://localhost:3000"
echo "   Dashboard: http://localhost:3001"
echo "   Backend:   http://localhost:5001"
echo ""
echo "📝 Useful PM2 Commands:"
echo "   View logs:      pm2 logs"
echo "   View status:    pm2 status"
echo "   Restart all:    pm2 restart all"
echo "   Stop all:       pm2 stop all"
echo "   Delete all:     pm2 delete all"
echo "   Monitor:        pm2 monit"
echo ""
echo "🔧 Configuration:"
echo "   PM2 Config:     $PROJECT_DIR/ecosystem.config.js"
echo "   Backend Env:    $PROJECT_DIR/backend/.env"
echo "   Logs:           $PROJECT_DIR/logs/"
echo ""
echo -e "${YELLOW}💡 Tip:${NC} Run 'pm2 logs' to see real-time logs from all services"
echo ""
