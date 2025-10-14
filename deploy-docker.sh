#!/bin/bash

# Production Deployment Script with Docker
# Sets up the entire MERN stack using Docker containers

set -e

# Colors
RED='\033[0;31m'
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Install Docker and Docker Compose
install_docker() {
    print_status "Installing Docker and Docker Compose..."
    
    if command -v docker &> /dev/null; then
        print_warning "Docker is already installed"
    else
        # Install Docker
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        print_success "Docker installed"
    fi
    
    if command -v docker-compose &> /dev/null; then
        print_warning "Docker Compose is already installed"
    else
        # Install Docker Compose
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
        print_success "Docker Compose installed"
    fi
}

# Create Docker Compose file
create_docker_compose() {
    print_status "Creating Docker Compose configuration..."
    
    cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  mongodb:
    image: mongo:6.0
    container_name: ecommerce-mongodb
    restart: unless-stopped
    ports:
      - "27017:27017"
    environment:
      MONGO_INITDB_ROOT_USERNAME: admin
      MONGO_INITDB_ROOT_PASSWORD: password
      MONGO_INITDB_DATABASE: ec
    volumes:
      - mongodb_data:/data/db
      - ./mongo-init:/docker-entrypoint-initdb.d
    networks:
      - ecommerce-network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: ecommerce-backend
    restart: unless-stopped
    ports:
      - "5001:5001"
    environment:
      - NODE_ENV=production
      - PORT=5001
      - DB_URL=mongodb://admin:password@mongodb:27017/ec?authSource=admin
    depends_on:
      - mongodb
    volumes:
      - ./backend:/app
      - /app/node_modules
    networks:
      - ecommerce-network

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: ecommerce-frontend
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://localhost:5001/api
    volumes:
      - ./frontend:/app
      - /app/node_modules
    networks:
      - ecommerce-network

  dashboard:
    build:
      context: ./dashboard
      dockerfile: Dockerfile
    container_name: ecommerce-dashboard
    restart: unless-stopped
    ports:
      - "3001:3001"
    environment:
      - REACT_APP_API_URL=http://localhost:5001/api
    volumes:
      - ./dashboard:/app
      - /app/node_modules
    networks:
      - ecommerce-network

  nginx:
    image: nginx:alpine
    container_name: ecommerce-nginx
    restart: unless-stopped
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/nginx.conf
      - ./nginx/ssl:/etc/nginx/ssl
    depends_on:
      - backend
      - frontend
      - dashboard
    networks:
      - ecommerce-network

volumes:
  mongodb_data:

networks:
  ecommerce-network:
    driver: bridge
EOF
    
    print_success "Docker Compose file created"
}

# Create Dockerfiles
create_dockerfiles() {
    print_status "Creating Dockerfiles..."
    
    # Backend Dockerfile
    mkdir -p backend
    cat > backend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Expose port
EXPOSE 5001

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:5001/health || exit 1

# Start application
CMD ["npm", "start"]
EOF
    
    # Frontend Dockerfile
    mkdir -p frontend
    cat > frontend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build for production
RUN npm run build

# Install serve to run the build
RUN npm install -g serve

# Expose port
EXPOSE 3000

# Start application
CMD ["serve", "-s", "build", "-l", "3000"]
EOF
    
    # Dashboard Dockerfile
    mkdir -p dashboard
    cat > dashboard/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build for production
RUN npm run build

# Install serve to run the build
RUN npm install -g serve

# Expose port
EXPOSE 3001

# Start application
CMD ["serve", "-s", "build", "-l", "3001"]
EOF
    
    print_success "Dockerfiles created"
}

# Create Nginx configuration
create_nginx_config() {
    print_status "Creating Nginx configuration..."
    
    mkdir -p nginx
    
    cat > nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream backend {
        server backend:5001;
    }
    
    upstream frontend {
        server frontend:3000;
    }
    
    upstream dashboard {
        server dashboard:3001;
    }

    server {
        listen 80;
        server_name localhost;

        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Dashboard
        location /dashboard {
            proxy_pass http://dashboard;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        # Backend API
        location /api {
            proxy_pass http://backend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF
    
    print_success "Nginx configuration created"
}

# Create environment files
create_env_files() {
    print_status "Creating environment files..."
    
    # Backend .env
    cat > backend/.env << 'EOF'
NODE_ENV=production
PORT=5001
DB_URL=mongodb://admin:password@mongodb:27017/ec?authSource=admin
SECRET=your_jwt_secret_change_this_in_production
cloud_name=your_cloudinary_cloud_name
api_key=your_cloudinary_api_key
api_secret=your_cloudinary_api_secret
STRIPE_SECRET_KEY=your_stripe_secret_key_here
EOF
    
    print_warning "Please edit backend/.env with your actual credentials!"
    print_success "Environment files created"
}

# Build and start services
start_production() {
    print_status "Building and starting production services..."
    
    # Build images
    docker-compose build
    
    # Start services
    docker-compose up -d
    
    # Wait for services to be ready
    sleep 30
    
    print_success "Production services started!"
}

# Show status
show_docker_status() {
    print_status "Service Status:"
    docker-compose ps
    echo ""
    print_status "Application URLs:"
    echo "🌐 Full Application:     http://localhost"
    echo "🛒 Frontend:             http://localhost:3000"
    echo "📊 Dashboard:            http://localhost:3001"
    echo "🔧 Backend API:          http://localhost:5001"
    echo ""
    print_status "Docker Commands:"
    echo "📋 Service status:       docker-compose ps"
    echo "📈 View logs:            docker-compose logs"
    echo "🔄 Restart services:     docker-compose restart"
    echo "⏹️  Stop services:        docker-compose down"
    echo "🗑️  Remove everything:    docker-compose down -v"
}

# Main function
main() {
    print_status "Starting Production Deployment with Docker..."
    
    install_docker
    create_docker_compose
    create_dockerfiles
    create_nginx_config
    create_env_files
    start_production
    show_docker_status
    
    print_success "🎉 Production deployment completed!"
    print_warning "IMPORTANT: Edit backend/.env with your actual credentials!"
}

# Handle commands
case "${1:-deploy}" in
    "deploy")
        main
        ;;
    "start")
        docker-compose up -d
        show_docker_status
        ;;
    "stop")
        docker-compose down
        print_success "Services stopped"
        ;;
    "restart")
        docker-compose restart
        show_docker_status
        ;;
    "logs")
        docker-compose logs -f
        ;;
    "status")
        show_docker_status
        ;;
    "clean")
        docker-compose down -v
        docker system prune -f
        print_success "All containers and volumes removed"
        ;;
    *)
        echo "Usage: $0 {deploy|start|stop|restart|logs|status|clean}"
        ;;
esac
