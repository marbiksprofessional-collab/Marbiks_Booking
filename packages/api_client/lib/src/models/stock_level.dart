class StockLevel {
  final String productId;
  final String name;
  final String sku;
  final String unit;
  final int reorderLevel;
  final int quantityOnHand;

  StockLevel({
    required this.productId,
    required this.name,
    required this.sku,
    required this.unit,
    required this.reorderLevel,
    required this.quantityOnHand,
  });

  bool get isLowStock => quantityOnHand <= reorderLevel;

  factory StockLevel.fromJson(Map<String, dynamic> json) => StockLevel(
        productId: json['productId'] as String,
        name: json['name'] as String,
        sku: json['sku'] as String,
        unit: json['unit'] as String,
        reorderLevel: json['reorderLevel'] as int,
        quantityOnHand: json['quantityOnHand'] as int,
      );
}
