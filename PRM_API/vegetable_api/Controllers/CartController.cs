using Microsoft.AspNetCore.Mvc;
using Services;
using vegetable_api.Contracts;

namespace vegetable_api.Controllers;

[ApiController]
[Route("api/accounts/{accountId:long}/cart")]
public class CartController(ICartService service) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<CartDto>> Get(long accountId, CancellationToken cancellationToken) =>
        Ok((await service.GetAsync(accountId, cancellationToken)).ToDto());

    [HttpPost("items")]
    public async Task<ActionResult<CartDto>> AddItem(
        long accountId,
        CartItemRequest request,
        CancellationToken cancellationToken) =>
        Ok((await service.AddItemAsync(accountId, request.VegetableId, request.Quantity, cancellationToken)).ToDto());

    [HttpPut("items/{vegetableId:long}")]
    public async Task<ActionResult<CartDto>> UpdateQuantity(
        long accountId,
        long vegetableId,
        UpdateCartQuantityRequest request,
        CancellationToken cancellationToken) =>
        Ok((await service.UpdateQuantityAsync(accountId, vegetableId, request.Quantity, cancellationToken)).ToDto());

    [HttpDelete("items/{vegetableId:long}")]
    public async Task<ActionResult<CartDto>> RemoveItem(
        long accountId,
        long vegetableId,
        CancellationToken cancellationToken) =>
        Ok((await service.RemoveItemAsync(accountId, vegetableId, cancellationToken)).ToDto());
}
