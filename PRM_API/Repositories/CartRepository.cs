using Microsoft.EntityFrameworkCore;
using DataAccess;
using DataAccess.Models;

namespace Repositories;

public sealed class CartRepository(IDataAccess dataAccess) : ICartRepository
{
    public Task<Cart?> GetByAccountIdAsync(
        long accountId,
        bool tracking = false,
        CancellationToken cancellationToken = default) =>
        dataAccess.Query<Cart>(tracking)
            .Include(x => x.Items)
            .ThenInclude(x => x.Vegetable)
            .SingleOrDefaultAsync(x => x.AccountId == accountId, cancellationToken);

    public ValueTask AddAsync(Cart cart, CancellationToken cancellationToken = default) =>
        dataAccess.AddAsync(cart, cancellationToken);
}
