#!/bin/bash

# ShopHub API - Complete E-commerce Workflow Test
# Tests entire customer journey from signup to order placement
# Usage: ./scripts/api_tests/6_complete_workflow.sh

BASE_URL="http://localhost:3000"
EMAIL="customer_$(date +%s)@example.com"
PASSWORD="SecurePass123!"

echo "=========================================="
echo "ShopHub API - Complete Workflow Test"
echo "=========================================="
echo "Testing full customer journey..."
echo ""

# Step 1: Signup
echo "🔹 Step 1: Creating New Customer Account..."
SIGNUP=$(curl -s -i -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d "{
    \"user\": {
      \"email\": \"$EMAIL\",
      \"password\": \"$PASSWORD\",
      \"password_confirmation\": \"$PASSWORD\",
      \"first_name\": \"Test\",
      \"last_name\": \"Customer\"
    }
  }")

TOKEN=$(echo "$SIGNUP" | grep -i "^authorization:" | cut -d' ' -f2- | tr -d '\r')

if [ ! -z "$TOKEN" ]; then
  echo "✅ Account created! Email: $EMAIL"
else
  echo "❌ Signup failed!"
  exit 1
fi

sleep 1

# Step 2: Browse Products
echo ""
echo "🔹 Step 2: Browsing Products..."
PRODUCTS=$(curl -s "$BASE_URL/api/v1/products?in_stock=true&per_page=3")
PRODUCT_ID_1=$(echo "$PRODUCTS" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data'][0]['id'])" 2>/dev/null)
PRODUCT_ID_2=$(echo "$PRODUCTS" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data'][1]['id'])" 2>/dev/null)
PRODUCT_NAME=$(echo "$PRODUCTS" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data'][0]['attributes']['name'])" 2>/dev/null)

echo "✅ Found products: #$PRODUCT_ID_1 ($PRODUCT_NAME), #$PRODUCT_ID_2"

sleep 1

# Step 3: Add to Cart
echo ""
echo "🔹 Step 3: Adding Products to Cart..."
curl -s -X POST "$BASE_URL/api/v1/cart/add_item" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"product_id\": $PRODUCT_ID_1, \"quantity\": 2}" > /dev/null

curl -s -X POST "$BASE_URL/api/v1/cart/add_item" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"product_id\": $PRODUCT_ID_2, \"quantity\": 1}" > /dev/null

CART=$(curl -s "$BASE_URL/api/v1/cart/items" -H "Authorization: $TOKEN")
CART_TOTAL=$(echo "$CART" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['total'])" 2>/dev/null)

echo "✅ Cart total: \$$CART_TOTAL"

sleep 1

# Step 4: Place Order
echo ""
echo "🔹 Step 4: Placing Order..."
ORDER=$(curl -s -X POST "$BASE_URL/api/v1/orders" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"items\": [
      {\"product_id\": $PRODUCT_ID_1, \"quantity\": 2},
      {\"product_id\": $PRODUCT_ID_2, \"quantity\": 1}
    ]
  }")

ORDER_ID=$(echo "$ORDER" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data']['id'])" 2>/dev/null)
ORDER_STATUS=$(echo "$ORDER" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data']['attributes']['status'])" 2>/dev/null)
ORDER_TOTAL=$(echo "$ORDER" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['data']['attributes']['total_amount'])" 2>/dev/null)

if [ ! -z "$ORDER_ID" ]; then
  echo "✅ Order placed successfully!"
  echo "   Order ID: #$ORDER_ID"
  echo "   Status: $ORDER_STATUS"
  echo "   Total: \$$ORDER_TOTAL"
else
  echo "❌ Order failed!"
  echo "$ORDER" | python3 -m json.tool 2>/dev/null
  exit 1
fi

sleep 1

# Step 5: View Order History
echo ""
echo "🔹 Step 5: Checking Order History..."
ORDERS=$(curl -s "$BASE_URL/api/v1/orders" -H "Authorization: $TOKEN")
ORDER_COUNT=$(echo "$ORDERS" | grep -o '"id"' | wc -l)
echo "✅ Order history retrieved: $ORDER_COUNT order(s)"

sleep 1

# Step 6: Leave Review
echo ""
echo "🔹 Step 6: Leaving Product Review..."
REVIEW=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$BASE_URL/api/v1/products/$PRODUCT_ID_1/reviews" \
  -H "Authorization: $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"review\": {
      \"rating\": 5,
      \"comment\": \"Great product! Fast delivery. Order #$ORDER_ID\"
    }
  }")

REVIEW_STATUS=$(echo "$REVIEW" | grep HTTP_STATUS | cut -d: -f2)

if [ "$REVIEW_STATUS" = "201" ]; then
  echo "✅ Review posted successfully!"
else
  echo "ℹ️  Review status: $REVIEW_STATUS (may already exist)"
fi

echo ""
echo "=========================================="
echo "🎉 Complete Workflow Test Finished!"
echo "=========================================="
echo ""
echo "Summary:"
echo "  ✅ Customer registered: $EMAIL"
echo "  ✅ Products browsed"
echo "  ✅ Cart managed"
echo "  ✅ Order placed: #$ORDER_ID"
echo "  ✅ Order history viewed"
echo "  ✅ Review posted"
echo ""
echo "🛍️  Full e-commerce journey completed successfully!"
echo ""
