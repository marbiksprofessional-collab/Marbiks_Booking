class Product {
  final String id;
  final String name;
  final String sku;
  final String? category;
  final String unit;
  final int reorderLevel;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    this.category,
    required this.unit,
    required this.reorderLevel,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        sku: json['sku'] as String,
        category: json['category'] as String?,
        unit: json['unit'] as String,
        reorderLevel: json['reorderLevel'] as int,
      );
}
