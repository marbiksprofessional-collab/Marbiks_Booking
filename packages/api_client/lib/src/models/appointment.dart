class Appointment {
  final String id;
  final String branchId;
  final String customerId;
  final String? technicianId;
  final String? resourceId;
  final String serviceId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String? notes;

  Appointment({
    required this.id,
    required this.branchId,
    required this.customerId,
    this.technicianId,
    this.resourceId,
    required this.serviceId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.notes,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'] as String,
        branchId: json['branchId'] as String,
        customerId: json['customerId'] as String,
        technicianId: json['technicianId'] as String?,
        resourceId: json['resourceId'] as String?,
        serviceId: json['serviceId'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: DateTime.parse(json['endTime'] as String),
        status: json['status'] as String,
        notes: json['notes'] as String?,
      );
}
