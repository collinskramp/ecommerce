# Server Setup Instructions

## MongoDB Configuration

This application requires MongoDB without authentication for development. Follow these steps on your server:

### Disable MongoDB Authentication

1. **Edit MongoDB configuration:**
   ```bash
   sudo nano /etc/mongod.conf
   ```

2. **Comment out or remove the security section:**
   ```yaml
   # security:
   #   authorization: enabled
   ```

3. **Restart MongoDB:**
   ```bash
   sudo systemctl restart mongod
   sudo systemctl status mongod
   ```

4. **Verify MongoDB is accessible:**
   ```bash
   mongosh
   show dbs
   exit
   ```

## Environment Setup

1. **Copy the example environment file:**
   ```bash
   cd /var/www/nodeApps/ecommerce/ecommerce/backend
   cp .env.example .env
   ```

2. **Edit .env file and ensure no spaces around `=` signs:**
   ```bash
   nano .env
   ```

   Example:
   ```env
   PORT=5001
   DB_URL=mongodb://127.0.0.1:27017/ec
   SECRET=ecommerce_super_secret_jwt_key_2025_change_in_production
   ```

3. **Restart PM2 with updated environment:**
   ```bash
   cd /var/www/nodeApps/ecommerce/ecommerce
   pm2 restart all --update-env
   ```

## Testing

Test the API endpoints:

```bash
# Test products endpoint
curl http://localhost:5001/api/home/get-products

# Test seller registration
curl -X POST http://localhost:5001/api/seller-register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Seller","email":"test@example.com","password":"password123"}'
```

## Common Issues

### "Authentication failed" errors
- Ensure MongoDB authentication is disabled
- Check `.env` file has no spaces: `DB_URL=mongodb://...` not `DB_URL = mongodb://...`

### "secret or public key must be provided"
- Ensure `.env` file has a valid SECRET value
- Restart PM2 with `--update-env` flag

### Connection refused
- Check if PM2 processes are running: `pm2 status`
- Check if MongoDB is running: `sudo systemctl status mongod`
