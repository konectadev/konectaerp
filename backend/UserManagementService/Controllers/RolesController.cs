using Microsoft.AspNetCore.Mvc;
using UserManagementService.Dtos;
using UserManagementService.Services;

namespace UserManagementService.Controllers;

[ApiController]
[Route("api/[controller]")]
public class RolesController : ControllerBase
{
    private readonly IRoleService _roleService;

    public RolesController(IRoleService roleService)
    {
        _roleService = roleService;
    }

    [HttpGet("{id:int}")]
    public async Task<IActionResult> Get(int id)
    {
        var role = await _roleService.GetByIdAsync(id);
        if (role == null) return NotFound();

        return Ok(new RoleDto { Id = role.Id, Name = role.Name });
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var roles = await _roleService.GetAllAsync();
        var dtos = roles.Select(r => new RoleDto { Id = r.Id, Name = r.Name });
        return Ok(dtos);
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateRoleDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        var role = new Models.Role { Name = dto.Name };
        var created = await _roleService.CreateAsync(role);
        return CreatedAtAction(nameof(Get), new { id = created.Id }, new RoleDto { Id = created.Id, Name = created.Name });
    }

    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] UpdateRoleDto dto)
    {
        if (!ModelState.IsValid) return BadRequest(ModelState);
        var role = new Models.Role { Name = dto.Name };
        var updated = await _roleService.UpdateAsync(id, role);
        if (updated == null) return NotFound();
        return Ok(new RoleDto { Id = updated.Id, Name = updated.Name });
    }

    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var ok = await _roleService.DeleteAsync(id);
        if (!ok) return NotFound();
        return NoContent();
    }
}
