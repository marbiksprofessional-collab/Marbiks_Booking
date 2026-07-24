class UnbilledAppointment {
  final String id;
  final String branchId;
  final String branchName;
  final String customerId;
  final String serviceName;
  final DateTime startTime;

  UnbilledAppointment({
    required this.id,
    required this.branchId,
    required this.branchName,
    required this.customerId,
    required this.serviceName,
    required this.startTime,
  });

  factory UnbilledAppointment.fromJson(Map<String, dynamic> json) => UnbilledAppointment(
        id: json['id'] as String,
        branchId: json['branchId'] as String,
        branchName: json['branchName'] as String,
        customerId: json['customerId'] as String,
        serviceName: json['serviceName'] as String,
        startTime: DateTime.parse(json['startTime'] as String),
      );
}

class OverdueInvoice {
  final String id;
  final String invoiceNumber;
  final String branchId;
  final String branchName;
  final String total;
  final DateTime createdAt;
  final int daysOverdue;

  OverdueInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.branchId,
    required this.branchName,
    required this.total,
    required this.createdAt,
    required this.daysOverdue,
  });

  factory OverdueInvoice.fromJson(Map<String, dynamic> json) => OverdueInvoice(
        id: json['id'] as String,
        invoiceNumber: json['invoiceNumber'] as String,
        branchId: json['branchId'] as String,
        branchName: json['branchName'] as String,
        total: json['total'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        daysOverdue: json['daysOverdue'] as int,
      );
}

/// Real anomaly signals derived from actual data (backend `GET
/// /reports/leakage`) - completed appointments nobody ever invoiced, and
/// invoices still unpaid past the threshold. Deliberately NOT an "AI fraud"
/// or IoT-sensor feature: there is no sensor feed or fraud model behind
/// this, just two honest SQL queries.
class LeakageReport {
  final DateTime generatedAt;
  final int unpaidDaysThreshold;
  final List<UnbilledAppointment> unbilledCompleted;
  final List<OverdueInvoice> overdueInvoices;
  final String overdueTotalAmount;

  LeakageReport({
    required this.generatedAt,
    required this.unpaidDaysThreshold,
    required this.unbilledCompleted,
    required this.overdueInvoices,
    required this.overdueTotalAmount,
  });

  factory LeakageReport.fromJson(Map<String, dynamic> json) => LeakageReport(
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        unpaidDaysThreshold: json['unpaidDaysThreshold'] as int,
        unbilledCompleted: (json['unbilledCompleted'] as List<dynamic>)
            .map((item) => UnbilledAppointment.fromJson(item as Map<String, dynamic>))
            .toList(),
        overdueInvoices: (json['overdueInvoices'] as List<dynamic>)
            .map((item) => OverdueInvoice.fromJson(item as Map<String, dynamic>))
            .toList(),
        overdueTotalAmount: json['overdueTotalAmount'] as String,
      );
}
