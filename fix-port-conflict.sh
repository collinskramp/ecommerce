#!/bin/bash

# Port Conflict Fix for MERN Ecommerce
# This script identifies and resolves port conflicts

echo "🔧 Port Conflict Resolution"
echo "==========================="

# Find what's using port 3000
echo ""
echo "🔍 Checking what's using port 3000:"
echo "==================================="
PORT_3000_PROCESS=$(netstat -tulpn | grep :3000 || echo "Nothing found with netstat")
echo "Port 3000 status: $PORT_3000_PROCESS"

# Alternative method using lsof
if command -v lsof &> /dev/null; then
    echo ""
    echo "Using lsof to check port 3000:"
    lsof -i :3000 || echo "Nothing found with lsof"
fi

# Alternative method using ss
echo ""
echo "Using ss to check port 3000:"
ss -tulpn | grep :3000 || echo "Nothing found with ss"

# Check for any node processes
echo ""
echo "🔍 All Node.js processes:"
echo "========================"
ps aux | grep node | grep -v grep || echo "No Node.js processes found"

# Check PM2 processes
echo ""
echo "📊 Current PM2 status:"
echo "====================="
pm2 status

echo ""
echo "🛑 Killing conflicting processes:"
echo "================================="

# Method 1: Kill processes using port 3000
echo "1. Killing processes on port 3000..."
if command -v lsof &> /dev/null; then
    # Get PIDs using port 3000
    PIDS=$(lsof -ti :3000)
    if [ -n "$PIDS" ]; then
        echo "Found PIDs using port 3000: $PIDS"
        for pid in $PIDS; do
            echo "   Killing PID $pid..."
            kill -9 $pid 2>/dev/null || echo "   Could not kill PID $pid"
        done
    else
        echo "   No processes found using port 3000 (lsof)"
    fi
else
    echo "   lsof not available, using alternative method..."
    # Alternative: use netstat and extract PID
    PID=$(netstat -tulpn | grep :3000 | awk '{print $7}' | cut -d'/' -f1)
    if [ -n "$PID" ] && [ "$PID" != "-" ]; then
        echo "   Found PID using port 3000: $PID"
        kill -9 $PID 2>/dev/null || echo "   Could not kill PID $PID"
    else
        echo "   No processes found using port 3000 (netstat)"
    fi
fi

# Method 2: Stop all PM2 processes and clean restart
echo ""
echo "2. Stopping all PM2 processes..."
pm2 stop all
pm2 delete all

# Wait a moment for processes to fully stop
echo "   Waiting 5 seconds for processes to stop..."
sleep 5

# Method 3: Kill any remaining node processes
echo ""
echo "3. Cleaning up any remaining node processes..."
pkill -f "react-scripts" 2>/dev/null || echo "   No react-scripts processes to kill"
pkill -f "node.*3000" 2>/dev/null || echo "   No node processes on port 3000 to kill"

# Verify ports are free
echo ""
echo "🔍 Verifying ports are now free:"
echo "==============================="
echo "Port 3000:"
netstat -tulpn | grep :3000 || echo "✅ Port 3000 is free"

echo "Port 3001:"
netstat -tulpn | grep :3001 || echo "✅ Port 3001 is free"

echo "Port 5001:"
netstat -tulpn | grep :5001 || echo "✅ Port 5001 is free"

# Find the project directory
if [[ -d "ecommerce" ]]; then
    PROJECT_DIR="$(pwd)/ecommerce"
elif [[ -d "/var/www/nodeApps/ecommerce/ecommerce" ]]; then
    PROJECT_DIR="/var/www/nodeApps/ecommerce/ecommerce"
elif [[ -d "$HOME/ecommerce" ]]; then
    PROJECT_DIR="$HOME/ecommerce"
else
    echo "❌ Could not find ecommerce project directory"
    exit 1
fi

echo ""
echo "✅ Found project at: $PROJECT_DIR"
cd "$PROJECT_DIR"

# Create a new PM2 configuration with different port handling
echo ""
echo "⚙️ Creating new PM2 configuration:"
echo "=================================="

