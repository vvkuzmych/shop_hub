# Docker Quick Start 🐳

## ⚡ 3 Commands to Get Started

```bash
# 1. Start services
docker-compose up -d

# 2. Setup database (first time only)
docker-compose exec backend bash -c "RAILS_ENV=test DATABASE_URL=postgresql://postgres:postgres@db:5432/shop_hub_test bundle exec rails db:create db:migrate"
docker-compose exec backend bundle exec rails db:seed

# 3. Open application
open http://localhost:5175
```

## 🌐 Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| **Frontend** | http://localhost:5175 | - |
| **Backend API** | http://localhost:3000 | - |
| **Admin** | http://localhost:5175/admin/products | admin@test.com / password123 |
| **Login** | http://localhost:5175/login | customer@test.com / password123 |

## 📊 Check Status

```bash
# View all containers
docker-compose ps

# View logs
docker-compose logs -f

# Check specific service
docker-compose logs -f backend
docker-compose logs -f frontend
```

## 🧪 Run Tests

```bash
# All tests
make docker-test

# Or manually
docker-compose exec backend bash -c "RAILS_ENV=test DATABASE_URL=postgresql://postgres:postgres@db:5432/shop_hub_test bundle exec rspec"
```

## 🛑 Stop Services

```bash
# Stop (keeps data)
docker-compose down

# Stop and remove all data
docker-compose down -v
```

## 🔧 Common Commands

```bash
# Rails console
docker-compose exec backend bundle exec rails console

# Run migration
docker-compose exec backend bundle exec rails db:migrate

# Run seeds
docker-compose exec backend bundle exec rails db:seed

# RuboCop check
docker-compose exec backend bundle exec rubocop

# Restart specific service
docker-compose restart backend
docker-compose restart frontend
```

## 📝 Makefile Shortcuts

```bash
make docker-up           # Start all services
make docker-down         # Stop all services
make docker-logs         # View all logs
make docker-test         # Run tests
make docker-console      # Rails console
make docker-db-setup     # Setup database
make docker-ps           # List containers
make help                # See all commands
```

## ✅ Verify Everything Works

```bash
# 1. Check all containers are running
docker-compose ps

# 2. Test backend API
curl http://localhost:3000/api/v1/products

# 3. Test frontend
curl http://localhost:5175

# 4. Run tests
make docker-test

# 5. Login to app
open http://localhost:5175/login
# Use: customer@test.com / password123
```

## 🎯 What's Running

- **PostgreSQL 16** - Database on port 5432
- **Redis 7** - Cache/jobs on port 6379
- **Rails 8.1** - Backend API on port 3000
- **React 18** - Frontend on port 5175
- **Sidekiq** - Background worker

## 🚀 Next Steps

- Read [Full Docker Guide](docs/DOCKER.md)
- Browse products: http://localhost:5175/products
- Admin panel: http://localhost:5175/admin/products
- Check [API Documentation](README.md#api-documentation)

---

**Status: Ready!** ✨

All services are running in Docker with hot-reloading enabled!
