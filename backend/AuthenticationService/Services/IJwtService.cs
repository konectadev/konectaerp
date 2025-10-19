using AuthenticationService.Models;
using System.Security.Claims;

namespace AuthenticationService.Services;

public interface IJwtService
{
    string GenerateToken(User user);
    string GenerateRefreshToken();
    ClaimsPrincipal? GetPrincipalFromExpiredToken(string token);
    bool ValidateToken(string token);
}
