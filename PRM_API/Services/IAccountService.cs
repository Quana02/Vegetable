using DataAccess.Models;

namespace Services;

public interface IAccountService
{
    Task<IReadOnlyList<Account>> ListAsync(byte? roleId, CancellationToken cancellationToken = default);
    Task<Account> GetByIdAsync(long id, CancellationToken cancellationToken = default);
    Task<Account> CreateAsync(Account account, CancellationToken cancellationToken = default);
    Task<Account> UpdateAsync(long id, Account account, CancellationToken cancellationToken = default);
    Task<Account> ChangeRoleAsync(long id, byte roleId, CancellationToken cancellationToken = default);
    Task<Account> SetActiveAsync(long id, bool isActive, CancellationToken cancellationToken = default);
}
