import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';
import '../utils/date_utils.dart';

class PurchaseOrderDetailScreen extends StatefulWidget {
  final PurchaseOrder purchaseOrder;
  final Map<String, Product> productsById;

  const PurchaseOrderDetailScreen({
    super.key,
    required this.purchaseOrder,
    required this.productsById,
  });

  @override
  State<PurchaseOrderDetailScreen> createState() => _PurchaseOrderDetailScreenState();
}

class _PurchaseOrderDetailScreenState extends State<PurchaseOrderDetailScreen> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  late PurchaseOrder _purchaseOrder;
  bool _isBusy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _purchaseOrder = widget.purchaseOrder;
  }

  Future<void> _receive() async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final updated = await _apiClient.receivePurchaseOrder(_purchaseOrder.id);
      setState(() => _purchaseOrder = updated);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final po = _purchaseOrder;
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase order')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Status: ${po.status}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Placed ${formatDateReadable(po.createdAt)}'),
          if (po.receivedAt != null) Text('Received ${formatDateReadable(po.receivedAt!)}'),
          const SizedBox(height: 16),
          ...po.items.map((item) {
            final product = widget.productsById[item.productId];
            return Card(
              child: ListTile(
                title: Text(product?.name ?? item.productId),
                subtitle: Text('Ordered ${item.quantityOrdered} · Received ${item.quantityReceived} · ₹${item.unitCost} each'),
              ),
            );
          }),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          if (po.status == 'ORDERED')
            FilledButton(
              onPressed: _isBusy ? null : _receive,
              child: _isBusy
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Mark as received (adds stock)'),
            ),
        ],
      ),
    );
  }
}
