# ShopHub - E-commerce API

A full-featured e-commerce REST API built with Ruby on Rails 8.1. ShopHub provides a complete backend solution for online shopping platforms with customer management, product catalog, shopping cart, order processing, and admin controls.

## 📋 Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Testing](#testing)
- [API Documentation](#api-documentation)
- [Project Structure](#project-structure)
- [API Testing Scripts](#api-testing-scripts)

---

## ✨ Features

### Customer Features
- **Authentication & Authorization**
  - User registration and login with JWT tokens
  - Password reset functionality (Devise)
  - Role-based access control (Customer/Admin)

- **Product Management**
  - Browse products with pagination
  - Search products by name/description
  - Filter by category, price range, stock availability
  - View featured products
  - Product reviews and ratings

- **Shopping Cart**
  - Add/remove items
  - Update quantities
  - Persistent cart storage

- **Order Management**
  - Place orders from cart
  - View order history
  - Track order status
  - Cancel pending orders

- **Reviews**
  - Rate products (1-5 stars)
  - Leave comments
  - View product reviews

### Admin Features
- User management
- Product CRUD operations
- Category management
- Order status updates
- System overview

---

## 🛠 Tech Stack

### Core
- **Ruby**: 3.3.6
- **Rails**: 8.1.2 (API-only mode)
- **Database**: PostgreSQL
- **Authentication**: Devise + Devise-JWT
- **Authorization**: Pundit

### Key Gems
- **Serialization**: jsonapi-serializer
- **Background Jobs**: Sidekiq
- **Pagination**: Kaminari
- **CORS**: rack-cors
- **Testing**: RSpec, FactoryBot, Faker, Shoulda Matchers
- **API Documentation**: Swagger/OpenAPI (static)
- **Code Quality**: RuboCop
- **Model Annotations**: annot8

---

## 📦 Prerequisites

### Option 1: Docker (Recommended for Quick Start)

- Docker Desktop 4.0+
- Docker Compose 2.0+

**Install Docker:**
```bash
# macOS
brew install --cask docker

# Windows: Download from docker.com
# Linux: Follow official installation guide
```

### Option 2: Local Development

- Ruby 3.3.6
- Rails 8.1.2
- PostgreSQL 14+
- Bundler 2.x
- Redis (for Sidekiq)
- Node.js 20+ (for frontend)

### Install Ruby (via rbenv)
```bash
rbenv install 3.3.6
rbenv global 3.3.6
```

### Install PostgreSQL
```bash
# macOS
brew install postgresql@14
brew services start postgresql@14

# Ubuntu/Debian
sudo apt-get install postgresql postgresql-contrib
sudo systemctl start postgresql
```

### Install Redis
```bash
# macOS
brew install redis
brew services start redis

# Ubuntu/Debian
sudo apt-get install redis-server
sudo systemctl start redis
```

---

## 🚀 Installation

### Option 1: Docker Setup (Recommended)

#### 1. Clone the Repository
```bash
git clone <repository-url>
cd shop_hub
```

#### 2. Setup Environment Variables
```bash
# Copy example files
cp .env.example .env
cp frontend/.env.example frontend/.env
```

Edit `.env` and `frontend/.env` with your configuration (see [Configuration](#configuration) section).

#### 3. Build and Start Services
```bash
# Build containers
docker-compose build

# Start all services (PostgreSQL, Redis, Backend, Frontend, Sidekiq)
docker-compose up -d

# Setup database
docker-compose exec backend rails db:create db:migrate db:seed
```

#### 4. Access Applications
- **Frontend**: http://localhost:5175
- **Backend API**: http://localhost:3000
- **API Docs**: http://localhost:3000/api-docs

**Default Credentials:**
- Admin: `admin@test.com` / `password123`
- Customer: `customer@test.com` / `password123`

For detailed Docker instructions, see [Docker Documentation](docs/DOCKER.md).

---

### Option 2: Local Development Setup

#### 1. Clone the Repository
```bash
git clone <repository-url>
cd shop_hub
```

#### 2. Install Dependencies
```bash
bundle install
cd frontend && npm install && cd ..
```

#### 3. Database Setup
```bash
# Create database
rails db:create

# Run migrations
rails db:migrate

# Seed sample data
rails db:seed
```

The seed command creates:
- 1 admin user (`admin@test.com` / `password123`)
- 1 customer user (`customer@test.com` / `password123`)
- 6 categories (with hierarchy)
- 10 products with images
- Sample orders with tracking

---

## ⚙️ Configuration

### Environment Variables

Create a `.env` file in the root directory (optional):

```bash
# Database
DATABASE_URL=postgresql://localhost/shop_hub_development

# JWT Secret
DEVISE_JWT_SECRET_KEY=your_secret_key_here

# Redis (for Sidekiq)
REDIS_URL=redis://localhost:6379/0

# CORS Origins (comma-separated)
CORS_ORIGINS=http://localhost:3000,http://localhost:3001
```

### Database Configuration

Edit `config/database.yml` if needed:

```yaml
development:
  adapter: postgresql
  encoding: unicode
  database: shop_hub_development
  pool: 5
  username: your_username
  password: your_password
  host: localhost
```

---

## 🏃 Running the Application

### Option 1: Docker (Recommended)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

**Services:**
- Frontend: http://localhost:5175
- Backend: http://localhost:3000
- PostgreSQL: localhost:5432
- Redis: localhost:6379

**Common Docker Commands:**
```bash
# Rails console
docker-compose exec backend rails console

# Run migrations
docker-compose exec backend rails db:migrate

# Run tests
docker-compose exec backend rspec

# View logs
docker-compose logs -f backend
docker-compose logs -f frontend
```

See [Docker Documentation](docs/DOCKER.md) for detailed usage.

---

### Option 2: Using Makefile

```bash
# Start all services (backend, frontend, sidekiq)
make start

# Stop all services
make stop

# View logs
make logs

# Run tests
make test

# See all available commands
make help
```

---

### Option 3: Manual Start

#### Start the Rails Backend (Terminal 1)

```bash
# Development mode (default port 3000)
rails server

# Or specify port
rails server -p 3000

# Or using Puma directly
bundle exec puma -C config/puma.rb
```

Server will be available at: `http://localhost:3000`

#### Start the React Frontend (Terminal 2)

```bash
cd frontend
npm run dev
```

Frontend will be available at: `http://localhost:5175`

#### Start Background Jobs (Terminal 3)

```bash
# In a separate terminal
bundle exec sidekiq
```

### Verify Installation

```bash
# Check backend is running
curl http://localhost:3000/api/v1/products

# Open frontend in browser
open http://localhost:5175  # macOS
# or
xdg-open http://localhost:5175  # Linux
```

---

## 🧪 Testing

### Run All Tests

```bash
# Run entire test suite
bundle exec rspec

# Run with coverage
COVERAGE=true bundle exec rspec
```

### Run Specific Tests

```bash
# Test specific file
bundle exec rspec spec/models/user_spec.rb

# Test specific line
bundle exec rspec spec/models/user_spec.rb:10

# Test by pattern
bundle exec rspec spec/models
bundle exec rspec spec/requests
```

### Test Coverage

Current test coverage: **153 passing examples**

Test files include:
- Model specs (User, Product, Order, Review, Category, etc.)
- Request specs (API endpoints)
- Controller specs
- Service specs

### Code Quality

```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a

# Check specific files
bundle exec rubocop app/models/
```

---

## 📚 API Documentation

### Swagger UI

API documentation is available via Swagger UI (development only):

```bash
# Start server
rails server

# Open in browser
http://localhost:3000/api-docs
```

Or view the static files:
- Swagger YAML: `public/swagger/swagger.yaml`
- Swagger UI: `public/swagger/index.html`

### API Endpoints Overview

#### Authentication
- `POST /api/v1/signup` - Register new user
- `POST /api/v1/login` - Login user
- `DELETE /api/v1/logout` - Logout user
- `POST /api/v1/password` - Reset password

#### Products (Public)
- `GET /api/v1/products` - List products (with filters)
- `GET /api/v1/products/search?q=laptop` - Search products
- `GET /api/v1/products/featured` - Featured products
- `GET /api/v1/products/:id` - Product details

#### Shopping Cart (Authenticated)
- `GET /api/v1/cart/items` - View cart
- `POST /api/v1/cart/add_item` - Add to cart
- `PATCH /api/v1/cart/update_quantity` - Update quantity
- `DELETE /api/v1/cart/remove_item` - Remove from cart
- `DELETE /api/v1/cart/clear` - Clear cart

#### Orders (Authenticated)
- `GET /api/v1/orders` - Order history
- `GET /api/v1/orders/:id` - Order details
- `POST /api/v1/orders` - Create order
- `PATCH /api/v1/orders/:id/cancel` - Cancel order

#### Reviews (Authenticated)
- `GET /api/v1/products/:id/reviews` - Product reviews
- `POST /api/v1/products/:id/reviews` - Create review

#### Categories (Public)
- `GET /api/v1/categories` - List categories
- `GET /api/v1/categories/:id` - Category details
- `GET /api/v1/categories/:id/products` - Products in category

#### Admin (Admin Only)
- `GET /api/v1/admin/users` - Manage users
- `GET /api/v1/admin/products` - Manage products
- `POST /api/v1/admin/products` - Create product
- `PATCH /api/v1/admin/products/:id` - Update product
- `DELETE /api/v1/admin/products/:id` - Delete product
- `GET /api/v1/admin/orders` - Manage orders
- `PATCH /api/v1/admin/orders/:id` - Update order status
- `GET /api/v1/admin/categories` - Manage categories

---

## 📁 Project Structure

```
shop_hub/
├── app/                      # Rails Backend
│   ├── controllers/
│   │   └── api/v1/           # API controllers
│   │       ├── admin/        # Admin controllers
│   │       ├── products_controller.rb
│   │       ├── orders_controller.rb
│   │       ├── carts_controller.rb
│   │       └── ...
│   ├── models/               # ActiveRecord models
│   │   ├── user.rb
│   │   ├── product.rb
│   │   ├── order.rb
│   │   ├── comment.rb        # Polymorphic
│   │   ├── address.rb        # Polymorphic
│   │   ├── attachment.rb     # Polymorphic
│   │   └── ...
│   ├── serializers/          # JSON:API serializers
│   │   ├── product_serializer.rb
│   │   ├── order_serializer.rb
│   │   └── ...
│   ├── services/             # Business logic services
│   │   └── orders/
│   │       └── create_service.rb
│   └── policies/             # Pundit authorization policies
│       ├── product_policy.rb
│       └── ...
├── frontend/                 # React Frontend
│   ├── src/
│   │   ├── api/              # API client layer
│   │   ├── components/       # React components
│   │   ├── pages/            # Page components
│   │   ├── store/            # Zustand state
│   │   ├── types/            # TypeScript types
│   │   └── App.tsx           # Main app
│   ├── public/               # Static assets
│   ├── package.json          # Node dependencies
│   └── README.md             # Frontend docs
├── config/
│   ├── routes.rb             # API routes
│   ├── database.yml          # Database config
│   └── initializers/
│       ├── cors.rb           # CORS configuration
│       ├── devise.rb         # Authentication config
│       └── ...
├── db/
│   ├── migrate/              # Database migrations
│   ├── seeds.rb              # Sample data
│   └── schema.rb             # Database schema
├── spec/                     # RSpec tests (200 passing)
│   ├── models/
│   ├── requests/
│   ├── controllers/
│   └── factories/            # FactoryBot factories
├── public/
│   └── swagger/              # API documentation
│       ├── swagger.yaml
│       └── index.html
├── scripts/
│   ├── api_tests/            # Shell scripts for API testing
│   ├── start.sh              # Start backend + frontend
│   └── stop.sh               # Stop all servers
├── docs/                     # Project documentation
├── FRONTEND_SETUP.md         # Frontend guide
└── README.md                 # This file
```

---

## 🧰 API Testing Scripts

The project includes shell scripts to test the API without a UI.

### Available Scripts

```bash
# Make scripts executable (one time)
chmod +x scripts/api_tests/*.sh

# 1. Authentication test
./scripts/api_tests/1_auth.sh

# 2. Products browsing test
./scripts/api_tests/2_products.sh

# 3. Shopping cart test
./scripts/api_tests/3_cart.sh

# 4. Orders test
./scripts/api_tests/4_orders.sh

# 5. Reviews test
./scripts/api_tests/5_reviews.sh

# 6. Complete e-commerce workflow (RECOMMENDED)
./scripts/api_tests/6_complete_workflow.sh

# 7. Admin operations test
./scripts/api_tests/7_admin.sh admin@shophub.com password
```

### Quick Test

Run the complete workflow to test end-to-end functionality:

```bash
# Start server
rails server

# In another terminal
./scripts/api_tests/6_complete_workflow.sh
```

This will:
- Create a new customer account
- Browse products
- Add items to cart
- Place an order
- Leave a review

See `scripts/api_tests/README.md` for detailed documentation.

---

## 🔑 Default Credentials

### Admin User
- **Email**: `admin@shophub.com`
- **Password**: `password`

### Test Customer Users
Created by seed file with random data (Faker gem).

---

## 📊 Database Schema

### Main Tables
- **users** - Customer and admin accounts
- **products** - Product catalog
- **categories** - Product categories (hierarchical)
- **cart_items** - Shopping cart items
- **orders** - Customer orders
- **order_items** - Order line items
- **reviews** - Product reviews
- **jwt_denylist** - Revoked JWT tokens

---

## 🐛 Troubleshooting

### Database Connection Error
```bash
# Check PostgreSQL is running
brew services list | grep postgresql

# Restart if needed
brew services restart postgresql@14
```

### Port Already in Use
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use different port
rails server -p 3001
```

### JWT Token Issues
```bash
# Clear revoked tokens
rails runner "JwtDenylist.where('exp < ?', Time.current).delete_all"
```

### Test Database Issues
```bash
# Reset test database
RAILS_ENV=test rails db:reset

# Prepare test database
rails db:test:prepare
```

---

## 📖 Additional Documentation

- **Implementation Summary**: `docs/IMPLEMENTATION_SUMMARY.md`
- **Recent Additions**: `docs/RECENT_ADDITIONS.md`
- **Swagger Setup**: `docs/SWAGGER_SETUP.md`
- **API Test Scripts**: `scripts/api_tests/README.md`
- **Test Results**: `scripts/api_tests/TEST_RESULTS.md`

---

## 🚀 Deployment

### Production Checklist

1. Set secure environment variables
2. Configure production database
3. Set up Redis for Sidekiq
4. Configure CORS for production domain
5. Enable HTTPS
6. Set up monitoring (New Relic, Datadog, etc.)
7. Configure CDN for static assets
8. Set up automated backups

### Docker (Optional)

The project includes Kamal for Docker deployment:

```bash
# Build and deploy
kamal deploy
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards

- Follow RuboCop guidelines
- Write tests for new features
- Use double quotes for strings
- Follow DRY principles
- Document API changes in Swagger

---

## 📝 License

This project is proprietary and confidential.

---

## 👥 Contact

For questions or support, please contact the development team.

---

## 🎯 Quick Start Summary

### Backend Setup

```bash
# 1. Install dependencies
bundle install

# 2. Setup database
rails db:create db:migrate db:seed

# 3. Start Rails API
rails server
```

**API is now running at `http://localhost:3000/api/v1`**

### Frontend Setup

```bash
# 1. Install dependencies
cd frontend
npm install

# 2. Start React app
npm run dev
```

**Frontend is now running at `http://localhost:5173`**

### Or Start Everything at Once

```bash
# Start both backend and frontend
./scripts/start.sh

# Stop everything
./scripts/stop.sh
```

### Test Everything

```bash
# Test API (shell scripts)
./scripts/api_tests/6_complete_workflow.sh

# View API docs
open http://localhost:3000/api-docs

# Open application
open http://localhost:5173
```

---

## 🌐 Frontend Application

The ShopHub frontend is a modern React + TypeScript application with:

### Features
- ✅ User authentication (signup/login)
- ✅ Product browsing with search and filters
- ✅ Shopping cart management
- ✅ Order placement and tracking
- ✅ Responsive design (mobile-first)
- ✅ Real-time cart updates

### Tech Stack
- React 18 + TypeScript
- Vite (blazing fast dev server)
- Tailwind CSS (modern styling)
- React Router (navigation)
- Zustand (state management)
- Axios (API client)
- TanStack Query (data fetching)

### Documentation
See `frontend/README.md` and `FRONTEND_SETUP.md` for detailed frontend documentation.

---

Enjoy building with ShopHub! 🛍️
