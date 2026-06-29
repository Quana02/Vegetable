using Microsoft.EntityFrameworkCore;
using DataAccess.Models;

namespace DataAccess;

public sealed class EfDataAccess(AppDbContext dbContext) : IDataAccess
{
    public IQueryable<TEntity> Query<TEntity>(bool tracking = false)
        where TEntity : class
    {
        var query = dbContext.Set<TEntity>().AsQueryable();
        return tracking ? query : query.AsNoTracking();
    }

    public ValueTask<TEntity?> FindAsync<TEntity>(
        object[] keyValues,
        CancellationToken cancellationToken = default)
        where TEntity : class =>
        dbContext.Set<TEntity>().FindAsync(keyValues, cancellationToken);

    public async ValueTask AddAsync<TEntity>(
        TEntity entity,
        CancellationToken cancellationToken = default)
        where TEntity : class =>
        await dbContext.Set<TEntity>().AddAsync(entity, cancellationToken);

    public void Remove<TEntity>(TEntity entity)
        where TEntity : class =>
        dbContext.Set<TEntity>().Remove(entity);

    public Task<int> SaveChangesAsync(CancellationToken cancellationToken = default) =>
        dbContext.SaveChangesAsync(cancellationToken);

    public async Task ExecuteInTransactionAsync(
        Func<CancellationToken, Task> operation,
        CancellationToken cancellationToken = default)
    {
        await using var transaction = await dbContext.Database.BeginTransactionAsync(cancellationToken);
        try
        {
            await operation(cancellationToken);
            await dbContext.SaveChangesAsync(cancellationToken);
            await transaction.CommitAsync(cancellationToken);
        }
        catch
        {
            await transaction.RollbackAsync(cancellationToken);
            throw;
        }
    }
}
