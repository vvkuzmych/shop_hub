#!/bin/bash

# ShopHub - Start Both Backend and Frontend
# Usage: ./scripts/start.sh

echo "=========================================="
echo "🚀 Starting ShopHub Application"
echo "=========================================="
echo ""

# Check if Rails server is already running
RAILS_PID=$(lsof -ti:3000 2>/dev/null)
if [ ! -z "$RAILS_PID" ]; then
  echo "⚠️  Rails server already running (PID: $RAILS_PID)"
  echo "   Backend: http://localhost:3000"
else
  echo "🔧 Starting Rails API..."
  cd "$(dirname "$0")/.."
  rails server -d
  echo "✅ Rails API started on http://localhost:3000"
fi

echo ""

# Check if Vite server is already running
VITE_PID=$(lsof -ti:5173 2>/dev/null)
if [ ! -z "$VITE_PID" ]; then
  echo "⚠️  Vite server already running (PID: $VITE_PID)"
  echo "   Frontend: http://localhost:5173"
else
  echo "🎨 Starting React Frontend..."
  cd "$(dirname "$0")/../frontend"
  npm run dev &
  echo "✅ React Frontend starting on http://localhost:5173"
fi

echo ""
echo "=========================================="
echo "✅ ShopHub is running!"
echo "=========================================="
echo ""
echo "📝 Access points:"
echo "   • Frontend: http://localhost:5173"
echo "   • Backend API: http://localhost:3000/api/v1"
echo "   • Swagger Docs: http://localhost:3000/api-docs"
echo ""
echo "🔑 Test credentials:"
echo "   Email: admin@shophub.com"
echo "   Password: password"
echo ""
echo "🛑 To stop:"
echo "   ./scripts/stop.sh"
echo ""
