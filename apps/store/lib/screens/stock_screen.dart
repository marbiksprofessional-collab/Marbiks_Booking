import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';
import '../utils/date_utils.dart';
import 'receive_stock_screen.dart';
import 'stock_actions_screen.dart';

class StockScreen extends StatefulWidget {
  final String branchId;

  const StockScreen({super.key, required this.branchId});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  late Future<List<StockLevel>> _stockFuture;
  late Future<List<StockBatch>> _expiringFuture;

  @override
  void initState() {
    super.initState();
    _stockFuture = _apiClient.getStock(widget.branchId);
    _expiringFuture = _apiClient.getExpiringBatches(widget.branchId, withinDays: 30);
  }

  void _refresh() {
    setState(() {
      _stockFuture = _apiClient.getStock(widget.branchId);
      _expiringFuture = _apiClient.getExpiringBatches(widget.branchId, withinDays: 30);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthSession>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          children: [
            FutureBuilder<List<StockBatch>>(
              future: _expiringFuture,
              builder: (context, snapshot) {
                final batches = snapshot.data ?? [];
                if (batches.isEmpty) return const SizedBox.shrink();
                return Container(
                  width: double.infinity,
                  color: Colors.orange.withOpacity(0.12),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Expiring within 30 days',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ...batches.map(
                        (batch) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${batch.productName ?? batch.productId} · '
                            '${batch.quantityRemaining} left · '
                            'expires ${batch.expiryDate != null ? formatDateReadable(batch.expiryDate!) : '-'}',
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            FutureBuilder<List<StockLevel>>(
              future: _stockFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Failed to load stock: ${snapshot.error}'),
                  );
                }
                final stock = snapshot.data ?? [];
                if (stock.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No products yet.')),
                  );
                }
                return Column(
                  children: stock
                      .map(
                        (item) => ListTile(
                          leading: Icon(
                            Icons.inventory_2_outlined,
                            color: item.isLowStock ? Colors.red : null,
                          ),
                          title: Text(item.name),
                          subtitle: Text('${item.sku} · reorder at ${item.reorderLevel} ${item.unit}'),
                          trailing: Text(
                            '${item.quantityOnHand} ${item.unit}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: item.isLowStock ? Colors.red : null,
                            ),
                          ),
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    StockActionsScreen(branchId: widget.branchId, stock: item),
                              ),
                            );
                            _refresh();
                          },
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_box_outlined),
        label: const Text('Receive stock'),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ReceiveStockScreen(branchId: widget.branchId)),
          );
          _refresh();
        },
      ),
    );
  }
}
