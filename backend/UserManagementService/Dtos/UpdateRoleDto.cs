using System.ComponentModel.DataAnnotations;

namespace UserManagementService.Dtos;

public class UpdateRoleDto
{
    [Required]
    public string? Name { get; set; }
}
