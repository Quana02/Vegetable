using DataAccess.Models;
using DataAccess;
using FirebaseAdmin;
using FirebaseAdmin.Auth;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Repositories;
using Services;
using vegetable_api.Contracts;

namespace vegetable_api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(
    IDataAccess dataAccess,
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

    [HttpPost("google-login")]
    public async Task<ActionResult<AccountDto>> GoogleLogin(
        GoogleLoginRequest request,
        CancellationToken cancellationToken)
    {
        if (FirebaseApp.DefaultInstance is null)
        {
            return StatusCode(StatusCodes.Status500InternalServerError, new
            {
                message = "Firebase Admin chÆ°a Ä‘Æ°á»£c cáº¥u hÃ¬nh. HÃ£y thiáº¿t láº­p Firebase:ServiceAccountPath hoáº·c GOOGLE_APPLICATION_CREDENTIALS."
            });
        }

        FirebaseToken token;
        try
        {
            token = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(request.IdToken);
        }
        catch
        {
            return Unauthorized(new { message = "Token Google/Firebase khÃ´ng há»£p lá»‡." });
        }

        var email = ClaimString(token, "email")?.Trim().ToLowerInvariant();
        if (string.IsNullOrWhiteSpace(email))
        {
            return Unauthorized(new { message = "TÃ i khoáº£n Google chÆ°a cÃ³ email há»£p lá»‡." });
        }

        var fullName =
            ClaimString(token, "name") ??
            ClaimString(token, "display_name") ??
            email.Split('@')[0];
        var avatarUrl = ClaimString(token, "picture");

        var account = await accountRepository.GetByEmailAsync(email, tracking: true, cancellationToken);
        if (account is not null)
        {
            if (!account.IsActive)
            {
                return Unauthorized(new { message = "TÃ i khoáº£n Ä‘Ã£ bá»‹ khoÃ¡." });
            }

            if (string.IsNullOrWhiteSpace(account.GoogleSubject))
            {
                account.GoogleSubject = token.Uid;
                account.AuthProvider = AuthProvider.Google;
                account.AvatarUrl ??= avatarUrl;
                account.UpdatedAt = DateTime.UtcNow;
                await dataAccess.SaveChangesAsync(cancellationToken);
            }
            else if (account.GoogleSubject != token.Uid)
            {
                return Unauthorized(new { message = "Email nÃ y Ä‘Ã£ liÃªn káº¿t vá»›i tÃ i khoáº£n Google khÃ¡c." });
            }

            return Ok(account.ToDto());
        }

        account = new Account
        {
            FullName = fullName,
            Email = email,
            AvatarUrl = avatarUrl,
            RoleId = 1,
            AuthProvider = AuthProvider.Google,
            GoogleSubject = token.Uid,
            IsActive = true
        };
        account = await accountService.CreateAsync(account, cancellationToken);
        return Ok((await accountService.GetByIdAsync(account.Id, cancellationToken)).ToDto());
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

    private static string? ClaimString(FirebaseToken token, string key) =>
        token.Claims.TryGetValue(key, out var value) ? value?.ToString() : null;
}
