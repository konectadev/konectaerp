#!/bin/bash
set -e

echo "Starting AuthenticationService..."

# Wait for database to be ready (optional)
if [ -n "$DB_HOST" ]; then
    echo "Waiting for database to be ready..."
    until nc -z $DB_HOST ${DB_PORT:-5432}; do
        echo "Database is unavailable - sleeping"
        sleep 1
    done
    echo "Database is up - executing command"
fi

# Run database migrations if needed (only if EF tools are available)
if [ "$RUN_MIGRATIONS" = "true" ]; then
    echo "Checking for EF tools..."
    if command -v dotnet-ef >/dev/null 2>&1; then
        echo "Running database migrations..."
        dotnet ef database update --no-build
    else
        echo "EF tools not available in runtime container. Skipping migrations."
        echo "Migrations should be run during build or in a separate migration container."
    fi
fi

# Start the application
echo "Starting the application..."
exec dotnet app/AuthenticationService.dll
