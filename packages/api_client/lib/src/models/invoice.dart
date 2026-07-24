class InvoiceItem {
  final String description;
  final int quantity;
  final String unitPrice;
  final String total;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        description: json['description'] as String,
        quantity: json['quantity'] as int,
        unitPrice: json['unitPrice'] as String,
        total: json['total'] as String,
      );
}

class Invoice {
  final String id;
  final String invoiceNumber;
  final String branchId;
  final String customerId;
  final String? appointmentId;
  final List<InvoiceItem> items;
  final String subtotal;
  final String discountAmount;
  final String taxAmount;
  final String total;
  final String paymentStatus;
  final String? paymentMethod;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.branchId,
    required this.customerId,
    this.appointmentId,
    required this.items,
    required this.subtotal,
    required this.discountAmount,
    required this.taxAmount,
    required this.total,
    required this.paymentStatus,
    this.paymentMethod,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'] as String,
        invoiceNumber: json['invoiceNumber'] as String,
        branchId: json['branchId'] as String,
        customerId: json['customerId'] as String,
        appointmentId: json['appointmentId'] as String?,
        items: (json['items'] as List<dynamic>)
            .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
            .toList(),
        subtotal: json['subtotal'] as String,
        discountAmount: json['discountAmount'] as String,
        taxAmount: json['taxAmount'] as String,
        total: json['total'] as String,
        paymentStatus: json['paymentStatus'] as String,
        paymentMethod: json['paymentMethod'] as String?,
      );
}
