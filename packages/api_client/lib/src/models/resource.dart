class ResourceModel {
  final String id;
  final String name;
  final String type;

  ResourceModel({required this.id, required this.name, required this.type});

  factory ResourceModel.fromJson(Map<String, dynamic> json) => ResourceModel(
        id: json['id'] as String,
        name: json['name'] as String,
        type: json['type'] as String,
      );
}
