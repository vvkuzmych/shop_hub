#!/bin/bash

# ShopHub API - Authentication Test Script
# Usage: ./scripts/api_tests/1_auth.sh

BASE_URL="http://localhost:3000"
EMAIL="test_$(date +%s)@example.com"
PASSWORD="Password123!"

echo "=========================================="
echo "ShopHub API - Authentication Test"
echo "=========================================="
echo ""

# 1. Signup
echo "1️⃣  Testing Signup..."
SIGNUP_RESPONSE=$(curl -s -i -X POST "$BASE_URL/api/v1/signup" \
  -H "Content-Type: application/json" \
  -d "{
    \"user\": {
      \"email\": \"$EMAIL\",
      \"password\": \"$PASSWORD\",
      \"password_confirmation\": \"$PASSWORD\",
      \"first_name\": \"Test\",
      \"last_name\": \"User\"
    }
  }")

HTTP_STATUS=$(echo "$SIGNUP_RESPONSE" | grep "HTTP/" | awk '{print $2}')
SIGNUP_BODY=$(echo "$SIGNUP_RESPONSE" | sed -n '/^{/,/^}/p')

if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "201" ]; then
  echo "✅ Signup successful!"
  TOKEN=$(echo "$SIGNUP_RESPONSE" | grep -i "^authorization:" | cut -d' ' -f2- | tr -d '\r')
  if [ -z "$TOKEN" ]; then
    # Try to extract from body if not in header
    TOKEN=$(echo "$SIGNUP_BODY" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data.get('token', ''))" 2>/dev/null)
  fi
  echo "🔑 JWT Token: ${TOKEN:0:50}..."
else
  echo "❌ Signup failed (Status: $HTTP_STATUS)"
  echo "$SIGNUP_BODY" | python3 -m json.tool 2>/dev/null || echo "$SIGNUP_BODY"
  exit 1
fi

echo ""
echo "----------------------------------------"
echo ""

# 2. Login
echo "2️⃣  Testing Login..."
LOGIN_RESPONSE=$(curl -s -i -X POST "$BASE_URL/api/v1/login" \
  -H "Content-Type: application/json" \
  -d "{
    \"user\": {
      \"email\": \"$EMAIL\",
      \"password\": \"$PASSWORD\"
    }
  }")

LOGIN_STATUS=$(echo "$LOGIN_RESPONSE" | grep "HTTP/" | awk '{print $2}')
LOGIN_TOKEN=$(echo "$LOGIN_RESPONSE" | grep -i "^authorization:" | cut -d' ' -f2- | tr -d '\r')

if [ "$LOGIN_STATUS" = "200" ]; then
  echo "✅ Login successful!"
  echo "🔑 New Token: ${LOGIN_TOKEN:0:50}..."
  
  # Save token for other scripts
  echo "$LOGIN_TOKEN" > /tmp/shophub_token.txt
  echo "📝 Token saved to /tmp/shophub_token.txt"
else
  echo "❌ Login failed (Status: $LOGIN_STATUS)"
  echo "$LOGIN_RESPONSE"
  exit 1
fi

echo ""
echo "----------------------------------------"
echo ""

# 3. Test authenticated endpoint
echo "3️⃣  Testing Authenticated Endpoint (Get Cart)..."
CART_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X GET "$BASE_URL/api/v1/cart/items" \
  -H "Authorization: $LOGIN_TOKEN")

CART_STATUS=$(echo "$CART_RESPONSE" | grep HTTP_STATUS | cut -d: -f2)
CART_BODY=$(echo "$CART_RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$CART_STATUS" = "200" ]; then
  echo "✅ Authenticated request successful!"
  echo "📦 Cart: $CART_BODY" | python3 -m json.tool 2>/dev/null || echo "$CART_BODY"
else
  echo "❌ Cart request failed (Status: $CART_STATUS)"
  echo "$CART_BODY"
fi

echo ""
echo "----------------------------------------"
echo ""

# 4. Logout
echo "4️⃣  Testing Logout..."
LOGOUT_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X DELETE "$BASE_URL/api/v1/logout" \
  -H "Authorization: $LOGIN_TOKEN")

LOGOUT_STATUS=$(echo "$LOGOUT_RESPONSE" | grep HTTP_STATUS | cut -d: -f2)

if [ "$LOGOUT_STATUS" = "200" ]; then
  echo "✅ Logout successful!"
else
  echo "❌ Logout failed (Status: $LOGOUT_STATUS)"
fi

echo ""
echo "=========================================="
echo "✅ Authentication Test Complete!"
echo "=========================================="
echo ""
echo "Test user created:"
echo "  Email: $EMAIL"
echo "  Password: $PASSWORD"
echo ""
