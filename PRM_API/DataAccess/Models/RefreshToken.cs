namespace DataAccess.Models;

public class RefreshToken
{
    public long Id { get; set; }
    public long AccountId { get; set; }
    public string TokenHash { get; set; } = string.Empty;
    public DateTime ExpiresAt { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? RevokedAt { get; set; }
    public Account Account { get; set; } = null!;
}
