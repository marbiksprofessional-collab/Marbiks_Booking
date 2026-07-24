import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import 'package:marbiks_super_admin/session/auth_session.dart';
import 'package:marbiks_super_admin/screens/login_screen.dart';
import 'package:marbiks_super_admin/theme/app_theme.dart';

void main() {
  testWidgets('shows the control-room login screen when logged out', (WidgetTester tester) async {
    final apiClient = ApiClient(baseUrl: 'http://localhost:3000/api/v1');

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthSession(apiClient),
        child: MaterialApp(theme: buildSuperAdminTheme(), home: const LoginScreen()),
      ),
    );

    expect(find.text('Enter control room'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
