#!/bin/bash

echo "=== Testing Database Connection and Setup ==="

# Test connection
echo "1. Testing database connection..."
podman exec konecta-postgres psql -U postgres -d konecta_erp -c "SELECT version();"

# Check if users table exists
echo ""
echo "2. Checking users table..."
podman exec konecta-postgres psql -U postgres -d konecta_erp -c "
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'Users' 
ORDER BY ordinal_position;"

# Check if admin user exists
echo ""
echo "3. Checking admin user..."
podman exec konecta-postgres psql -U postgres -d konecta_erp -c 'SELECT * FROM "Users" ;'


# Count tables
echo ""
echo "4. Counting tables..."
podman exec konecta-postgres psql -U postgres -d konecta_erp -c "
SELECT 
    COUNT(*) as table_count
FROM information_schema.tables 
WHERE table_schema = 'public';"

# Show database size
echo ""
echo "5. Database size and info..."
podman exec konecta-postgres psql -U postgres -d konecta_erp -c "
SELECT 
    pg_size_pretty(pg_database_size('konecta_erp')) as db_size,
    (SELECT COUNT(*) FROM Users) as user_count,
    (SELECT COUNT(*) FROM refresh_tokens) as token_count;"