#!/bin/bash

# ShopHub API - Products Test Script
# Usage: ./scripts/api_tests/2_products.sh

BASE_URL="http://localhost:3000"

echo "=========================================="
echo "ShopHub API - Products Test"
echo "=========================================="
echo ""

# 1. List Products
echo "1️⃣  Testing Product List..."
PRODUCTS=$(curl -s -w "\nHTTP_STATUS:%{http_code}" "$BASE_URL/api/v1/products")
STATUS=$(echo "$PRODUCTS" | grep HTTP_STATUS | cut -d: -f2)
BODY=$(echo "$PRODUCTS" | sed '/HTTP_STATUS/d')

if [ "$STATUS" = "200" ]; then
  echo "✅ Product list retrieved!"
  COUNT=$(echo "$BODY" | grep -o '"id"' | wc -l)
  echo "📦 Found $COUNT products"
  echo "$BODY" | python3 -m json.tool 2>/dev/null | head -30
else
  echo "❌ Failed (Status: $STATUS)"
fi

echo ""
echo "----------------------------------------"
echo ""

# 2. Search Products
echo "2️⃣  Testing Product Search..."
SEARCH=$(curl -s "$BASE_URL/api/v1/products/search?q=laptop")
echo "🔍 Searching for 'laptop'..."
echo "$SEARCH" | python3 -m json.tool 2>/dev/null | grep -A 5 '"name"' | head -10

echo ""
echo "----------------------------------------"
echo ""

# 3. Featured Products
echo "3️⃣  Testing Featured Products..."
FEATURED=$(curl -s "$BASE_URL/api/v1/products/featured?limit=5")
echo "⭐ Getting featured products..."
echo "$FEATURED" | python3 -m json.tool 2>/dev/null | grep -A 3 '"attributes"' | head -15

echo ""
echo "----------------------------------------"
echo ""

# 4. Filter by Price
echo "4️⃣  Testing Price Filter..."
FILTERED=$(curl -s "$BASE_URL/api/v1/products?min_price=20&max_price=100&in_stock=true")
echo "💰 Products between $20-$100 (in stock)..."
echo "$FILTERED" | python3 -m json.tool 2>/dev/null | grep -E '"name"|"price"' | head -20

echo ""
echo "----------------------------------------"
echo ""

# 5. Get Product Details
echo "5️⃣  Testing Product Details..."
PRODUCT_ID=$(echo "$BODY" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data'][0]['id'])" 2>/dev/null)

if [ ! -z "$PRODUCT_ID" ]; then
  DETAILS=$(curl -s "$BASE_URL/api/v1/products/$PRODUCT_ID")
  echo "📋 Product #$PRODUCT_ID details:"
  echo "$DETAILS" | python3 -m json.tool 2>/dev/null | grep -A 10 '"attributes"' | head -15
else
  echo "⚠️  No products found to test details"
fi

echo ""
echo "=========================================="
echo "✅ Products Test Complete!"
echo "=========================================="
echo ""
