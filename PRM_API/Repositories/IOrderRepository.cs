using DataAccess.Models;

namespace Repositories;

public interface IOrderRepository
{
    Task<IReadOnlyList<Order>> GetByAccountIdAsync(long accountId, CancellationToken cancellationToken = default);
    Task<Order?> GetByIdAsync(long id, bool tracking = false, CancellationToken cancellationToken = default);
    Task<bool> OrderCodeExistsAsync(string orderCode, CancellationToken cancellationToken = default);
    ValueTask AddAsync(Order order, CancellationToken cancellationToken = default);
}
