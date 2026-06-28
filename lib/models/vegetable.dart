class Vegetable {
  const Vegetable({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.unit,
    required this.description,
    required this.imageUrl,
    this.stock = 0,
  });

  final String id;
  final String name;
  final String category;
  final double price;
  final String unit;
  final String description;
  final String imageUrl;
  final int stock;

  Vegetable copyWith({
    String? name,
    String? category,
    double? price,
    String? unit,
    String? description,
    String? imageUrl,
    int? stock,
  }) {
    return Vegetable(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
    );
  }
}
