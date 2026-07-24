class PurchaseOrderItem {
  final String id;
  final String productId;
  final int quantityOrdered;
  final int quantityReceived;
  final String unitCost;

  PurchaseOrderItem({
    required this.id,
    required this.productId,
    required this.quantityOrdered,
    required this.quantityReceived,
    required this.unitCost,
  });

  factory PurchaseOrderItem.fromJson(Map<String, dynamic> json) => PurchaseOrderItem(
        id: json['id'] as String,
        productId: json['productId'] as String,
        quantityOrdered: json['quantityOrdered'] as int,
        quantityReceived: json['quantityReceived'] as int,
        unitCost: json['unitCost'] as String,
      );
}

class PurchaseOrder {
  final String id;
  final String branchId;
  final String vendorId;
  final String status;
  final DateTime? receivedAt;
  final DateTime createdAt;
  final List<PurchaseOrderItem> items;

  PurchaseOrder({
    required this.id,
    required this.branchId,
    required this.vendorId,
    required this.status,
    this.receivedAt,
    required this.createdAt,
    required this.items,
  });

  factory PurchaseOrder.fromJson(Map<String, dynamic> json) => PurchaseOrder(
        id: json['id'] as String,
        branchId: json['branchId'] as String,
        vendorId: json['vendorId'] as String,
        status: json['status'] as String,
        receivedAt:
            json['receivedAt'] != null ? DateTime.parse(json['receivedAt'] as String) : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        items: (json['items'] as List<dynamic>)
            .map((item) => PurchaseOrderItem.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
