# Quick Server Fix Guide

## The Problem
- **Local (your Mac)**: Uses Docker MongoDB WITH authentication (`admin:password`)
- **Server**: Uses system MongoDB WITHOUT authentication (no username/password)

## Fix on Server

**Run these commands on your server:**

```bash
# 1. Go to backend directory
cd /var/www/nodeApps/ecommerce/ecommerce/backend

# 2. Update .env file (remove authentication)
cat > .env << 'EOF'
PORT=5001
DB_URL=mongodb://127.0.0.1:27017/ec
SECRET=ecommerce_super_secret_jwt_key_2025_change_in_production
cloud_name=your_cloudinary_cloud_name
api_key=your_cloudinary_api_key
api_secret=your_cloudinary_api_secret
STRIPE_SECRET_KEY=your_stripe_secret_key_here
EOF

# 3. Verify the file (no spaces around = signs)
cat .env

# 4. Completely restart PM2
pm2 delete ecommerce-backend
cd /var/www/nodeApps/ecommerce/ecommerce/backend
pm2 start server.js --name ecommerce-backend

# 5. Check logs
pm2 logs ecommerce-backend --lines 20

# 6. Test
curl http://localhost:5001/api/home/get-products
```

## Test Registration

```bash
curl -X POST http://localhost:5001/api/seller-register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Seller","email":"test@example.com","password":"password123"}'
```

You should see: `{"token":"...","message":"Register Success"}`

## Key Differences

| Environment | MongoDB Setup | DB_URL |
|-------------|--------------|---------|
| **Local (Mac)** | Docker with auth | `mongodb://admin:password@127.0.0.1:27017/ec?authSource=admin` |
| **Server** | System MongoDB (no auth) | `mongodb://127.0.0.1:27017/ec` |
