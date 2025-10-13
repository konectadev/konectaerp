using UserManagementService.Models;

namespace UserManagementService.Services;

public interface IRoleService
{
    Task<Role?> GetByIdAsync(int id);
    Task<IEnumerable<Role>> GetAllAsync();
    Task<Role> CreateAsync(Role role);
    Task<Role?> UpdateAsync(int id, Role role);
    Task<bool> DeleteAsync(int id);
}
