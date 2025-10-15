#!/bin/bash

# Quick Start Script - Install and Run with PM2 (No MongoDB Check)
# Use this if you're using MongoDB Atlas or have MongoDB already configured

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🚀 Quick Start with PM2"
echo ""

PROJECT_DIR=$(pwd)

# Check PM2
echo -e "${BLUE}[1/5]${NC} Checking PM2..."
if ! command -v pm2 &> /dev/null; then
    echo "Installing PM2..."
    npm install -g pm2
fi
echo -e "${GREEN}✓${NC} PM2 ready"

# Install dependencies
echo -e "${BLUE}[2/5]${NC} Installing dependencies..."
cd "$PROJECT_DIR/backend" && npm install &
cd "$PROJECT_DIR/frontend" && npm install &
cd "$PROJECT_DIR/dashboard" && npm install &
wait
echo -e "${GREEN}✓${NC} Dependencies installed"

# Setup .env
echo -e "${BLUE}[3/5]${NC} Checking environment..."
cd "$PROJECT_DIR"
if [ ! -f "backend/.env" ]; then
    cat > backend/.env << 'EOF'
PORT=5001
DB_URL=mongodb://127.0.0.1:27017/ec
SECRET=dev_secret_key_change_me
cloud_name=your_cloudinary_name
api_key=your_api_key
api_secret=your_api_secret
STRIPE_SECRET_KEY=sk_test_your_key
EOF
    echo -e "${YELLOW}⚠${NC} Created backend/.env - update with your credentials"
fi

# Create ecosystem config
echo -e "${BLUE}[4/5]${NC} Creating PM2 config..."
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [
    {
      name: 'ecommerce-backend',
      script: './backend/server.js',
      instances: 1,
      env: { NODE_ENV: 'development', PORT: 5001 }
    },
    {
      name: 'ecommerce-frontend',
      script: 'npm',
      args: 'start',
      cwd: './frontend',
      env: { PORT: 3000, BROWSER: 'none' }
    },
    {
      name: 'ecommerce-dashboard',
      script: 'npm',
      args: 'start',
      cwd: './dashboard',
      env: { PORT: 3001, BROWSER: 'none' }
    }
  ]
};
EOF

mkdir -p logs

# Start with PM2
echo -e "${BLUE}[5/5]${NC} Starting services..."
pm2 delete all 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save

echo ""
echo -e "${GREEN}✅ All services started!${NC}"
echo ""
pm2 list
echo ""
echo "🌐 Access:"
echo "   Frontend:  http://localhost:3000"
echo "   Dashboard: http://localhost:3001"
echo "   Backend:   http://localhost:5001"
echo ""
echo "📝 Commands:"
echo "   pm2 logs       - View logs"
echo "   pm2 restart all - Restart"
echo "   pm2 stop all   - Stop"
echo ""
