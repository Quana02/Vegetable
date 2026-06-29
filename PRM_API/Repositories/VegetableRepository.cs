using Microsoft.EntityFrameworkCore;
using DataAccess;
using DataAccess.Models;

namespace Repositories;

public sealed class VegetableRepository(IDataAccess dataAccess) : IVegetableRepository
{
    public async Task<IReadOnlyList<Vegetable>> SearchAsync(
        string? keyword,
        int? categoryId,
        decimal? minPrice,
        decimal? maxPrice,
        bool includeInactive = false,
        CancellationToken cancellationToken = default)
    {
        var query = dataAccess.Query<Vegetable>().Include(x => x.Category).AsQueryable();

        if (!includeInactive)
        {
            query = query.Where(x => x.IsActive);
        }

        if (!string.IsNullOrWhiteSpace(keyword))
        {
            var search = keyword.Trim();
            query = query.Where(x => x.Name.Contains(search));
        }

        if (categoryId.HasValue)
        {
            query = query.Where(x => x.CategoryId == categoryId.Value);
        }

        if (minPrice.HasValue)
        {
            query = query.Where(x => x.Price >= minPrice.Value);
        }

        if (maxPrice.HasValue)
        {
            query = query.Where(x => x.Price <= maxPrice.Value);
        }

        return await query.OrderBy(x => x.Name).ToListAsync(cancellationToken);
    }

    public Task<Vegetable?> GetByIdAsync(
        long id,
        bool tracking = false,
        CancellationToken cancellationToken = default)
    {
        var query = dataAccess.Query<Vegetable>(tracking).Include(x => x.Category);
        return query.SingleOrDefaultAsync(x => x.Id == id, cancellationToken);
    }

    public Task<bool> SlugExistsAsync(
        string slug,
        long? excludingId = null,
        CancellationToken cancellationToken = default) =>
        dataAccess.Query<Vegetable>()
            .AnyAsync(x => x.Slug == slug && (!excludingId.HasValue || x.Id != excludingId), cancellationToken);

    public ValueTask AddAsync(Vegetable vegetable, CancellationToken cancellationToken = default) =>
        dataAccess.AddAsync(vegetable, cancellationToken);

    public void Remove(Vegetable vegetable) => dataAccess.Remove(vegetable);
}
