class AuthenticatedUser {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? branchId;

  AuthenticatedUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.branchId,
  });

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) => AuthenticatedUser(
        id: json['id'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        branchId: json['branchId'] as String?,
      );
}

class AuthResult {
  final String accessToken;
  final AuthenticatedUser user;

  AuthResult({required this.accessToken, required this.user});

  factory AuthResult.fromJson(Map<String, dynamic> json) => AuthResult(
        accessToken: json['accessToken'] as String,
        user: AuthenticatedUser.fromJson(json['user'] as Map<String, dynamic>),
      );
}
