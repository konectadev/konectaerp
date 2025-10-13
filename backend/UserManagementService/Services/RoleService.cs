using UserManagementService.Data;
using UserManagementService.Models;
using Microsoft.EntityFrameworkCore;

namespace UserManagementService.Services;

public class RoleService : IRoleService
{
    private readonly UserDbContext _db;

    public RoleService(UserDbContext db)
    {
        _db = db;
    }

    public async Task<Role?> GetByIdAsync(int id)
    {
        return await _db.Roles!.FindAsync(id);
    }

    public async Task<IEnumerable<Role>> GetAllAsync()
    {
        return await _db.Roles!.ToListAsync();
    }

    public async Task<Role> CreateAsync(Role role)
    {
        _db.Roles!.Add(role);
        await _db.SaveChangesAsync();
        return role;
    }

    public async Task<Role?> UpdateAsync(int id, Role role)
    {
        var existing = await _db.Roles!.FindAsync(id);
        if (existing == null) return null;
        existing.Name = role.Name;
        await _db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await _db.Roles!.FindAsync(id);
        if (existing == null) return false;
        _db.Roles.Remove(existing);
        await _db.SaveChangesAsync();
        return true;
    }
}
