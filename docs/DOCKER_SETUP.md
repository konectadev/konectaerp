# Docker Compose Setup for Konecta ERP

This guide explains how to run the Konecta ERP system using Docker Compose for testing and development.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- At least 4GB RAM available for containers
- Ports 4200, 5001, 5432, 8500 available

### Basic Setup (Frontend + Auth + Database)

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

### Access Points
- **Frontend**: http://localhost:4200
- **Authentication API**: http://localhost:5001
- **API Documentation**: http://localhost:5001/swagger
- **Database**: localhost:5432 (postgres/postgres123)

## 📋 Services Overview

### Core Services (Always Running)
- **postgres**: PostgreSQL 15 database
- **authentication-service**: .NET 8 Authentication API
- **frontend**: Angular frontend application

### Optional Services (Use Profiles)
- **consul**: Service discovery (use `--profile consul`)
- **redis**: Caching service (use `--profile cache`)

## 🔧 Configuration

### Environment Variables

#### PostgreSQL
```yaml
POSTGRES_DB: konecta_erp
POSTGRES_USER: postgres
POSTGRES_PASSWORD: postgres123
```

#### Authentication Service
```yaml
ConnectionStrings__DefaultConnection: Host=postgres;Port=5432;Database=konecta_erp;Username=postgres;Password=postgres123
JwtSettings__SecretKey: YourSuperSecretKeyForJWTTokenGenerationMinimum32Characters
JwtSettings__ExpirationMinutes: 60
```

## 🛠️ Development Commands

### Start with Specific Services
```bash
# Start only core services
docker-compose up -d postgres authentication-service frontend

# Start with Consul
docker-compose --profile consul up -d

# Start with Redis
docker-compose --profile cache up -d

# Start everything including optional services
docker-compose --profile consul --profile cache up -d
```

### Database Operations
```bash
# Access PostgreSQL shell
docker-compose exec postgres psql -U postgres -d konecta_erp

# Run migrations (automatic on startup)
docker-compose exec authentication-service dotnet ef database update

# Reset database
docker-compose down -v
docker-compose up -d postgres
```

### Service Management
```bash
# View service status
docker-compose ps

# View logs for specific service
docker-compose logs -f authentication-service
docker-compose logs -f frontend
docker-compose logs -f postgres

# Restart specific service
docker-compose restart authentication-service

# Rebuild and restart service
docker-compose up -d --build authentication-service
```

## 🧪 Testing the Setup

### 1. Health Checks
```bash
# Check if all services are healthy
curl http://localhost:5001/health
curl http://localhost:4200
```

### 2. Test Authentication Flow
```bash
# Register a new user
curl -X POST http://localhost:5001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "password": "password123"
  }'

# Login
curl -X POST http://localhost:5001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "password123"
  }'
```

### 3. Frontend Testing
1. Open http://localhost:4200
2. Click "Register" to create a new account
3. Login with your credentials
4. You should be redirected to the dashboard

## 🔍 Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Check what's using the port
sudo netstat -tulpn | grep :5001
sudo netstat -tulpn | grep :4200

# Stop conflicting services or change ports in docker-compose.yml
```

#### Database Connection Issues
```bash
# Check if PostgreSQL is running
docker-compose exec postgres pg_isready -U postgres

# Check database logs
docker-compose logs postgres

# Reset database
docker-compose down -v
docker-compose up -d postgres
```

#### Authentication Service Issues
```bash
# Check service logs
docker-compose logs authentication-service

# Check if migrations ran
docker-compose exec authentication-service dotnet ef database update

# Rebuild service
docker-compose up -d --build authentication-service
```

#### Frontend Issues
```bash
# Check frontend logs
docker-compose logs frontend

# Rebuild frontend
docker-compose up -d --build frontend
```

### Reset Everything
```bash
# Stop and remove all containers, networks, and volumes
docker-compose down -v --remove-orphans

# Remove all images (optional)
docker-compose down --rmi all

# Start fresh
docker-compose up -d
```

## 📊 Monitoring

### View Resource Usage
```bash
# Container resource usage
docker stats

# Service-specific stats
docker stats konecta-postgres konecta-auth-service konecta-frontend
```

### Database Monitoring
```bash
# Connect to database
docker-compose exec postgres psql -U postgres -d konecta_erp

# View active connections
SELECT * FROM pg_stat_activity;

# View database size
SELECT pg_size_pretty(pg_database_size('konecta_erp'));
```

## 🔒 Security Notes

### Development vs Production
- This setup is for **development and testing only**
- Default passwords are used for convenience
- JWT secret key is hardcoded (change for production)
- CORS is set to allow all origins

### Production Considerations
- Use strong, unique passwords
- Generate secure JWT secret keys
- Configure proper CORS policies
- Use environment-specific configuration files
- Enable SSL/TLS
- Use secrets management

## 📁 File Structure
```
├── docker-compose.yml              # Main compose file
├── docker-compose.override.yml     # Development overrides
├── backend/AuthenticationService/
│   ├── Dockerfile                  # Auth service container
│   ├── init-db.sql                # Database initialization
│   └── entrypoint.sh              # Container startup script
├── frontend/
│   └── Dockerfile                  # Frontend container
└── devops/scripts/
    └── postgres-dev-setup.sql     # Development database setup
```

## 🆘 Getting Help

If you encounter issues:
1. Check the logs: `docker-compose logs -f`
2. Verify all services are healthy: `docker-compose ps`
3. Try rebuilding: `docker-compose up -d --build`
4. Reset everything: `docker-compose down -v && docker-compose up -d`

For persistent issues, check the individual service documentation in their respective README files.
