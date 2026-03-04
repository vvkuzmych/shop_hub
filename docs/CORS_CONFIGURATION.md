# CORS Configuration Guide

## Overview

CORS (Cross-Origin Resource Sharing) has been configured to allow your React frontend (or any client) to communicate with the ShopHub API.

## Current Configuration

**File**: `config/initializers/cors.rb`

### Development Settings
```ruby
origins "*"  # Allows requests from ANY origin
```

### Allowed Methods
- GET
- POST
- PUT
- PATCH
- DELETE
- OPTIONS (preflight requests)
- HEAD

### Exposed Headers
- `Authorization` - Required for JWT token access

### Credentials
- `credentials: true` - Allows cookies and authorization headers

---

## Testing CORS

### From Browser Console
```javascript
fetch('http://localhost:3000/api/v1/products')
  .then(res => res.json())
  .then(data => console.log(data))
  .catch(err => console.error(err));
```

### From React App
```javascript
// Login example
fetch('http://localhost:3000/api/v1/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    user: {
      email: 'user@example.com',
      password: 'password123'
    }
  })
})
.then(response => {
  const token = response.headers.get('Authorization');
  console.log('JWT Token:', token);
  return response.json();
})
.then(data => console.log(data));
```

---

## Production Configuration

### ⚠️ IMPORTANT: Update Before Deployment

Replace `origins "*"` with your actual frontend domain:

```ruby
# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Production: Only allow your frontend domain
    origins ENV.fetch("FRONTEND_URL", "https://yourdomain.com")

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      expose: [ "Authorization" ],
      credentials: true
  end
end
```

### Environment Variables

Add to your production environment:
```bash
FRONTEND_URL=https://yourdomain.com
```

Or for multiple domains:
```ruby
origins [ 
  "https://yourdomain.com",
  "https://www.yourdomain.com",
  "https://app.yourdomain.com"
]
```

---

## Common CORS Issues & Solutions

### Issue 1: "No 'Access-Control-Allow-Origin' header"
**Solution**: CORS is not enabled. Make sure `cors.rb` is uncommented and server is restarted.

### Issue 2: "Credentials flag is true, but Access-Control-Allow-Credentials is not"
**Solution**: Add `credentials: true` to CORS config.

### Issue 3: JWT token not accessible in frontend
**Solution**: Add `expose: ["Authorization"]` to CORS config.

### Issue 4: OPTIONS requests failing
**Solution**: Include `:options` in the methods array.

---

## Security Recommendations

### Development
- ✅ Use `origins "*"` for easier testing
- ✅ Allow all methods
- ✅ Expose Authorization header

### Staging
- ⚠️ Restrict origins to staging domain
- ✅ Keep all methods allowed
- ✅ Test with real frontend

### Production
- 🔒 **CRITICAL**: Only allow specific frontend domains
- 🔒 Consider restricting methods if needed
- 🔒 Monitor CORS errors in logs
- 🔒 Use environment variables for origins

---

## Testing Checklist

- [ ] GET requests work without authentication
- [ ] POST requests work for signup/login
- [ ] Authorization header is accessible in response
- [ ] JWT token can be sent in subsequent requests
- [ ] OPTIONS preflight requests succeed
- [ ] Authenticated endpoints work with token
- [ ] Error responses include CORS headers

---

## Frontend Integration Example

### React with Axios
```javascript
import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:3000',
  withCredentials: true
});

// Intercept responses to get JWT token
api.interceptors.response.use(
  (response) => {
    const token = response.headers['authorization'];
    if (token) {
      localStorage.setItem('jwt_token', token);
    }
    return response;
  }
);

// Add token to requests
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('jwt_token');
    if (token) {
      config.headers.Authorization = token;
    }
    return config;
  }
);

export default api;
```

### Usage
```javascript
// Login
api.post('/api/v1/login', {
  user: {
    email: 'user@example.com',
    password: 'password123'
  }
})
.then(res => console.log('Logged in:', res.data));

// Get products (authenticated)
api.get('/api/v1/cart/items')
.then(res => console.log('Cart:', res.data));
```

---

## Debugging CORS

### Check Server Logs
Look for OPTIONS requests in Rails logs:
```
Started OPTIONS "/api/v1/signup" for ::1 at 2026-03-04 15:34:28 +0200
```

### Check Browser Network Tab
1. Open DevTools → Network
2. Find the failed request
3. Check Response Headers for CORS headers:
   - `Access-Control-Allow-Origin`
   - `Access-Control-Allow-Methods`
   - `Access-Control-Allow-Headers`
   - `Access-Control-Expose-Headers`

### Enable Verbose CORS Logging
Add to `config/environments/development.rb`:
```ruby
config.middleware.insert_before 0, Rack::Cors, debug: true do
  # ... your CORS config
end
```

---

## Additional Resources

- [Rack::CORS Documentation](https://github.com/cyu/rack-cors)
- [MDN CORS Guide](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)
- [Understanding CORS](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)

---

## Quick Fix Commands

### Restart Server After Changes
```bash
# Stop server (Ctrl+C)
# Then restart:
rails server
```

### Test CORS with cURL
```bash
# Test OPTIONS request
curl -X OPTIONS \
  -H "Origin: http://localhost:3001" \
  -H "Access-Control-Request-Method: POST" \
  -H "Access-Control-Request-Headers: Content-Type" \
  -v \
  http://localhost:3000/api/v1/signup

# Test POST request
curl -X POST \
  -H "Origin: http://localhost:3001" \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@test.com","password":"password123","password_confirmation":"password123"}}' \
  -v \
  http://localhost:3000/api/v1/signup
```

---

**Status**: ✅ CORS is now configured and ready for frontend integration!
