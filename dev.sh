#!/bin/bash

# Development Environment Quick Start
# Simple script to run the MERN stack locally for development

echo "🚀 Starting MERN Ecommerce Development Environment"
echo "=================================================="

# Check if we're in the right directory
if [[ ! -f "backend/package.json" ]] || [[ ! -f "frontend/package.json" ]] || [[ ! -f "dashboard/package.json" ]]; then
    echo "❌ Please run this script from the project root directory"
    echo "Should contain: backend/, frontend/, dashboard/ folders"
    exit 1
fi

# Kill any existing processes on our ports
echo "🧹 Cleaning up existing processes..."
pkill -f "react-scripts" 2>/dev/null || true
pkill -f "node.*server.js" 2>/dev/null || true
lsof -ti:3000,3001,5001 | xargs kill -9 2>/dev/null || true

# Install dependencies if needed
install_if_needed() {
    local dir=$1
    if [[ ! -d "$dir/node_modules" ]]; then
        echo "📦 Installing $dir dependencies..."
        cd "$dir" && npm install && cd ..
    fi
}

install_if_needed "backend"
install_if_needed "frontend"
install_if_needed "dashboard"

# Setup .env if missing
if [[ ! -f "backend/.env" ]]; then
    echo "⚙️ Creating backend/.env file..."
    cp backend/.env.example backend/.env 2>/dev/null || true
    echo "⚠️  Please edit backend/.env with your API keys!"
fi

# Start backend
echo "🔧 Starting backend server..."
cd backend
npm start &
BACKEND_PID=$!
cd ..

sleep 2

# Start frontend on default port 3000
echo "🛒 Starting frontend..."
cd frontend
npm start &
FRONTEND_PID=$!
cd ..

sleep 2

# Start dashboard
echo "📊 Starting dashboard..."
cd dashboard
PORT=3001 npm start &
DASHBOARD_PID=$!
cd ..

echo ""
echo "✅ All services starting..."
echo "🔧 Backend:   http://localhost:5001"
echo "🛒 Frontend:  http://localhost:3000"
echo "📊 Dashboard: http://localhost:3001"
echo ""
echo "💡 Services will auto-reload on file changes"
echo "Press Ctrl+C to stop all services"

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Stopping all services..."
    kill $BACKEND_PID $FRONTEND_PID $DASHBOARD_PID 2>/dev/null || true
    echo "✅ All services stopped"
    exit 0
}

# Set trap for cleanup
trap cleanup INT TERM

# Keep script running
wait
