# Swagger API Documentation Setup

## Overview

ShopHub API now includes comprehensive Swagger/OpenAPI 3.0 documentation accessible via a web interface.

## Access the Documentation

### Local Development
```
http://localhost:3000/swagger/
```

### Production
```
https://your-domain.com/swagger/
```

## Features

### Interactive API Explorer
- ✅ **Try It Out**: Test API endpoints directly from the browser
- ✅ **Authentication**: Built-in JWT token management
- ✅ **Request/Response Examples**: See example data for all endpoints
- ✅ **Schema Validation**: View detailed data models and validations
- ✅ **Filtering**: Search through endpoints quickly

### Documented Endpoints

#### Authentication
- POST `/api/v1/signup` - User registration
- POST `/api/v1/login` - User login
- DELETE `/api/v1/logout` - User logout

#### Products
- GET `/api/v1/products` - List products (with search & filters)
- GET `/api/v1/products/{id}` - Get product details
- GET `/api/v1/products/search` - Search products
- GET `/api/v1/products/featured` - Get featured products

#### Shopping Cart
- GET `/api/v1/cart/items` - View cart
- POST `/api/v1/cart/add_item` - Add to cart
- PATCH `/api/v1/cart/update_quantity` - Update quantity
- DELETE `/api/v1/cart/remove_item` - Remove item
- DELETE `/api/v1/cart/clear` - Clear cart

#### Orders
- GET `/api/v1/orders` - List orders
- POST `/api/v1/orders` - Create order
- GET `/api/v1/orders/{id}` - Get order details
- PATCH `/api/v1/orders/{id}/cancel` - Cancel order

#### Categories & Reviews
- GET `/api/v1/categories` - List categories
- GET `/api/v1/categories/{id}/products` - Products by category
- GET `/api/v1/products/{id}/reviews` - Product reviews
- POST `/api/v1/products/{id}/reviews` - Create review

#### Admin Endpoints
- Products, Categories, Orders, Users management

## How to Use

### 1. Testing Authenticated Endpoints

1. First, obtain a JWT token by calling the `/api/v1/login` endpoint
2. Copy the token from the response header `Authorization: Bearer <token>`
3. Click the "Authorize" button at the top right
4. Enter: `Bearer YOUR_TOKEN_HERE`
5. Click "Authorize" and "Close"
6. All subsequent requests will include the token

### 2. Testing a Product Search

1. Navigate to **Products** section
2. Click on `GET /api/v1/products`
3. Click "Try it out"
4. Enter search parameters:
   - `q`: "laptop"
   - `in_stock`: true
   - `max_price`: 1000
5. Click "Execute"
6. View the response below

### 3. Creating an Order

1. Make sure you're authenticated (see step 1)
2. Navigate to **Orders** section
3. Click on `POST /api/v1/orders`
4. Click "Try it out"
5. Edit the request body:
```json
{
  "items": [
    {
      "product_id": 1,
      "quantity": 2
    },
    {
      "product_id": 2,
      "quantity": 1
    }
  ]
}
```
6. Click "Execute"
7. View the created order in the response

## File Structure

```
public/swagger/
├── index.html      # Swagger UI HTML page
└── swagger.yaml    # OpenAPI 3.0 specification
```

## Updating Documentation

### Manual Updates
Edit `/public/swagger/swagger.yaml` to add or modify endpoint documentation.

### Documentation Format
The YAML file follows [OpenAPI 3.0 Specification](https://swagger.io/specification/):

```yaml
paths:
  /api/v1/your-endpoint:
    get:
      tags:
        - Your Tag
      summary: Brief description
      parameters:
        - name: param_name
          in: query
          schema:
            type: string
      responses:
        '200':
          description: Success response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/YourSchema'
```

## Tips

### Response Codes
- `200` - OK
- `201` - Created
- `401` - Unauthorized (missing or invalid JWT)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `422` - Validation Error

### Authentication Workflow
1. **Signup**: `POST /api/v1/signup` → Get JWT token
2. **Store Token**: Save the Authorization header value
3. **Use Token**: Include in all protected endpoint requests
4. **Logout**: `DELETE /api/v1/logout` → Token is revoked

### Common Query Parameters
- **Pagination**: `page`, `per_page`
- **Search**: `q`
- **Filters**: `category_id`, `min_price`, `max_price`, `in_stock`, `featured`
- **Sorting**: Not yet implemented (future feature)

## Benefits

1. **Developer Onboarding**: New developers can explore the API visually
2. **Frontend Development**: Frontend team can test endpoints without backend code
3. **API Contract**: Clear contract between frontend and backend
4. **Testing**: Manual testing without writing code
5. **Documentation**: Always up-to-date API reference

## Next Steps

Consider integrating:
1. **Postman Collection**: Export Swagger to Postman collection
2. **Code Generation**: Generate client SDKs from Swagger spec
3. **API Versioning**: Add v2 endpoints when needed
4. **Webhooks Documentation**: Document webhook payloads

## Support

For issues or questions about the API documentation:
- Check the examples in the Swagger UI
- Review the schema definitions
- Test endpoints in the "Try it out" mode
- Contact: api@shophub.example.com
