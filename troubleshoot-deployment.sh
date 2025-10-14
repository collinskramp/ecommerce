#!/bin/bash

# Troubleshoot Ubuntu Deployment - MERN Ecommerce
# Run this script on your Ubuntu server to diagnose and fix connection issues

echo "🔍 MERN Ecommerce Deployment Troubleshooting"
echo "=============================================="

# Check PM2 status
echo ""
echo "📊 Current PM2 Status:"
pm2 status

# Check if processes are actually listening on ports
echo ""
echo "🔌 Port Status Check:"
echo "Backend (Port 5001):"
netstat -tulpn | grep :5001 || echo "❌ Port 5001 not listening"

echo "Frontend (Port 3000):"
netstat -tulpn | grep :3000 || echo "❌ Port 3000 not listening"

echo "Dashboard (Port 3001):"
netstat -tulpn | grep :3001 || echo "❌ Port 3001 not listening"

# Check PM2 logs for errors
echo ""
echo "📋 Recent PM2 Logs (last 10 lines):"
pm2 logs --lines 10

# Check if MongoDB is running
echo ""
echo "🗄️  MongoDB Status:"
systemctl status mongod --no-pager || echo "❌ MongoDB service check failed"

# Check firewall status
echo ""
echo "🔥 Firewall Status:"
sudo ufw status || echo "❌ UFW status check failed"

# Check if Node.js processes are running
echo ""
echo "🔄 Node.js Processes:"
ps aux | grep node | grep -v grep || echo "❌ No Node.js processes found"

# Test local connections
echo ""
echo "🧪 Local Connection Tests:"
echo "Testing backend API..."
curl -s http://localhost:5001/api/test || curl -s http://localhost:5001 || echo "❌ Backend connection failed"

echo ""
echo "Testing frontend..."
curl -s -I http://localhost:3000 | head -1 || echo "❌ Frontend connection failed"

echo ""
echo "Testing dashboard..."
curl -s -I http://localhost:3001 | head -1 || echo "❌ Dashboard connection failed"

# Check environment files
echo ""
echo "📁 Environment Files Check:"
if [ -f "backend/.env" ]; then
    echo "✅ backend/.env exists"
    echo "Environment variables configured:"
    grep -E "^[A-Z_]+" backend/.env | head -5
else
    echo "❌ backend/.env missing"
fi

# Memory and disk check
echo ""
echo "💾 System Resources:"
echo "Memory usage:"
free -h

echo ""
echo "Disk usage:"
df -h /

# Detailed PM2 info
echo ""
echo "🔍 Detailed PM2 Info:"
pm2 describe all

echo ""
echo "🔧 TROUBLESHOOTING STEPS:"
echo "========================"

# Check for common issues and provide fixes
if ! netstat -tulpn | grep -q :3000; then
    echo "❌ Frontend not listening on port 3000"
    echo "💡 Try: pm2 restart ecommerce-frontend"
fi

if ! netstat -tulpn | grep -q :5001; then
    echo "❌ Backend not listening on port 5001"
    echo "💡 Try: pm2 restart ecommerce-backend"
fi

if ! netstat -tulpn | grep -q :3001; then
    echo "❌ Dashboard not listening on port 3001"
    echo "💡 Try: pm2 restart ecommerce-dashboard"
fi

echo ""
echo "🚀 Quick Fix Commands:"
echo "====================="
echo "Restart all services:     pm2 restart all"
echo "View detailed logs:       pm2 logs"
echo "Stop all services:        pm2 stop all"
echo "Start all services:       pm2 start all"
echo "Delete and restart:       pm2 delete all && pm2 start ecosystem.config.js"

# Check if ecosystem.config.js exists
if [ -f "ecosystem.config.js" ]; then
    echo "✅ ecosystem.config.js found"
else
    echo "❌ ecosystem.config.js missing - creating one..."
    cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'ecommerce-backend',
      script: 'backend/server.js',
      cwd: '.',
      env: {
        NODE_ENV: 'production',
        PORT: 5001
      }
    },
    {
      name: 'ecommerce-frontend',
      script: 'npm',
      args: 'start',
      cwd: './frontend',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      }
    },
    {
      name: 'ecommerce-dashboard',
      script: 'npm',
      args: 'start',
      cwd: './dashboard',
      env: {
        NODE_ENV: 'production',
        PORT: 3001
      }
    }
  ]
};
EOF
    echo "✅ Created ecosystem.config.js"
fi

echo ""
echo "🌐 External Access Setup:"
echo "========================="
echo "If you need external access (not just localhost):"
echo "1. Check AWS Security Groups allow ports 3000, 3001, 5001"
echo "2. Update UFW: sudo ufw allow 3000 && sudo ufw allow 3001 && sudo ufw allow 5001"
echo "3. Use public IP instead of localhost for external access"

# Get public IP
PUBLIC_IP=$(curl -s ifconfig.me || curl -s ipinfo.io/ip || echo "Unable to get public IP")
if [ "$PUBLIC_IP" != "Unable to get public IP" ]; then
    echo ""
    echo "🌍 Your Public IP: $PUBLIC_IP"
    echo "External URLs would be:"
    echo "Frontend:  http://$PUBLIC_IP:3000"
    echo "Dashboard: http://$PUBLIC_IP:3001"
    echo "Backend:   http://$PUBLIC_IP:5001"
fi

echo ""
echo "✅ Troubleshooting complete!"
echo "Run the suggested commands above to fix any issues found."
