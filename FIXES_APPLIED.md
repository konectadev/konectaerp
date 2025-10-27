# Fixes Applied for PostgreSQL Authentication Error

## Issues Fixed

### 1. PostgreSQL Authentication Configuration
**Error:** `no pg_hba.conf entry for host "10.89.0.4"`

**Root Cause:** The PostgreSQL container wasn't using the custom `pg_hba.conf` file that allows Docker network connections.

**Changes Made:**
- Updated `docker-compose.yml` to build postgres from custom Dockerfile
- Modified `database/Dockerfile` to properly copy and apply `pg_hba.conf` during initialization
- Created `database/init-pg-hba.sh` script to copy custom HBA config to data directory
- Fixed container name inconsistencies in `startup.sh`

### 2. Database Tables Not Created / Wrong Table Names
**Error:** `relation "Users" does not exist`

**Root Causes:**
1. EF Core wasn't automatically creating the database tables on startup
2. Database had lowercase tables from `init-database.sql` but EF Core expected uppercase table names
3. PostgreSQL translates unquoted identifiers to lowercase by default

**Changes Made:**
- Added automatic database creation code to `Program.cs` using `EnsureCreated()`
- Removed `init-database.sql` from Dockerfile (EF Core manages table creation)
- Added explicit table name configuration in `AuthDbContext.cs` (Users, Roles, UserRoles)
- Application now creates tables automatically when `RUN_MIGRATIONS=true`

## Files Modified

1. `docker-compose.yml` - Build postgres from custom Dockerfile
2. `database/Dockerfile` - Remove init-database.sql, add initialization script
3. `database/init-pg-hba.sh` - Copy custom pg_hba.conf
4. `startup.sh` - Fix container name references
5. `backend/AuthenticationService/Program.cs` - Add database auto-creation
6. `backend/AuthenticationService/Data/AuthDbContext.cs` - Add explicit table names
7. `database/setup-postgres.sh` - Removed (replaced by init-pg-hba.sh)
8. `fix-postgres-auth.sh` - Created helper script

## How to Apply the Fixes

You have two options:

### Option 1: Use the Fix Script (Recommended)
```bash
./fix-postgres-auth.sh
```

This will:
1. Stop all existing containers
2. Remove the postgres volume (delete existing data)
3. Rebuild everything with the new configuration
4. Start all services

### Option 2: Manual Steps
```bash
# Stop and remove containers
podman stop konecta-postgres konecta-auth-service konecta-frontend
podman rm konecta-postgres konecta-auth-service konecta-frontend

# Remove the postgres volume to get fresh database
podman volume rm postgres_data

# Rebuild and start
./startup.sh
```

## Expected Results

After applying the fixes:
- ✅ PostgreSQL will accept connections from Docker networks (10.x.x.x, 172.16.x.x, 192.168.x.x)
- ✅ Database tables (Users, Roles, UserRoles) will be created automatically
- ✅ Authentication service will connect successfully
- ✅ No more "no pg_hba.conf entry" errors
- ✅ No more "relation does not exist" errors

## Verification

After running the startup script, verify with:

```bash
# Check postgres logs
podman logs konecta-postgres

# Check auth service logs
podman logs konecta-auth-service

# Test the API
curl http://localhost:5001/health
```

