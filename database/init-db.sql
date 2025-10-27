-- Initialize Konecta ERP Database
-- This script runs when the PostgreSQL container starts for the first time

-- Create the main database (already created by POSTGRES_DB env var)
-- But we can add any additional setup here

-- Create extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create a test user for development (optional)
-- This is just for testing purposes
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'konecta_dev') THEN
        CREATE ROLE konecta_dev WITH LOGIN PASSWORD 'dev123';
        GRANT ALL PRIVILEGES ON DATABASE konecta_erp TO konecta_dev;
    END IF;
END
$$;

-- Grant permissions
GRANT ALL PRIVILEGES ON SCHEMA public TO postgres;
GRANT ALL PRIVILEGES ON SCHEMA public TO konecta_dev;

-- Set timezone
SET timezone = 'UTC';

-- Log successful initialization
DO $$
BEGIN
    RAISE NOTICE 'Konecta ERP database initialized successfully!';
END
$$;
