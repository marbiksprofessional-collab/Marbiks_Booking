import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import 'package:marbiks_front_office_billing/session/auth_session.dart';
import 'package:marbiks_front_office_billing/screens/login_screen.dart';

void main() {
  testWidgets('shows the login screen when logged out', (WidgetTester tester) async {
    final apiClient = ApiClient(baseUrl: 'http://localhost:3000/api/v1');

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthSession(apiClient),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Log in'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
