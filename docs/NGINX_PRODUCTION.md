# Nginx & Production Deployment Guide

## Overview

This guide explains the production architecture with Nginx as a reverse proxy and provides deployment instructions.

## Architecture Comparison

### Development (Current)
```
┌─────────┐     :5175      ┌──────────────┐
│ Browser │ ───────────────► Vite Dev     │
│         │                 │ (HMR)        │
└─────────┘                 └──────────────┘
     │
     │ :3000
     │
     ▼
┌──────────────┐
│ Rails API    │
└──────────────┘
```

### Production (Recommended)
```
┌─────────┐     :80/:443     ┌──────────────┐
│ Browser │ ─────────────────► Nginx        │
└─────────┘                   └──────┬───────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
              ┌──────────┐    ┌──────────┐    ┌──────────┐
              │ Static   │    │ Rails    │    │ Rails    │
              │ Files    │    │ API #1   │    │ API #2   │
              │ (React)  │    └──────────┘    └──────────┘
              └──────────┘
```

## Why Nginx in Production?

### 1. **Performance**
- **Static File Serving**: Nginx serves React build files 10x faster than Rails
- **Compression**: Built-in gzip reduces bandwidth by 60-80%
- **Connection Pooling**: Efficient handling of concurrent requests
- **Caching**: Reduces backend load for static assets

### 2. **Security**
- **SSL/TLS Termination**: Centralized certificate management
- **Rate Limiting**: Protects against DDoS and brute-force attacks
- **Request Filtering**: Blocks malicious requests
- **Headers**: Adds security headers (HSTS, CSP, etc.)

### 3. **Scalability**
- **Load Balancing**: Distribute traffic across multiple backend instances
- **Health Checks**: Automatic failover for unhealthy backends
- **Zero-Downtime Deploys**: Rolling updates without service interruption

### 4. **Simplicity**
- **Single Entry Point**: One domain, one port (80/443)
- **Unified Logging**: All requests in one place
- **Easy Monitoring**: Centralized metrics and health checks

## Quick Start (Production with Nginx)

### 1. Build Frontend

```bash
cd frontend
npm run build
# Creates frontend/dist/ with optimized static files
```

### 2. Configure Environment

```bash
cp .env.production.example .env.production
# Edit .env.production with your production credentials
```

### 3. Start Production Stack

```bash
# Build and start all services
docker-compose -f docker-compose.prod.yml up -d --build

# Setup database (first time only)
docker-compose -f docker-compose.prod.yml exec backend bundle exec rails db:create db:migrate db:seed
```

### 4. Access Application

- **Application**: http://localhost (port 80)
- **API**: http://localhost/api/v1
- **Health Check**: http://localhost/health

## Nginx Configuration

### Main Configuration (`nginx/nginx.conf`)

Key settings:
- **Worker Processes**: Auto-scales with CPU cores
- **Gzip Compression**: Enabled for text/json/js/css
- **Client Max Body Size**: 20MB (for image uploads)
- **Rate Limiting**: 10 req/s for API, 5 req/m for auth

### Site Configuration (`nginx/sites-enabled/shophub.conf`)

#### API Routing
```nginx
location /api/ {
    proxy_pass http://backend_api;
    # Rate limiting: 10 req/s, burst 20
    limit_req zone=api_limit burst=20 nodelay;
}
```

#### Static Files (React)
```nginx
location / {
    root /var/www/frontend;
    try_files $uri $uri/ /index.html;  # React Router support
}
```

#### Caching Strategy
- **Static Assets** (js/css/images): 1 year
- **ActiveStorage Files**: 1 hour
- **API Responses**: No cache (dynamic data)

## SSL/HTTPS Setup

### Option 1: Let's Encrypt (Recommended)

Install Certbot:
```bash
# On host machine
sudo apt-get install certbot python3-certbot-nginx

# Generate certificate
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal (certbot installs cron job automatically)
```

### Option 2: Custom Certificate

Place your certificates in `nginx/ssl/`:
```bash
nginx/ssl/
├── fullchain.pem    # Certificate + intermediate chain
└── privkey.pem      # Private key
```

Uncomment HTTPS server block in `nginx/sites-enabled/shophub.conf`.

## Load Balancing

To run multiple backend instances:

### 1. Update `docker-compose.prod.yml`

```yaml
services:
  backend:
    deploy:
      replicas: 3  # Run 3 instances
```

### 2. Update Nginx upstream

```nginx
upstream backend_api {
    least_conn;  # Load balancing algorithm
    server backend1:3000;
    server backend2:3000;
    server backend3:3000;
    keepalive 32;
}
```

## Monitoring & Logs

### View Nginx Logs

```bash
# Access logs
docker-compose -f docker-compose.prod.yml exec nginx tail -f /var/log/nginx/access.log

# Error logs
docker-compose -f docker-compose.prod.yml exec nginx tail -f /var/log/nginx/error.log

# Application-specific logs
docker-compose -f docker-compose.prod.yml exec nginx tail -f /var/log/nginx/shophub.access.log
```

