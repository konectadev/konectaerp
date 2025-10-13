using System.ComponentModel.DataAnnotations;

namespace UserManagementService.Dtos;

public class UserDto
{
    public int Id { get; set; }

    [Required]
    public string? Username { get; set; }

    [EmailAddress]
    public string? Email { get; set; }
}
