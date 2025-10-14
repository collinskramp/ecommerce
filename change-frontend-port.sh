#!/bin/bash

# Quick Port Change - Use port 3002 for frontend to avoid conflicts
echo "🔧 Changing Frontend to Port 3002"
echo "=================================="

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

echo "✅ Found project at: $PROJECT_DIR"
cd "$PROJECT_DIR"

# Stop PM2 processes
echo ""
echo "🛑 Stopping PM2 processes..."
pm2 stop all

# Create new PM2 config with frontend on port 3002
echo ""
echo "⚙️ Creating PM2 config with frontend on port 3002..."

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
        PORT: 3002,
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

echo "✅ PM2 configuration updated - Frontend now uses port 3002"

# Delete all PM2 processes to ensure clean start
echo ""
echo "🧹 Cleaning up PM2 processes..."
pm2 delete all 2>/dev/null || echo "No processes to delete"

# Make sure logs directory exists
mkdir -p logs

# Start services
echo ""
echo "🚀 Starting services..."
pm2 start ecosystem.config.js

# Wait for services to start
echo ""
echo "⏳ Waiting 10 seconds for services to start..."
sleep 10

# Check PM2 status
echo ""
echo "📊 PM2 Status:"
pm2 status

# Test connections
echo ""
echo "🧪 Testing connections:"
echo "======================"

test_connection() {
    local url="$1"
    local name="$2"
    
    echo -n "Testing $name... "
    if curl -s --connect-timeout 5 "$url" > /dev/null 2>&1; then
        echo "✅ OK"
    else
        echo "❌ FAILED"
    fi
}

test_connection "http://localhost:5001" "Backend API (5001)"
test_connection "http://localhost:3002" "Frontend (3002)"
test_connection "http://localhost:3001" "Dashboard (3001)"

# Show the new URLs
echo ""
echo "🌐 Updated Application URLs:"
echo "============================"
echo "Frontend (Customer):  http://localhost:3002"
echo "Dashboard (Admin):    http://localhost:3001"
echo "Backend API:          http://localhost:5001"

# Get public IP for external access
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "Unable to get public IP")
if [ "$PUBLIC_IP" != "Unable to get public IP" ]; then
    echo ""
    echo "🌍 External Access URLs:"
    echo "========================"
    echo "Frontend:  http://$PUBLIC_IP:3002"
    echo "Dashboard: http://$PUBLIC_IP:3001"
    echo "Backend:   http://$PUBLIC_IP:5001"
    echo ""
    echo "📝 Don't forget to update your firewall:"
    echo "sudo ufw allow 3002"
fi

echo ""
echo "✅ Port change complete!"
echo "Frontend is now running on port 3002 to avoid conflicts."
