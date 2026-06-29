namespace DataAccess.Models;

public class Account
{
    public long Id { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? PasswordHash { get; set; }
    public string? PhoneNumber { get; set; }
    public string? AvatarUrl { get; set; }
    public byte RoleId { get; set; }
    public AuthProvider AuthProvider { get; set; } = AuthProvider.Local;
    public string? GoogleSubject { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    public Role Role { get; set; } = null!;
    public Cart? Cart { get; set; }
    public ICollection<Address> Addresses { get; set; } = [];
    public ICollection<Order> Orders { get; set; } = [];
    public ICollection<RefreshToken> RefreshTokens { get; set; } = [];
    public ICollection<Vegetable> CreatedVegetables { get; set; } = [];
    public ICollection<Vegetable> UpdatedVegetables { get; set; } = [];
}
