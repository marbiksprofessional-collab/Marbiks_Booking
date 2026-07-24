class StockBatch {
  final String id;
  final String productId;
  final String? productName;
  final String branchId;
  final String? batchNumber;
  final DateTime? expiryDate;
  final int quantityReceived;
  final int quantityRemaining;

  StockBatch({
    required this.id,
    required this.productId,
    this.productName,
    required this.branchId,
    this.batchNumber,
    this.expiryDate,
    required this.quantityReceived,
    required this.quantityRemaining,
  });

  factory StockBatch.fromJson(Map<String, dynamic> json) => StockBatch(
        id: json['id'] as String,
        productId: json['productId'] as String,
        productName: (json['product'] as Map<String, dynamic>?)?['name'] as String?,
        branchId: json['branchId'] as String,
        batchNumber: json['batchNumber'] as String?,
        expiryDate:
            json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : null,
        quantityReceived: json['quantityReceived'] as int,
        quantityRemaining: json['quantityRemaining'] as int,
      );
}
