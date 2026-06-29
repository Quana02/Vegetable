using System.Globalization;
using System.Text;
using System.Text.RegularExpressions;
using DataAccess;
using DataAccess.Models;
using Repositories;

namespace Services;

public sealed class VegetableService(
    IVegetableRepository vegetables,
    IRepository<Category> categories,
    IDataAccess dataAccess) : IVegetableService
{
    public Task<IReadOnlyList<Vegetable>> SearchAsync(
        string? keyword,
        int? categoryId,
        decimal? minPrice,
        decimal? maxPrice,
        bool includeInactive = false,
        CancellationToken cancellationToken = default)
    {
        if (minPrice < 0 || maxPrice < 0 || minPrice > maxPrice)
        {
            throw new ArgumentException("Khoảng giá không hợp lệ.");
        }

        return vegetables.SearchAsync(
            keyword,
            categoryId,
            minPrice,
            maxPrice,
            includeInactive,
            cancellationToken);
    }

    public async Task<Vegetable> GetByIdAsync(long id, CancellationToken cancellationToken = default) =>
        await vegetables.GetByIdAsync(id, cancellationToken: cancellationToken)
        ?? throw new KeyNotFoundException("Không tìm thấy sản phẩm rau.");

    public async Task<Vegetable> CreateAsync(
        Vegetable vegetable,
        CancellationToken cancellationToken = default)
    {
        await ValidateAsync(vegetable, cancellationToken);
        vegetable.Id = 0;
        vegetable.Name = vegetable.Name.Trim();
        vegetable.Slug = string.IsNullOrWhiteSpace(vegetable.Slug)
            ? CreateSlug(vegetable.Name)
            : CreateSlug(vegetable.Slug);
        vegetable.CreatedAt = DateTime.UtcNow;
        vegetable.UpdatedAt = DateTime.UtcNow;

        if (await vegetables.SlugExistsAsync(vegetable.Slug, cancellationToken: cancellationToken))
        {
            vegetable.Slug = $"{vegetable.Slug}-{Guid.NewGuid():N}"[..Math.Min(vegetable.Slug.Length + 9, 180)];
        }

        await vegetables.AddAsync(vegetable, cancellationToken);
        await dataAccess.SaveChangesAsync(cancellationToken);
        return vegetable;
    }

    public async Task<Vegetable> UpdateAsync(
        long id,
        Vegetable input,
        CancellationToken cancellationToken = default)
    {
        await ValidateAsync(input, cancellationToken);
        var vegetable = await vegetables.GetByIdAsync(id, tracking: true, cancellationToken)
            ?? throw new KeyNotFoundException("Không tìm thấy sản phẩm rau.");
        var slug = string.IsNullOrWhiteSpace(input.Slug) ? CreateSlug(input.Name) : CreateSlug(input.Slug);
        if (await vegetables.SlugExistsAsync(slug, id, cancellationToken))
        {
            throw new InvalidOperationException("Slug sản phẩm đã tồn tại.");
        }

        vegetable.CategoryId = input.CategoryId;
        vegetable.Name = input.Name.Trim();
        vegetable.Slug = slug;
        vegetable.Description = input.Description?.Trim();
        vegetable.Price = input.Price;
        vegetable.Unit = input.Unit.Trim();
        vegetable.Stock = input.Stock;
        vegetable.ImageUrl = input.ImageUrl?.Trim();
        vegetable.IsActive = input.IsActive;
        vegetable.UpdatedById = input.UpdatedById;
        vegetable.UpdatedAt = DateTime.UtcNow;

        await dataAccess.SaveChangesAsync(cancellationToken);
        return vegetable;
    }

    public async Task DeleteAsync(long id, CancellationToken cancellationToken = default)
    {
        var vegetable = await vegetables.GetByIdAsync(id, tracking: true, cancellationToken)
            ?? throw new KeyNotFoundException("Không tìm thấy sản phẩm rau.");
        vegetable.IsActive = false;
        vegetable.UpdatedAt = DateTime.UtcNow;
        await dataAccess.SaveChangesAsync(cancellationToken);
    }

    private async Task ValidateAsync(Vegetable vegetable, CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(vegetable.Name) || string.IsNullOrWhiteSpace(vegetable.Unit))
        {
            throw new ArgumentException("Tên và đơn vị sản phẩm không được để trống.");
        }

        if (vegetable.Price < 0 || vegetable.Stock < 0)
        {
            throw new ArgumentException("Giá và tồn kho không được là số âm.");
        }

        if (await categories.GetByIdAsync([vegetable.CategoryId], cancellationToken) is null)
        {
            throw new ArgumentException("Loại rau không tồn tại.");
        }
    }

    private static string CreateSlug(string value)
    {
        var normalized = value.Trim().ToLowerInvariant().Replace('đ', 'd').Normalize(NormalizationForm.FormD);
        var builder = new StringBuilder();
        foreach (var character in normalized)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(character) != UnicodeCategory.NonSpacingMark)
            {
                builder.Append(character);
            }
        }

        var slug = Regex.Replace(builder.ToString().Normalize(NormalizationForm.FormC), @"[^a-z0-9]+", "-");
        return slug.Trim('-');
    }
}
