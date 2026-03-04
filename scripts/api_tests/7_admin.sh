#!/bin/bash

# ShopHub API - Admin Operations Test Script
# Requires: Admin user in database
# Usage: ./scripts/api_tests/7_admin.sh [admin_email] [admin_password]

BASE_URL="http://localhost:3000"

# Use provided credentials or defaults
ADMIN_EMAIL="${1:-admin@shophub.com}"
ADMIN_PASSWORD="${2:-password123}"

echo "=========================================="
echo "ShopHub API - Admin Operations Test"
echo "=========================================="
echo ""

# 1. Admin Login
echo "1️⃣  Logging in as Admin..."
LOGIN=$(curl -s -i -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"user\": {
      \"email\": \"$ADMIN_EMAIL\",
      \"password\": \"$ADMIN_PASSWORD\"
    }
  }")

ADMIN_TOKEN=$(echo "$LOGIN" | grep -i "^authorization:" | cut -d' ' -f2- | tr -d '\r')

if [ -z "$ADMIN_TOKEN" ]; then
  echo "❌ Admin login failed!"
  echo "Usage: $0 [admin_email] [admin_password]"
  echo "Or create admin user first:"
  echo "  User.create!(email: 'admin@shophub.com', password: 'password123', role: :admin)"
  exit 1
fi

echo "✅ Admin logged in!"
echo ""

# 2. View All Users
echo "2️⃣  Viewing All Users (Admin)..."
USERS=$(curl -s "$BASE_URL/api/v1/admin/users" \
  -H "Authorization: $ADMIN_TOKEN")
USER_COUNT=$(echo "$USERS" | grep -o '"id"' | wc -l)
echo "✅ Total users: $USER_COUNT"
echo "$USERS" | python3 -m json.tool 2>/dev/null | grep -E '"email"|"role"' | head -10

echo ""
echo "----------------------------------------"
echo ""

# 3. View All Orders
echo "3️⃣  Viewing All Orders (Admin)..."
ORDERS=$(curl -s "$BASE_URL/api/v1/admin/orders" \
  -H "Authorization: $ADMIN_TOKEN")
ORDER_COUNT=$(echo "$ORDERS" | grep -o '"id"' | wc -l)
echo "✅ Total orders: $ORDER_COUNT"
echo "$ORDERS" | python3 -m json.tool 2>/dev/null | head -30

echo ""
echo "----------------------------------------"
echo ""

# 4. Create New Product
echo "4️⃣  Creating New Product (Admin)..."
CATEGORIES=$(curl -s "$BASE_URL/api/v1/categories")
CATEGORY_ID=$(echo "$CATEGORIES" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data'][0]['id'])" 2>/dev/null)

NEW_PRODUCT=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$BASE_URL/api/v1/admin/products" \
  -H "Authorization: $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"product\": {
      \"name\": \"Test Product $(date +%s)\",
      \"description\": \"Created via admin API test\",
      \"price\": 99.99,
      \"stock\": 50,
      \"sku\": \"TEST-$(date +%s)\",
      \"category_id\": $CATEGORY_ID,
      \"active\": true,
      \"featured\": false
    }
  }")

PRODUCT_STATUS=$(echo "$NEW_PRODUCT" | grep HTTP_STATUS | cut -d: -f2)
PRODUCT_BODY=$(echo "$NEW_PRODUCT" | sed '/HTTP_STATUS/d')

if [ "$PRODUCT_STATUS" = "201" ]; then
  echo "✅ Product created!"
  NEW_PRODUCT_ID=$(echo "$PRODUCT_BODY" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data']['id'])" 2>/dev/null)
  echo "🆔 Product ID: $NEW_PRODUCT_ID"
  echo "$PRODUCT_BODY" | python3 -m json.tool 2>/dev/null | grep -A 10 '"attributes"'
else
  echo "❌ Product creation failed (Status: $PRODUCT_STATUS)"
  echo "$PRODUCT_BODY"
fi

echo ""
echo "----------------------------------------"
echo ""

# 5. Update Order Status
if [ "$ORDER_COUNT" -gt 0 ]; then
  echo "5️⃣  Updating Order Status (Admin)..."
  ORDER_ID=$(echo "$ORDERS" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data'][0]['id'])" 2>/dev/null)
  
  UPDATE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X PATCH "$BASE_URL/api/v1/admin/orders/$ORDER_ID" \
    -H "Authorization: $ADMIN_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"order\": {
        \"status\": \"confirmed\"
      }
    }")
  
  UPDATE_STATUS=$(echo "$UPDATE" | grep HTTP_STATUS | cut -d: -f2)
  
  if [ "$UPDATE_STATUS" = "200" ]; then
    echo "✅ Order #$ORDER_ID status updated to 'confirmed'"
  else
    echo "ℹ️  Status: $UPDATE_STATUS"
  fi
else
  echo "5️⃣  No orders to update"
fi

echo ""
echo "=========================================="
echo "✅ Admin Operations Test Complete!"
echo "=========================================="
echo ""
echo "Tested:"
echo "  ✅ Admin authentication"
echo "  ✅ User management"
echo "  ✅ Order management"
echo "  ✅ Product creation"
echo "  ✅ Order status updates"
echo ""
