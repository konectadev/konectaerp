using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using AuthenticationService.Services;
using System.Security.Claims;

namespace AuthenticationService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;
    private readonly ILogger<AuthController> _logger;

    public AuthController(IAuthService authService, ILogger<AuthController> logger)
    {
        _authService = authService;
        _logger = logger;
    }

    [HttpPost("register")]
    public async Task<ActionResult<AuthResult>> Register([FromBody] RegisterRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var result = await _authService.RegisterAsync(request);
        
        if (!result.Success)
        {
            return BadRequest(new { message = result.ErrorMessage });
        }

        return Ok(new
        {
            token = result.Token,
            refreshToken = result.RefreshToken,
            user = result.User
        });
    }

    [HttpPost("login")]
    public async Task<ActionResult<AuthResult>> Login([FromBody] LoginRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var result = await _authService.LoginAsync(request);
        
        if (!result.Success)
        {
            return Unauthorized(new { message = result.ErrorMessage });
        }

        return Ok(new
        {
            token = result.Token,
            refreshToken = result.RefreshToken,
            user = result.User
        });
    }

    [HttpPost("refresh")]
    public ActionResult RefreshToken([FromBody] RefreshTokenRequest request)
    {
        // TODO: Implement refresh token logic
        return Ok(new { message = "Refresh token endpoint - to be implemented" });
    }

    [HttpGet("me")]
    [Authorize]
    public async Task<ActionResult<UserDto>> GetCurrentUser()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var user = await _authService.GetUserByIdAsync(userId);
        if (user == null)
        {
            return NotFound();
        }

        return Ok(new UserDto
        {
            Id = user.Id,
            Email = user.Email,
            FirstName = user.FirstName,
            LastName = user.LastName,
            Roles = user.UserRoles.Select(ur => ur.Role.Name).ToList(),
            CreatedAt = user.CreatedAt,
            LastLoginAt = user.LastLoginAt
        });
    }

    [HttpPost("change-password")]
    [Authorize]
    public async Task<ActionResult> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        if (!ModelState.IsValid)
        {
            return BadRequest(ModelState);
        }

        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdClaim) || !Guid.TryParse(userIdClaim, out var userId))
        {
            return Unauthorized();
        }

        var success = await _authService.ChangePasswordAsync(userId, request.CurrentPassword, request.NewPassword);
        
        if (!success)
        {
            return BadRequest(new { message = "Current password is incorrect" });
        }

        return Ok(new { message = "Password changed successfully" });
    }

    [HttpPost("logout")]
    [Authorize]
    public ActionResult Logout()
    {
        // TODO: Implement token blacklisting if needed
        return Ok(new { message = "Logged out successfully" });
    }
}

public class RefreshTokenRequest
{
    public string RefreshToken { get; set; } = string.Empty;
}

public class ChangePasswordRequest
{
    public string CurrentPassword { get; set; } = string.Empty;
    public string NewPassword { get; set; } = string.Empty;
}
