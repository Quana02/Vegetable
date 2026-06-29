namespace DataAccess.Models;

public class Cart
{
    public long Id { get; set; }
    public long AccountId { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public Account Account { get; set; } = null!;
    public ICollection<CartItem> Items { get; set; } = [];
}
