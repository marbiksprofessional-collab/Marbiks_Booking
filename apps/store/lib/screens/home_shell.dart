import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../session/auth_session.dart';
import 'stock_screen.dart';
import 'purchase_orders_screen.dart';

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
    final branchId = session.user?.branchId;

    if (branchId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Marbiks Store')),
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
        children: [
          StockScreen(branchId: branchId),
          PurchaseOrdersScreen(branchId: branchId),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory_2_outlined), label: 'Stock'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), label: 'Orders'),
        ],
      ),
    );
  }
}
