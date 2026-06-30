using DataAccess.Models;

namespace vegetable_api.Contracts;

public sealed record RoleDto(byte Id, string Name, string DisplayName);

public sealed record AccountDto(
    long Id,
    string FullName,
    string Email,
    string? PhoneNumber,
    string? AvatarUrl,
    byte RoleId,
    string Role,
    bool IsActive);

public sealed record LoginRequest(string Email, string Password);
public sealed record DemoLoginRequest(string Role);
public sealed record RegisterRequest(string FullName, string Email, string Password);

public sealed record CreateAccountRequest(
    string FullName,
    string Email,
    string Password,
    byte RoleId,
    bool IsActive = true);

public sealed record UpdateAccountRequest(
    string FullName,
    string Email,
    string? PhoneNumber,
    string? AvatarUrl,
    byte RoleId,
    bool IsActive);

public sealed record ChangeRoleRequest(byte RoleId);
public sealed record SetAccountActiveRequest(bool IsActive);

public sealed record CategoryDto(int Id, string Name, string Slug, string? Description);

public sealed record VegetableDto(
    long Id,
    int CategoryId,
    string CategoryName,
    string Name,
    string Slug,
    string? Description,
    decimal Price,
    string Unit,
    int Stock,
    string? ImageUrl,
    bool IsActive,
    DateTime CreatedAt);

public sealed record VegetableUpsertRequest(
    int CategoryId,
    string Name,
    string? Slug,
    string? Description,
    decimal Price,
    string Unit,
    int Stock,
    string? ImageUrl,
    bool IsActive = true);

public sealed record CartItemDto(
    long VegetableId,
    string Name,
    string? ImageUrl,
    decimal Price,
    string Unit,
    int Quantity,
    decimal LineTotal,
    int AvailableStock);

public sealed record CartDto(long Id, long AccountId, IReadOnlyList<CartItemDto> Items, decimal Total);
public sealed record CartItemRequest(long VegetableId, int Quantity);
public sealed record UpdateCartQuantityRequest(int Quantity);

public sealed record AddressDto(
    long Id,
    long AccountId,
    string RecipientName,
    string PhoneNumber,
    string AddressLine,
    string? Ward,
    string? District,
    string Province,
    bool IsDefault);

public sealed record AddressRequest(
    string RecipientName,
    string PhoneNumber,
    string AddressLine,
    string? Ward,
    string? District,
    string Province,
    bool IsDefault);

public sealed record CheckoutRequest(long AddressId, PaymentMethod PaymentMethod, string? CustomerNote);
public sealed record ChangeOrderStatusRequest(OrderStatus Status);

public sealed record OrderItemDto(
    long Id,
    long? VegetableId,
    string VegetableName,
    string? VegetableImageUrl,
    string Unit,
    decimal UnitPrice,
    int Quantity,
    decimal LineTotal);

public sealed record OrderDto(
    long Id,
    string OrderCode,
    long AccountId,
    OrderStatus Status,
    PaymentMethod PaymentMethod,
    PaymentStatus PaymentStatus,
    decimal Subtotal,
    decimal ShippingFee,
    decimal TotalAmount,
    string RecipientName,
    string RecipientPhone,
    string ShippingAddress,
    DateTime CreatedAt,
    IReadOnlyList<OrderItemDto> Items);

public static class ApiMapper
{
    public static AccountDto ToDto(this Account account) => new(
        account.Id,
        account.FullName,
        account.Email,
        account.PhoneNumber,
        account.AvatarUrl,
        account.RoleId,
        account.RoleId switch
        {
            3 => "admin",
            2 => "staff",
            _ => "user"
        },
        account.IsActive);

    public static VegetableDto ToDto(this Vegetable vegetable) => new(
        vegetable.Id,
        vegetable.CategoryId,
        vegetable.Category?.Name ?? string.Empty,
        vegetable.Name,
        vegetable.Slug,
        vegetable.Description,
        vegetable.Price,
        vegetable.Unit,
        vegetable.Stock,
        vegetable.ImageUrl,
        vegetable.IsActive,
        vegetable.CreatedAt);

    public static CartDto ToDto(this Cart cart)
    {
        var items = cart.Items.Select(item => new CartItemDto(
            item.VegetableId,
            item.Vegetable.Name,
            item.Vegetable.ImageUrl,
            item.Vegetable.Price,
            item.Vegetable.Unit,
            item.Quantity,
            item.Vegetable.Price * item.Quantity,
            item.Vegetable.Stock)).ToList();
        return new CartDto(cart.Id, cart.AccountId, items, items.Sum(x => x.LineTotal));
    }

    public static AddressDto ToDto(this Address address) => new(
        address.Id,
        address.AccountId,
        address.RecipientName,
        address.PhoneNumber,
        address.AddressLine,
        address.Ward,
        address.District,
        address.Province,
        address.IsDefault);

    public static OrderDto ToDto(this Order order) => new(
        order.Id,
        order.OrderCode,
        order.AccountId,
        order.Status,
        order.PaymentMethod,
        order.PaymentStatus,
        order.Subtotal,
        order.ShippingFee,
        order.TotalAmount,
        order.RecipientName,
        order.RecipientPhone,
        order.ShippingAddress,
        order.CreatedAt,
        order.Items.Select(item => new OrderItemDto(
            item.Id,
            item.VegetableId,
            item.VegetableName,
            item.VegetableImageUrl,
            item.Unit,
            item.UnitPrice,
            item.Quantity,
            item.UnitPrice * item.Quantity)).ToList());
}
