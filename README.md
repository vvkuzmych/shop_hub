# ShopHub - E-commerce Product Catalog

A modern e-commerce platform built with Ruby on Rails API backend and React TypeScript frontend.

## ✨ Features

- **Product Catalog** - Browse and search products with filtering and pagination
- **Shopping Cart** - Add/remove items, adjust quantities with real-time updates
- **User Authentication** - JWT-based authentication with Devise
- **Order Management** - Complete order lifecycle with multiple delivery methods
- **Payment Integration** - Stripe payment processing
- **Delivery Options**:
  - Home Delivery
  - Store Pickup
  - Nova Poshta (Ukrainian delivery service)
- **Admin Panel** - Manage products, orders, and users
- **Reviews & Ratings** - Customer product reviews
- **Real-time Updates** - Cart badge updates instantly

## 🛠️ Tech Stack

**Backend:**
- Ruby 3.3.6
- Rails 8.1.2
- PostgreSQL 16
- Redis (for Sidekiq)
- Sidekiq (background jobs)

**Frontend:**
- React 18
- TypeScript
- Vite
- Zustand (state management)
- CSS Modules

**Infrastructure:**
- Docker & Docker Compose
- Nginx (production)

## 📋 Prerequisites

### Option 1: Docker (Recommended)
- Docker Desktop or Docker Engine
- Docker Compose

### Option 2: Local Development
- Ruby 3.3.6
- Rails 8.1.2
- PostgreSQL 16+
- Redis
- Node.js 20+
- npm or yarn

## 🚀 Quick Start

### Development with Docker (Recommended)

```bash
# Clone the repository
git clone <repository-url>
cd shop_hub

# Start all services
docker-compose up -d

# Setup database
docker-compose exec backend bundle exec rails db:create db:migrate db:seed

# Access the application
# Frontend: http://localhost:5175
# Backend:  http://localhost:3000/api/v1
```

### Local Development

**Backend:**
```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed

# Start server (port 3000)
rails server
```

**Frontend:**
```bash
cd frontend

# Install dependencies
npm install

# Start development server (port 5175)
npm run dev
```

### Using Makefile

```bash
# View all available commands
make help

# Development
make start          # Start both backend and frontend
make stop           # Stop all services
make logs           # View logs

# Docker
make docker-up      # Start Docker containers
make docker-down    # Stop Docker containers
make docker-test    # Run tests in Docker

# Production
make prod-build     # Build production images with Nginx
make prod-up        # Start production stack
make prod-setup     # Setup production database
```

## 🔐 Default Credentials

### Admin Account
```
Email:    admin@shophub.com
Password: password
```

### Test Customer
```
Email:    customer@test.com
Password: password123
```

## 📚 Documentation

Comprehensive guides available in the [`docs/`](./docs) directory:

- **[Docker Setup Guide](./docs/DOCKER.md)** - Development with Docker
- **[Nginx & Production](./docs/NGINX_PRODUCTION.md)** - Production deployment with Nginx
- **[Database Seeding](./docs/SEEDING_DATA.md)** - Populate test data
- **[Nova Poshta Integration](./docs/NOVA_POSHTA_INTEGRATION.md)** - Ukrainian delivery
- **[Eager Loading Strategies](./docs/EAGER_LOADING_STRATEGIES.md)** - Performance optimization

## 🏗️ Project Structure

```
shop_hub/
├── app/
│   ├── controllers/api/v1/    # API endpoints
│   ├── models/                # Database models
│   ├── serializers/           # JSON:API serializers
│   ├── services/              # Business logic
│   └── mailers/               # Email templates
├── frontend/
│   ├── src/
│   │   ├── api/              # API client
│   │   ├── components/       # React components
│   │   ├── pages/            # Page components
│   │   ├── store/            # Zustand state
│   │   └── types/            # TypeScript types
│   ├── Dockerfile            # Frontend dev container
│   └── Dockerfile.prod       # Frontend production build
├── nginx/                     # Nginx configuration (production)
│   ├── nginx.conf
│   └── sites-enabled/
├── docker-compose.yml         # Development stack
├── docker-compose.prod.yml    # Production stack with Nginx
├── Dockerfile.dev             # Backend dev container
├── Dockerfile                 # Backend production image
└── docs/                      # Documentation
```

