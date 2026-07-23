import 'dart:convert';
import 'package:http/http.dart' as http;

class MarbiksHttpClient {
  static const String _baseUrl = 'http://localhost:3000/api/v1';

    // 📱 1. Request OTP Token Payload Connection
      Future<Map<String, dynamic>> requestOtpToken(String phone) async {
          final url = Uri.parse('$_baseUrl/auth/otp/request');
              try {
                    final response = await http.post(
                            url,
                                    headers: {'Content-Type': 'application/json'},
                                            body: jsonEncode({'phoneNumber': phone}),
                                                  );
                                                        return jsonDecode(response.body);
                                                            } catch (e) {
                                                                  return {'status': 'error', 'message': 'Network communication failure: ${e.toString()}'};
                                                                      }
                                                                        }

                                                                          // 🔑 2. Verify OTP Session Token Gateway Connection
                                                                            Future<Map<String, dynamic>> verifyOtpToken(String phone, String code) async {
                                                                                final url = Uri.parse('$_baseUrl/auth/otp/verify');
                                                                                    try {
                                                                                          final response = await http.post(
                                                                                                  url,
                                                                                                          headers: {'Content-Type': 'application/json'},
                                                                                                                  body: jsonEncode({'phoneNumber': phone, 'otpCode': code}),
                                                                                                                        );
                                                                                                                              return jsonDecode(response.body);
                                                                                                                                  } catch (e) {
                                                                                                                                        return {'status': 'error', 'message': 'Verification service timed out: ${e.toString()}'};
                                                                                                                                            }
                                                                                                                                              }

                                                                                                                                                // 📅 3. Real-time Multi-tenant Appointment Scheduling Pipeline
                                                                                                                                                  Future<Map<String, dynamic>> executeSmartBooking(Map<String, dynamic> bookingPayload) async {
                                                                                                                                                      final url = Uri.parse('$_baseUrl/appointments/book');
                                                                                                                                                          try {
                                                                                                                                                                final response = await http.post(
                                                                                                                                                                        url,
                                                                                                                                                                                headers: {'Content-Type': 'application/json'},
                                                                                                                                                                                        body: jsonEncode(bookingPayload),
                                                                                                                                                                                              );
                                                                                                                                                                                                    return jsonDecode(response.body);
                                                                                                                                                                                                        } catch (e) {
                                                                                                                                                                                                              return {'status': 'error', 'message': 'AI Router pipeline execution crash: ${e.toString()}'};
                                                                                                                                                                                                                  }
                                                                                                                                                                                                                    }
                                                                                                                                                                                                                    }
                                                                                                                                                                                                                    