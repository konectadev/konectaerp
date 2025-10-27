#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== Konecta ERP Deployment ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() {
    echo -e "${GREEN}[$(date +'%T')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%T')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%T')] ERROR: $1${NC}"
    exit 1
}

# Cleanup function
cleanup() {
    log "Cleaning up..."
    podman stop konecta-postgres-custom konecta-auth-service konecta-frontend 2>/dev/null || true
    podman rm konecta-postgres-custom konecta-auth-service konecta-frontend 2>/dev/null || true
}

# Trap Ctrl+C
trap cleanup SIGINT

# Create network
log "Creating network..."
podman network create konecta-network 2>/dev/null && log "Network created" || log "Network already exists"

# Build PostgreSQL image with custom config
log "Building PostgreSQL image with custom configuration..."
podman build -t konecta-postgres-custom -f database/Dockerfile database/ || error "Failed to build PostgreSQL image"

# Start PostgreSQL with custom config
echo "Starting PostgreSQL with custom configuration..."
podman run -d \
  --name konecta-postgres \
  --network konecta-network \
  -e POSTGRES_DB=konecta_erp \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres123 \
  -e POSTGRES_INITDB_ARGS="--encoding=UTF-8" \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  konecta-postgres-custom

# Wait for PostgreSQL and database setup
echo "Waiting for database setup..."
sleep 10

# Test database setup
echo "Testing database setup..."
podman exec konecta-postgres-custom psql -U postgres -d konecta_erp -c "SELECT COUNT(*) as user_count FROM users;" || echo "Database not ready yet, waiting..."
sleep 5

# Build and start Authentication Service
log "Building Authentication Service..."
if [ -d "backend/AuthenticationService" ]; then
    cd backend/AuthenticationService
    podman build -t authentication-service . || error "Failed to build authentication service"
    
    log "Starting Authentication Service..."
    podman run -d \
      --name konecta-auth-service \
      --network konecta-network \
      -e ASPNETCORE_ENVIRONMENT=Development \
      -e ASPNETCORE_URLS=http://+:5001 \
      -e "ConnectionStrings__DefaultConnection=Host=konecta-postgres;Port=5432;Database=konecta_erp;Username=postgres;Password=postgres123" \
      -e JwtSettings__SecretKey=YourSuperSecretKeyForJWTTokenGenerationMinimum32Characters \
      -e JwtSettings__Issuer=KonectaERP \
      -e JwtSettings__Audience=KonectaERPUsers \
      -e JwtSettings__ExpirationMinutes=60 \
      -e Consul__Enabled=false \
      -e RUN_MIGRATIONS=true \
      -p 5001:5001 \
      authentication-service || error "Failed to start authentication service"
    
    cd ../..
else
    warn "AuthenticationService directory not found. Skipping."
fi

# Build and start Frontend
log "Building Frontend..."
if [ -d "frontend" ] && [ -f "frontend/Dockerfile" ]; then
    cd frontend
    podman build -t frontend . || warn "Failed to build frontend"
    
    log "Starting Frontend..."
    podman run -d \
      --name konecta-frontend \
      --network konecta-network \
      -e NODE_ENV=production \
      -p 4200:80 \
      frontend || warn "Failed to start frontend"
    
    cd ..
else
    warn "Frontend directory or Dockerfile not found. Skipping frontend."
fi

# Health checks
log "Performing health checks..."
sleep 10

log "Checking services..."
echo "PostgreSQL: $(podman inspect --format='{{.State.Status}}' konecta-postgres-custom)"
echo "Auth Service: $(podman inspect --format='{{.State.Status}}' konecta-auth-service)"
if podman ps --format "table {{.Names}}\t{{.Status}}" | grep -q konecta-frontend; then
    echo "Frontend: $(podman inspect --format='{{.State.Status}}' konecta-frontend)"
fi

echo ""
log "=== Deployment Complete ==="
echo ""
echo "Services:"
echo "  PostgreSQL Database: localhost:5432"
echo "  Authentication API:  localhost:5001"
echo "  Frontend:           localhost:4200"
echo ""
echo "Management Commands:"
echo "  View all containers: podman ps"
echo "  View logs:          podman logs <container-name>"
echo "  Stop services:      podman stop konecta-postgres-custom konecta-auth-service konecta-frontend"
echo "  Remove services:    podman rm konecta-postgres-custom konecta-auth-service konecta-frontend"
echo ""