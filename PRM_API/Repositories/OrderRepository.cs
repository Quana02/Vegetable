using Microsoft.EntityFrameworkCore;
using DataAccess;
using DataAccess.Models;

namespace Repositories;

public sealed class OrderRepository(IDataAccess dataAccess) : IOrderRepository
{
    public async Task<IReadOnlyList<Order>> GetByAccountIdAsync(
        long accountId,
        CancellationToken cancellationToken = default) =>
        await dataAccess.Query<Order>()
            .Include(x => x.Items)
            .Where(x => x.AccountId == accountId)
            .OrderByDescending(x => x.CreatedAt)
            .ToListAsync(cancellationToken);

    public Task<Order?> GetByIdAsync(
        long id,
        bool tracking = false,
        CancellationToken cancellationToken = default) =>
        dataAccess.Query<Order>(tracking)
            .Include(x => x.Items)
            .ThenInclude(x => x.Vegetable)
            .SingleOrDefaultAsync(x => x.Id == id, cancellationToken);

    public Task<bool> OrderCodeExistsAsync(
        string orderCode,
        CancellationToken cancellationToken = default) =>
        dataAccess.Query<Order>().AnyAsync(x => x.OrderCode == orderCode, cancellationToken);

    public ValueTask AddAsync(Order order, CancellationToken cancellationToken = default) =>
        dataAccess.AddAsync(order, cancellationToken);
}
