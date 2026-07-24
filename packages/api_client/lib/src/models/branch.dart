class Branch {
  final String id;
  final String code;
  final String name;
  final String? city;

  Branch({required this.id, required this.code, required this.name, this.city});

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json['id'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        city: json['city'] as String?,
      );
}
