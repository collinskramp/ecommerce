#!/bin/bash

# Quick Fix for MERN Ecommerce Deployment Issues
# This script fixes the index.html missing files and path issues

echo "🔧 MERN Ecommerce Quick Fix"
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

# Stop PM2 processes first
echo ""
echo "🛑 Stopping PM2 processes..."
pm2 stop all

# Check if public directories and index.html files exist
echo ""
echo "📁 Checking required files..."

check_file() {
    local file_path="$1"
    local description="$2"
    
    if [[ -f "$file_path" ]]; then
        echo "✅ $description exists"
        return 0
    else
        echo "❌ $description missing: $file_path"
        return 1
    fi
}

# Check frontend files
check_file "$PROJECT_DIR/frontend/public/index.html" "Frontend index.html"
check_file "$PROJECT_DIR/frontend/package.json" "Frontend package.json"

# Check dashboard files  
check_file "$PROJECT_DIR/dashboard/public/index.html" "Dashboard index.html"
check_file "$PROJECT_DIR/dashboard/package.json" "Dashboard package.json"

# Check backend files
check_file "$PROJECT_DIR/backend/server.js" "Backend server.js"
check_file "$PROJECT_DIR/backend/package.json" "Backend package.json"

# Create missing public directories and index.html files if needed
create_missing_files() {
    echo ""
    echo "📝 Creating missing files..."
    
    # Frontend index.html
    if [[ ! -f "$PROJECT_DIR/frontend/public/index.html" ]]; then
        echo "Creating frontend/public/index.html..."
        mkdir -p "$PROJECT_DIR/frontend/public"
        cat > "$PROJECT_DIR/frontend/public/index.html" << 'EOF'
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
        echo "✅ Created frontend/public/index.html"
    fi
    
    # Dashboard index.html
    if [[ ! -f "$PROJECT_DIR/dashboard/public/index.html" ]]; then
        echo "Creating dashboard/public/index.html..."
        mkdir -p "$PROJECT_DIR/dashboard/public"
        cat > "$PROJECT_DIR/dashboard/public/index.html" << 'EOF'
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
        echo "✅ Created dashboard/public/index.html"
    fi
}

create_missing_files

# Create logs directory
echo ""
echo "📋 Setting up logs directory..."
mkdir -p logs
echo "✅ Logs directory created"

# Create a new PM2 ecosystem configuration with absolute paths
echo ""
echo "⚙️  Creating PM2 configuration with absolute paths..."

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
      script: 'npm',
      args: 'start',
      env: {
        PORT: 3000,
        BROWSER: 'none'
      },
      error_file: '$PROJECT_DIR/logs/frontend-error.log',
      out_file: '$PROJECT_DIR/logs/frontend-out.log',
      log_file: '$PROJECT_DIR/logs/frontend-combined.log',
      time: true
    },
    {
      name: 'ecommerce-dashboard',
      cwd: '$PROJECT_DIR/dashboard',
      script: 'npm',
      args: 'start',
      env: {
        PORT: 3001,
        BROWSER: 'none'
      },
      error_file: '$PROJECT_DIR/logs/dashboard-error.log',
      out_file: '$PROJECT_DIR/logs/dashboard-out.log',
      log_file: '$PROJECT_DIR/logs/dashboard-combined.log',
      time: true
    }
  ]
};
EOF

echo "✅ PM2 configuration created with absolute paths"

# Verify all directories exist and have the right files
echo ""
echo "🔍 Final verification..."
echo "Project directory: $PROJECT_DIR"
echo "Frontend: $(ls -la $PROJECT_DIR/frontend/public/index.html 2>/dev/null || echo 'MISSING')"
echo "Dashboard: $(ls -la $PROJECT_DIR/dashboard/public/index.html 2>/dev/null || echo 'MISSING')"
echo "Backend: $(ls -la $PROJECT_DIR/backend/server.js 2>/dev/null || echo 'MISSING')"

# Delete any existing PM2 processes
echo ""
echo "🧹 Cleaning up existing PM2 processes..."
pm2 delete all 2>/dev/null || echo "No processes to delete"

# Start services with the new configuration
echo ""
echo "🚀 Starting services with PM2..."
pm2 start ecosystem.config.js

# Wait a moment for services to start
sleep 5

# Check PM2 status
echo ""
echo "📊 PM2 Status:"
pm2 status

# Test connections
echo ""
echo "🧪 Testing connections..."

test_connection() {
    local url="$1"
    local name="$2"
    local timeout=5
    
    if curl -s --connect-timeout $timeout "$url" > /dev/null 2>&1; then
        echo "✅ $name: $url - OK"
    else
        echo "❌ $name: $url - FAILED"
    fi
}

test_connection "http://localhost:5001" "Backend API"
test_connection "http://localhost:3000" "Frontend"
test_connection "http://localhost:3001" "Dashboard"

echo ""
echo "🏁 Quick fix completed!"
echo ""
echo "📋 Next steps:"
echo "- Check 'pm2 logs' for any errors"
echo "- Visit http://localhost:3000 for frontend"
echo "- Visit http://localhost:3001 for dashboard"
echo "- Visit http://localhost:5001 for backend API"
echo ""
echo "If you still have issues:"
echo "- Run: pm2 logs"
echo "- Run: pm2 restart all"
echo "- Check firewall: sudo ufw status"
