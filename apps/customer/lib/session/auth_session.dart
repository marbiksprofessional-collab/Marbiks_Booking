import 'package:flutter/foundation.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

class AuthSession extends ChangeNotifier {
  final ApiClient apiClient;
  AuthenticatedUser? _user;
  Customer? _profile;
  String? _error;
  bool _isBusy = false;

  AuthSession(this.apiClient);

  AuthenticatedUser? get user => _user;
  Customer? get profile => _profile;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  bool get isBusy => _isBusy;

  Future<String?> requestOtp(String phone) async {
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      return await apiClient.requestCustomerOtp(phone);
    } on ApiException catch (e) {
      _error = e.message;
      return null;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> verifyOtp({
    required String phone,
    required String code,
    String? fullName,
    String? email,
  }) async {
    _isBusy = true;
    _error = null;
    notifyListeners();
    try {
      final result = await apiClient.verifyCustomerOtp(
        phone: phone,
        code: code,
        fullName: fullName,
        email: email,
      );
      apiClient.setToken(result.accessToken);
      _user = result.user;
      await refreshProfile();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    try {
      _profile = await apiClient.getMyProfile();
      notifyListeners();
    } on ApiException {
      // Profile refresh failures are non-fatal - the cached copy (if any) stays.
    }
  }

  void logout() {
    apiClient.setToken(null);
    _user = null;
    _profile = null;
    notifyListeners();
  }
}
