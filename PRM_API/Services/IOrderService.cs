using DataAccess.Models;

namespace Services;

public interface IOrderService
{
    Task<IReadOnlyList<Order>> GetByAccountIdAsync(long accountId, CancellationToken cancellationToken = default);
    Task<Order> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<Order> CheckoutAsync(
        long accountId,
        long addressId,
        PaymentMethod paymentMethod,
        string? customerNote,
        CancellationToken cancellationToken = default);
    Task<Order> ChangeStatusAsync(long id, OrderStatus status, CancellationToken cancellationToken = default);
}
