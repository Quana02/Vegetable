using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using DataAccess;

namespace Repositories;

public class Repository<TEntity>(IDataAccess dataAccess) : IRepository<TEntity>
    where TEntity : class
{
    public ValueTask<TEntity?> GetByIdAsync(
        object[] keyValues,
        CancellationToken cancellationToken = default) =>
        dataAccess.FindAsync<TEntity>(keyValues, cancellationToken);

    public async Task<IReadOnlyList<TEntity>> ListAsync(
        Expression<Func<TEntity, bool>>? predicate = null,
        CancellationToken cancellationToken = default)
    {
        var query = dataAccess.Query<TEntity>();
        if (predicate is not null)
        {
            query = query.Where(predicate);
        }

        return await query.ToListAsync(cancellationToken);
    }

    public ValueTask AddAsync(TEntity entity, CancellationToken cancellationToken = default) =>
        dataAccess.AddAsync(entity, cancellationToken);

    public void Remove(TEntity entity) => dataAccess.Remove(entity);
}
