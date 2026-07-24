import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../session/auth_session.dart';
import 'queue_screen.dart';
import 'commission_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    if (session.user?.branchId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Marbiks Service Provider')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Your account is not assigned to a branch yet. '
              'Ask an administrator to assign one before using the app.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [QueueScreen(), CommissionScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.checklist), label: 'Queue'),
          NavigationDestination(icon: Icon(Icons.payments_outlined), label: 'Commission'),
        ],
      ),
    );
  }
}
