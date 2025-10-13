using UserManagementService.Data;
using UserManagementService.Models;
using Microsoft.EntityFrameworkCore;

namespace UserManagementService.Services;

public class UserService : IUserService
{
    private readonly UserDbContext _db;

    public UserService(UserDbContext db)
    {
        _db = db;
    }

    public async Task<User?> GetByIdAsync(int id)
    {
        return await _db.Users!.FindAsync(id);
    }

    public async Task<IEnumerable<User>> GetAllAsync()
    {
        return await _db.Users!.ToListAsync();
    }

    public async Task<User> CreateAsync(User user)
    {
        _db.Users!.Add(user);
        await _db.SaveChangesAsync();
        return user;
    }

    public async Task<User?> UpdateAsync(int id, User user)
    {
        var existing = await _db.Users!.FindAsync(id);
        if (existing == null) return null;

        existing.Username = user.Username;
        existing.Email = user.Email;
        await _db.SaveChangesAsync();
        return existing;
    }

    public async Task<bool> DeleteAsync(int id)
    {
        var existing = await _db.Users!.FindAsync(id);
        if (existing == null) return false;
        _db.Users.Remove(existing);
        await _db.SaveChangesAsync();
        return true;
    }
}
