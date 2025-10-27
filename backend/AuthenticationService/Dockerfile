## Multi-stage Dockerfile for AuthenticationService (.NET 8)

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore as distinct layers
COPY AuthenticationService.csproj ./
RUN dotnet restore "AuthenticationService.csproj"

# Copy the remaining source and build
COPY . .
RUN dotnet build "AuthenticationService.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "AuthenticationService.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Install netcat for database connectivity check
RUN apt-get update && apt-get install -y netcat-openbsd && rm -rf /var/lib/apt/lists/*

# Align with service config defaults (ServiceConfig:Port defaults to 5001)
ENV ASPNETCORE_URLS=http://+:5001
ENV DOTNET_RUNNING_IN_CONTAINER=true
ENV ASPNETCORE_ENVIRONMENT=Production
ENV RUN_MIGRATIONS=true

# Copy published app
COPY --from=publish /app/publish .

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose service port
EXPOSE 5001

# Run the service
ENTRYPOINT ["/entrypoint.sh"]


