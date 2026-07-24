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
import 'models/resource.dart';
import 'models/service_item.dart';

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

  void dispose() {
    _httpClient.close();
  }
}
