using DataAccess;
using DataAccess.Models;
using Repositories;

namespace Services;

public sealed class AccountService(
    IAccountRepository accounts,
    IRepository<Role> roles,
    IDataAccess dataAccess) : IAccountService
{
    public Task<IReadOnlyList<Account>> ListAsync(
        byte? roleId,
        CancellationToken cancellationToken = default) =>
        accounts.ListAsync(roleId, cancellationToken);

    public async Task<Account> GetByIdAsync(long id, CancellationToken cancellationToken = default) =>
        await accounts.GetByIdAsync(id, cancellationToken: cancellationToken)
        ?? throw new KeyNotFoundException("Không tìm thấy tài khoản.");

    public async Task<Account> CreateAsync(Account account, CancellationToken cancellationToken = default)
    {
        await ValidateAsync(account, cancellationToken);
        if (await accounts.EmailExistsAsync(account.Email.Trim(), cancellationToken: cancellationToken))
        {
            throw new InvalidOperationException("Email đã được sử dụng.");
        }

        account.Id = 0;
        account.FullName = account.FullName.Trim();
        account.Email = account.Email.Trim().ToLowerInvariant();
        account.CreatedAt = DateTime.UtcNow;
        account.UpdatedAt = DateTime.UtcNow;
        await accounts.AddAsync(account, cancellationToken);
        await dataAccess.SaveChangesAsync(cancellationToken);
        return account;
    }

    public async Task<Account> UpdateAsync(
        long id,
        Account input,
        CancellationToken cancellationToken = default)
    {
        await ValidateAsync(input, cancellationToken);
        var account = await accounts.GetByIdAsync(id, tracking: true, cancellationToken)
            ?? throw new KeyNotFoundException("Không tìm thấy tài khoản.");
        var email = input.Email.Trim().ToLowerInvariant();
        if (await accounts.EmailExistsAsync(email, id, cancellationToken))
        {
            throw new InvalidOperationException("Email đã được sử dụng.");
        }

        account.FullName = input.FullName.Trim();
        account.Email = email;
        account.PhoneNumber = input.PhoneNumber?.Trim();
        account.AvatarUrl = input.AvatarUrl?.Trim();
        account.RoleId = input.RoleId;
        account.IsActive = input.IsActive;
        account.UpdatedAt = DateTime.UtcNow;
        await dataAccess.SaveChangesAsync(cancellationToken);
        return account;
    }

    public async Task<Account> ChangeRoleAsync(
        long id,
        byte roleId,
        CancellationToken cancellationToken = default)
    {
        if (await roles.GetByIdAsync([roleId], cancellationToken) is null)
        {
            throw new ArgumentException("Vai trò không tồn tại.");
        }

        var account = await accounts.GetByIdAsync(id, tracking: true, cancellationToken)
            ?? throw new KeyNotFoundException("Không tìm thấy tài khoản.");
        account.RoleId = roleId;
        account.UpdatedAt = DateTime.UtcNow;
        await dataAccess.SaveChangesAsync(cancellationToken);
        return account;
    }

    public async Task<Account> SetActiveAsync(
        long id,
        bool isActive,
        CancellationToken cancellationToken = default)
    {
        var account = await accounts.GetByIdAsync(id, tracking: true, cancellationToken)
            ?? throw new KeyNotFoundException("Không tìm thấy tài khoản.");
        account.IsActive = isActive;
        account.UpdatedAt = DateTime.UtcNow;
        await dataAccess.SaveChangesAsync(cancellationToken);
        return account;
    }

    private async Task ValidateAsync(Account account, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(account.FullName) || string.IsNullOrWhiteSpace(account.Email))
        {
            throw new ArgumentException("Họ tên và email không được để trống.");
        }

        if (account.AuthProvider == AuthProvider.Local && string.IsNullOrWhiteSpace(account.PasswordHash))
        {
            throw new ArgumentException("Tài khoản local phải có mật khẩu đã hash.");
        }

        if (account.AuthProvider == AuthProvider.Google && string.IsNullOrWhiteSpace(account.GoogleSubject))
        {
            throw new ArgumentException("Tài khoản Google phải có Google Subject.");
        }

        if (await roles.GetByIdAsync([account.RoleId], cancellationToken) is null)
        {
            throw new ArgumentException("Vai trò không tồn tại.");
        }
    }
}
