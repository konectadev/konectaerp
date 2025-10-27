// using FluentAssertions;
// using Moq;
// using AuthenticationService.Services;
// using AuthenticationService.Data;
// using Microsoft.Extensions.Logging;

// namespace AuthenticationService.Tests;

// public class AuthServiceTests
// {
//     private readonly Mock<AuthDbContext> _mockDbContext;
//     private readonly Mock<IJwtService> _mockJwtService;
//     private readonly Mock<ILogger<AuthService>> _mockLogger;
//     private readonly AuthService _authService;

//     public AuthServiceTests()
//     {
//         _mockDbContext = new Mock<AuthDbContext>();
//         _mockJwtService = new Mock<IJwtService>();
//         _mockLogger = new Mock<ILogger<AuthService>>();
        
//         _authService = new AuthService(_mockDbContext.Object, _mockJwtService.Object, _mockLogger.Object);
//     }

//     [Fact]
//     public async Task RegisterUser_WithValidData_ReturnsSuccess()
//     {
//         // Arrange
//         var request = new RegisterRequest 
//         { 
//             Username = "testuser", 
//             Email = "test@example.com", 
//             Password = "Password123!" 
//         };

//         // Act & Assert
//         await Assert.ThrowsAsync<NotImplementedException>(() => 
//             _authService.RegisterUser(request));
//     }

//     [Theory]
//     [InlineData("", "test@example.com", "Password123!")]
//     [InlineData("testuser", "invalid-email", "Password123!")]
//     [InlineData("testuser", "test@example.com", "short")]
//     public async Task RegisterUser_WithInvalidData_ThrowsException(string username, string email, string password)
//     {
//         // Arrange
//         var request = new RegisterRequest 
//         { 
//             Username = username, 
//             Email = email, 
//             Password = password 
//         };

//         // Act & Assert
//         await Assert.ThrowsAsync<NotImplementedException>(() => 
//             _authService.RegisterUser(request));
//     }
// }