## 🧪 Testing

### Backend (RSpec)
```bash
# Run all tests
bundle exec rspec

# Run specific file
bundle exec rspec spec/models/product_spec.rb

# In Docker
make docker-test
```

### Frontend
```bash
cd frontend
npm test
```

### Code Quality
```bash
# Backend linting (RuboCop)
bundle exec rubocop
bundle exec rubocop --autocorrect-all

# Frontend linting (ESLint)
cd frontend
npm run lint
```

## 🌐 API Endpoints

**Base URL:** `http://localhost:3000/api/v1`

### Authentication
- `POST /signup` - Register new user
- `POST /login` - User login
- `DELETE /logout` - User logout

### Products
- `GET /products` - List products
- `GET /products/:id` - Product details
- `POST /admin/products` - Create product (admin)

### Cart
- `POST /cart/add_item` - Add item to cart
- `PATCH /cart/update_quantity` - Update quantity
- `DELETE /cart/remove_item` - Remove item
- `GET /cart` - View cart

### Orders
- `GET /orders` - User orders
- `POST /orders` - Create order
- `PATCH /orders/:id/cancel` - Cancel order

## 🚀 Production Deployment

### Why Nginx?

For production, we use Nginx as a reverse proxy for:
- **Performance**: Faster static file serving
- **Security**: SSL/TLS termination, rate limiting
- **Scalability**: Load balancing across multiple backends
- **Single Entry Point**: One domain, one port (80/443)

### Quick Production Setup

```bash
# Build frontend
cd frontend && npm run build

# Start production stack with Nginx
make prod-build
make prod-up

# Setup database
make prod-setup

# Access: http://localhost
```

See [Nginx & Production Guide](./docs/NGINX_PRODUCTION.md) for detailed instructions including:
- SSL/HTTPS setup
- Load balancing
- Performance tuning
- Security best practices

## 🔧 Environment Variables

### Backend (`.env`)
```bash
DATABASE_URL=postgresql://postgres:password@localhost:5432/shop_hub_development
REDIS_URL=redis://localhost:6379/0
STRIPE_SECRET_KEY=sk_test_...
NOVA_POSHTA_API_KEY=your_key_here
```

### Frontend (`frontend/.env`)
```bash
VITE_API_URL=http://localhost:3000/api/v1
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_...
```

### Production (`.env.production`)
See `.env.production.example` for all required production variables.

## 🐛 Troubleshooting

### Port Already in Use
```bash
# Kill process on port
lsof -ti:3000 | xargs kill -9

# Or use Docker which handles ports automatically
make docker-up
```

### Database Connection Errors
```bash
# Local
brew services start postgresql

# Docker
docker-compose restart db
```

### Frontend Build Issues
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
```

## 📈 Performance

- **Eager Loading**: Optimized queries to prevent N+1 problems
- **Caching**: Redis caching for frequently accessed data
- **Background Jobs**: Sidekiq for email sending and heavy tasks
- **Nginx**: Gzip compression, static file caching (production)

## 🔒 Security

- JWT authentication with token blacklist
- CORS configuration
- SQL injection prevention (ActiveRecord)
- XSS protection
- Rate limiting (production nginx)
- SSL/TLS encryption (production)

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run tests: `make test`
4. Run linters: `bundle exec rubocop`
5. Commit and push
6. Create a Pull Request

## 📝 License

[Add your license here]

## 📞 Support

- **Documentation**: See [`docs/`](./docs) directory
- **Issues**: Check `log/development.log`
- **Rails Console**: `rails console` or `make docker-console`
- **Debug**: Use `binding.pry` (backend) or browser DevTools (frontend)

---

**Development**: Use Docker for consistent environment
**Production**: Deploy with Nginx for performance and security

See [docs/NGINX_PRODUCTION.md](./docs/NGINX_PRODUCTION.md) for production deployment guide.
