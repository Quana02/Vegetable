using DataAccess.Models;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Repositories;
using Services;
using vegetable_api.Contracts;

namespace vegetable_api.Controllers;

[ApiController]
[Route("api/accounts")]
public class AccountsController(
    IAccountService service,
    IRepository<Role> roleRepository,
    IPasswordHasher<Account> passwordHasher) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<AccountDto>>> GetAll(
        [FromQuery] byte? roleId,
        CancellationToken cancellationToken) =>
        Ok((await service.ListAsync(roleId, cancellationToken)).Select(x => x.ToDto()));

    [HttpGet("roles")]
    public async Task<ActionResult<IReadOnlyList<RoleDto>>> GetRoles(CancellationToken cancellationToken) =>
        Ok((await roleRepository.ListAsync(cancellationToken: cancellationToken))
            .OrderBy(x => x.Id)
            .Select(x => new RoleDto(x.Id, x.Name, x.DisplayName)));

    [HttpGet("{id:long}")]
    public async Task<ActionResult<AccountDto>> Get(long id, CancellationToken cancellationToken) =>
        Ok((await service.GetByIdAsync(id, cancellationToken)).ToDto());

    [HttpPost]
    public async Task<ActionResult<AccountDto>> Create(
        CreateAccountRequest request,
        CancellationToken cancellationToken)
    {
        var account = new Account
        {
            FullName = request.FullName,
            Email = request.Email,
            RoleId = request.RoleId,
            AuthProvider = AuthProvider.Local,
            IsActive = request.IsActive
        };
        account.PasswordHash = passwordHasher.HashPassword(account, request.Password);
        account = await service.CreateAsync(account, cancellationToken);
        return CreatedAtAction(nameof(Get), new { id = account.Id }, (await service.GetByIdAsync(account.Id, cancellationToken)).ToDto());
    }

    [HttpPut("{id:long}")]
    public async Task<ActionResult<AccountDto>> Update(
        long id,
        UpdateAccountRequest request,
        CancellationToken cancellationToken) =>
        Ok((await service.UpdateAsync(id, new Account
        {
            FullName = request.FullName,
            Email = request.Email,
            PhoneNumber = request.PhoneNumber,
            AvatarUrl = request.AvatarUrl,
            RoleId = request.RoleId,
            IsActive = request.IsActive,
            AuthProvider = AuthProvider.Local,
            PasswordHash = "preserved"
        }, cancellationToken)).ToDto());

    [HttpPatch("{id:long}/role")]
    public async Task<ActionResult<AccountDto>> ChangeRole(
        long id,
        ChangeRoleRequest request,
        CancellationToken cancellationToken) =>
        Ok((await service.ChangeRoleAsync(id, request.RoleId, cancellationToken)).ToDto());

    [HttpPatch("{id:long}/active")]
    public async Task<ActionResult<AccountDto>> SetActive(
        long id,
        SetAccountActiveRequest request,
        CancellationToken cancellationToken) =>
        Ok((await service.SetActiveAsync(id, request.IsActive, cancellationToken)).ToDto());

    [HttpDelete("{id:long}")]
    public async Task<IActionResult> Delete(long id, CancellationToken cancellationToken)
    {
        await service.SetActiveAsync(id, false, cancellationToken);
        return NoContent();
    }
}
