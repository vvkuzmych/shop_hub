#!/bin/bash

# ShopHub API - Shopping Cart Test Script
# Requires: Run 1_auth.sh first to get token
# Usage: ./scripts/api_tests/3_cart.sh

BASE_URL="http://localhost:3000"

# Get token from previous auth test
if [ -f /tmp/shophub_token.txt ]; then
  TOKEN=$(cat /tmp/shophub_token.txt)
else
  echo "❌ No token found. Run ./scripts/api_tests/1_auth.sh first!"
  exit 1
fi

echo "=========================================="
echo "ShopHub API - Shopping Cart Test"
echo "=========================================="
echo "🔑 Using saved token"
echo ""

# Get first product ID for testing
PRODUCTS=$(curl -s "$BASE_URL/api/v1/products")
PRODUCT_ID=$(echo "$PRODUCTS" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data'][0]['id'])" 2>/dev/null)

if [ -z "$PRODUCT_ID" ]; then
  echo "❌ No products found. Run db:seed first!"
  exit 1
fi

echo "📦 Using Product ID: $PRODUCT_ID"
echo ""

# 1. View Empty Cart
echo "1️⃣  Viewing Cart (should be empty)..."
CART=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$BASE_URL/api/v1/cart/items" \
  -H "Authorization: $TOKEN")
STATUS=$(echo "$CART" | grep HTTP_STATUS | cut -d: -f2)
BODY=$(echo "$CART" | sed '/HTTP_STATUS/d')

if [ "$STATUS" = "200" ]; then
  echo "✅ Cart retrieved!"
  echo "$BODY" | python3 -m json.tool 2>/dev/null
else
  echo "❌ Failed (Status: $STATUS)"
fi

echo ""
echo "----------------------------------------"
echo ""

# 2. Add Item to Cart
echo "2️⃣  Adding Product to Cart..."
ADD_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$BASE_URL/api/v1/cart/add_item" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"product_id\": $PRODUCT_ID,
    \"quantity\": 2
  }")

ADD_STATUS=$(echo "$ADD_RESPONSE" | grep HTTP_STATUS | cut -d: -f2)
ADD_BODY=$(echo "$ADD_RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$ADD_STATUS" = "200" ]; then
  echo "✅ Item added to cart!"
  echo "$ADD_BODY" | python3 -m json.tool 2>/dev/null
else
  echo "❌ Failed (Status: $ADD_STATUS)"
  echo "$ADD_BODY"
fi

echo ""
echo "----------------------------------------"
echo ""

# 3. View Cart with Items
echo "3️⃣  Viewing Cart (with items)..."
CART_FULL=$(curl -s "$BASE_URL/api/v1/cart/items" \
  -H "Authorization: $TOKEN")
echo "✅ Cart contents:"
echo "$CART_FULL" | python3 -m json.tool 2>/dev/null

echo ""
echo "----------------------------------------"
echo ""

# 4. Update Quantity
echo "4️⃣  Updating Item Quantity..."
UPDATE_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X PATCH "$BASE_URL/api/v1/cart/update_quantity" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"product_id\": $PRODUCT_ID,
    \"quantity\": 5
  }")

UPDATE_STATUS=$(echo "$UPDATE_RESPONSE" | grep HTTP_STATUS | cut -d: -f2)

if [ "$UPDATE_STATUS" = "200" ]; then
  echo "✅ Quantity updated to 5!"
else
  echo "❌ Failed (Status: $UPDATE_STATUS)"
fi

echo ""
echo "----------------------------------------"
echo ""

# 5. Remove Item
echo "5️⃣  Removing Item from Cart..."
REMOVE_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X DELETE "$BASE_URL/api/v1/cart/remove_item" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"product_id\": $PRODUCT_ID
  }")

REMOVE_STATUS=$(echo "$REMOVE_RESPONSE" | grep HTTP_STATUS | cut -d: -f2)

if [ "$REMOVE_STATUS" = "200" ]; then
  echo "✅ Item removed from cart!"
else
  echo "❌ Failed (Status: $REMOVE_STATUS)"
fi

echo ""
echo "=========================================="
echo "✅ Shopping Cart Test Complete!"
echo "=========================================="
echo ""