cat > ecosystem.config.js << EOF
module.exports = {
  apps: [
    {
      name: 'ecommerce-backend',
      cwd: '$PROJECT_DIR/backend',
      script: 'server.js',
      env: {
        NODE_ENV: 'production',
        PORT: 5001
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: '$PROJECT_DIR/logs/backend-error.log',
      out_file: '$PROJECT_DIR/logs/backend-out.log',
      log_file: '$PROJECT_DIR/logs/backend-combined.log',
      time: true
    },
    {
      name: 'ecommerce-frontend',
      cwd: '$PROJECT_DIR/frontend',
      script: 'node_modules/.bin/react-scripts',
      args: 'start',
      env: {
        PORT: 3000,
        BROWSER: 'none',
        CI: 'true',
        HOST: '0.0.0.0'
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: '$PROJECT_DIR/logs/frontend-error.log',
      out_file: '$PROJECT_DIR/logs/frontend-out.log',
      log_file: '$PROJECT_DIR/logs/frontend-combined.log',
      time: true
    },
    {
      name: 'ecommerce-dashboard',
      cwd: '$PROJECT_DIR/dashboard',
      script: 'node_modules/.bin/react-scripts',
      args: 'start',
      env: {
        PORT: 3001,
        BROWSER: 'none',
        CI: 'true',
        HOST: '0.0.0.0'
      },
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      error_file: '$PROJECT_DIR/logs/dashboard-error.log',
      out_file: '$PROJECT_DIR/logs/dashboard-out.log',
      log_file: '$PROJECT_DIR/logs/dashboard-combined.log',
      time: true
    }
  ]
};
EOF

echo "✅ PM2 configuration created"

# Make sure logs directory exists
mkdir -p logs

# Start services with new configuration
echo ""
echo "🚀 Starting services with clean configuration:"
echo "=============================================="
pm2 start ecosystem.config.js

# Wait for services to start
echo ""
echo "⏳ Waiting 15 seconds for services to start..."
sleep 15

# Check PM2 status
echo ""
echo "📊 PM2 Status:"
echo "=============="
pm2 status

# Check what's now listening on ports
echo ""
echo "🔍 Port status after restart:"
echo "============================="
echo "Port 3000:"
netstat -tulpn | grep :3000 || echo "❌ Nothing listening on port 3000"

echo "Port 3001:"
netstat -tulpn | grep :3001 || echo "❌ Nothing listening on port 3001"

echo "Port 5001:"
netstat -tulpn | grep :5001 || echo "❌ Nothing listening on port 5001"

# Test connections
echo ""
echo "🧪 Testing connections:"
echo "======================"

test_connection() {
    local url="$1"
    local name="$2"
    local timeout=10
    
    echo -n "Testing $name... "
    if curl -s --connect-timeout $timeout "$url" > /dev/null 2>&1; then
        echo "✅ OK"
        return 0
    else
        echo "❌ FAILED"
        return 1
    fi
}

BACKEND_OK=0
FRONTEND_OK=0
DASHBOARD_OK=0

test_connection "http://localhost:5001" "Backend API" && BACKEND_OK=1
test_connection "http://localhost:3000" "Frontend" && FRONTEND_OK=1
test_connection "http://localhost:3001" "Dashboard" && DASHBOARD_OK=1

# Summary
echo ""
echo "📋 Final Summary:"
echo "================="
echo "Backend (5001):  $([ $BACKEND_OK -eq 1 ] && echo "✅ Working" || echo "❌ Failed")"
echo "Frontend (3000): $([ $FRONTEND_OK -eq 1 ] && echo "✅ Working" || echo "❌ Failed")"
echo "Dashboard (3001): $([ $DASHBOARD_OK -eq 1 ] && echo "✅ Working" || echo "❌ Failed")"

if [ $FRONTEND_OK -eq 0 ]; then
    echo ""
    echo "🔍 Frontend still failing. Additional debugging:"
    echo "==============================================="
    echo "Frontend logs (last 5 lines):"
    pm2 logs ecommerce-frontend --lines 5
    
    echo ""
    echo "Manual test command:"
    echo "cd $PROJECT_DIR/frontend && PORT=3000 npm start"
fi

echo ""
echo "🏁 Port conflict resolution complete!"
echo ""
echo "If issues persist:"
echo "1. Check PM2 logs: pm2 logs"
echo "2. Try manual start: cd $PROJECT_DIR/frontend && PORT=3000 npm start"
echo "3. Check firewall: sudo ufw status"
