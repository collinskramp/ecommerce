#!/bin/bash

# Frontend-specific debugging and fix for MERN Ecommerce
# This script focuses on diagnosing and fixing frontend issues

echo "🔍 Frontend Debugging & Fix"
echo "============================"

# Get the current directory
CURRENT_DIR=$(pwd)
echo "Current directory: $CURRENT_DIR"

# Find the ecommerce directory
if [[ -d "ecommerce" ]]; then
    PROJECT_DIR="$CURRENT_DIR/ecommerce"
elif [[ -d "/var/www/nodeApps/ecommerce" ]]; then
    PROJECT_DIR="/var/www/nodeApps/ecommerce"
elif [[ -d "$HOME/ecommerce" ]]; then
    PROJECT_DIR="$HOME/ecommerce"
else
    echo "❌ Could not find ecommerce project directory"
    exit 1
fi

echo "✅ Found project at: $PROJECT_DIR"
cd "$PROJECT_DIR"

# Check frontend PM2 logs specifically
echo ""
echo "📋 Frontend PM2 Logs (last 20 lines):"
echo "======================================"
pm2 logs ecommerce-frontend --lines 20

echo ""
echo "📁 Frontend Directory Structure:"
echo "================================="
echo "Frontend directory contents:"
ls -la "$PROJECT_DIR/frontend/" 2>/dev/null || echo "❌ Frontend directory not found"

echo ""
echo "Frontend public directory:"
ls -la "$PROJECT_DIR/frontend/public/" 2>/dev/null || echo "❌ Frontend public directory not found"

echo ""
echo "📦 Frontend Package.json Check:"
echo "==============================="
if [[ -f "$PROJECT_DIR/frontend/package.json" ]]; then
    echo "✅ package.json exists"
    echo "Scripts section:"
    cat "$PROJECT_DIR/frontend/package.json" | grep -A 10 '"scripts"' | head -15
    echo ""
    echo "Dependencies:"
    cat "$PROJECT_DIR/frontend/package.json" | grep -A 5 '"dependencies"' | head -10
else
    echo "❌ Frontend package.json missing"
fi

echo ""
echo "🌐 Port Check:"
echo "=============="
echo "Checking what's running on port 3000:"
netstat -tulpn | grep :3000 || echo "❌ Nothing listening on port 3000"

echo "Checking what's running on port 3001:"
netstat -tulpn | grep :3001 || echo "❌ Nothing listening on port 3001"

echo "Checking what's running on port 5001:"
netstat -tulpn | grep :5001 || echo "✅ Backend should be here"

# Check if React development server is having issues
echo ""
echo "🔧 React Development Server Diagnostics:"
echo "========================================"

# Check if there are any node processes
echo "Node processes running:"
ps aux | grep node | grep -v grep || echo "❌ No node processes found"

echo ""
echo "React-scripts installation check:"
if [[ -f "$PROJECT_DIR/frontend/node_modules/.bin/react-scripts" ]]; then
    echo "✅ react-scripts is installed"
else
    echo "❌ react-scripts missing - need to reinstall"
fi

# Check for common React issues
echo ""
echo "🔍 Common Issues Check:"
echo "======================"

# Check if node_modules exists
if [[ -d "$PROJECT_DIR/frontend/node_modules" ]]; then
    echo "✅ node_modules exists"
else
    echo "❌ node_modules missing - dependencies not installed"
fi

# Check for src directory
if [[ -d "$PROJECT_DIR/frontend/src" ]]; then
    echo "✅ src directory exists"
    echo "Main src files:"
    ls -la "$PROJECT_DIR/frontend/src/" | head -10
else
    echo "❌ src directory missing"
fi

# Check for App.js or App.jsx
if [[ -f "$PROJECT_DIR/frontend/src/App.js" ]] || [[ -f "$PROJECT_DIR/frontend/src/App.jsx" ]]; then
    echo "✅ App component exists"
else
    echo "❌ App component missing"
fi

# Check for index.js
if [[ -f "$PROJECT_DIR/frontend/src/index.js" ]]; then
    echo "✅ index.js exists"
else
    echo "❌ index.js missing"
fi

echo ""
echo "🛠️  Frontend Fix Attempts:"
echo "=========================="

# Fix 1: Reinstall frontend dependencies
echo "1. Reinstalling frontend dependencies..."
cd "$PROJECT_DIR/frontend"
echo "Current directory: $(pwd)"

# Remove node_modules and package-lock.json to ensure clean install
if [[ -d "node_modules" ]]; then
    echo "   Removing old node_modules..."
    rm -rf node_modules
