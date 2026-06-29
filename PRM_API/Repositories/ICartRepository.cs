using DataAccess.Models;

namespace Repositories;

public interface ICartRepository
{
    Task<Cart?> GetByAccountIdAsync(
        long accountId,
        bool tracking = false,
        CancellationToken cancellationToken = default);

    ValueTask AddAsync(Cart cart, CancellationToken cancellationToken = default);
}
