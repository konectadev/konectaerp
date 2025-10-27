-- Development setup for PostgreSQL
-- This script provides additional development configurations

-- Create development-specific schemas
CREATE SCHEMA IF NOT EXISTS dev;
CREATE SCHEMA IF NOT EXISTS test;

-- Set up development user with more permissions
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'konecta_dev') THEN
        CREATE ROLE konecta_dev WITH LOGIN PASSWORD 'dev123';
        GRANT ALL PRIVILEGES ON DATABASE konecta_erp TO konecta_dev;
        GRANT ALL PRIVILEGES ON SCHEMA public TO konecta_dev;
        GRANT ALL PRIVILEGES ON SCHEMA dev TO konecta_dev;
        GRANT ALL PRIVILEGES ON SCHEMA test TO konecta_dev;
    END IF;
END
$$;

-- Create test database for unit tests
SELECT 'CREATE DATABASE konecta_erp_test'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'konecta_erp_test')\gexec

-- Grant permissions on test database
GRANT ALL PRIVILEGES ON DATABASE konecta_erp_test TO postgres;
GRANT ALL PRIVILEGES ON DATABASE konecta_erp_test TO konecta_dev;

-- Enable useful extensions for development
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Set up logging for development
ALTER SYSTEM SET log_statement = 'all';
ALTER SYSTEM SET log_min_duration_statement = 0;
ALTER SYSTEM SET log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ';

-- Reload configuration
SELECT pg_reload_conf();

-- Log successful development setup
DO $$
BEGIN
    RAISE NOTICE 'Development database setup completed successfully!';
    RAISE NOTICE 'Main database: konecta_erp';
    RAISE NOTICE 'Test database: konecta_erp_test';
    RAISE NOTICE 'Development user: konecta_dev (password: dev123)';
END
$$;
