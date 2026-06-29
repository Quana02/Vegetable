using Microsoft.EntityFrameworkCore;

namespace DataAccess.Models;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    private static readonly DateTime SeedDate = new(2026, 6, 28, 0, 0, 0, DateTimeKind.Utc);

    public DbSet<Role> Roles => Set<Role>();
    public DbSet<Account> Accounts => Set<Account>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<Category> Categories => Set<Category>();
    public DbSet<Vegetable> Vegetables => Set<Vegetable>();
    public DbSet<Address> Addresses => Set<Address>();
    public DbSet<Cart> Carts => Set<Cart>();
    public DbSet<CartItem> CartItems => Set<CartItem>();
    public DbSet<Order> Orders => Set<Order>();
    public DbSet<OrderItem> OrderItems => Set<OrderItem>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        ConfigureRole(modelBuilder);
        ConfigureAccount(modelBuilder);
        ConfigureRefreshToken(modelBuilder);
        ConfigureCategory(modelBuilder);
        ConfigureVegetable(modelBuilder);
        ConfigureAddress(modelBuilder);
        ConfigureCart(modelBuilder);
        ConfigureCartItem(modelBuilder);
        ConfigureOrder(modelBuilder);
        ConfigureOrderItem(modelBuilder);
    }

    private static void ConfigureRole(ModelBuilder modelBuilder)
    {
        var builder = modelBuilder.Entity<Role>();
        builder.ToTable("Roles");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Id).ValueGeneratedNever();
        builder.Property(x => x.Name).HasMaxLength(20).IsUnicode(false).IsRequired();
        builder.Property(x => x.DisplayName).HasMaxLength(50).IsRequired();
        builder.HasIndex(x => x.Name).IsUnique();
        builder.HasData(
            new Role { Id = 1, Name = "user", DisplayName = "Người dùng" },
            new Role { Id = 2, Name = "staff", DisplayName = "Nhân viên" },
            new Role { Id = 3, Name = "admin", DisplayName = "Quản trị viên" });
    }

    private static void ConfigureAccount(ModelBuilder modelBuilder)
    {
        var builder = modelBuilder.Entity<Account>();
        builder.ToTable("Accounts", table => table.HasCheckConstraint(
            "CK_Accounts_LoginMethod",
            "([AuthProvider] = 'Local' AND [PasswordHash] IS NOT NULL) OR " +
            "([AuthProvider] = 'Google' AND [GoogleSubject] IS NOT NULL)"));
        builder.HasKey(x => x.Id);
        builder.Property(x => x.FullName).HasMaxLength(120).IsRequired();
        builder.Property(x => x.Email).HasMaxLength(255).IsUnicode(false).IsRequired();
        builder.Property(x => x.PasswordHash).HasMaxLength(255);
        builder.Property(x => x.PhoneNumber).HasMaxLength(20).IsUnicode(false);
        builder.Property(x => x.AvatarUrl).HasMaxLength(1000);
        builder.Property(x => x.AuthProvider).HasConversion<string>().HasMaxLength(20).IsUnicode(false);
        builder.Property(x => x.GoogleSubject).HasMaxLength(255).IsUnicode(false);
        builder.Property(x => x.IsActive).HasDefaultValue(true);
        builder.Property(x => x.CreatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
        builder.Property(x => x.UpdatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
        builder.HasIndex(x => x.Email).IsUnique();
        builder.HasIndex(x => x.GoogleSubject).IsUnique().HasFilter("[GoogleSubject] IS NOT NULL");
        builder.HasIndex(x => new { x.RoleId, x.IsActive });
        builder.HasOne(x => x.Role)
            .WithMany(x => x.Accounts)
            .HasForeignKey(x => x.RoleId)
            .OnDelete(DeleteBehavior.Restrict);
    }

    private static void ConfigureRefreshToken(ModelBuilder modelBuilder)
    {
        var builder = modelBuilder.Entity<RefreshToken>();
        builder.ToTable("RefreshTokens");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.TokenHash).HasMaxLength(128).IsUnicode(false).IsRequired();
        builder.Property(x => x.CreatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
        builder.HasIndex(x => x.TokenHash).IsUnique();
        builder.HasIndex(x => new { x.AccountId, x.ExpiresAt });
        builder.HasOne(x => x.Account)
            .WithMany(x => x.RefreshTokens)
            .HasForeignKey(x => x.AccountId)
            .OnDelete(DeleteBehavior.Cascade);
    }

    private static void ConfigureCategory(ModelBuilder modelBuilder)
    {
        var builder = modelBuilder.Entity<Category>();
        builder.ToTable("Categories");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Name).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Slug).HasMaxLength(100).IsUnicode(false).IsRequired();
        builder.Property(x => x.Description).HasMaxLength(500);
        builder.Property(x => x.IsActive).HasDefaultValue(true);
        builder.Property(x => x.CreatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
        builder.HasIndex(x => x.Name).IsUnique();
        builder.HasIndex(x => x.Slug).IsUnique();
        builder.HasData(
            new Category { Id = 1, Name = "Rau lá", Slug = "rau-la", Description = "Các loại rau ăn lá tươi", CreatedAt = SeedDate },
            new Category { Id = 2, Name = "Rau củ", Slug = "rau-cu", Description = "Các loại củ giàu dinh dưỡng", CreatedAt = SeedDate },
            new Category { Id = 3, Name = "Rau quả", Slug = "rau-qua", Description = "Các loại rau thu hoạch phần quả", CreatedAt = SeedDate },
            new Category { Id = 4, Name = "Rau hoa", Slug = "rau-hoa", Description = "Các loại rau thu hoạch phần hoa", CreatedAt = SeedDate });
    }

    private static void ConfigureVegetable(ModelBuilder modelBuilder)
    {
        var builder = modelBuilder.Entity<Vegetable>();
        builder.ToTable("Vegetables", table =>
        {
            table.HasCheckConstraint("CK_Vegetables_Price", "[Price] >= 0");
            table.HasCheckConstraint("CK_Vegetables_Stock", "[Stock] >= 0");
        });
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Name).HasMaxLength(150).IsRequired();
        builder.Property(x => x.Slug).HasMaxLength(180).IsUnicode(false).IsRequired();
        builder.Property(x => x.Description).HasMaxLength(2000);
        builder.Property(x => x.Price).HasPrecision(18, 2);
        builder.Property(x => x.Unit).HasMaxLength(30).IsRequired();
        builder.Property(x => x.ImageUrl).HasMaxLength(1000);
        builder.Property(x => x.IsActive).HasDefaultValue(true);
        builder.Property(x => x.CreatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
        builder.Property(x => x.UpdatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
        builder.HasIndex(x => x.Slug).IsUnique();
        builder.HasIndex(x => new { x.CategoryId, x.IsActive });
        builder.HasIndex(x => x.Price);
        builder.HasIndex(x => x.Name);
        builder.HasOne(x => x.Category)
            .WithMany(x => x.Vegetables)
            .HasForeignKey(x => x.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.CreatedBy)
            .WithMany(x => x.CreatedVegetables)
            .HasForeignKey(x => x.CreatedById)
            .OnDelete(DeleteBehavior.Restrict);
        builder.HasOne(x => x.UpdatedBy)
            .WithMany(x => x.UpdatedVegetables)
            .HasForeignKey(x => x.UpdatedById)
            .OnDelete(DeleteBehavior.Restrict);
        builder.HasData(CreateVegetableSeedData());
    }

    private static void ConfigureAddress(ModelBuilder modelBuilder)
    {
        var builder = modelBuilder.Entity<Address>();
        builder.ToTable("Addresses");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.RecipientName).HasMaxLength(120).IsRequired();
        builder.Property(x => x.PhoneNumber).HasMaxLength(20).IsUnicode(false).IsRequired();
        builder.Property(x => x.AddressLine).HasMaxLength(300).IsRequired();
        builder.Property(x => x.Ward).HasMaxLength(100);
        builder.Property(x => x.District).HasMaxLength(100);
        builder.Property(x => x.Province).HasMaxLength(100).IsRequired();
        builder.Property(x => x.CreatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
        builder.HasIndex(x => x.AccountId).IsUnique().HasFilter("[IsDefault] = 1");
        builder.HasOne(x => x.Account)
            .WithMany(x => x.Addresses)
            .HasForeignKey(x => x.AccountId)
            .OnDelete(DeleteBehavior.Cascade);
    }

    private static void ConfigureCart(ModelBuilder modelBuilder)
    {
        var builder = modelBuilder.Entity<Cart>();
        builder.ToTable("Carts");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.CreatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
        builder.Property(x => x.UpdatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
        builder.HasIndex(x => x.AccountId).IsUnique();
        builder.HasOne(x => x.Account)
            .WithOne(x => x.Cart)
            .HasForeignKey<Cart>(x => x.AccountId)
            .OnDelete(DeleteBehavior.Cascade);
    }

    private static void ConfigureCartItem(ModelBuilder modelBuilder)
    {
        var builder = modelBuilder.Entity<CartItem>();
        builder.ToTable("CartItems", table =>
            table.HasCheckConstraint("CK_CartItems_Quantity", "[Quantity] > 0"));
        builder.HasKey(x => new { x.CartId, x.VegetableId });
        builder.Property(x => x.AddedAt).HasDefaultValueSql("SYSUTCDATETIME()");
        builder.HasOne(x => x.Cart)
            .WithMany(x => x.Items)
            .HasForeignKey(x => x.CartId)
            .OnDelete(DeleteBehavior.Cascade);
        builder.HasOne(x => x.Vegetable)
            .WithMany(x => x.CartItems)
            .HasForeignKey(x => x.VegetableId)
            .OnDelete(DeleteBehavior.Restrict);
    }

    private static void ConfigureOrder(ModelBuilder modelBuilder)
    {
        var builder = modelBuilder.Entity<Order>();
        builder.ToTable("Orders", table =>
        {
            table.HasCheckConstraint("CK_Orders_Subtotal", "[Subtotal] >= 0");
            table.HasCheckConstraint("CK_Orders_ShippingFee", "[ShippingFee] >= 0");
            table.HasCheckConstraint("CK_Orders_DiscountAmount", "[DiscountAmount] >= 0");
            table.HasCheckConstraint("CK_Orders_TotalAmount", "[TotalAmount] >= 0");
        });
        builder.HasKey(x => x.Id);
        builder.Property(x => x.OrderCode).HasMaxLength(30).IsUnicode(false).IsRequired();
        builder.Property(x => x.Status).HasConversion<string>().HasMaxLength(20).IsUnicode(false);
        builder.Property(x => x.PaymentMethod).HasConversion<string>().HasMaxLength(20).IsUnicode(false);
        builder.Property(x => x.PaymentStatus).HasConversion<string>().HasMaxLength(20).IsUnicode(false);
        builder.Property(x => x.Subtotal).HasPrecision(18, 2);
        builder.Property(x => x.ShippingFee).HasPrecision(18, 2);
        builder.Property(x => x.DiscountAmount).HasPrecision(18, 2);
        builder.Property(x => x.TotalAmount).HasPrecision(18, 2);
        builder.Property(x => x.RecipientName).HasMaxLength(120).IsRequired();
        builder.Property(x => x.RecipientPhone).HasMaxLength(20).IsUnicode(false).IsRequired();
        builder.Property(x => x.ShippingAddress).HasMaxLength(600).IsRequired();
        builder.Property(x => x.CustomerNote).HasMaxLength(500);
        builder.Property(x => x.CancellationReason).HasMaxLength(500);
        builder.Property(x => x.CreatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
        builder.Property(x => x.UpdatedAt).HasDefaultValueSql("SYSUTCDATETIME()");
        builder.HasIndex(x => x.OrderCode).IsUnique();
        builder.HasIndex(x => new { x.AccountId, x.CreatedAt });
        builder.HasIndex(x => new { x.Status, x.CreatedAt });
        builder.HasOne(x => x.Account)
            .WithMany(x => x.Orders)
            .HasForeignKey(x => x.AccountId)
            .OnDelete(DeleteBehavior.Restrict);
    }

    private static void ConfigureOrderItem(ModelBuilder modelBuilder)
    {
        var builder = modelBuilder.Entity<OrderItem>();
        builder.ToTable("OrderItems", table =>
        {
            table.HasCheckConstraint("CK_OrderItems_UnitPrice", "[UnitPrice] >= 0");
            table.HasCheckConstraint("CK_OrderItems_Quantity", "[Quantity] > 0");
        });
        builder.HasKey(x => x.Id);
        builder.Property(x => x.VegetableName).HasMaxLength(150).IsRequired();
        builder.Property(x => x.VegetableImageUrl).HasMaxLength(1000);
        builder.Property(x => x.Unit).HasMaxLength(30).IsRequired();
        builder.Property(x => x.UnitPrice).HasPrecision(18, 2);
        builder.Property(x => x.LineTotal)
            .HasPrecision(18, 2)
            .HasComputedColumnSql("[UnitPrice] * [Quantity]", stored: true);
        builder.HasIndex(x => x.OrderId);
        builder.HasOne(x => x.Order)
            .WithMany(x => x.Items)
            .HasForeignKey(x => x.OrderId)
            .OnDelete(DeleteBehavior.Cascade);
        builder.HasOne(x => x.Vegetable)
            .WithMany(x => x.OrderItems)
            .HasForeignKey(x => x.VegetableId)
            .OnDelete(DeleteBehavior.SetNull);
    }

    private static Vegetable[] CreateVegetableSeedData() =>
    [
        CreateVegetable(1, 1, "Cải bó xôi", "cai-bo-xoi", "Cải bó xôi tươi, giàu sắt và vitamin, thu hoạch trong ngày.", 28000, "bó", 42, "https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=900"),
        CreateVegetable(2, 3, "Cà chua bi", "ca-chua-bi", "Cà chua bi vị ngọt thanh, giòn mọng, phù hợp làm salad.", 45000, "500g", 30, "https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=900"),
        CreateVegetable(3, 4, "Bông cải xanh", "bong-cai-xanh", "Bông cải xanh chắc bông, giàu chất xơ và chất chống oxy hóa.", 52000, "500g", 18, "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=900"),
        CreateVegetable(4, 2, "Cà rốt Đà Lạt", "ca-rot-da-lat", "Cà rốt củ đều, giòn ngọt, phù hợp cho món canh và nước ép.", 35000, "kg", 55, "https://images.unsplash.com/photo-1447175008436-170170753dd2?w=900"),
        CreateVegetable(5, 1, "Xà lách lô lô", "xa-lach-lo-lo", "Xà lách lá giòn, được trồng theo phương pháp thủy canh.", 32000, "500g", 25, "https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=900"),
        CreateVegetable(6, 3, "Ớt chuông", "ot-chuong", "Ớt chuông nhiều màu, ít hạt, vị ngọt nhẹ và giàu vitamin C.", 68000, "500g", 16, "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=900"),
        CreateVegetable(7, 2, "Khoai tây", "khoai-tay", "Khoai tây ruột vàng, bở thơm, phù hợp chiên hoặc nấu súp.", 38000, "kg", 61, "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=900"),
        CreateVegetable(8, 3, "Bí ngòi xanh", "bi-ngoi-xanh", "Bí ngòi non, mềm ngọt, ít calo và dễ chế biến.", 42000, "kg", 21, "https://images.unsplash.com/photo-1596636478939-59fed7a083f2?w=900")
    ];

    private static Vegetable CreateVegetable(
        long id,
        int categoryId,
        string name,
        string slug,
        string description,
        decimal price,
        string unit,
        int stock,
        string imageUrl) => new()
        {
            Id = id,
            CategoryId = categoryId,
            Name = name,
            Slug = slug,
            Description = description,
            Price = price,
            Unit = unit,
            Stock = stock,
            ImageUrl = imageUrl,
            IsActive = true,
            CreatedAt = SeedDate,
            UpdatedAt = SeedDate
        };
}
