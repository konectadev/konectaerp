using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using UserManagementService.Data;
using UserManagementService.Services;
using Consul;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Swagger Configuration with JWT
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo 
    { 
        Title = "Konecta ERP - User Management Service", 
        Version = "v1",
        Description = "User and Role Management Service for Konecta ERP System"
    });
    
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// Database Configuration - PostgreSQL
builder.Services.AddDbContext<UserDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// JWT Authentication Configuration
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"] ?? throw new InvalidOperationException("JWT SecretKey is not configured");

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings["Issuer"],
        ValidAudience = jwtSettings["Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey))
    };
});

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("AdminOnly", policy => policy.RequireRole("Admin"));
    options.AddPolicy("HRManager", policy => policy.RequireRole("Admin", "HR_Manager"));
});

// Register Services
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IRoleService, RoleService>();

// Consul Configuration
builder.Services.AddSingleton<IConsulClient, ConsulClient>(p => new ConsulClient(consulConfig =>
{
    var address = builder.Configuration["Consul:Host"];
    consulConfig.Address = new Uri(address ?? "http://localhost:8500");
}));

// CORS Configuration
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

// Register with Consul
var consulClient = app.Services.GetRequiredService<IConsulClient>();
var lifetime = app.Services.GetRequiredService<IHostApplicationLifetime>();
var serviceName = "user-management-service";
var serviceId = $"{serviceName}-{Guid.NewGuid()}";
var consulEnabled = builder.Configuration.GetValue<bool>("Consul:Enabled");

if (consulEnabled)
{
    lifetime.ApplicationStarted.Register(() =>
    {
        // Run registration in background and do not block app startup.
        _ = Task.Run(async () =>
        {
            var services = app.Services;
            var logger = services.GetService<ILogger<Program>>();
            try
            {
                var registration = new AgentServiceRegistration
                {
                    ID = serviceId,
                    Name = serviceName,
                    Address = builder.Configuration["ServiceConfig:Host"] ?? "localhost",
                    Port = int.Parse(builder.Configuration["ServiceConfig:Port"] ?? "5002"),
                    Check = new AgentServiceCheck
                    {
                        HTTP = $"http://{builder.Configuration["ServiceConfig:Host"] ?? "localhost"}:{builder.Configuration["ServiceConfig:Port"] ?? "5002"}/health",
                        Interval = TimeSpan.FromSeconds(10),
                        Timeout = TimeSpan.FromSeconds(5)
                    }
                };

                await consulClient.Agent.ServiceRegister(registration);
                logger?.LogInformation("Service registered with Consul: {ServiceId}", serviceId);
            }
            catch (Exception ex)
            {
                // If Consul is not available, log and continue running the application.
                var logger2 = services.GetService<ILogger<Program>>();
                logger2?.LogWarning(ex, "Could not register service with Consul at {ConsulHost}. Continuing without Consul.", builder.Configuration["Consul:Host"] ?? "http://localhost:8500");
            }
        });
    });

    lifetime.ApplicationStopping.Register(() =>
    {
        _ = Task.Run(async () =>
        {
            var services = app.Services;
            var logger = services.GetService<ILogger<Program>>();
            try
            {
                await consulClient.Agent.ServiceDeregister(serviceId);
                logger?.LogInformation("Service deregistered from Consul: {ServiceId}", serviceId);
            }
            catch (Exception ex)
            {
                logger?.LogWarning(ex, "Failed to deregister service from Consul: {ServiceId}", serviceId);
            }
        });
    });
}

// Health Check Endpoint
app.MapGet("/health", () => Results.Ok(new { status = "Healthy", service = serviceName }));

// Apply migrations and seed data at startup
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<UserDbContext>();
    db.Database.Migrate();
    SeedData.Initialize(db);
}

app.Run();