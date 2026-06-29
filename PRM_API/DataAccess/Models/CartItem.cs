namespace DataAccess.Models;

public class CartItem
{
    public long CartId { get; set; }
    public long VegetableId { get; set; }
    public int Quantity { get; set; }
    public DateTime AddedAt { get; set; } = DateTime.UtcNow;
    public Cart Cart { get; set; } = null!;
    public Vegetable Vegetable { get; set; } = null!;
}