fi

if [[ -f "package-lock.json" ]]; then
    echo "   Removing package-lock.json..."
    rm -f package-lock.json
fi

echo "   Running npm install..."
npm install

# Check if installation was successful
if [[ -d "node_modules" ]]; then
    echo "✅ Dependencies reinstalled successfully"
else
    echo "❌ Dependency installation failed"
fi

cd "$PROJECT_DIR"

# Fix 2: Create a simple test to verify React can start
echo ""
echo "2. Testing React start capability..."
cd "$PROJECT_DIR/frontend"

# Try to start react-scripts directly (with timeout)
echo "   Testing react-scripts start..."
timeout 30s npm start &
START_PID=$!

sleep 10
if kill -0 $START_PID 2>/dev/null; then
    echo "✅ React server started successfully"
    kill $START_PID 2>/dev/null
else
    echo "❌ React server failed to start"
fi

cd "$PROJECT_DIR"

# Fix 3: Update PM2 configuration for frontend specifically
echo ""
echo "3. Creating optimized PM2 configuration for frontend..."

# Create a new ecosystem config with more detailed frontend setup
cat > ecosystem.config.js << EOF
module.exports = {
  apps: [
    {
      name: 'ecommerce-backend',
      cwd: '$PROJECT_DIR/backend',
      script: 'npm',
      args: 'start',
      env: {
        NODE_ENV: 'production',
        PORT: 5001
      },
      error_file: '$PROJECT_DIR/logs/backend-error.log',
      out_file: '$PROJECT_DIR/logs/backend-out.log',
      log_file: '$PROJECT_DIR/logs/backend-combined.log',
      time: true
    },
    {
      name: 'ecommerce-frontend',
      cwd: '$PROJECT_DIR/frontend',
      script: './node_modules/.bin/react-scripts',
      args: 'start',
      env: {
        PORT: 3000,
        BROWSER: 'none',
        CI: 'true',
        FORCE_COLOR: '0'
      },
      error_file: '$PROJECT_DIR/logs/frontend-error.log',
      out_file: '$PROJECT_DIR/logs/frontend-out.log',
      log_file: '$PROJECT_DIR/logs/frontend-combined.log',
      time: true,
      max_memory_restart: '1G'
    },
    {
      name: 'ecommerce-dashboard',
      cwd: '$PROJECT_DIR/dashboard',
      script: './node_modules/.bin/react-scripts',
      args: 'start',
      env: {
        PORT: 3001,
        BROWSER: 'none',
        CI: 'true',
        FORCE_COLOR: '0'
      },
      error_file: '$PROJECT_DIR/logs/dashboard-error.log',
      out_file: '$PROJECT_DIR/logs/dashboard-out.log',
      log_file: '$PROJECT_DIR/logs/dashboard-combined.log',
      time: true,
      max_memory_restart: '1G'
    }
  ]
};
EOF

echo "✅ Updated PM2 configuration with direct react-scripts execution"

# Fix 4: Restart with new configuration
echo ""
echo "4. Restarting services with new configuration..."

# Stop all processes
pm2 delete all 2>/dev/null || echo "No processes to delete"

# Start with new config
pm2 start ecosystem.config.js

echo ""
echo "5. Waiting for services to start..."
sleep 15

# Check status
echo ""
echo "📊 Updated PM2 Status:"
pm2 status

# Test connections again
echo ""
echo "🧪 Connection Tests:"
echo "==================="

test_connection() {
    local url="\$1"
    local name="\$2"
    local timeout=10
    
    echo -n "Testing \$name... "
    if curl -s --connect-timeout \$timeout "\$url" > /dev/null 2>&1; then
        echo "✅ OK"
    else
        echo "❌ FAILED"
        # Try to get more specific error
        curl -s --connect-timeout \$timeout "\$url" 2>&1 | head -1
    fi
}

test_connection "http://localhost:5001" "Backend API"
test_connection "http://localhost:3000" "Frontend"
test_connection "http://localhost:3001" "Dashboard"

echo ""
echo "📋 Final Status:"
echo "================"
echo "If frontend is still failing:"
echo "1. Check logs: pm2 logs ecommerce-frontend"
echo "2. Manual test: cd \$PROJECT_DIR/frontend && npm start"
echo "3. Check firewall: sudo ufw status"
echo "4. Verify React dependencies: cd \$PROJECT_DIR/frontend && npm ls react-scripts"

echo ""
echo "🏁 Frontend debugging complete!"
