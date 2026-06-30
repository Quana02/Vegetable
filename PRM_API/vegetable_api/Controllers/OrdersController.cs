using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using Services;
using vegetable_api.Contracts;
using vegetable_api.Hubs;

namespace vegetable_api.Controllers;

[ApiController]
[Route("api/orders")]
public class OrdersController(IOrderService service, IHubContext<AppHub> hubContext) : ControllerBase
{
    [HttpGet("account/{accountId:long}")]
    public async Task<ActionResult<IReadOnlyList<OrderDto>>> GetByAccount(
        long accountId,
        CancellationToken cancellationToken) =>
        Ok((await service.GetByAccountIdAsync(accountId, cancellationToken)).Select(x => x.ToDto()));

    [HttpGet("{id:long}")]
    public async Task<ActionResult<OrderDto>> Get(long id, CancellationToken cancellationToken) =>
        Ok((await service.GetByIdAsync(id, cancellationToken)).ToDto());

    [HttpPost("checkout/{accountId:long}")]
    public async Task<ActionResult<OrderDto>> Checkout(
        long accountId,
        CheckoutRequest request,
        CancellationToken cancellationToken)
    {
        var order = await service.CheckoutAsync(
            accountId,
            request.AddressId,
            request.PaymentMethod,
            request.CustomerNote,
            cancellationToken);
        await hubContext.Clients.All.SendAsync("VegetablesUpdated", cancellationToken: cancellationToken);
        return CreatedAtAction(nameof(Get), new { id = order.Id }, order.ToDto());
    }

    [HttpPatch("{id:long}/status")]
    public async Task<ActionResult<OrderDto>> ChangeStatus(
        long id,
        ChangeOrderStatusRequest request,
        CancellationToken cancellationToken)
    {
        var result = await service.ChangeStatusAsync(id, request.Status, cancellationToken);
        if (request.Status == DataAccess.Models.OrderStatus.Cancelled)
        {
            await hubContext.Clients.All.SendAsync("VegetablesUpdated", cancellationToken: cancellationToken);
        }
        return Ok(result.ToDto());
    }
}
