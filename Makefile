.PHONY: help start stop restart logs logs-backend logs-frontend status setup test lint clean

# Colors for output
GREEN  := \033[0;32m
YELLOW := \033[0;33m
RED    := \033[0;31m
NC     := \033[0m # No Color

# Paths
BACKEND_DIR := .
FRONTEND_DIR := frontend
BACKEND_PID := tmp/pids/server.pid
FRONTEND_PID := tmp/pids/frontend.pid
LOG_DIR := log

help: ## Show this help message
	@echo "$(GREEN)ShopHub - E-commerce Application$(NC)"
	@echo ""
	@echo "Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

setup: ## Install dependencies for both backend and frontend
	@echo "$(GREEN)Installing backend dependencies...$(NC)"
	bundle install
	@echo "$(GREEN)Installing frontend dependencies...$(NC)"
	cd $(FRONTEND_DIR) && npm install
	@echo "$(GREEN)Setting up database...$(NC)"
	rails db:create db:migrate db:seed
	@echo "$(GREEN)Setup complete!$(NC)"

start: ## Start both backend and frontend servers
	@echo "$(GREEN)Starting ShopHub application...$(NC)"
	@mkdir -p tmp/pids $(LOG_DIR)
	@if [ -f $(BACKEND_PID) ]; then \
		echo "$(YELLOW)Backend is already running (PID: $$(cat $(BACKEND_PID)))$(NC)"; \
	else \
		echo "$(GREEN)Starting Rails backend...$(NC)"; \
		rails server > $(LOG_DIR)/backend.log 2>&1 & echo $$! > $(BACKEND_PID); \
		echo "$(GREEN)Backend started (PID: $$(cat $(BACKEND_PID)))$(NC)"; \
	fi
	@if [ -f $(FRONTEND_PID) ]; then \
		echo "$(YELLOW)Frontend is already running (PID: $$(cat $(FRONTEND_PID)))$(NC)"; \
	else \
		echo "$(GREEN)Starting React frontend...$(NC)"; \
		cd $(FRONTEND_DIR) && npm run dev > ../$(LOG_DIR)/frontend.log 2>&1 & echo $$! > ../$(FRONTEND_PID); \
		echo "$(GREEN)Frontend started (PID: $$(cat $(FRONTEND_PID)))$(NC)"; \
	fi
	@echo ""
	@echo "$(GREEN)✓ Application started!$(NC)"
	@echo "  Backend:  http://localhost:3000"
	@echo "  Frontend: http://localhost:5173"
	@echo ""
	@echo "View logs with: make logs"

stop: ## Stop both backend and frontend servers
	@echo "$(RED)Stopping ShopHub application...$(NC)"
	@if [ -f $(BACKEND_PID) ]; then \
		kill -TERM $$(cat $(BACKEND_PID)) 2>/dev/null || true; \
		rm -f $(BACKEND_PID); \
		echo "$(RED)Backend stopped$(NC)"; \
	else \
		echo "$(YELLOW)Backend is not running$(NC)"; \
	fi
	@if [ -f $(FRONTEND_PID) ]; then \
		kill -TERM $$(cat $(FRONTEND_PID)) 2>/dev/null || true; \
		rm -f $(FRONTEND_PID); \
		echo "$(RED)Frontend stopped$(NC)"; \
	else \
		echo "$(YELLOW)Frontend is not running$(NC)"; \
	fi
	@echo "$(RED)✓ Application stopped$(NC)"

restart: stop start ## Restart both servers

status: ## Check status of backend and frontend servers
	@echo "$(GREEN)ShopHub Application Status$(NC)"
	@echo ""
	@if [ -f $(BACKEND_PID) ] && kill -0 $$(cat $(BACKEND_PID)) 2>/dev/null; then \
		echo "  Backend:  $(GREEN)✓ Running$(NC) (PID: $$(cat $(BACKEND_PID)))"; \
	else \
		echo "  Backend:  $(RED)✗ Stopped$(NC)"; \
		rm -f $(BACKEND_PID); \
	fi
	@if [ -f $(FRONTEND_PID) ] && kill -0 $$(cat $(FRONTEND_PID)) 2>/dev/null; then \
		echo "  Frontend: $(GREEN)✓ Running$(NC) (PID: $$(cat $(FRONTEND_PID)))"; \
	else \
		echo "  Frontend: $(RED)✗ Stopped$(NC)"; \
		rm -f $(FRONTEND_PID); \
	fi
	@echo ""

logs: ## View logs from both backend and frontend (tail -f)
	@if [ ! -f $(LOG_DIR)/backend.log ] && [ ! -f $(LOG_DIR)/frontend.log ]; then \
		echo "$(YELLOW)No log files found. Start the application first with 'make start'$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Viewing logs (Ctrl+C to exit)...$(NC)"
	@tail -f $(LOG_DIR)/backend.log $(LOG_DIR)/frontend.log 2>/dev/null || true

logs-backend: ## View backend logs only
	@if [ ! -f $(LOG_DIR)/backend.log ]; then \
		echo "$(YELLOW)Backend log not found$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Backend logs (Ctrl+C to exit)...$(NC)"
	@tail -f $(LOG_DIR)/backend.log

logs-frontend: ## View frontend logs only
	@if [ ! -f $(LOG_DIR)/frontend.log ]; then \
		echo "$(YELLOW)Frontend log not found$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)Frontend logs (Ctrl+C to exit)...$(NC)"
	@tail -f $(LOG_DIR)/frontend.log

logs-rails: ## View Rails development log
	@tail -f $(LOG_DIR)/development.log

test: ## Run tests for both backend and frontend
	@echo "$(GREEN)Running backend tests...$(NC)"
	bundle exec rspec
	@echo ""
	@echo "$(GREEN)Running frontend tests...$(NC)"
	cd $(FRONTEND_DIR) && npm test

test-backend: ## Run backend tests only
	@echo "$(GREEN)Running backend tests...$(NC)"
	bundle exec rspec

test-frontend: ## Run frontend tests only
	@echo "$(GREEN)Running frontend tests...$(NC)"
	cd $(FRONTEND_DIR) && npm test

lint: ## Run linters for both backend and frontend
	@echo "$(GREEN)Running RuboCop...$(NC)"
	bundle exec rubocop
	@echo ""
	@echo "$(GREEN)Running ESLint...$(NC)"
	cd $(FRONTEND_DIR) && npm run lint

lint-fix: ## Auto-fix linting issues
	@echo "$(GREEN)Auto-fixing RuboCop issues...$(NC)"
	bundle exec rubocop --autocorrect-all
	@echo ""
	@echo "$(GREEN)Auto-fixing ESLint issues...$(NC)"
	cd $(FRONTEND_DIR) && npm run lint -- --fix

console: ## Open Rails console
	@rails console

db-migrate: ## Run database migrations
	@rails db:migrate

db-reset: ## Reset database (drop, create, migrate, seed)
	@echo "$(RED)WARNING: This will destroy all data!$(NC)"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	@rails db:drop db:create db:migrate db:seed

db-seed: ## Seed database with sample data
	@rails db:seed

clean: ## Clean temporary files and logs
	@echo "$(GREEN)Cleaning temporary files...$(NC)"
	@rm -f $(BACKEND_PID) $(FRONTEND_PID)
	@rm -f $(LOG_DIR)/backend.log $(LOG_DIR)/frontend.log
	@echo "$(GREEN)Clean complete!$(NC)"

build: ## Build frontend for production
	@echo "$(GREEN)Building frontend for production...$(NC)"
	cd $(FRONTEND_DIR) && npm run build
	@echo "$(GREEN)Build complete!$(NC)"

stripe-webhook: ## Start Stripe webhook listener (requires Stripe CLI)
	@echo "$(GREEN)Starting Stripe webhook listener...$(NC)"
	@stripe listen --forward-to localhost:3000/api/v1/payments/webhook

# Docker commands
docker-build: ## Build Docker containers
	@echo "$(GREEN)Building Docker containers...$(NC)"
	docker-compose build

docker-up: ## Start application in Docker
	@echo "$(GREEN)Starting Docker containers...$(NC)"
	docker-compose up -d
	@echo ""
	@echo "$(GREEN)✓ Docker containers started!$(NC)"
	@echo "  Backend:  http://localhost:3000"
	@echo "  Frontend: http://localhost:5175"
	@echo ""
	@echo "View logs with: make docker-logs"

docker-down: ## Stop Docker containers
	@echo "$(RED)Stopping Docker containers...$(NC)"
	docker-compose down
	@echo "$(RED)✓ Docker containers stopped$(NC)"

docker-restart: docker-down docker-up ## Restart Docker containers

docker-logs: ## View Docker logs
	docker-compose logs -f

docker-logs-backend: ## View Docker backend logs
	docker-compose logs -f backend

docker-logs-frontend: ## View Docker frontend logs
	docker-compose logs -f frontend

docker-ps: ## List Docker containers status
	docker-compose ps

docker-exec-backend: ## Execute bash in backend container
	docker-compose exec backend bash

docker-exec-frontend: ## Execute sh in frontend container
	docker-compose exec frontend sh

docker-db-setup: ## Setup database in Docker
	@echo "$(GREEN)Setting up database in Docker...$(NC)"
	docker-compose exec backend bundle exec rails db:create db:migrate db:seed
	@echo "$(GREEN)Database setup complete!$(NC)"

docker-db-migrate: ## Run migrations in Docker
	docker-compose exec backend bundle exec rails db:migrate

docker-db-reset: ## Reset database in Docker
	@echo "$(RED)WARNING: This will destroy all data in Docker!$(NC)"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	docker-compose exec backend bundle exec rails db:drop db:create db:migrate db:seed

docker-test: ## Run tests in Docker
	@echo "$(GREEN)Running tests in Docker...$(NC)"
	docker-compose exec backend bash -c "RAILS_ENV=test DATABASE_URL=postgresql://postgres:postgres@db:5432/shop_hub_test bundle exec rspec"

docker-console: ## Open Rails console in Docker
	docker-compose exec backend bundle exec rails console

docker-clean: ## Remove Docker containers, networks, and volumes
	@echo "$(RED)WARNING: This will remove all Docker data including volumes!$(NC)"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ] || exit 1
	docker-compose down -v
	docker system prune -f
	@echo "$(RED)Docker cleanup complete!$(NC)"

.DEFAULT_GOAL := help
