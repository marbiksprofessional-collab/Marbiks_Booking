class ServiceItem {
  final String id;
  final String name;
  final String? category;
  final int durationMinutes;
  final String price;

  ServiceItem({
    required this.id,
    required this.name,
    this.category,
    required this.durationMinutes,
    required this.price,
  });

  factory ServiceItem.fromJson(Map<String, dynamic> json) => ServiceItem(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String?,
        durationMinutes: json['durationMinutes'] as int,
        price: json['price'] as String,
      );
}
