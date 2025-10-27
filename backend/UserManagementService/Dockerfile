## Multi-stage Dockerfile for UserManagementService (.NET 8)

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj and restore as distinct layers
COPY UserManagementService.csproj ./
RUN dotnet restore "UserManagementService.csproj"

# Copy the remaining source and build
COPY . .
RUN dotnet build "UserManagementService.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "UserManagementService.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Final runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Align with service config defaults (ServiceConfig:Port defaults to 5002)
ENV ASPNETCORE_URLS=http://+:5002
ENV DOTNET_RUNNING_IN_CONTAINER=true

# Copy published app
COPY --from=publish /app/publish .

# Expose service port
EXPOSE 5002

# Run the service
ENTRYPOINT ["dotnet", "UserManagementService.dll"]


