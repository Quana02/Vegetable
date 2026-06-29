namespace DataAccess.Models;

public class OrderItem
{
    public long Id { get; set; }
    public long OrderId { get; set; }
    public long? VegetableId { get; set; }
    public string VegetableName { get; set; } = string.Empty;
    public string? VegetableImageUrl { get; set; }
    public string Unit { get; set; } = string.Empty;
    public decimal UnitPrice { get; set; }
    public int Quantity { get; set; }
    public decimal LineTotal { get; private set; }
    public Order Order { get; set; } = null!;
    public Vegetable? Vegetable { get; set; }
}
