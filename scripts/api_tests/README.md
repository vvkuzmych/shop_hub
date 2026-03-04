# API Test Scripts

Quick shell scripts to test ShopHub API without a UI.

## Prerequisites

1. **Start Rails server:**
   ```bash
   rails server
   ```

2. **Seed database:**
   ```bash
   rails db:seed
   ```

3. **Make scripts executable:**
   ```bash
   chmod +x scripts/api_tests/*.sh
   ```

## Available Scripts

### 1. Authentication (`1_auth.sh`)
Tests user registration, login, logout, and JWT token handling.

```bash
./scripts/api_tests/1_auth.sh
```

**Tests:**
- ✅ User signup
- ✅ User login
- ✅ Token storage
- ✅ Authenticated request
- ✅ User logout

**Output:** Saves JWT token to `/tmp/shophub_token.txt` for other scripts.

---

### 2. Products (`2_products.sh`)
Tests product listing, search, and filtering.

```bash
./scripts/api_tests/2_products.sh
```

**Tests:**
- ✅ List all products
- ✅ Search by keyword
- ✅ Featured products
- ✅ Price range filtering
- ✅ Product details

---

### 3. Shopping Cart (`3_cart.sh`)
Tests cart operations. Requires token from auth script.

```bash
./scripts/api_tests/3_cart.sh
```

**Tests:**
- ✅ View empty cart
- ✅ Add items
- ✅ Update quantities
- ✅ Remove items
- ✅ View cart total

---

### 4. Orders (`4_orders.sh`)
Tests order creation and management. Requires token.

```bash
./scripts/api_tests/4_orders.sh
```

**Tests:**
- ✅ Create order
- ✅ View order history
- ✅ Order details
- ✅ Cancel order

---

### 5. Reviews (`5_reviews.sh`)
Tests product reviews. Requires token.

```bash
./scripts/api_tests/5_reviews.sh
```

**Tests:**
- ✅ View product reviews
- ✅ Create review
- ✅ Rating validation

---

### 6. Complete Workflow (`6_complete_workflow.sh`)
End-to-end customer journey test.

```bash
./scripts/api_tests/6_complete_workflow.sh
```

**Tests entire flow:**
- Signup → Browse → Add to Cart → Place Order → Leave Review

---

### 7. Admin Operations (`7_admin.sh`)
Tests admin functionality. Requires admin credentials.

```bash
./scripts/api_tests/7_admin.sh [admin_email] [admin_password]
# Or use defaults:
./scripts/api_tests/7_admin.sh
```

**Tests:**
- ✅ Admin login
- ✅ View all users
- ✅ View all orders
- ✅ Create product
- ✅ Update order status

---

## Running All Tests

Execute all scripts in sequence:

```bash
cd /Users/vkuzm/RubymineProjects/shop_hub

# Make executable
chmod +x scripts/api_tests/*.sh

# Run all tests
./scripts/api_tests/1_auth.sh && \
./scripts/api_tests/2_products.sh && \
./scripts/api_tests/3_cart.sh && \
./scripts/api_tests/4_orders.sh && \
./scripts/api_tests/5_reviews.sh && \
./scripts/api_tests/6_complete_workflow.sh

# Test admin (if you have admin user)
./scripts/api_tests/7_admin.sh admin@shophub.com password123
```

---

## Creating Admin User

If you need to create an admin user for testing:

```bash
rails console
```

Then:
```ruby
User.create!(
  email: 'admin@shophub.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  role: :admin
)
```

---

## Tips

- **View Raw JSON:** Add `| python3 -m json.tool` to any curl command
- **Save Responses:** Add `> output.json` to save response
- **Check Status Only:** Add `-w "%{http_code}"` to curl
- **Verbose Output:** Add `-v` flag to curl for debugging

---

## Example Manual Curl Commands

### Get Products
```bash
curl http://localhost:3000/api/v1/products
```

### Login
```bash
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"user@example.com","password":"password123"}}'
```

### Authenticated Request
```bash
TOKEN="Bearer your_jwt_token_here"
curl http://localhost:3000/api/v1/cart/items \
  -H "Authorization: $TOKEN"
```

---

## Troubleshooting

**"Connection refused"**  
→ Make sure Rails server is running: `rails server`

**"No token found"**  
→ Run `1_auth.sh` first to generate and save token

**"Forbidden"**  
→ Check user role (admin required for some endpoints)

**"No products found"**  
→ Run `rails db:seed` to populate database
