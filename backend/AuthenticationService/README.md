# Authentication Service

A .NET 8 Web API service for handling user authentication and authorization in the Konecta ERP system.

## Features

- User registration and login
- JWT token generation and validation
- Role-based access control
- Password hashing with SHA256
- PostgreSQL database integration
- Swagger API documentation
- Health check endpoint
- Consul service discovery integration

## Setup

1. **Install EF Core tools** (if not already installed):
   ```bash
   dotnet tool install --global dotnet-ef
   ```

2. **Update database connection string** in `appsettings.json`:
   ```json
   {
     "ConnectionStrings": {
       "DefaultConnection": "Host=localhost;Port=5432;Database=konecta_erp;Username=postgres;Password=yourpassword"
     }
   }
   ```

3. **Create and apply migrations**:
   ```bash
   dotnet ef migrations add InitialCreate
   dotnet ef database update
   ```

4. **Run the service**:
   ```bash
   dotnet run
   ```

## API Endpoints

- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login with email/password
- `GET /api/auth/me` - Get current user info (requires auth)
- `POST /api/auth/change-password` - Change password (requires auth)
- `POST /api/auth/logout` - Logout (requires auth)
- `GET /health` - Health check

## Default Roles

The system comes with three default roles:
- **Admin** - System Administrator
- **Manager** - Department Manager  
- **Employee** - Regular Employee (default for new users)

## Configuration

Key configuration options in `appsettings.json`:

- `JwtSettings.SecretKey` - JWT signing key (minimum 32 characters)
- `JwtSettings.ExpirationMinutes` - Token expiration time
- `ServiceConfig.Port` - Service port (default: 5001)
- `Consul.Host` - Consul service discovery host

## Frontend Integration

The frontend Angular app is configured to use this service at `http://localhost:5001/api/auth/`.

## Docker

Build and run with Docker:

```bash
# Build
docker build -t authentication-service:latest .

# Run (without database)
docker run --rm -p 5001:5001 authentication-service:latest

# Run with database connection
docker run --rm -p 5001:5001 \
  -e ConnectionStrings__DefaultConnection="Host=host.docker.internal;Port=5432;Database=konecta_erp;Username=postgres;Password=yourpassword" \
  -e RUN_MIGRATIONS=true \
  authentication-service:latest

# Run with Consul enabled
docker run --rm -p 5001:5001 \
  -e ConnectionStrings__DefaultConnection="Host=host.docker.internal;Port=5432;Database=konecta_erp;Username=postgres;Password=yourpassword" \
  -e Consul__Enabled=true \
  -e Consul__Host="http://consul:8500" \
  authentication-service:latest
```

## Docker Compose

For a complete setup with PostgreSQL and Consul:

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: konecta_erp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: yourpassword
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  consul:
    image: consul:latest
    ports:
      - "8500:8500"
    command: agent -server -ui -node=server-1 -bootstrap-expect=1 -client=0.0.0.0

  authentication-service:
    build: .
    ports:
      - "5001:5001"
    environment:
      - ConnectionStrings__DefaultConnection=Host=postgres;Port=5432;Database=konecta_erp;Username=postgres;Password=yourpassword
      - Consul__Enabled=true
      - Consul__Host=http://consul:8500
      - RUN_MIGRATIONS=true
    depends_on:
      - postgres
      - consul

volumes:
  postgres_data:
```
