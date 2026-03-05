# ShopHub - Quick Start Guide

## 🚀 Start Application

### Option 1: Docker (Recommended) 🐳

```bash
# Build and start
docker-compose up -d

# Setup database (first time only)
docker-compose exec backend rails db:create db:migrate db:seed
```

### Option 2: Local Development

```bash
cd /Users/vkuzm/RubymineProjects/shop_hub
./scripts/start.sh
```

### Option 3: Using Makefile

```bash
# Local
make start

# Docker
make docker-up
```

## 🌐 Access URLs

| Service | URL |
|---------|-----|
| **Frontend** | http://localhost:5175 |
| **Backend API** | http://localhost:3000 |
| **Swagger Docs** | http://localhost:3000/api-docs |

## 🔑 Login Credentials

```
Email: admin@shophub.com
Password: password
```

## 🧪 Test API (Without UI)

```bash
./scripts/api_tests/6_complete_workflow.sh
```

## 🛑 Stop Application

```bash
# Local development
./scripts/stop.sh
# or
make stop

# Docker
docker-compose down
# or
make docker-down
```

## 📊 Project Stats

- **Backend**: Rails 8.1 + PostgreSQL
- **Frontend**: React 18 + TypeScript + Tailwind
- **Tests**: 200 passing ✅
- **Code Quality**: RuboCop clean ✅
- **Build**: Production ready ✅

## 💡 What You Can Do

1. **Browse Products** → http://localhost:5175/products
2. **Search & Filter** → Price, category, stock
3. **Add to Cart** → Manage quantities
4. **Place Orders** → Complete checkout
5. **View Orders** → Track order status
6. **Admin Panel** → Manage products/orders

## 🏗️ Tech Stack

**Backend:**
- Ruby 3.3.6
- Rails 8.1.2 (API mode)
- PostgreSQL
- Devise + JWT
- RSpec (200 tests)

**Frontend:**
- React 18 + TypeScript
- Vite
- Tailwind CSS v4
- React Router v6
- Zustand
- Axios

## 📚 Full Documentation

- `README.md` - Complete guide
- `docs/DOCKER.md` - Docker setup guide 🐳
- `FRONTEND_SETUP.md` - Frontend details
- `FULLSTACK_SUMMARY.md` - Full overview
- `frontend/README.md` - Frontend dev guide

---

**Status: READY TO USE** ✨

Open http://localhost:5175 and start shopping! 🛍️
