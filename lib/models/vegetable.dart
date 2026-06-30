class Vegetable {
  const Vegetable({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.description,
    required this.imageUrl,
    this.categoryId = 0,
    this.stock = 0,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String description;
  final String imageUrl;
  final int categoryId;
  final int stock;
  final bool isActive;
  final DateTime? createdAt;

  factory Vegetable.fromJson(Map<String, dynamic> json) => Vegetable(
    id: json['id'].toString(),
    name: json['name'] as String,
    category: (json['categoryName'] ?? json['category'] ?? '') as String,
    categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
    price: (json['price'] as num).toDouble(),
    unit: json['unit'] as String,
    description: (json['description'] ?? '') as String,
    imageUrl: (json['imageUrl'] ?? '') as String,
    stock: (json['stock'] as num?)?.toInt() ?? 0,
    isActive: json['isActive'] as bool? ?? true,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );

  Map<String, dynamic> toApiJson() => {
    'categoryId': categoryId,
    'name': name,
    'slug': null,
    'description': description,
    'price': price,
    'unit': unit,
    'stock': stock,
    'imageUrl': imageUrl,
    'isActive': isActive,
  };

  Vegetable copyWith({
    String? name,
    String? category,
    double? price,
    String? unit,
    String? description,
    String? imageUrl,
    int? categoryId,
    int? stock,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Vegetable(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      categoryId: categoryId ?? this.categoryId,
      stock: stock ?? this.stock,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
