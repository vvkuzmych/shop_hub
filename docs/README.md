# ShopHub Documentation

Welcome to the ShopHub documentation! This directory contains guides and documentation for developers working on the ShopHub e-commerce platform.

## 📚 Available Documentation

### [Docker Setup Guide](./DOCKER.md) 🐳
Complete guide to running ShopHub with Docker for development.

**Topics covered:**
- Quick start with docker-compose
- Environment configuration
- Common Docker commands
- Development workflow
- Debugging in containers
- Production deployment

### [Nginx & Production Deployment](./NGINX_PRODUCTION.md) 🚀
Complete guide to production deployment with Nginx reverse proxy.

**Topics covered:**
- Why use Nginx in production
- Architecture comparison (dev vs prod)
- SSL/HTTPS setup
- Load balancing
- Performance tuning
- Security best practices
- Troubleshooting

### [Database Seeding Guide](./SEEDING_DATA.md)
Learn how to populate your development database with sample data for testing.

**Topics covered:**
- Main seed file usage
- Order tracking test data
- User accounts and credentials
- Customizing seed data
- Troubleshooting common issues

### [Nova Poshta Integration](./NOVA_POSHTA_INTEGRATION.md)
Complete guide to the Nova Poshta delivery service integration.

**Topics covered:**
- Ukrainian delivery service overview
- Customer checkout experience
- Backend implementation details
- Frontend components
- API integration details
- Testing and seed data

### [Eager Loading Strategies](./EAGER_LOADING_STRATEGIES.md)
Guide to optimizing database queries in Rails to avoid N+1 query problems.

**Topics covered:**
- N+1 query detection
- `includes`, `eager_load`, `preload`, `joins` explained
- Performance optimization techniques
- Caching strategies

---

## 🏗️ Project Structure

```
shop_hub/
├── app/
│   ├── controllers/      # API endpoints
│   ├── models/          # Database models
│   ├── serializers/     # JSON:API serializers
│   ├── services/        # Business logic
│   └── mailers/         # Email templates
├── db/
│   ├── migrate/         # Database migrations
│   ├── seeds.rb         # Main seed file
│   └── seeds_*.rb       # Specialized seed files
├── frontend/            # React/TypeScript frontend
│   ├── src/
│   │   ├── api/        # API client
│   │   ├── components/ # React components
│   │   ├── pages/      # Page components
│   │   ├── store/      # Zustand state management
│   │   └── types/      # TypeScript types
└── docs/                # This directory
```

---

## 🚀 Quick Start

### Option 1: Docker (Recommended) 🐳

```bash
# Build and start all services
docker-compose up -d

# Setup database
docker-compose exec backend rails db:create db:migrate db:seed

# Access applications
# Frontend: http://localhost:5175
# Backend:  http://localhost:3000
```

See [Docker Setup Guide](./DOCKER.md) for detailed instructions.

### Option 2: Local Development

**Backend (Rails API)**

```bash
# Install dependencies
bundle install

# Setup database
rails db:create db:migrate db:seed

# Start server
rails server
# Or use: make start
```

**Frontend (React)**

```bash
cd frontend

# Install dependencies
npm install

# Start development server
npm run dev
```

### Using Makefile

```bash
# View all available commands
make help

# Local development
make start          # Start both backend and frontend
make stop           # Stop all services
make logs           # View logs

# Docker commands
make docker-up      # Start Docker containers
make docker-down    # Stop Docker containers
make docker-logs    # View Docker logs
```

---

## 🔑 Default Credentials

### Admin Account
```
Email:    admin@shophub.com
Password: password
```

Access admin panel: `http://localhost:5173/admin/products`

### Test Customer
```
Email:    customer@test.com
Password: password123
```

---

## 📖 Feature Guides

### Delivery Methods

ShopHub supports three delivery methods:

1. **Home Delivery** - Standard delivery to customer's address
2. **Store Pickup** - Customer picks up from physical store location
3. **Nova Poshta** - Delivery to Nova Poshta warehouse (Ukrainian delivery service)
   - [Full documentation](./NOVA_POSHTA_INTEGRATION.md)

### Order Status Flow

**Home Delivery Orders:**
1. Pending → Payment Received → Processing → Packed → Shipped → Out for Delivery → Delivered

**Store Pickup Orders:**
1. Pending → Payment Received → Processing → Packed → Ready for Pickup → Picked Up

**Nova Poshta Orders:**
1. Pending → Payment Received → Processing → Packed → Shipped → Out for Delivery → Delivered
   - Uses Nova Poshta warehouse for final delivery
   - Tracking numbers format: `NP` + 11 digits

### Payment Integration

- **Provider**: Stripe
- **Test Card**: 4242 4242 4242 4242
- **Environment**: Test mode enabled by default

### Email Notifications

Emails are sent on:
- Order confirmation
- Status updates
- Payment confirmation

**Development**: Emails are logged to console (check `log/development.log`)

---

## 🧪 Testing

### Backend Tests (RSpec)

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/product_spec.rb

# With coverage
bundle exec rspec --format documentation
```

### Frontend Tests

```bash
cd frontend

# Run tests
npm test

# Run tests in watch mode
npm test -- --watch
```

### Linting

```bash
# Backend (RuboCop)
bundle exec rubocop
bundle exec rubocop --autocorrect-all

# Frontend (ESLint)
cd frontend
npm run lint
```

---

## 🔧 Configuration

### Environment Variables

**Backend** (`.env`):
```bash
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
DATABASE_URL=postgresql://...
```

**Frontend** (`frontend/.env`):
```bash
VITE_API_URL=http://localhost:3000/api/v1
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_...
```

---

## 📝 Code Style

### Ruby (RuboCop)

- Double quotes for strings
- 2-space indentation
- Follow Rails conventions
- No trailing whitespace

### TypeScript/React

- Use TypeScript for type safety
- CSS Modules for styling
- Functional components with hooks
- Use Zustand for state management

---

## 🐛 Common Issues

### "Address already in use" (Port conflict)

```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use a different port
rails server -p 3001
```

### Database connection errors

```bash
# Check PostgreSQL is running
brew services list

# Start PostgreSQL
brew services start postgresql

# Reset database
rails db:reset
```

### Frontend build errors

```bash
cd frontend

# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install

# Clear Vite cache
rm -rf dist .vite
npm run build
```

---

## 📚 Additional Guides

### Creating New Features

1. **Backend**: Create migration, model, controller, serializer, tests
2. **Frontend**: Create page component, API client, types
3. **Test**: Write specs, test in browser
4. **Document**: Update relevant docs

### Database Migrations

```bash
# Create migration
rails generate migration AddFieldToModel field:type

# Run migrations
rails db:migrate

# Rollback last migration
rails db:rollback

# Reset database
rails db:reset
```

### Adding New Dependencies

**Backend**:
```bash
# Add to Gemfile
gem 'gem_name', '~> 1.0'

# Install
bundle install
```

**Frontend**:
```bash
cd frontend
npm install package-name
```

---

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run tests and linters
4. Commit with descriptive messages
5. Push and create PR

---

## 📞 Support

- **Issues**: Check `log/development.log` for errors
- **Debugging**: Use `binding.pry` (backend) or browser DevTools (frontend)
- **Rails Console**: `rails console` for database queries

---

## 📜 License

[Add your license information here]
