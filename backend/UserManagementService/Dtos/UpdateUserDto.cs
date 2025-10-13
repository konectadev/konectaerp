using System.ComponentModel.DataAnnotations;

namespace UserManagementService.Dtos;

public class UpdateUserDto
{
    [Required]
    public string? Username { get; set; }

    [EmailAddress]
    public string? Email { get; set; }
}
