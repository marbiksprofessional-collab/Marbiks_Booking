import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../session/auth_session.dart';
import 'appointments_screen.dart';

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();
    final branchId = session.user?.branchId;

    if (branchId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Marbiks Front Office')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Your account is not assigned to a branch yet. '
              'Ask an administrator to assign one before using the booking desk.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return AppointmentsScreen(branchId: branchId);
  }
}
