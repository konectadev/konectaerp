#!/bin/bash
set -e

echo "=== Fixing PostgreSQL Authentication Configuration ==="
echo ""
echo "This script will:"
echo "  1. Stop and remove existing containers"
echo "  2. Remove the old postgres volume (this will DELETE existing data)"
echo "  3. Rebuild and restart with proper pg_hba.conf"
echo ""
read -p "Continue? This will delete existing database data! (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Stopping containers..."
podman stop konecta-postgres konecta-auth-service konecta-frontend 2>/dev/null || true

echo "Removing containers..."
podman rm konecta-postgres konecta-auth-service konecta-frontend 2>/dev/null || true

echo "Removing old postgres volume..."
podman volume rm postgres_data 2>/dev/null || true

echo ""
echo "Now running the startup script..."
./startup.sh

echo ""
echo "=== Done ==="
echo "The database has been recreated with proper authentication configuration."
echo "The error 'no pg_hba.conf entry for host 10.89.0.4' should now be resolved."