### Nginx Status

```bash
# Test configuration
docker-compose -f docker-compose.prod.yml exec nginx nginx -t

# Reload configuration (no downtime)
docker-compose -f docker-compose.prod.yml exec nginx nginx -s reload
```

## Performance Tuning

### 1. Worker Connections
Increase for high traffic:
```nginx
events {
    worker_connections 4096;  # Default: 1024
}
```

### 2. Caching
Increase cache size:
```nginx
proxy_cache_path /var/cache/nginx levels=1:2 
                 keys_zone=my_cache:100m  # Default: 10m
                 max_size=10g;            # Default: 1g
```

### 3. Compression Level
Balance CPU vs bandwidth:
```nginx
gzip_comp_level 6;  # 1 (fast) to 9 (best compression)
```

## Troubleshooting

### 502 Bad Gateway

**Cause**: Backend not responding

**Solutions**:
```bash
# Check backend status
docker-compose -f docker-compose.prod.yml ps backend

# Check backend logs
docker-compose -f docker-compose.prod.yml logs backend

# Restart backend
docker-compose -f docker-compose.prod.yml restart backend
```

### 413 Request Entity Too Large

**Cause**: File upload exceeds limit

**Solution**: Increase in `nginx.conf`:
```nginx
client_max_body_size 50M;  # Default: 20M
```

### Rate Limit Errors (429)

**Cause**: Too many requests

**Solutions**:
1. Increase rate in `nginx.conf`:
   ```nginx
   limit_req_zone $binary_remote_addr zone=api_limit:10m rate=20r/s;
   ```
2. Increase burst in site config:
   ```nginx
   limit_req zone=api_limit burst=50 nodelay;
   ```

### Static Files Not Updating

**Cause**: Browser/nginx cache

**Solutions**:
```bash
# Clear nginx cache
docker-compose -f docker-compose.prod.yml exec nginx rm -rf /var/cache/nginx/*

# Rebuild frontend
cd frontend && npm run build

# Restart nginx
docker-compose -f docker-compose.prod.yml restart nginx
```

## Security Best Practices

### 1. Hide Nginx Version
```nginx
http {
    server_tokens off;
}
```

### 2. Add Security Headers
```nginx
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Content-Security-Policy "default-src 'self'" always;
```

### 3. Restrict Request Methods
```nginx
if ($request_method !~ ^(GET|HEAD|POST|PUT|PATCH|DELETE|OPTIONS)$) {
    return 405;
}
```

### 4. Block Suspicious User Agents
```nginx
if ($http_user_agent ~* (bot|scanner|crawler)) {
    return 403;
}
```

## Deployment Checklist

- [ ] Build frontend: `npm run build`
- [ ] Set production environment variables in `.env.production`
- [ ] Generate SECRET_KEY_BASE: `bundle exec rails secret`
- [ ] Setup SSL certificates (Let's Encrypt or custom)
- [ ] Configure domain DNS records
- [ ] Run database migrations: `rails db:migrate`
- [ ] Seed initial data (if needed): `rails db:seed`
- [ ] Test API: `curl http://yourdomain.com/api/v1/health`
- [ ] Test frontend: Visit `http://yourdomain.com`
- [ ] Setup monitoring (optional): Sentry, New Relic, etc.
- [ ] Configure backups: Database and uploaded files
- [ ] Setup log rotation
- [ ] Enable firewall: Allow only 80, 443, 22

## Cost Comparison

### Option 1: No Nginx (Separate Ports)
```
- Load Balancer (AWS ALB): $16/month
- Frontend Instance (t3.micro): $8/month
- Backend Instance (t3.small): $17/month
Total: ~$41/month
```

### Option 2: With Nginx (Recommended)
```
- Single Instance (t3.small): $17/month
- Nginx (included, no cost)
- Savings: $24/month (58% cheaper)
```

## Next Steps

1. **Monitoring**: Add Prometheus + Grafana for metrics
2. **CI/CD**: Automate deployments with GitHub Actions
3. **CDN**: Add Cloudflare for global static asset delivery
4. **Database**: Setup PostgreSQL replication for high availability
5. **Redis**: Configure Redis Sentinel for failover

## Resources

- [Nginx Official Docs](https://nginx.org/en/docs/)
- [Nginx Best Practices](https://www.nginx.com/blog/nginx-best-practices/)
- [Rails Asset Pipeline](https://guides.rubyonrails.org/asset_pipeline.html)
- [Docker Compose Production](https://docs.docker.com/compose/production/)
- [Let's Encrypt](https://letsencrypt.org/)

## Summary

**Development**: Keep current setup (no nginx)
**Production**: Use nginx for better performance, security, and cost savings

Questions? Check logs first: `docker-compose -f docker-compose.prod.yml logs`
