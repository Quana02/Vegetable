using DataAccess;
using DataAccess.Models;
using Repositories;

namespace Services;

public sealed class CartService(
    ICartRepository carts,
    IVegetableRepository vegetables,
    IDataAccess dataAccess) : ICartService
{
    public async Task<Cart> GetAsync(long accountId, CancellationToken cancellationToken = default)
    {
        var cart = await carts.GetByAccountIdAsync(accountId, cancellationToken: cancellationToken);
        if (cart is not null)
        {
            return cart;
        }

        cart = new Cart { AccountId = accountId };
        await carts.AddAsync(cart, cancellationToken);
        await dataAccess.SaveChangesAsync(cancellationToken);
        return cart;
    }

    public async Task<Cart> AddItemAsync(
        long accountId,
        long vegetableId,
        int quantity,
        CancellationToken cancellationToken = default)
    {
        if (quantity <= 0)
        {
            throw new ArgumentException("Số lượng phải lớn hơn 0.");
        }

        var vegetable = await vegetables.GetByIdAsync(vegetableId, tracking: true, cancellationToken)
            ?? throw new KeyNotFoundException("Không tìm thấy sản phẩm rau.");
        if (!vegetable.IsActive || vegetable.Stock < quantity)
        {
            throw new InvalidOperationException("Sản phẩm không hoạt động hoặc không đủ tồn kho.");
        }

        var cart = await GetTrackedCartAsync(accountId, cancellationToken);
        var item = cart.Items.SingleOrDefault(x => x.VegetableId == vegetableId);
        if (item is null)
        {
            cart.Items.Add(new CartItem
            {
                VegetableId = vegetableId,
                Vegetable = vegetable,
                Quantity = quantity
            });
        }
        else
        {
            if (item.Quantity + quantity > vegetable.Stock)
            {
                throw new InvalidOperationException("Số lượng trong giỏ vượt quá tồn kho.");
            }

            item.Quantity += quantity;
        }

        cart.UpdatedAt = DateTime.UtcNow;
        await dataAccess.SaveChangesAsync(cancellationToken);
        return cart;
    }

    public async Task<Cart> UpdateQuantityAsync(
        long accountId,
        long vegetableId,
        int quantity,
        CancellationToken cancellationToken = default)
    {
        var cart = await GetTrackedCartAsync(accountId, cancellationToken);
        var item = cart.Items.SingleOrDefault(x => x.VegetableId == vegetableId)
            ?? throw new KeyNotFoundException("Sản phẩm không có trong giỏ hàng.");
        if (quantity <= 0)
        {
            dataAccess.Remove(item);
        }
        else
        {
            if (quantity > item.Vegetable.Stock)
            {
                throw new InvalidOperationException("Số lượng trong giỏ vượt quá tồn kho.");
            }

            item.Quantity = quantity;
        }

        cart.UpdatedAt = DateTime.UtcNow;
        await dataAccess.SaveChangesAsync(cancellationToken);
        return cart;
    }

    public Task<Cart> RemoveItemAsync(
        long accountId,
        long vegetableId,
        CancellationToken cancellationToken = default) =>
        UpdateQuantityAsync(accountId, vegetableId, 0, cancellationToken);

    private async Task<Cart> GetTrackedCartAsync(long accountId, CancellationToken cancellationToken)
    {
        var cart = await carts.GetByAccountIdAsync(accountId, tracking: true, cancellationToken);
        if (cart is not null)
        {
            return cart;
        }

        cart = new Cart { AccountId = accountId };
        await carts.AddAsync(cart, cancellationToken);
        return cart;
    }
}
