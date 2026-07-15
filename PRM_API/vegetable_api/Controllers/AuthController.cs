using DataAccess;
using DataAccess.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;
using Repositories;
using Services;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using vegetable_api.Contracts;

namespace vegetable_api.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(
    IDataAccess dataAccess,
    IConfiguration configuration,
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
        CancellationToken cancellationToken) =>
        await SignInWithFirebaseAsync(request.IdToken, null, cancellationToken);

    [HttpPost("firebase-login")]
    public async Task<ActionResult<AccountDto>> FirebaseLogin(
        FirebaseLoginRequest request,
        CancellationToken cancellationToken) =>
        await SignInWithFirebaseAsync(request.IdToken, request.FullName, cancellationToken);

    private async Task<ActionResult<AccountDto>> SignInWithFirebaseAsync(
        string idToken,
        string? requestedFullName,
        CancellationToken cancellationToken)
    {
        var projectId = configuration["Firebase:ProjectId"];
        if (string.IsNullOrWhiteSpace(projectId))
        {
            return StatusCode(StatusCodes.Status500InternalServerError, new
            {
                message = "Firebase ProjectId is not configured. Set Firebase:ProjectId in appsettings."
            });
        }

        ClaimsPrincipal principal;
        try
        {
            principal = await VerifyFirebaseIdTokenAsync(idToken, projectId, cancellationToken);
        }
        catch
        {
            return Unauthorized(new { message = "Firebase token is invalid." });
        }

        var firebaseUid =
            ClaimString(principal, "user_id") ??
            ClaimString(principal, ClaimTypes.NameIdentifier) ??
            ClaimString(principal, JwtRegisteredClaimNames.Sub);
        if (string.IsNullOrWhiteSpace(firebaseUid))
        {
            return Unauthorized(new { message = "Firebase token does not have a valid user id." });
        }

        var email =
        ClaimString(principal, "email") ??
        ClaimString(principal, ClaimTypes.Email);

        email = email?.Trim().ToLowerInvariant();
        if (string.IsNullOrWhiteSpace(email))
        {
            return Unauthorized(new { message = "Firebase account does not have a valid email." });
        }

        var cleanRequestedFullName = requestedFullName?.Trim();
        var fullName =
            (!string.IsNullOrWhiteSpace(cleanRequestedFullName) ? cleanRequestedFullName : null) ??
            ClaimString(principal, "name") ??
            ClaimString(principal, "display_name") ??
            email.Split('@')[0];
        var avatarUrl = ClaimString(principal, "picture");

        var account = await accountRepository.GetByEmailAsync(email, tracking: true, cancellationToken);
        if (account is not null)
        {
            if (!account.IsActive)
            {
                return Unauthorized(new { message = "Account is locked." });
            }

            if (string.IsNullOrWhiteSpace(account.GoogleSubject))
            {
                account.GoogleSubject = firebaseUid;
                account.AuthProvider = AuthProvider.Google;
                account.AvatarUrl ??= avatarUrl;
                account.UpdatedAt = DateTime.UtcNow;
                await dataAccess.SaveChangesAsync(cancellationToken);
            }
            else if (account.GoogleSubject != firebaseUid)
            {
                return Unauthorized(new { message = "This email is already linked to another Firebase account." });
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
            GoogleSubject = firebaseUid,
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

    private static async Task<ClaimsPrincipal> VerifyFirebaseIdTokenAsync(
        string idToken,
        string projectId,
        CancellationToken cancellationToken)
    {
        var metadataAddress =
            $"https://securetoken.google.com/{projectId}/.well-known/openid-configuration";
        var configurationManager = new ConfigurationManager<OpenIdConnectConfiguration>(
            metadataAddress,
            new OpenIdConnectConfigurationRetriever());
        var openIdConfiguration = await configurationManager.GetConfigurationAsync(cancellationToken);

        var validationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = $"https://securetoken.google.com/{projectId}",
            ValidateAudience = true,
            ValidAudience = projectId,
            ValidateIssuerSigningKey = true,
            IssuerSigningKeys = openIdConfiguration.SigningKeys,
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(5)
        };

        return new JwtSecurityTokenHandler().ValidateToken(
            idToken,
            validationParameters,
            out _);
    }

    private static string? ClaimString(ClaimsPrincipal principal, string key) =>
        principal.Claims.FirstOrDefault(claim => claim.Type == key)?.Value;
}
