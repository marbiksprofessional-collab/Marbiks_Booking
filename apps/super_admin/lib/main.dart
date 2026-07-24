import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import 'config.dart';
import 'session/auth_session.dart';
import 'screens/login_screen.dart';
import 'super_admin_dashboard.dart';
import 'theme/app_theme.dart';

void main() {
  final apiClient = ApiClient(baseUrl: apiBaseUrl);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthSession(apiClient),
      child: const MarbiksSuperAdminApp(),
    ),
  );
}

class MarbiksSuperAdminApp extends StatelessWidget {
  const MarbiksSuperAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marbiks Control Room',
      debugShowCheckedModeBanner: false,
      theme: buildSuperAdminTheme(),
      darkTheme: buildSuperAdminTheme(),
      themeMode: ThemeMode.dark,
      home: Consumer<AuthSession>(
        builder: (context, session, _) {
          return session.isLoggedIn ? const SuperAdminDashboard() : const LoginScreen();
        },
      ),
    );
  }
}
