using DataAccess.Models;

namespace Repositories;

public interface IVegetableRepository
{
    Task<IReadOnlyList<Vegetable>> SearchAsync(
        string? keyword,
        int? categoryId,
        decimal? minPrice,
        decimal? maxPrice,
        bool includeInactive = false,
        CancellationToken cancellationToken = default);

    Task<Vegetable?> GetByIdAsync(
        long id,
        bool tracking = false,
        CancellationToken cancellationToken = default);

    Task<bool> SlugExistsAsync(
        string slug,
        long? excludingId = null,
        CancellationToken cancellationToken = default);

    ValueTask AddAsync(Vegetable vegetable, CancellationToken cancellationToken = default);
    void Remove(Vegetable vegetable);
}
