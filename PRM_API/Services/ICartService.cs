using DataAccess.Models;

namespace Services;

public interface ICartService
{
    Task<Cart> GetAsync(long accountId, CancellationToken cancellationToken = default);
    Task<Cart> AddItemAsync(long accountId, long vegetableId, int quantity, CancellationToken cancellationToken = default);
    Task<Cart> UpdateQuantityAsync(long accountId, long vegetableId, int quantity, CancellationToken cancellationToken = default);
    Task<Cart> RemoveItemAsync(long accountId, long vegetableId, CancellationToken cancellationToken = default);
}
