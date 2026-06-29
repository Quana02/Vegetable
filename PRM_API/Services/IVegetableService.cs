using DataAccess.Models;

namespace Services;

public interface IVegetableService
{
    Task<IReadOnlyList<Vegetable>> SearchAsync(
        string? keyword,
        int? categoryId,
        decimal? minPrice,
        decimal? maxPrice,
        bool includeInactive = false,
        CancellationToken cancellationToken = default);

    Task<Vegetable> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<Vegetable> CreateAsync(Vegetable vegetable, CancellationToken cancellationToken = default);
    Task<Vegetable> UpdateAsync(long id, Vegetable vegetable, CancellationToken cancellationToken = default);
    Task DeleteAsync(long id, CancellationToken cancellationToken = default);
}
