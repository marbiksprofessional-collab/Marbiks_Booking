import 'package:flutter/foundation.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

const _allowedRoles = {'SUPER_ADMIN', 'DIRECTOR', 'GENERAL_MANAGER'};

class AuthSession extends ChangeNotifier {
  final ApiClient apiClient;
  AuthenticatedUser? _user;
  String? _error;
  bool _isLoggingIn = false;

  AuthSession(this.apiClient);

  AuthenticatedUser? get user => _user;
  bool get isLoggedIn => _user != null;
  String? get error => _error;
  bool get isLoggingIn => _isLoggingIn;

  Future<bool> login(String email, String password) async {
    _isLoggingIn = true;
    _error = null;
    notifyListeners();

    try {
      final result = await apiClient.login(email, password);

      if (!_allowedRoles.contains(result.user.role)) {
        apiClient.setToken(null);
        _error = 'This control room is restricted to Directors, General Managers, '
            'and Super Admins.';
        return false;
      }

      apiClient.setToken(result.accessToken);
      _user = result.user;
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      return false;
    } finally {
      _isLoggingIn = false;
      notifyListeners();
    }
  }

  void logout() {
    apiClient.setToken(null);
    _user = null;
    notifyListeners();
  }
}
