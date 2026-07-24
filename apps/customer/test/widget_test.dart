import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import 'package:marbiks_customer/session/auth_session.dart';
import 'package:marbiks_customer/screens/login_screen.dart';

void main() {
  testWidgets('shows the phone/OTP login screen when logged out', (WidgetTester tester) async {
    final apiClient = ApiClient(baseUrl: 'http://localhost:3000/api/v1');

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthSession(apiClient),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    expect(find.text('Send OTP'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
