using DataAccess.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Repositories;
using Services;
using vegetable_api.Contracts;

namespace vegetable_api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(
    IAccountRepository accountRepository,
    IRepository<Role> roleRepository,
    IAccountService accountService,
    IPasswordHasher<Account> passwordHasher) : ControllerBase
{
    [HttpPost("login")]
    public async Task<ActionResult<AccountDto>> Login(
        LoginRequest request,
        CancellationToken cancellationToken)
    {
        var account = await accountRepository.GetByEmailAsync(
            request.Email.Trim().ToLowerInvariant(),
            cancellationToken: cancellationToken);
        if (account is null || !account.IsActive || account.PasswordHash is null)
        {
            return Unauthorized(new { message = "Email hoặc mật khẩu không đúng." });
        }

        var result = passwordHasher.VerifyHashedPassword(account, account.PasswordHash, request.Password);
        if (result == PasswordVerificationResult.Failed)
        {
            return Unauthorized(new { message = "Email hoặc mật khẩu không đúng." });
        }

        return Ok(account.ToDto());
    }

    [HttpPost("demo-login")]
    public async Task<ActionResult<AccountDto>> DemoLogin(
        DemoLoginRequest request,
        CancellationToken cancellationToken)
    {
        var roleName = request.Role.Trim().ToLowerInvariant();
        var role = (await roleRepository.ListAsync(x => x.Name == roleName, cancellationToken)).SingleOrDefault();
        if (role is null)
        {
            return BadRequest(new { message = "Vai trò không hợp lệ." });
        }

        var existing = (await accountRepository.ListAsync(role.Id, cancellationToken)).FirstOrDefault(x => x.IsActive);
        if (existing is not null)
        {
            return Ok(existing.ToDto());
        }

        var account = new Account
        {
            FullName = role.Name switch
            {
                "admin" => "Quản trị viên Demo",
                "staff" => "Nhân viên Demo",
                _ => "Người dùng Demo"
            },
            Email = $"{role.Name}@greenbasket.vn",
            RoleId = role.Id,
            AuthProvider = AuthProvider.Local,
            IsActive = true
        };
        account.PasswordHash = passwordHasher.HashPassword(account, "123456");
        account = await accountService.CreateAsync(account, cancellationToken);
        return Ok((await accountService.GetByIdAsync(account.Id, cancellationToken)).ToDto());
    }

    [HttpPost("register")]
    public async Task<ActionResult<AccountDto>> Register(
        RegisterRequest request,
        CancellationToken cancellationToken)
    {
        if (request.Password.Length < 6)
        {
            return BadRequest(new { message = "Mật khẩu tối thiểu 6 ký tự." });
        }

        var account = new Account
        {
            FullName = request.FullName,
            Email = request.Email,
            RoleId = 1,
            AuthProvider = AuthProvider.Local,
            IsActive = true
        };
        account.PasswordHash = passwordHasher.HashPassword(account, request.Password);
        account = await accountService.CreateAsync(account, cancellationToken);
        return CreatedAtAction(nameof(Register), (await accountService.GetByIdAsync(account.Id, cancellationToken)).ToDto());
    }
}
