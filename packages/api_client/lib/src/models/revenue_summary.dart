class BranchRevenue {
  final String branchId;
  final String branchName;
  final String totalBilled;
  final String totalCollected;
  final String totalOutstanding;
  final String totalTax;
  final int invoiceCount;

  BranchRevenue({
    required this.branchId,
    required this.branchName,
    required this.totalBilled,
    required this.totalCollected,
    required this.totalOutstanding,
    required this.totalTax,
    required this.invoiceCount,
  });

  factory BranchRevenue.fromJson(Map<String, dynamic> json) => BranchRevenue(
        branchId: json['branchId'] as String,
        branchName: json['branchName'] as String,
        totalBilled: json['totalBilled'] as String,
        totalCollected: json['totalCollected'] as String,
        totalOutstanding: json['totalOutstanding'] as String,
        totalTax: json['totalTax'] as String,
        invoiceCount: json['invoiceCount'] as int,
      );
}

/// Real aggregate revenue across all branches for a date range, computed
/// server-side from actual invoices (backend `GET /reports/revenue`).
///
/// [cgst] and [sgst] are an honest display-only split of [totalTax] (halved,
/// assuming intra-state sales) - there is no separate CGST/SGST ledger on the
/// backend, so don't treat these as independently-sourced figures.
class RevenueSummary {
  final DateTime from;
  final DateTime to;
  final String totalBilled;
  final String totalCollected;
  final String totalOutstanding;
  final String totalTax;
  final String cgst;
  final String sgst;
  final int branchCount;
  final List<BranchRevenue> branches;

  RevenueSummary({
    required this.from,
    required this.to,
    required this.totalBilled,
    required this.totalCollected,
    required this.totalOutstanding,
    required this.totalTax,
    required this.cgst,
    required this.sgst,
    required this.branchCount,
    required this.branches,
  });

  factory RevenueSummary.fromJson(Map<String, dynamic> json) => RevenueSummary(
        from: DateTime.parse(json['from'] as String),
        to: DateTime.parse(json['to'] as String),
        totalBilled: json['totalBilled'] as String,
        totalCollected: json['totalCollected'] as String,
        totalOutstanding: json['totalOutstanding'] as String,
        totalTax: json['totalTax'] as String,
        cgst: json['cgst'] as String,
        sgst: json['sgst'] as String,
        branchCount: json['branchCount'] as int,
        branches: (json['branches'] as List<dynamic>)
            .map((item) => BranchRevenue.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
