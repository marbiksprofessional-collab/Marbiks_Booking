import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';
import '../utils/date_utils.dart';
import 'create_purchase_order_screen.dart';
import 'purchase_order_detail_screen.dart';

class PurchaseOrdersScreen extends StatefulWidget {
  final String branchId;

  const PurchaseOrdersScreen({super.key, required this.branchId});

  @override
  State<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends State<PurchaseOrdersScreen> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  late Future<List<PurchaseOrder>> _ordersFuture;
  Future<List<Product>>? _productsFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _apiClient.getPurchaseOrders(branchId: widget.branchId);
    _productsFuture = _apiClient.getProducts();
  }

  void _refresh() {
    setState(() {
      _ordersFuture = _apiClient.getPurchaseOrders(branchId: widget.branchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase orders'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh)],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, productSnapshot) {
          final productsById = {
            for (final product in productSnapshot.data ?? <Product>[]) product.id: product,
          };
          return FutureBuilder<List<PurchaseOrder>>(
            future: _ordersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Failed to load purchase orders: ${snapshot.error}'));
              }
              final orders = snapshot.data ?? [];
              if (orders.isEmpty) {
                return const Center(child: Text('No purchase orders yet.'));
              }
              return ListView.separated(
                itemCount: orders.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return ListTile(
                    leading: Icon(
                      order.status == 'RECEIVED'
                          ? Icons.check_circle_outline
                          : order.status == 'CANCELLED'
                              ? Icons.cancel_outlined
                              : Icons.local_shipping_outlined,
                    ),
                    title: Text('${order.items.length} item(s) · ${formatDateReadable(order.createdAt)}'),
                    subtitle: Text(order.status),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PurchaseOrderDetailScreen(
                            purchaseOrder: order,
                            productsById: productsById,
                          ),
                        ),
                      );
                      _refresh();
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New order'),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => CreatePurchaseOrderScreen(branchId: widget.branchId)),
          );
          _refresh();
        },
      ),
    );
  }
}
