using Microsoft.AspNetCore.Mvc;
using UserManagementService.Dtos;
using UserManagementService.Services;
using UserManagementService.Models;

namespace UserManagementService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsersController : ControllerBase
{
    private readonly IUserService _userService;

    public UsersController(IUserService userService)
    {
        _userService = userService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id)
    {
        var user = await _userService.GetByIdAsync(id);
        if (user == null) return NotFound();

        return Ok(new UserDto { Id = user.Id, Username = user.Username, Email = user.Email });
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var users = await _userService.GetAllAsync();
        var dtos = users.Select(u => new UserDto { Id = u.Id, Username = u.Username, Email = u.Email });
        return Ok(dtos);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateUserDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var user = new User { Username = dto.Username, Email = dto.Email };
        var created = await _userService.CreateAsync(user);
        return CreatedAtAction(nameof(Get), new { id = created.Id }, new UserDto { Id = created.Id, Username = created.Username, Email = created.Email });
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateUserDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);

        var user = new User { Username = dto.Username, Email = dto.Email };
        var updated = await _userService.UpdateAsync(id, user);
        if (updated == null) return NotFound();
        return Ok(new UserDto { Id = updated.Id, Username = updated.Username, Email = updated.Email });
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var ok = await _userService.DeleteAsync(id);
        if (!ok) return NotFound();
        return NoContent();
    }

    // Additional endpoints (Create, Update, Delete) can be added later
}
