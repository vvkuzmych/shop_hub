#!/bin/bash

# ShopHub API - Reviews Test Script
# Requires: Run 1_auth.sh first to get token
# Usage: ./scripts/api_tests/5_reviews.sh

BASE_URL="http://localhost:3000"

# Get token
if [ -f /tmp/shophub_token.txt ]; then
  TOKEN=$(cat /tmp/shophub_token.txt)
else
  echo "❌ No token found. Run ./scripts/api_tests/1_auth.sh first!"
  exit 1
fi

echo "=========================================="
echo "ShopHub API - Reviews Test"
echo "=========================================="
echo ""

# Get first product
PRODUCTS=$(curl -s "$BASE_URL/api/v1/products?per_page=1")
PRODUCT_ID=$(echo "$PRODUCTS" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data'][0]['id'])" 2>/dev/null)

if [ -z "$PRODUCT_ID" ]; then
  echo "❌ No products found. Run db:seed first!"
  exit 1
fi

echo "📦 Testing reviews for Product #$PRODUCT_ID"
echo ""

# 1. View Existing Reviews
echo "1️⃣  Viewing Product Reviews..."
REVIEWS=$(curl -s "$BASE_URL/api/v1/products/$PRODUCT_ID/reviews")
echo "✅ Reviews retrieved:"
echo "$REVIEWS" | python3 -m json.tool 2>/dev/null | head -30

echo ""
echo "----------------------------------------"
echo ""

# 2. Create Review
echo "2️⃣  Creating New Review..."
REVIEW_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$BASE_URL/api/v1/products/$PRODUCT_ID/reviews" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"review\": {
      \"rating\": 5,
      \"comment\": \"Excellent product! Highly recommended. Tested via API script at $(date).\"
    }
  }")

REVIEW_STATUS=$(echo "$REVIEW_RESPONSE" | grep HTTP_STATUS | cut -d: -f2)
REVIEW_BODY=$(echo "$REVIEW_RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$REVIEW_STATUS" = "201" ]; then
  echo "✅ Review created successfully!"
  REVIEW_ID=$(echo "$REVIEW_BODY" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data']['id'])" 2>/dev/null)
  echo "🆔 Review ID: $REVIEW_ID"
  echo "$REVIEW_BODY" | python3 -m json.tool 2>/dev/null | grep -A 8 '"attributes"'
else
  echo "⚠️  Review creation status: $REVIEW_STATUS"
  echo "$REVIEW_BODY" | python3 -m json.tool 2>/dev/null || echo "$REVIEW_BODY"
  echo "(Note: May fail if you already reviewed this product)"
fi

echo ""
echo "----------------------------------------"
echo ""

# 3. View Reviews Again
echo "3️⃣  Viewing Updated Reviews..."
UPDATED_REVIEWS=$(curl -s "$BASE_URL/api/v1/products/$PRODUCT_ID/reviews")
REVIEW_COUNT=$(echo "$UPDATED_REVIEWS" | grep -o '"id"' | wc -l)
echo "✅ Total reviews: $REVIEW_COUNT"
echo "$UPDATED_REVIEWS" | python3 -m json.tool 2>/dev/null | grep -E '"rating"|"comment"' | head -10

echo ""
echo "=========================================="
echo "✅ Reviews Test Complete!"
echo "=========================================="
echo ""
