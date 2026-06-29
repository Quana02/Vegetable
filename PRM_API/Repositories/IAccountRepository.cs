using DataAccess.Models;

namespace Repositories;

public interface IAccountRepository
{
    Task<IReadOnlyList<Account>> ListAsync(byte? roleId, CancellationToken cancellationToken = default);
    Task<Account?> GetByIdAsync(long id, bool tracking = false, CancellationToken cancellationToken = default);
    Task<Account?> GetByEmailAsync(string email, bool tracking = false, CancellationToken cancellationToken = default);
    Task<bool> EmailExistsAsync(string email, long? excludingId = null, CancellationToken cancellationToken = default);
    ValueTask AddAsync(Account account, CancellationToken cancellationToken = default);
    void Remove(Account account);
}
