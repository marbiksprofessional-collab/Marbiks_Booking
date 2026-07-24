class Customer {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final int loyaltyPoints;

  Customer({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    required this.loyaltyPoints,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
        loyaltyPoints: json['loyaltyPoints'] as int? ?? 0,
      );
}
