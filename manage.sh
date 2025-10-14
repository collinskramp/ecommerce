#!/bin/bash

# Ecommerce Project Management Script
# Quick commands for common operations

PROJECT_DIR="/var/www/nodeApps/ecommerce/ecommerce"

case "$1" in
    "status")
        echo "🔍 Project Status"
        echo "================="
        echo "PM2 Processes:"
        pm2 status
        echo ""
        echo "Database Collections:"
        mongosh ec --quiet --eval "
        console.log('Products:', db.products.countDocuments());
        console.log('Categories:', db.categorys.countDocuments());
        console.log('Banners:', db.banners.countDocuments());
        console.log('Customers:', db.customers.countDocuments());
        console.log('Sellers:', db.sellers.countDocuments());
        "
        ;;
    "logs")
        pm2 logs ${2:-""} --lines ${3:-50}
        ;;
    "restart")
        echo "🔄 Restarting services..."
        pm2 restart all --update-env
        echo "✅ Services restarted"
        ;;
    "stop")
        echo "🛑 Stopping services..."
        pm2 stop all
        echo "✅ Services stopped"
        ;;
    "start")
        echo "▶️ Starting services..."
        cd $PROJECT_DIR
        pm2 start ecosystem.config.js
        echo "✅ Services started"
        ;;
    "update")
        echo "📦 Updating project..."
        cd $PROJECT_DIR
        git pull origin main
        pm2 restart all --update-env
        echo "✅ Project updated"
        ;;
    "populate")
        echo "🗄️ Populating database..."
        cd $PROJECT_DIR
        if [ -f "populate_products_only.js" ]; then
            node populate_products_only.js
        else
            echo "No populate script found"
        fi
        ;;
    "clean-logs")
        echo "🧹 Cleaning logs..."
        pm2 flush
        echo "✅ Logs cleaned"
        ;;
    *)
        echo "🛠️ Ecommerce Management Commands"
        echo "================================"
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  status      - Show project status"
        echo "  logs [app]  - View logs (optionally for specific app)"
        echo "  restart     - Restart all services"
        echo "  stop        - Stop all services"
        echo "  start       - Start all services"
        echo "  update      - Pull latest code and restart"
        echo "  populate    - Populate database with sample data"
        echo "  clean-logs  - Clear all PM2 logs"
        echo ""
        echo "Examples:"
        echo "  $0 status"
        echo "  $0 logs ecommerce-backend"
        echo "  $0 restart"
        ;;
esac
