#!/bin/bash

# Test script for authentication and cart functionality
echo "🧪 Testing Authentication and Cart Functionality"
echo "=============================================="
echo ""

# Test 1: Check if backend is running
echo "1. Testing Backend Health..."
if curl -s http://localhost:5001 >/dev/null 2>&1; then
    echo "✅ Backend is responding"
else
    echo "❌ Backend is not responding"
    exit 1
fi
echo ""

# Test 2: Test user registration
echo "2. Testing User Registration..."
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:5001/api/auth/customer/customer-register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "password": "123456"
  }' \
  -c /tmp/cookies.txt)

if echo "$REGISTER_RESPONSE" | grep -q "error"; then
    echo "⚠️  Registration response: $REGISTER_RESPONSE"
else
    echo "✅ Registration successful"
fi
echo ""

# Test 3: Test user login
echo "3. Testing User Login..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:5001/api/auth/customer/customer-login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "123456"
  }' \
  -c /tmp/cookies.txt)

if echo "$LOGIN_RESPONSE" | grep -q "token"; then
    echo "✅ Login successful"
else
    echo "❌ Login failed: $LOGIN_RESPONSE"
fi
echo ""

# Test 4: Test getting products
echo "4. Testing Product Listing..."
PRODUCTS_RESPONSE=$(curl -s http://localhost:5001/api/home/get-products)
if echo "$PRODUCTS_RESPONSE" | grep -q "products"; then
    echo "✅ Products endpoint working"
else
    echo "❌ Products endpoint failed"
fi
echo ""

# Test 5: Test adding to cart (this is where the toString error might occur)
echo "5. Testing Add to Cart..."
# First get a product ID from products
PRODUCT_ID=$(echo "$PRODUCTS_RESPONSE" | grep -o '"_id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -n "$PRODUCT_ID" ]; then
    echo "   Using product ID: $PRODUCT_ID"
    CART_RESPONSE=$(curl -s -X POST http://localhost:5001/api/home/product/add-to-cart \
      -H "Content-Type: application/json" \
      -b /tmp/cookies.txt \
      -d "{
        \"productId\": \"$PRODUCT_ID\",
        \"quantity\": 1
      }")
    
    if echo "$CART_RESPONSE" | grep -q "error"; then
        echo "❌ Cart add failed: $CART_RESPONSE"
    else
        echo "✅ Add to cart successful"
    fi
else
    echo "⚠️  No products found to test cart functionality"
fi
echo ""

# Test 6: Check PM2 logs for toString errors
echo "6. Checking for toString errors in logs..."
if pm2 logs ecommerce-backend --lines 10 2>/dev/null | grep -q "toString"; then
    echo "⚠️  toString errors still present in logs"
    echo "   Recent log entries:"
    pm2 logs ecommerce-backend --lines 5 2>/dev/null | tail -5
else
    echo "✅ No toString errors found in recent logs"
fi
echo ""

# Cleanup
rm -f /tmp/cookies.txt

echo "🏁 Test completed!"
echo ""
echo "💡 To monitor logs in real-time:"
echo "   pm2 logs ecommerce-backend --lines 0"
echo ""
echo "🔧 To restart backend if needed:"
echo "   pm2 restart ecommerce-backend"
