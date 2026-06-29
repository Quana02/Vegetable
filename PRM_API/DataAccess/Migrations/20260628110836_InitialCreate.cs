using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Categories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(80)", maxLength: 80, nullable: false),
                    Slug = table.Column<string>(type: "varchar(100)", unicode: false, maxLength: 100, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Categories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    Id = table.Column<byte>(type: "tinyint", nullable: false),
                    Name = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    DisplayName = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Accounts",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FullName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    Email = table.Column<string>(type: "varchar(255)", unicode: false, maxLength: 255, nullable: false),
                    PasswordHash = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    PhoneNumber = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: true),
                    AvatarUrl = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    RoleId = table.Column<byte>(type: "tinyint", nullable: false),
                    AuthProvider = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    GoogleSubject = table.Column<string>(type: "varchar(255)", unicode: false, maxLength: 255, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Accounts", x => x.Id);
                    table.CheckConstraint("CK_Accounts_LoginMethod", "([AuthProvider] = 'Local' AND [PasswordHash] IS NOT NULL) OR ([AuthProvider] = 'Google' AND [GoogleSubject] IS NOT NULL)");
                    table.ForeignKey(
                        name: "FK_Accounts_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Addresses",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AccountId = table.Column<long>(type: "bigint", nullable: false),
                    RecipientName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    PhoneNumber = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    AddressLine = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: false),
                    Ward = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    District = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    Province = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    IsDefault = table.Column<bool>(type: "bit", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Addresses", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Addresses_Accounts_AccountId",
                        column: x => x.AccountId,
                        principalTable: "Accounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Carts",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AccountId = table.Column<long>(type: "bigint", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Carts", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Carts_Accounts_AccountId",
                        column: x => x.AccountId,
                        principalTable: "Accounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Orders",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OrderCode = table.Column<string>(type: "varchar(30)", unicode: false, maxLength: 30, nullable: false),
                    AccountId = table.Column<long>(type: "bigint", nullable: false),
                    Status = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    PaymentMethod = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    PaymentStatus = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    Subtotal = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    ShippingFee = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    DiscountAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    TotalAmount = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    RecipientName = table.Column<string>(type: "nvarchar(120)", maxLength: 120, nullable: false),
                    RecipientPhone = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    ShippingAddress = table.Column<string>(type: "nvarchar(600)", maxLength: 600, nullable: false),
                    CustomerNote = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CancellationReason = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    CompletedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Orders", x => x.Id);
                    table.CheckConstraint("CK_Orders_DiscountAmount", "[DiscountAmount] >= 0");
                    table.CheckConstraint("CK_Orders_ShippingFee", "[ShippingFee] >= 0");
                    table.CheckConstraint("CK_Orders_Subtotal", "[Subtotal] >= 0");
                    table.CheckConstraint("CK_Orders_TotalAmount", "[TotalAmount] >= 0");
                    table.ForeignKey(
                        name: "FK_Orders_Accounts_AccountId",
                        column: x => x.AccountId,
                        principalTable: "Accounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "RefreshTokens",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AccountId = table.Column<long>(type: "bigint", nullable: false),
                    TokenHash = table.Column<string>(type: "varchar(128)", unicode: false, maxLength: 128, nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    RevokedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RefreshTokens", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RefreshTokens_Accounts_AccountId",
                        column: x => x.AccountId,
                        principalTable: "Accounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Vegetables",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CategoryId = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Slug = table.Column<string>(type: "varchar(180)", unicode: false, maxLength: 180, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    Price = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    Unit = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    Stock = table.Column<int>(type: "int", nullable: false),
                    ImageUrl = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    CreatedById = table.Column<long>(type: "bigint", nullable: true),
                    UpdatedById = table.Column<long>(type: "bigint", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Vegetables", x => x.Id);
                    table.CheckConstraint("CK_Vegetables_Price", "[Price] >= 0");
                    table.CheckConstraint("CK_Vegetables_Stock", "[Stock] >= 0");
                    table.ForeignKey(
                        name: "FK_Vegetables_Accounts_CreatedById",
                        column: x => x.CreatedById,
                        principalTable: "Accounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Vegetables_Accounts_UpdatedById",
                        column: x => x.UpdatedById,
                        principalTable: "Accounts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Vegetables_Categories_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "Categories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "CartItems",
                columns: table => new
                {
                    CartId = table.Column<long>(type: "bigint", nullable: false),
                    VegetableId = table.Column<long>(type: "bigint", nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    AddedAt = table.Column<DateTime>(type: "datetime2", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CartItems", x => new { x.CartId, x.VegetableId });
                    table.CheckConstraint("CK_CartItems_Quantity", "[Quantity] > 0");
                    table.ForeignKey(
                        name: "FK_CartItems_Carts_CartId",
                        column: x => x.CartId,
                        principalTable: "Carts",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CartItems_Vegetables_VegetableId",
                        column: x => x.VegetableId,
                        principalTable: "Vegetables",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "OrderItems",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    OrderId = table.Column<long>(type: "bigint", nullable: false),
                    VegetableId = table.Column<long>(type: "bigint", nullable: true),
                    VegetableName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    VegetableImageUrl = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    Unit = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: false),
                    UnitPrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    Quantity = table.Column<int>(type: "int", nullable: false),
                    LineTotal = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false, computedColumnSql: "[UnitPrice] * [Quantity]", stored: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrderItems", x => x.Id);
                    table.CheckConstraint("CK_OrderItems_Quantity", "[Quantity] > 0");
                    table.CheckConstraint("CK_OrderItems_UnitPrice", "[UnitPrice] >= 0");
                    table.ForeignKey(
                        name: "FK_OrderItems_Orders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "Orders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_OrderItems_Vegetables_VegetableId",
                        column: x => x.VegetableId,
                        principalTable: "Vegetables",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.SetNull);
                });

            migrationBuilder.InsertData(
                table: "Categories",
                columns: new[] { "Id", "CreatedAt", "Description", "IsActive", "Name", "Slug" },
                values: new object[,]
                {
                    { 1, new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), "Các loại rau ăn lá tươi", true, "Rau lá", "rau-la" },
                    { 2, new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), "Các loại củ giàu dinh dưỡng", true, "Rau củ", "rau-cu" },
                    { 3, new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), "Các loại rau thu hoạch phần quả", true, "Rau quả", "rau-qua" },
                    { 4, new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), "Các loại rau thu hoạch phần hoa", true, "Rau hoa", "rau-hoa" }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "Id", "DisplayName", "Name" },
                values: new object[,]
                {
                    { (byte)1, "Người dùng", "user" },
                    { (byte)2, "Nhân viên", "staff" },
                    { (byte)3, "Quản trị viên", "admin" }
                });

            migrationBuilder.InsertData(
                table: "Vegetables",
                columns: new[] { "Id", "CategoryId", "CreatedAt", "CreatedById", "Description", "ImageUrl", "IsActive", "Name", "Price", "Slug", "Stock", "Unit", "UpdatedAt", "UpdatedById" },
                values: new object[,]
                {
                    { 1L, 1, new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null, "Cải bó xôi tươi, giàu sắt và vitamin, thu hoạch trong ngày.", "https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=900", true, "Cải bó xôi", 28000m, "cai-bo-xoi", 42, "bó", new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null },
                    { 2L, 3, new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null, "Cà chua bi vị ngọt thanh, giòn mọng, phù hợp làm salad.", "https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=900", true, "Cà chua bi", 45000m, "ca-chua-bi", 30, "500g", new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null },
                    { 3L, 4, new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null, "Bông cải xanh chắc bông, giàu chất xơ và chất chống oxy hóa.", "https://images.unsplash.com/photo-1459411621453-7b03977f4bfc?w=900", true, "Bông cải xanh", 52000m, "bong-cai-xanh", 18, "500g", new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null },
                    { 4L, 2, new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null, "Cà rốt củ đều, giòn ngọt, phù hợp cho món canh và nước ép.", "https://images.unsplash.com/photo-1447175008436-170170753dd2?w=900", true, "Cà rốt Đà Lạt", 35000m, "ca-rot-da-lat", 55, "kg", new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null },
                    { 5L, 1, new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null, "Xà lách lá giòn, được trồng theo phương pháp thủy canh.", "https://images.unsplash.com/photo-1622206151226-18ca2c9ab4a1?w=900", true, "Xà lách lô lô", 32000m, "xa-lach-lo-lo", 25, "500g", new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null },
                    { 6L, 3, new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null, "Ớt chuông nhiều màu, ít hạt, vị ngọt nhẹ và giàu vitamin C.", "https://images.unsplash.com/photo-1563565375-f3fdfdbefa83?w=900", true, "Ớt chuông", 68000m, "ot-chuong", 16, "500g", new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null },
                    { 7L, 2, new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null, "Khoai tây ruột vàng, bở thơm, phù hợp chiên hoặc nấu súp.", "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=900", true, "Khoai tây", 38000m, "khoai-tay", 61, "kg", new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null },
                    { 8L, 3, new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null, "Bí ngòi non, mềm ngọt, ít calo và dễ chế biến.", "https://images.unsplash.com/photo-1596636478939-59fed7a083f2?w=900", true, "Bí ngòi xanh", 42000m, "bi-ngoi-xanh", 21, "kg", new DateTime(2026, 6, 28, 0, 0, 0, 0, DateTimeKind.Utc), null }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Accounts_Email",
                table: "Accounts",
                column: "Email",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Accounts_GoogleSubject",
                table: "Accounts",
                column: "GoogleSubject",
                unique: true,
                filter: "[GoogleSubject] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Accounts_RoleId_IsActive",
                table: "Accounts",
                columns: new[] { "RoleId", "IsActive" });

            migrationBuilder.CreateIndex(
                name: "IX_Addresses_AccountId",
                table: "Addresses",
                column: "AccountId",
                unique: true,
                filter: "[IsDefault] = 1");

            migrationBuilder.CreateIndex(
                name: "IX_CartItems_VegetableId",
                table: "CartItems",
                column: "VegetableId");

            migrationBuilder.CreateIndex(
                name: "IX_Carts_AccountId",
                table: "Carts",
                column: "AccountId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Categories_Name",
                table: "Categories",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Categories_Slug",
                table: "Categories",
                column: "Slug",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_OrderItems_OrderId",
                table: "OrderItems",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_OrderItems_VegetableId",
                table: "OrderItems",
                column: "VegetableId");

            migrationBuilder.CreateIndex(
                name: "IX_Orders_AccountId_CreatedAt",
                table: "Orders",
                columns: new[] { "AccountId", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_Orders_OrderCode",
                table: "Orders",
                column: "OrderCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Orders_Status_CreatedAt",
                table: "Orders",
                columns: new[] { "Status", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_AccountId_ExpiresAt",
                table: "RefreshTokens",
                columns: new[] { "AccountId", "ExpiresAt" });

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_TokenHash",
                table: "RefreshTokens",
                column: "TokenHash",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Roles_Name",
                table: "Roles",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Vegetables_CategoryId_IsActive",
                table: "Vegetables",
                columns: new[] { "CategoryId", "IsActive" });

            migrationBuilder.CreateIndex(
                name: "IX_Vegetables_CreatedById",
                table: "Vegetables",
                column: "CreatedById");

            migrationBuilder.CreateIndex(
                name: "IX_Vegetables_Name",
                table: "Vegetables",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_Vegetables_Price",
                table: "Vegetables",
                column: "Price");

            migrationBuilder.CreateIndex(
                name: "IX_Vegetables_Slug",
                table: "Vegetables",
                column: "Slug",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Vegetables_UpdatedById",
                table: "Vegetables",
                column: "UpdatedById");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Addresses");

            migrationBuilder.DropTable(
                name: "CartItems");

            migrationBuilder.DropTable(
                name: "OrderItems");

            migrationBuilder.DropTable(
                name: "RefreshTokens");

            migrationBuilder.DropTable(
                name: "Carts");

            migrationBuilder.DropTable(
                name: "Orders");

            migrationBuilder.DropTable(
                name: "Vegetables");

            migrationBuilder.DropTable(
                name: "Accounts");

            migrationBuilder.DropTable(
                name: "Categories");

            migrationBuilder.DropTable(
                name: "Roles");
        }
    }
}
