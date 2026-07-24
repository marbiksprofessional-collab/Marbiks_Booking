import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import 'config.dart';
import 'session/auth_session.dart';
import 'screens/login_screen.dart';
import 'screens/home_shell.dart';

void main() {
  final apiClient = ApiClient(baseUrl: apiBaseUrl);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthSession(apiClient),
      child: const MarbiksServiceProviderApp(),
    ),
  );
}

class MarbiksServiceProviderApp extends StatelessWidget {
  const MarbiksServiceProviderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marbiks Service Provider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00695C),
        useMaterial3: true,
      ),
      home: Consumer<AuthSession>(
        builder: (context, session, _) {
          return session.isLoggedIn ? const HomeShell() : const LoginScreen();
        },
      ),
    );
  }
}
