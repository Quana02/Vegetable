using DataAccess.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Services;
using vegetable_api.Contracts;
using vegetable_api.Hubs;

namespace vegetable_api.Controllers;

[ApiController]
[Route("api/vegetables")]
public class VegetablesController(IVegetableService service, IHubContext<AppHub> hubContext) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<VegetableDto>>> GetAll(
        [FromQuery] string? search,
        [FromQuery] int? categoryId,
        [FromQuery] decimal? minPrice,
        [FromQuery] decimal? maxPrice,
        [FromQuery] bool includeInactive = false,
        CancellationToken cancellationToken = default) =>
        Ok((await service.SearchAsync(search, categoryId, minPrice, maxPrice, includeInactive, cancellationToken))
            .Select(x => x.ToDto()));

    [HttpGet("{id:long}")]
    public async Task<ActionResult<VegetableDto>> Get(long id, CancellationToken cancellationToken) =>
        Ok((await service.GetByIdAsync(id, cancellationToken)).ToDto());

    [HttpPost]
    public async Task<ActionResult<VegetableDto>> Create(
        VegetableUpsertRequest request,
        CancellationToken cancellationToken)
    {
        var result = await service.CreateAsync(ToEntity(request), cancellationToken);
        await hubContext.Clients.All.SendAsync("VegetablesUpdated", cancellationToken: cancellationToken);
        return CreatedAtAction(nameof(Get), new { id = result.Id }, result.ToDto());
    }

    [HttpPut("{id:long}")]
    public async Task<ActionResult<VegetableDto>> Update(
        long id,
        VegetableUpsertRequest request,
        CancellationToken cancellationToken)
    {
        var result = await service.UpdateAsync(id, ToEntity(request), cancellationToken);
        await hubContext.Clients.All.SendAsync("VegetablesUpdated", cancellationToken: cancellationToken);
        return Ok(result.ToDto());
    }

    [HttpDelete("{id:long}")]
    public async Task<IActionResult> Delete(long id, CancellationToken cancellationToken)
    {
        await service.DeleteAsync(id, cancellationToken);
        await hubContext.Clients.All.SendAsync("VegetablesUpdated", cancellationToken: cancellationToken);
        return NoContent();
    }

    private static Vegetable ToEntity(VegetableUpsertRequest request) => new()
    {
        CategoryId = request.CategoryId,
        Name = request.Name,
        Slug = request.Slug ?? string.Empty,
        Description = request.Description,
        Price = request.Price,
        Unit = request.Unit,
        Stock = request.Stock,
        ImageUrl = request.ImageUrl,
        IsActive = request.IsActive
    };
}
