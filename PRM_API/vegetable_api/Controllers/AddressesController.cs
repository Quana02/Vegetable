using DataAccess;
using DataAccess.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using vegetable_api.Contracts;

namespace vegetable_api.Controllers;

[ApiController]
[Route("api/accounts/{accountId:long}/addresses")]
public class AddressesController(IDataAccess dataAccess) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<AddressDto>>> GetAll(
        long accountId,
        CancellationToken cancellationToken) =>
        Ok((await dataAccess.Query<Address>()
            .Where(x => x.AccountId == accountId)
            .OrderByDescending(x => x.IsDefault)
            .ToListAsync(cancellationToken)).Select(x => x.ToDto()));

    [HttpPost]
    public async Task<ActionResult<AddressDto>> Create(
        long accountId,
        AddressRequest request,
        CancellationToken cancellationToken)
    {
        if (request.IsDefault)
        {
            var currentDefaults = await dataAccess.Query<Address>(tracking: true)
                .Where(x => x.AccountId == accountId && x.IsDefault)
                .ToListAsync(cancellationToken);
            currentDefaults.ForEach(x => x.IsDefault = false);
        }

        var address = new Address
        {
            AccountId = accountId,
            RecipientName = request.RecipientName.Trim(),
            PhoneNumber = request.PhoneNumber.Trim(),
            AddressLine = request.AddressLine.Trim(),
            Ward = request.Ward?.Trim(),
            District = request.District?.Trim(),
            Province = request.Province.Trim(),
            IsDefault = request.IsDefault
        };
        await dataAccess.AddAsync(address, cancellationToken);
        await dataAccess.SaveChangesAsync(cancellationToken);
        return CreatedAtAction(nameof(GetAll), new { accountId }, address.ToDto());
    }
}
