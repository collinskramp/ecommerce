#!/bin/bash

# PM2 Management Script for MERN Ecommerce

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

# Check if PM2 is installed
check_pm2() {
    if ! command -v pm2 &> /dev/null; then
        print_error "PM2 is not installed. Installing PM2..."
        npm install -g pm2
        print_success "PM2 installed successfully"
    fi
}

# Create logs directory if it doesn't exist
create_logs_dir() {
    if [ ! -d "logs" ]; then
        mkdir -p logs
        print_status "Created logs directory"
    fi
}

# Start all services
start_all() {
    print_status "Starting all services with PM2..."
    check_pm2
    create_logs_dir
    
    pm2 start ecosystem.config.js
    pm2 save
    
    print_success "All services started successfully!"
    show_status
}

# Stop all services
stop_all() {
    print_status "Stopping all services..."
    pm2 stop all 2>/dev/null || true
    print_success "All services stopped"
}

# Restart all services
restart_all() {
    print_status "Restarting all services..."
    pm2 restart all 2>/dev/null || start_all
    print_success "All services restarted"
}

# Delete all services
delete_all() {
    print_warning "Deleting all PM2 processes..."
    pm2 delete all 2>/dev/null || true
    print_success "All processes deleted"
}

# Show PM2 status
show_status() {
    echo ""
    print_status "PM2 Process Status:"
    pm2 status
    echo ""
    print_status "Application URLs:"
    echo "🛒 Frontend (Customer):  http://localhost:3000"
    echo "📊 Dashboard (Admin):    http://localhost:3001"
    echo "🔧 Backend API:          http://localhost:5001"
}

# Show logs
show_logs() {
    local service=$1
    if [ -z "$service" ]; then
        print_status "Showing logs for all services..."
        pm2 logs
    else
        print_status "Showing logs for $service..."
        pm2 logs "$service"
    fi
}

# Monitor services
monitor() {
    print_status "Opening PM2 monitor..."
    pm2 monit
}

# Start specific service
start_service() {
    local service=$1
    if [ -z "$service" ]; then
        print_error "Please specify a service: backend, frontend, or dashboard"
        return 1
    fi
    
    case $service in
        backend)
            pm2 start ecosystem.config.js --only ecommerce-backend
            ;;
        frontend)
            pm2 start ecosystem.config.js --only ecommerce-frontend
            ;;
        dashboard)
            pm2 start ecosystem.config.js --only ecommerce-dashboard
            ;;
        *)
            print_error "Invalid service: $service. Use: backend, frontend, or dashboard"
            return 1
            ;;
    esac
    
    print_success "$service started successfully"
}

# Restart specific service
restart_service() {
    local service=$1
    if [ -z "$service" ]; then
        print_error "Please specify a service: backend, frontend, or dashboard"
        return 1
    fi
    
    pm2 restart "ecommerce-$service" 2>/dev/null || start_service "$service"
    print_success "$service restarted successfully"
}

# Stop specific service
stop_service() {
    local service=$1
    if [ -z "$service" ]; then
        print_error "Please specify a service: backend, frontend, or dashboard"
        return 1
    fi
    
    pm2 stop "ecommerce-$service"
    print_success "$service stopped successfully"
}

# Setup PM2 startup
setup_startup() {
    print_status "Setting up PM2 startup script..."
    pm2 startup
    print_warning "Run the command above with sudo to complete startup setup"
}

# Show help
show_help() {
    echo "PM2 Management Script for MERN Ecommerce"
    echo ""
    echo "Usage: $0 [COMMAND] [SERVICE]"
    echo ""
    echo "Commands:"
    echo "  start           Start all services"
    echo "  stop            Stop all services"
    echo "  restart         Restart all services"
    echo "  delete          Delete all PM2 processes"
    echo "  status          Show PM2 status"
    echo "  logs [service]  Show logs (all or specific service)"
    echo "  monitor         Open PM2 monitor"
    echo "  startup         Setup PM2 startup script"
    echo ""
    echo "Service-specific commands:"
    echo "  start [service]     Start specific service"
    echo "  restart [service]   Restart specific service"
    echo "  stop [service]      Stop specific service"
    echo ""
    echo "Services: backend, frontend, dashboard"
    echo ""
    echo "Examples:"
    echo "  $0 start                    # Start all services"
    echo "  $0 restart frontend         # Restart only frontend"
    echo "  $0 logs backend            # Show backend logs"
    echo "  $0 status                  # Show PM2 status"
}

# Main script logic
case "${1:-}" in
    start)
        if [ -n "${2:-}" ]; then
            start_service "$2"
        else
            start_all
        fi
        ;;
    stop)
        if [ -n "${2:-}" ]; then
            stop_service "$2"
        else
            stop_all
        fi
        ;;
    restart)
        if [ -n "${2:-}" ]; then
            restart_service "$2"
        else
            restart_all
        fi
        ;;
    delete)
        delete_all
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs "${2:-}"
        ;;
    monitor)
        monitor
        ;;
    startup)
        setup_startup
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        print_warning "No command specified. Starting all services..."
        start_all
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
