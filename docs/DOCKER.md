# Docker Setup for ShopHub

This guide explains how to run ShopHub using Docker for development.

## Prerequisites

- **Docker**: Install [Docker Desktop](https://www.docker.com/products/docker-desktop) (includes Docker Compose)
  - macOS: `brew install --cask docker`
  - Windows: Download installer from docker.com
  - Linux: Follow [official installation guide](https://docs.docker.com/engine/install/)

- **Docker Compose**: Version 2.0+ (included with Docker Desktop)

## Quick Start

### 1. Setup Environment Variables

Create `.env` file in the root directory:

```bash
cp .env.example .env
```

Edit `.env` and set required values:

```bash
# Database
DATABASE_URL=postgresql://postgres:postgres@db:5432/shop_hub_development
REDIS_URL=redis://redis:6379/0

# Nova Poshta API (optional for testing)
NOVA_POSHTA_API_KEY=your_api_key_here

# Stripe (optional for testing)
STRIPE_SECRET_KEY=sk_test_your_stripe_secret_key
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret

# Frontend URL
FRONTEND_URL=http://localhost:5175
```

Create `frontend/.env`:

```bash
cd frontend
cp .env.example .env
```

Edit `frontend/.env`:

```bash
VITE_API_URL=http://localhost:3000/api/v1
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_your_stripe_publishable_key
```

### 2. Build and Start Services

```bash
# Build all containers
docker-compose build

# Start all services
docker-compose up
```

Or run in detached mode:

```bash
docker-compose up -d
```

### 3. Setup Database

In a new terminal, run:

```bash
# Create and migrate database
docker-compose exec backend rails db:create db:migrate

# Seed initial data (optional)
docker-compose exec backend rails db:seed

# Seed order tracking examples (optional)
docker-compose exec backend rails runner db/seeds_order_tracking.rb
```

### 4. Access Applications

- **Frontend**: http://localhost:5175
- **Backend API**: http://localhost:3000
- **API Documentation**: http://localhost:3000/api/v1
- **PostgreSQL**: localhost:5432
- **Redis**: localhost:6379

### 5. Default Credentials

After seeding:

**Admin User:**
- Email: `admin@test.com`
- Password: `password123`

**Customer User:**
- Email: `customer@test.com`
- Password: `password123`

## Docker Services

The `docker-compose.yml` defines the following services:

### 1. **db** (PostgreSQL 16)
- Database server
- Port: 5432
- Data persisted in `postgres_data` volume

### 2. **redis**
- Cache and background job queue
- Port: 6379
- Data persisted in `redis_data` volume

### 3. **backend** (Rails API)
- Rails 8.1 application
- Port: 3000
- Hot-reloading enabled (code changes reflected immediately)
- Bundler gems cached in `bundle_cache` volume

### 4. **frontend** (React + Vite)
- React 18 with TypeScript
- Port: 5175
- Hot Module Replacement (HMR) enabled
- node_modules persisted in anonymous volume

### 5. **sidekiq**
- Background job processor
- Handles async tasks (emails, etc.)
- No exposed ports

## Common Commands

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f sidekiq
```

### Run Rails Commands

```bash
# Rails console
docker-compose exec backend bundle exec rails console

# Run migrations
docker-compose exec backend bundle exec rails db:migrate

# Run seeds
docker-compose exec backend bundle exec rails db:seed

# Reset database
docker-compose exec backend bundle exec rails db:reset

# Generate migration
docker-compose exec backend bundle exec rails generate migration AddFieldToModel
```

### Run Tests

```bash
# RSpec (backend tests)
docker-compose exec backend bash -c "RAILS_ENV=test DATABASE_URL=postgresql://postgres:postgres@db:5432/shop_hub_test bundle exec rspec"

# Or using Makefile
make docker-test

# Specific test file
docker-compose exec backend bash -c "RAILS_ENV=test DATABASE_URL=postgresql://postgres:postgres@db:5432/shop_hub_test bundle exec rspec spec/models/user_spec.rb"

# RuboCop (code style)
docker-compose exec backend bundle exec rubocop

# Brakeman (security)
docker-compose exec backend bundle exec brakeman
```

**Note**: Test database (`shop_hub_test`) is automatically created on first test run.

### Frontend Commands

```bash
# Install new npm package
docker-compose exec frontend npm install package-name

# Run TypeScript check
docker-compose exec frontend npm run build

# ESLint
docker-compose exec frontend npm run lint
```

### Database Operations

```bash
# Connect to PostgreSQL
docker-compose exec db psql -U postgres -d shop_hub_development

# Backup database
docker-compose exec db pg_dump -U postgres shop_hub_development > backup.sql

# Restore database
docker-compose exec -T db psql -U postgres shop_hub_development < backup.sql

# Drop and recreate
docker-compose exec backend bundle exec rails db:drop db:create db:migrate db:seed
```

### Restart Services

```bash
# Restart all services
docker-compose restart

# Restart specific service
docker-compose restart backend
docker-compose restart frontend

# Rebuild and restart (after Gemfile/package.json changes)
docker-compose up -d --build backend
docker-compose up -d --build frontend
```

### Stop Services

```bash
# Stop all services (keeps containers)
docker-compose stop

# Stop and remove containers
docker-compose down

# Stop, remove containers, and remove volumes (CAUTION: deletes data)
docker-compose down -v
```

### Clean Up

```bash
# Remove stopped containers
docker-compose rm

# Remove unused images
docker image prune

# Remove all unused data (CAUTION)
docker system prune -a --volumes
```

## Development Workflow

### 1. Making Code Changes

**Backend (Rails):**
- Changes are reflected immediately (no restart needed)
- If you add gems to Gemfile:
  ```bash
  docker-compose exec backend bundle install
  docker-compose restart backend
  ```

**Frontend (React):**
- Vite HMR updates browser automatically
- If you add npm packages:
  ```bash
  docker-compose exec frontend npm install
  docker-compose restart frontend
  ```

### 2. Running Migrations

```bash
# Create migration
docker-compose exec backend bundle exec rails generate migration AddFieldToModel field:type

# Run migration
docker-compose exec backend bundle exec rails db:migrate

# Rollback
docker-compose exec backend bundle exec rails db:rollback
```

### 3. Debugging

**Backend:**
```bash
# Add binding.pry or debugger to your code
# Then attach to container:
docker attach shophub_backend

# Or view logs:
docker-compose logs -f backend
```

**Frontend:**
- Use browser DevTools
- Console logs appear in terminal: `docker-compose logs -f frontend`

### 4. Running Background Jobs

Sidekiq processes jobs automatically. To test:

```bash
# Monitor Sidekiq
docker-compose logs -f sidekiq

# Check Redis queue
docker-compose exec redis redis-cli
> KEYS *
> LLEN sidekiq:queue:default
```

## Troubleshooting

### Port Already in Use

If ports 3000, 5175, 5432, or 6379 are already in use:

```bash
# Find process using port
lsof -i :3000

# Kill process
kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "3001:3000"  # Use 3001 instead of 3000
```

### Database Connection Failed

```bash
# Check if database is healthy
docker-compose ps

# Restart database
docker-compose restart db

# Wait for health check
docker-compose logs db | grep "ready to accept connections"

# Recreate database
docker-compose down
docker-compose up -d db
docker-compose exec backend bundle exec rails db:create
```

### Bundle Install Errors

```bash
# Clear bundler cache
docker-compose down
docker volume rm shop_hub_bundle_cache
docker-compose up -d --build backend
```

### Frontend Not Updating

```bash
# Clear node_modules
docker-compose down
docker-compose up -d --build frontend

# Or manually:
docker-compose exec frontend rm -rf node_modules
docker-compose exec frontend npm install
docker-compose restart frontend
```

### Permission Errors

```bash
# Fix file permissions
sudo chown -R $USER:$USER .

# Or run as root (not recommended for production)
docker-compose exec -u root backend bash
```

## Production Deployment

The main `Dockerfile` (not `Dockerfile.dev`) is production-ready and optimized for:
- **Kamal deployment**
- **Smaller image size**
- **Security (non-root user)**
- **Performance (jemalloc, bootsnap)**

To build production image:

```bash
docker build -t shophub:latest .
docker run -d -p 80:80 \
  -e RAILS_MASTER_KEY=<your_master_key> \
  -e DATABASE_URL=<production_db_url> \
  --name shophub shophub:latest
```

For detailed production deployment, see [Kamal documentation](https://kamal-deploy.org).

## Docker Compose File Structure

```yaml
services:
  db:          # PostgreSQL database
  redis:       # Cache and job queue
  backend:     # Rails API server
  frontend:    # React/Vite dev server
  sidekiq:     # Background job processor

volumes:
  postgres_data:  # Database persistence
  redis_data:     # Redis persistence
  bundle_cache:   # Bundler gems cache
```

## Environment Variables Reference

### Backend (.env)

```bash
# Database
DATABASE_URL=postgresql://user:password@host:port/database
REDIS_URL=redis://host:port/db

# Rails
RAILS_ENV=development
RAILS_MAX_THREADS=5

# External APIs
NOVA_POSHTA_API_KEY=your_key
STRIPE_SECRET_KEY=sk_test_your_key
STRIPE_WEBHOOK_SECRET=whsec_your_secret

# URLs
FRONTEND_URL=http://localhost:5175
```

### Frontend (frontend/.env)

```bash
# API URL
VITE_API_URL=http://localhost:3000/api/v1

# Stripe
VITE_STRIPE_PUBLISHABLE_KEY=pk_test_your_key
```

## Best Practices

1. **Don't commit secrets**: Keep `.env` files in `.gitignore`
2. **Use volumes**: Persist data in named volumes, not containers
3. **Health checks**: Wait for services to be healthy before starting dependents
4. **Logs**: Monitor logs regularly: `docker-compose logs -f`
5. **Cleanup**: Remove unused containers/images periodically
6. **Backup**: Regularly backup `postgres_data` volume
7. **Updates**: Keep Docker images updated: `docker-compose pull`

## Additional Resources

- [Docker Documentation](https://docs.docker.com)
- [Docker Compose Documentation](https://docs.docker.com/compose)
- [Rails Docker Guide](https://guides.rubyonrails.org/getting_started_with_devcontainer.html)
- [Vite Docker Guide](https://vitejs.dev/guide/static-deploy.html)

## Support

For issues or questions:
1. Check logs: `docker-compose logs -f`
2. Verify all services are healthy: `docker-compose ps`
3. Review this documentation
4. Check project README.md
