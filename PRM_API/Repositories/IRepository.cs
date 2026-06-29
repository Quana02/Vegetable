using System.Linq.Expressions;

namespace Repositories;

public interface IRepository<TEntity>
    where TEntity : class
{
    ValueTask<TEntity?> GetByIdAsync(object[] keyValues, CancellationToken cancellationToken = default);

    Task<IReadOnlyList<TEntity>> ListAsync(
        Expression<Func<TEntity, bool>>? predicate = null,
        CancellationToken cancellationToken = default);

    ValueTask AddAsync(TEntity entity, CancellationToken cancellationToken = default);
    void Remove(TEntity entity);
}
