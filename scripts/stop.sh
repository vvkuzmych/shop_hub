#!/bin/bash

# ShopHub - Stop Both Backend and Frontend
# Usage: ./scripts/stop.sh

echo "=========================================="
echo "🛑 Stopping ShopHub Application"
echo "=========================================="
echo ""

# Stop Rails server
RAILS_PID=$(lsof -ti:3000 2>/dev/null)
if [ ! -z "$RAILS_PID" ]; then
  echo "🔧 Stopping Rails API (PID: $RAILS_PID)..."
  kill -9 $RAILS_PID
  echo "✅ Rails API stopped"
else
  echo "ℹ️  Rails API not running"
fi

echo ""

# Stop Vite server
VITE_PID=$(lsof -ti:5173 2>/dev/null)
if [ ! -z "$VITE_PID" ]; then
  echo "🎨 Stopping React Frontend (PID: $VITE_PID)..."
  kill -9 $VITE_PID
  echo "✅ React Frontend stopped"
else
  echo "ℹ️  React Frontend not running"
fi

echo ""
echo "=========================================="
echo "✅ ShopHub stopped"
echo "=========================================="
echo ""
