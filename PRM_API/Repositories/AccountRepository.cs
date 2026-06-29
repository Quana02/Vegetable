using Microsoft.EntityFrameworkCore;
using DataAccess;
using DataAccess.Models;

namespace Repositories;

public sealed class AccountRepository(IDataAccess dataAccess) : IAccountRepository
{
    public async Task<IReadOnlyList<Account>> ListAsync(
        byte? roleId,
        CancellationToken cancellationToken = default)
    {
        var query = dataAccess.Query<Account>().Include(x => x.Role).AsQueryable();
        if (roleId.HasValue)
        {
            query = query.Where(x => x.RoleId == roleId.Value);
        }

        return await query.OrderBy(x => x.FullName).ToListAsync(cancellationToken);
    }

    public Task<Account?> GetByIdAsync(
        long id,
        bool tracking = false,
        CancellationToken cancellationToken = default) =>
        dataAccess.Query<Account>(tracking)
            .Include(x => x.Role)
            .SingleOrDefaultAsync(x => x.Id == id, cancellationToken);

    public Task<Account?> GetByEmailAsync(
        string email,
        bool tracking = false,
        CancellationToken cancellationToken = default) =>
        dataAccess.Query<Account>(tracking)
            .Include(x => x.Role)
            .SingleOrDefaultAsync(x => x.Email == email, cancellationToken);

    public Task<bool> EmailExistsAsync(
        string email,
        long? excludingId = null,
        CancellationToken cancellationToken = default) =>
        dataAccess.Query<Account>()
            .AnyAsync(x => x.Email == email && (!excludingId.HasValue || x.Id != excludingId), cancellationToken);

    public ValueTask AddAsync(Account account, CancellationToken cancellationToken = default) =>
        dataAccess.AddAsync(account, cancellationToken);

    public void Remove(Account account) => dataAccess.Remove(account);
}
