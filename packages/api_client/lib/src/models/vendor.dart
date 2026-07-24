class Vendor {
  final String id;
  final String name;
  final String? phone;
  final String? email;

  Vendor({required this.id, required this.name, this.phone, this.email});

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
      );
}
