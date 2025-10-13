using UserManagementService.Models;

namespace UserManagementService.Data;

public static class SeedData
{
    public static void Initialize(UserDbContext db)
    {
        if (db.Roles == null) return;

        if (!db.Roles.Any())
        {
            db.Roles.AddRange(
                new Role { Name = "Admin" },
                new Role { Name = "HR_Manager" }
            );
            db.SaveChanges();
        }

        if (db.Users == null) return;

        if (!db.Users.Any())
        {
            db.Users.Add(new User { Username = "admin", Email = "admin@konecta.local" });
            db.SaveChanges();
        }
    }
}
