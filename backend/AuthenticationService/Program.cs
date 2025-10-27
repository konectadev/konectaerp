using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.Text;
using AuthenticationService.Data;
using AuthenticationService.Services;
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
        Title = "Konecta ERP - Authentication Service", 
        Version = "v1",
        Description = "Authentication and Authorization Service for Konecta ERP System"
    });
    
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header using the Bearer scheme. Enter 'Bearer' [space] and then your token",
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
builder.Services.AddDbContext<AuthDbContext>(options =>
    options.UseNpgsql(builder.Configuration.GetConnectionString("DefaultConnection")));

// JWT Configuration
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var secretKey = jwtSettings["SecretKey"] ?? throw new InvalidOperationException("JWT SecretKey is not configured");

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
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
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey)),
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();

// Register Services
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddScoped<IJwtService, JwtService>();

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

// Register with Consul (optional - only if Consul is available)
var consulEnabled = builder.Configuration.GetValue<bool>("Consul:Enabled", false);
if (consulEnabled)
{
    try
    {
        var consulClient = app.Services.GetRequiredService<IConsulClient>();
        var lifetime = app.Services.GetRequiredService<IHostApplicationLifetime>();
        var serviceName = "authentication-service";
        var serviceId = $"{serviceName}-{Guid.NewGuid()}";

        lifetime.ApplicationStarted.Register(() =>
        {
            try
            {
                var registration = new AgentServiceRegistration
                {
                    ID = serviceId,
                    Name = serviceName,
                    Address = builder.Configuration["ServiceConfig:Host"] ?? "localhost",
                    Port = int.Parse(builder.Configuration["ServiceConfig:Port"] ?? "5001"),
                    Check = new AgentServiceCheck
                    {
                        HTTP = $"http://{builder.Configuration["ServiceConfig:Host"] ?? "localhost"}:{builder.Configuration["ServiceConfig:Port"] ?? "5001"}/health",
                        Interval = TimeSpan.FromSeconds(10),
                        Timeout = TimeSpan.FromSeconds(5)
                    }
                };
                
                consulClient.Agent.ServiceRegister(registration).Wait();
                Console.WriteLine($"Service registered with Consul: {serviceId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to register with Consul: {ex.Message}");
            }
        });

        lifetime.ApplicationStopping.Register(() =>
        {
            try
            {
                consulClient.Agent.ServiceDeregister(serviceId).Wait();
                Console.WriteLine($"Service deregistered from Consul: {serviceId}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to deregister from Consul: {ex.Message}");
            }
        });
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Consul registration failed: {ex.Message}");
    }
}
else
{
    Console.WriteLine("Consul registration disabled");
}

// Health Check Endpoint
app.MapGet("/health", () => Results.Ok(new { status = "Healthy", service = "authentication-service" }));

app.Run();