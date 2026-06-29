using DataAccess;
using DataAccess.Models;
using Repositories;

namespace Services;

public sealed class OrderService(
    IOrderRepository orders,
    ICartRepository carts,
    IRepository<Address> addresses,
    IDataAccess dataAccess) : IOrderService
{
    private const decimal FreeShippingThreshold = 200_000m;
    private const decimal StandardShippingFee = 25_000m;

    public Task<IReadOnlyList<Order>> GetByAccountIdAsync(
        long accountId,
        CancellationToken cancellationToken = default) =>
        orders.GetByAccountIdAsync(accountId, cancellationToken);

    public async Task<Order> GetByIdAsync(long id, CancellationToken cancellationToken = default) =>
        await orders.GetByIdAsync(id, cancellationToken: cancellationToken)
        ?? throw new KeyNotFoundException("Không tìm thấy đơn hàng.");

    public async Task<Order> CheckoutAsync(
        long accountId,
        long addressId,
        PaymentMethod paymentMethod,
        string? customerNote,
        CancellationToken cancellationToken = default)
    {
        var order = new Order();
        await dataAccess.ExecuteInTransactionAsync(async token =>
        {
            var address = await addresses.GetByIdAsync([addressId], token)
                ?? throw new KeyNotFoundException("Không tìm thấy địa chỉ giao hàng.");
            if (address.AccountId != accountId)
            {
                throw new InvalidOperationException("Địa chỉ không thuộc tài khoản hiện tại.");
            }

            var cart = await carts.GetByAccountIdAsync(accountId, tracking: true, token)
                ?? throw new InvalidOperationException("Giỏ hàng đang trống.");
            if (cart.Items.Count == 0)
            {
                throw new InvalidOperationException("Giỏ hàng đang trống.");
            }

            foreach (var item in cart.Items)
            {
                if (!item.Vegetable.IsActive || item.Quantity > item.Vegetable.Stock)
                {
                    throw new InvalidOperationException($"Sản phẩm {item.Vegetable.Name} không đủ tồn kho.");
                }
            }

            var subtotal = cart.Items.Sum(x => x.Vegetable.Price * x.Quantity);
            var shippingFee = subtotal >= FreeShippingThreshold ? 0 : StandardShippingFee;
            order = new Order
            {
                OrderCode = $"GB{Guid.NewGuid():N}"[..14].ToUpperInvariant(),
                AccountId = accountId,
                Status = OrderStatus.Pending,
                PaymentMethod = paymentMethod,
                PaymentStatus = PaymentStatus.Unpaid,
                Subtotal = subtotal,
                ShippingFee = shippingFee,
                DiscountAmount = 0,
                TotalAmount = subtotal + shippingFee,
                RecipientName = address.RecipientName,
                RecipientPhone = address.PhoneNumber,
                ShippingAddress = string.Join(", ", new[]
                {
                    address.AddressLine,
                    address.Ward,
                    address.District,
                    address.Province
                }.Where(x => !string.IsNullOrWhiteSpace(x))),
                CustomerNote = customerNote?.Trim(),
                Items = cart.Items.Select(item => new OrderItem
                {
                    VegetableId = item.VegetableId,
                    VegetableName = item.Vegetable.Name,
                    VegetableImageUrl = item.Vegetable.ImageUrl,
                    Unit = item.Vegetable.Unit,
                    UnitPrice = item.Vegetable.Price,
                    Quantity = item.Quantity
                }).ToList()
            };

            foreach (var item in cart.Items.ToList())
            {
                item.Vegetable.Stock -= item.Quantity;
                item.Vegetable.UpdatedAt = DateTime.UtcNow;
                dataAccess.Remove(item);
            }

            cart.UpdatedAt = DateTime.UtcNow;
            await orders.AddAsync(order, token);
        }, cancellationToken);

        return order;
    }

    public async Task<Order> ChangeStatusAsync(
        long id,
        OrderStatus status,
        CancellationToken cancellationToken = default)
    {
        var order = await orders.GetByIdAsync(id, tracking: true, cancellationToken)
            ?? throw new KeyNotFoundException("Không tìm thấy đơn hàng.");
        if (!IsValidTransition(order.Status, status))
        {
            throw new InvalidOperationException($"Không thể chuyển đơn từ {order.Status} sang {status}.");
        }

        if (status == OrderStatus.Cancelled)
        {
            foreach (var item in order.Items.Where(x => x.Vegetable is not null))
            {
                item.Vegetable!.Stock += item.Quantity;
                item.Vegetable.UpdatedAt = DateTime.UtcNow;
            }
        }

        order.Status = status;
        order.UpdatedAt = DateTime.UtcNow;
        if (status == OrderStatus.Completed)
        {
            order.CompletedAt = DateTime.UtcNow;
            if (order.PaymentMethod == PaymentMethod.Cod)
            {
                order.PaymentStatus = PaymentStatus.Paid;
            }
        }

        await dataAccess.SaveChangesAsync(cancellationToken);
        return order;
    }

    private static bool IsValidTransition(OrderStatus current, OrderStatus next) =>
        (current, next) switch
        {
            (OrderStatus.Pending, OrderStatus.Confirmed or OrderStatus.Cancelled) => true,
            (OrderStatus.Confirmed, OrderStatus.Shipping or OrderStatus.Cancelled) => true,
            (OrderStatus.Shipping, OrderStatus.Completed) => true,
            _ => false
        };
}
