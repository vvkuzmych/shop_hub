#!/bin/bash

# ShopHub API - Orders Test Script
# Requires: Run 1_auth.sh first to get token
# Usage: ./scripts/api_tests/4_orders.sh

BASE_URL="http://localhost:3000"

# Get token
if [ -f /tmp/shophub_token.txt ]; then
  TOKEN=$(cat /tmp/shophub_token.txt)
else
  echo "❌ No token found. Run ./scripts/api_tests/1_auth.sh first!"
  exit 1
fi

echo "=========================================="
echo "ShopHub API - Orders Test"
echo "=========================================="
echo ""

# Get products for order
PRODUCTS=$(curl -s "$BASE_URL/api/v1/products?per_page=2")
PRODUCT_ID_1=$(echo "$PRODUCTS" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data'][0]['id'])" 2>/dev/null)
PRODUCT_ID_2=$(echo "$PRODUCTS" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data'][1]['id'])" 2>/dev/null)

if [ -z "$PRODUCT_ID_1" ]; then
  echo "❌ No products found. Run db:seed first!"
  exit 1
fi

echo "📦 Using Products: #$PRODUCT_ID_1, #$PRODUCT_ID_2"
echo ""

# 1. Create Order
echo "1️⃣  Creating Order..."
ORDER_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$BASE_URL/api/v1/orders" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"items\": [
      {
        \"product_id\": $PRODUCT_ID_1,
        \"quantity\": 2
      },
      {
        \"product_id\": $PRODUCT_ID_2,
        \"quantity\": 1
      }
    ]
  }")

ORDER_STATUS=$(echo "$ORDER_RESPONSE" | grep HTTP_STATUS | cut -d: -f2)
ORDER_BODY=$(echo "$ORDER_RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$ORDER_STATUS" = "201" ]; then
  echo "✅ Order created successfully!"
  ORDER_ID=$(echo "$ORDER_BODY" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data']['id'])" 2>/dev/null)
  echo "🆔 Order ID: $ORDER_ID"
  echo "$ORDER_BODY" | python3 -m json.tool 2>/dev/null | grep -A 5 '"attributes"'
else
  echo "❌ Order creation failed (Status: $ORDER_STATUS)"
  echo "$ORDER_BODY" | python3 -m json.tool 2>/dev/null || echo "$ORDER_BODY"
  exit 1
fi

echo ""
echo "----------------------------------------"
echo ""

# 2. View Order History
echo "2️⃣  Viewing Order History..."
ORDERS=$(curl -s "$BASE_URL/api/v1/orders" \
  -H "Authorization: $TOKEN")
echo "✅ Order list retrieved!"
echo "$ORDERS" | python3 -m json.tool 2>/dev/null | head -30

echo ""
echo "----------------------------------------"
echo ""

# 3. View Order Details
echo "3️⃣  Viewing Order Details..."
ORDER_DETAILS=$(curl -s "$BASE_URL/api/v1/orders/$ORDER_ID" \
  -H "Authorization: $TOKEN")
echo "✅ Order #$ORDER_ID details:"
echo "$ORDER_DETAILS" | python3 -m json.tool 2>/dev/null | head -40

echo ""
echo "----------------------------------------"
echo ""

# 4. Cancel Order (if pending)
echo "4️⃣  Canceling Order..."
CANCEL_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X PATCH "$BASE_URL/api/v1/orders/$ORDER_ID/cancel" \
  -H "Authorization: $TOKEN")

CANCEL_STATUS=$(echo "$CANCEL_RESPONSE" | grep HTTP_STATUS | cut -d: -f2)
CANCEL_BODY=$(echo "$CANCEL_RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$CANCEL_STATUS" = "200" ]; then
  echo "✅ Order cancelled!"
  echo "$CANCEL_BODY" | python3 -m json.tool 2>/dev/null | grep '"status"'
else
  echo "ℹ️  Cannot cancel (Status: $CANCEL_STATUS) - might be already processed"
fi

echo ""
echo "=========================================="
echo "✅ Orders Test Complete!"
echo "=========================================="
echo ""
