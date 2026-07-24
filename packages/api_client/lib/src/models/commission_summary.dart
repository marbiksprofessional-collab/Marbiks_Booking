class CommissionLine {
  final String appointmentId;
  final String serviceName;
  final String invoiceTotal;
  final String commissionPercent;
  final String commissionAmount;

  CommissionLine({
    required this.appointmentId,
    required this.serviceName,
    required this.invoiceTotal,
    required this.commissionPercent,
    required this.commissionAmount,
  });

  factory CommissionLine.fromJson(Map<String, dynamic> json) => CommissionLine(
        appointmentId: json['appointmentId'] as String,
        serviceName: json['serviceName'] as String,
        invoiceTotal: json['invoiceTotal'] as String,
        commissionPercent: json['commissionPercent'] as String,
        commissionAmount: json['commissionAmount'] as String,
      );
}

class CommissionSummary {
  final String technicianId;
  final String from;
  final String to;
  final String totalCommission;
  final List<CommissionLine> lines;

  CommissionSummary({
    required this.technicianId,
    required this.from,
    required this.to,
    required this.totalCommission,
    required this.lines,
  });

  factory CommissionSummary.fromJson(Map<String, dynamic> json) => CommissionSummary(
        technicianId: json['technicianId'] as String,
        from: json['from'] as String,
        to: json['to'] as String,
        totalCommission: json['totalCommission'] as String,
        lines: (json['lines'] as List<dynamic>)
            .map((line) => CommissionLine.fromJson(line as Map<String, dynamic>))
            .toList(),
      );
}
