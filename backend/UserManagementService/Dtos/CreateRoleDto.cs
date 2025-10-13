using System.ComponentModel.DataAnnotations;

namespace UserManagementService.Dtos;

public class CreateRoleDto
{
    [Required]
    public string? Name { get; set; }
}
