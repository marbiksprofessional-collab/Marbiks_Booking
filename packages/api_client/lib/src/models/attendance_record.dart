class AttendanceRecord {
  final String id;
  final String userId;
  final String branchId;
  final DateTime clockInAt;
  final DateTime? clockOutAt;

  AttendanceRecord({
    required this.id,
    required this.userId,
    required this.branchId,
    required this.clockInAt,
    this.clockOutAt,
  });

  bool get isClockedIn => clockOutAt == null;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => AttendanceRecord(
        id: json['id'] as String,
        userId: json['userId'] as String,
        branchId: json['branchId'] as String,
        clockInAt: DateTime.parse(json['clockInAt'] as String),
        clockOutAt:
            json['clockOutAt'] != null ? DateTime.parse(json['clockOutAt'] as String) : null,
      );
}
