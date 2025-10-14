#!/bin/bash

# Quick Development Setup Script for MERN Ecommerce
# For development environment only

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

# Quick setup function
quick_setup() {
    print_status "Quick MERN Ecommerce Setup..."
    
    # Install dependencies if not already installed
    if [[ ! -d "backend/node_modules" ]]; then
        print_status "Installing backend dependencies..."
        cd backend && npm install && cd ..
    fi
    
    if [[ ! -d "frontend/node_modules" ]]; then
        print_status "Installing frontend dependencies..."
        cd frontend && npm install && cd ..
    fi
    
    if [[ ! -d "dashboard/node_modules" ]]; then
        print_status "Installing dashboard dependencies..."
        cd dashboard && npm install && cd ..
    fi
    
    # Setup environment if not exists
    if [[ ! -f "backend/.env" ]]; then
        print_status "Creating .env file..."
        cp backend/.env.example backend/.env
        print_warning "Please edit backend/.env with your credentials!"
    fi
    
    print_success "Setup complete!"
}

# Start development servers
start_dev() {
    print_status "Starting development servers..."
    
    # Function to start a service in background
    start_service() {
        local service=$1
        local port=$2
        local dir=$3
        
        print_status "Starting $service on port $port..."
        cd $dir
        npm start &
        local pid=$!
        echo $pid > ../${service}.pid
        cd ..
        print_success "$service started (PID: $pid)"
    }
    
    # Start all services
    start_service "backend" "5001" "backend"
    sleep 3
    start_service "frontend" "3000" "frontend"
    sleep 3
    start_service "dashboard" "3001" "dashboard"
    
    print_success "All development servers started!"
    echo ""
    echo "🛒 Frontend:  http://localhost:3000"
    echo "📊 Dashboard: http://localhost:3001"
    echo "🔧 Backend:   http://localhost:5001"
    echo ""
    echo "Press Ctrl+C to stop all servers"
    
    # Wait for Ctrl+C
    trap 'stop_dev; exit' INT
    while true; do
        sleep 1
    done
}

# Stop development servers
stop_dev() {
    print_status "Stopping development servers..."
    
    # Kill processes by PID files
    for service in backend frontend dashboard; do
        if [[ -f "${service}.pid" ]]; then
            local pid=$(cat ${service}.pid)
            if ps -p $pid > /dev/null 2>&1; then
                kill $pid
                print_success "$service stopped (PID: $pid)"
            fi
            rm -f ${service}.pid
        fi
    done
    
    # Also kill any remaining npm processes
    pkill -f "npm start" 2>/dev/null || true
    
    print_success "All development servers stopped!"
}

# Status check
check_status() {
    print_status "Checking service status..."
    
    local services=(
        "backend:5001"
        "frontend:3000"
        "dashboard:3001"
    )
    
    for service_port in "${services[@]}"; do
        local service=${service_port%:*}
        local port=${service_port#*:}
        
        if netstat -tlnp 2>/dev/null | grep -q ":$port "; then
            print_success "$service is running on port $port"
        else
            print_warning "$service is not running on port $port"
        fi
    done
}

# Show help
show_help() {
    echo "MERN Ecommerce Development Helper"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  setup     - Install dependencies and setup environment"
    echo "  start     - Start all development servers"
    echo "  stop      - Stop all development servers"
    echo "  restart   - Restart all development servers"
    echo "  status    - Check service status"
    echo "  logs      - Show logs (if using PM2)"
    echo "  help      - Show this help message"
    echo ""
}

# Main logic
case "${1:-help}" in
    "setup")
        quick_setup
        ;;
    "start")
        quick_setup
        start_dev
        ;;
    "stop")
        stop_dev
        ;;
    "restart")
        stop_dev
        sleep 2
        quick_setup
        start_dev
        ;;
    "status")
        check_status
        ;;
    "logs")
        if command -v pm2 &> /dev/null; then
            pm2 logs
        else
            print_warning "PM2 not installed. Use 'tail -f backend/logs/*.log' for manual logs"
        fi
        ;;
    "help"|*)
        show_help
        ;;
esac
