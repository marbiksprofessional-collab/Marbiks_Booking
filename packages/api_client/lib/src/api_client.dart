import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_exception.dart';
import 'models/appointment.dart';
import 'models/attendance_record.dart';
import 'models/auth_result.dart';
import 'models/branch.dart';
import 'models/commission_summary.dart';
import 'models/customer.dart';
import 'models/invoice.dart';
import 'models/product.dart';
import 'models/purchase_order.dart';
import 'models/resource.dart';
import 'models/review.dart';
import 'models/service_item.dart';
import 'models/stock_batch.dart';
import 'models/stock_level.dart';
import 'models/vendor.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _httpClient;
  String? _token;

  ApiClient({required this.baseUrl, http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Future<dynamic> _decode(http.Response response) async {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    final message = body is Map && body['message'] != null
        ? (body['message'] is List ? body['message'].join(', ') : body['message'].toString())
        : 'Request failed with status ${response.statusCode}';
    throw ApiException(response.statusCode, message);
  }

  Future<AuthResult> login(String email, String password) async {
    final response = await _httpClient.post(
      _uri('/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return AuthResult.fromJson(json);
  }

  Future<List<Branch>> getBranches() async {
    final response = await _httpClient.get(_uri('/branches'), headers: _headers);
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => Branch.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<ServiceItem>> getServices() async {
    final response = await _httpClient.get(_uri('/services'), headers: _headers);
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => ServiceItem.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<ResourceModel>> getResources(String branchId) async {
    final response = await _httpClient.get(
      _uri('/resources', {'branchId': branchId}),
      headers: _headers,
    );
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => ResourceModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Customer>> searchCustomers(String search) async {
    final response = await _httpClient.get(
      _uri('/customers', search.isEmpty ? null : {'search': search}),
      headers: _headers,
    );
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => Customer.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Customer> createCustomer({
    required String fullName,
    required String phone,
    String? email,
  }) async {
    final response = await _httpClient.post(
      _uri('/customers'),
      headers: _headers,
      body: jsonEncode({
        'fullName': fullName,
        'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
      }),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return Customer.fromJson(json);
  }

  Future<List<Appointment>> getAppointments({
    required String branchId,
    required String date,
  }) async {
    final response = await _httpClient.get(
      _uri('/appointments', {'branchId': branchId, 'date': date}),
      headers: _headers,
    );
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => Appointment.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Appointment> createAppointment({
    required String branchId,
    required String customerId,
    required String serviceId,
    required DateTime startTime,
    String? technicianId,
    String? resourceId,
    String? notes,
  }) async {
    final response = await _httpClient.post(
      _uri('/appointments'),
      headers: _headers,
      body: jsonEncode({
        'branchId': branchId,
        'customerId': customerId,
        'serviceId': serviceId,
        'startTime': startTime.toUtc().toIso8601String(),
        if (technicianId != null) 'technicianId': technicianId,
        if (resourceId != null) 'resourceId': resourceId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return Appointment.fromJson(json);
  }

  Future<Appointment> rescheduleAppointment({
    required String id,
    required DateTime startTime,
    String? technicianId,
    String? resourceId,
  }) async {
    final response = await _httpClient.patch(
      _uri('/appointments/$id/reschedule'),
      headers: _headers,
      body: jsonEncode({
        'startTime': startTime.toUtc().toIso8601String(),
        if (technicianId != null) 'technicianId': technicianId,
        if (resourceId != null) 'resourceId': resourceId,
      }),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return Appointment.fromJson(json);
  }

  Future<Appointment> cancelAppointment(String id) async {
    final response =
        await _httpClient.patch(_uri('/appointments/$id/cancel'), headers: _headers);
    final json = await _decode(response) as Map<String, dynamic>;
    return Appointment.fromJson(json);
  }

  Future<Appointment> completeAppointment(String id) async {
    final response =
        await _httpClient.patch(_uri('/appointments/$id/complete'), headers: _headers);
    final json = await _decode(response) as Map<String, dynamic>;
    return Appointment.fromJson(json);
  }

  Future<Invoice> createInvoiceFromAppointment({
    required String branchId,
    required String customerId,
    required String appointmentId,
    double? discountAmount,
  }) async {
    final response = await _httpClient.post(
      _uri('/invoices'),
      headers: _headers,
      body: jsonEncode({
        'branchId': branchId,
        'customerId': customerId,
        'appointmentId': appointmentId,
        if (discountAmount != null) 'discountAmount': discountAmount,
      }),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return Invoice.fromJson(json);
  }

  Future<Invoice> markInvoicePaid(String id, String paymentMethod) async {
    final response = await _httpClient.patch(
      _uri('/invoices/$id/pay'),
      headers: _headers,
      body: jsonEncode({'paymentMethod': paymentMethod}),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return Invoice.fromJson(json);
  }

  Future<List<Appointment>> getMyAppointments({required String date}) async {
    final response = await _httpClient.get(
      _uri('/appointments/my', {'date': date}),
      headers: _headers,
    );
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => Appointment.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<Appointment>> getCustomerHistory(String customerId) async {
    final response = await _httpClient.get(
      _uri('/appointments/customer/$customerId'),
      headers: _headers,
    );
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => Appointment.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<AttendanceRecord> clockIn(String branchId) async {
    final response = await _httpClient.post(
      _uri('/attendance/clock-in'),
      headers: _headers,
      body: jsonEncode({'branchId': branchId}),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return AttendanceRecord.fromJson(json);
  }

  Future<AttendanceRecord> clockOut() async {
    final response = await _httpClient.post(_uri('/attendance/clock-out'), headers: _headers);
    final json = await _decode(response) as Map<String, dynamic>;
    return AttendanceRecord.fromJson(json);
  }

  Future<AttendanceRecord?> getAttendanceStatus() async {
    final response = await _httpClient.get(_uri('/attendance/me/status'), headers: _headers);
    final json = await _decode(response);
    if (json == null) return null;
    return AttendanceRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<CommissionSummary> getCommissionSummary({required String from, required String to}) async {
    final response = await _httpClient.get(
      _uri('/commissions/me', {'from': from, 'to': to}),
      headers: _headers,
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return CommissionSummary.fromJson(json);
  }

  Future<List<Product>> getProducts() async {
    final response = await _httpClient.get(_uri('/products'), headers: _headers);
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => Product.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Product> createProduct({
    required String name,
    required String sku,
    String? category,
    String? unit,
    int? reorderLevel,
  }) async {
    final response = await _httpClient.post(
      _uri('/products'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'sku': sku,
        if (category != null && category.isNotEmpty) 'category': category,
        if (unit != null && unit.isNotEmpty) 'unit': unit,
        if (reorderLevel != null) 'reorderLevel': reorderLevel,
      }),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return Product.fromJson(json);
  }

  Future<List<Vendor>> getVendors() async {
    final response = await _httpClient.get(_uri('/vendors'), headers: _headers);
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => Vendor.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Vendor> createVendor({required String name, String? phone, String? email}) async {
    final response = await _httpClient.post(
      _uri('/vendors'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (email != null && email.isNotEmpty) 'email': email,
      }),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return Vendor.fromJson(json);
  }

  Future<List<StockLevel>> getStock(String branchId) async {
    final response = await _httpClient.get(
      _uri('/inventory/stock', {'branchId': branchId}),
      headers: _headers,
    );
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => StockLevel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<StockLevel>> getLowStock(String branchId) async {
    final response = await _httpClient.get(
      _uri('/inventory/low-stock', {'branchId': branchId}),
      headers: _headers,
    );
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => StockLevel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<List<StockBatch>> getExpiringBatches(String branchId, {int withinDays = 30}) async {
    final response = await _httpClient.get(
      _uri('/inventory/expiring', {'branchId': branchId, 'withinDays': '$withinDays'}),
      headers: _headers,
    );
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => StockBatch.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> receiveStock({
    required String branchId,
    required String productId,
    required int quantity,
    String? unitCost,
    String? batchNumber,
    DateTime? expiryDate,
    String? vendorId,
  }) async {
    final response = await _httpClient.post(
      _uri('/inventory/receive'),
      headers: _headers,
      body: jsonEncode({
        'branchId': branchId,
        'productId': productId,
        'quantity': quantity,
        if (unitCost != null) 'unitCost': unitCost,
        if (batchNumber != null && batchNumber.isNotEmpty) 'batchNumber': batchNumber,
        if (expiryDate != null) 'expiryDate': expiryDate.toUtc().toIso8601String(),
        if (vendorId != null) 'vendorId': vendorId,
      }),
    );
    await _decode(response);
  }

  Future<void> consumeStock({
    required String branchId,
    required String productId,
    required int quantity,
    String? note,
  }) async {
    final response = await _httpClient.post(
      _uri('/inventory/consume'),
      headers: _headers,
      body: jsonEncode({
        'branchId': branchId,
        'productId': productId,
        'quantity': quantity,
        if (note != null && note.isNotEmpty) 'note': note,
      }),
    );
    await _decode(response);
  }

  Future<void> transferStock({
    required String fromBranchId,
    required String toBranchId,
    required String productId,
    required int quantity,
  }) async {
    final response = await _httpClient.post(
      _uri('/inventory/transfer'),
      headers: _headers,
      body: jsonEncode({
        'fromBranchId': fromBranchId,
        'toBranchId': toBranchId,
        'productId': productId,
        'quantity': quantity,
      }),
    );
    await _decode(response);
  }

  Future<void> adjustStock({
    required String branchId,
    required String productId,
    required int quantityDelta,
    required String reason,
  }) async {
    final response = await _httpClient.post(
      _uri('/inventory/adjust'),
      headers: _headers,
      body: jsonEncode({
        'branchId': branchId,
        'productId': productId,
        'quantityDelta': quantityDelta,
        'reason': reason,
      }),
    );
    await _decode(response);
  }

  Future<PurchaseOrder> createPurchaseOrder({
    required String branchId,
    required String vendorId,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await _httpClient.post(
      _uri('/purchase-orders'),
      headers: _headers,
      body: jsonEncode({'branchId': branchId, 'vendorId': vendorId, 'items': items}),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return PurchaseOrder.fromJson(json);
  }

  Future<List<PurchaseOrder>> getPurchaseOrders({String? branchId}) async {
    final response = await _httpClient.get(
      _uri('/purchase-orders', branchId != null ? {'branchId': branchId} : null),
      headers: _headers,
    );
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => PurchaseOrder.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<PurchaseOrder> receivePurchaseOrder(String id) async {
    final response = await _httpClient.patch(
      _uri('/purchase-orders/$id/receive'),
      headers: _headers,
      body: jsonEncode({}),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return PurchaseOrder.fromJson(json);
  }

  /// Requests an OTP for the given phone number. There is no SMS gateway
  /// wired up on the backend yet, so outside production the response
  /// includes the raw code (`devCode`) so the login flow can be exercised
  /// without a real SMS provider - it will be null once a real gateway is
  /// configured and NODE_ENV=production on the backend.
  Future<String?> requestCustomerOtp(String phone) async {
    final response = await _httpClient.post(
      _uri('/customer-auth/otp/request'),
      headers: _headers,
      body: jsonEncode({'phone': phone}),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return json['devCode'] as String?;
  }

  Future<AuthResult> verifyCustomerOtp({
    required String phone,
    required String code,
    String? fullName,
    String? email,
  }) async {
    final response = await _httpClient.post(
      _uri('/customer-auth/otp/verify'),
      headers: _headers,
      body: jsonEncode({
        'phone': phone,
        'code': code,
        if (fullName != null && fullName.isNotEmpty) 'fullName': fullName,
        if (email != null && email.isNotEmpty) 'email': email,
      }),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return AuthResult.fromJson(json);
  }

  Future<Customer> getMyProfile() async {
    final response = await _httpClient.get(_uri('/me'), headers: _headers);
    final json = await _decode(response) as Map<String, dynamic>;
    return Customer.fromJson(json);
  }

  Future<List<Appointment>> getMyBookings() async {
    final response = await _httpClient.get(_uri('/me/appointments'), headers: _headers);
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => Appointment.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Appointment> bookMyAppointment({
    required String branchId,
    required String serviceId,
    required DateTime startTime,
    String? technicianId,
    String? resourceId,
    String? notes,
  }) async {
    final response = await _httpClient.post(
      _uri('/me/appointments'),
      headers: _headers,
      body: jsonEncode({
        'branchId': branchId,
        'serviceId': serviceId,
        'startTime': startTime.toUtc().toIso8601String(),
        if (technicianId != null) 'technicianId': technicianId,
        if (resourceId != null) 'resourceId': resourceId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      }),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return Appointment.fromJson(json);
  }

  Future<Appointment> rescheduleMyAppointment(String id, DateTime startTime) async {
    final response = await _httpClient.patch(
      _uri('/me/appointments/$id/reschedule'),
      headers: _headers,
      body: jsonEncode({'startTime': startTime.toUtc().toIso8601String()}),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return Appointment.fromJson(json);
  }

  Future<Appointment> cancelMyAppointment(String id) async {
    final response =
        await _httpClient.patch(_uri('/me/appointments/$id/cancel'), headers: _headers);
    final json = await _decode(response) as Map<String, dynamic>;
    return Appointment.fromJson(json);
  }

  Future<List<Invoice>> getMyInvoices() async {
    final response = await _httpClient.get(_uri('/me/invoices'), headers: _headers);
    final json = await _decode(response) as List<dynamic>;
    return json.map((item) => Invoice.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Review> submitReview({
    required String appointmentId,
    required int rating,
    String? comment,
  }) async {
    final response = await _httpClient.post(
      _uri('/reviews'),
      headers: _headers,
      body: jsonEncode({
        'appointmentId': appointmentId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      }),
    );
    final json = await _decode(response) as Map<String, dynamic>;
    return Review.fromJson(json);
  }

  void dispose() {
    _httpClient.close();
  }
}
