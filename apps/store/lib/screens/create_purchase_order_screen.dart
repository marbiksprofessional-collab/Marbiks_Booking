import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';

class _DraftItem {
  Product? product;
  final quantityController = TextEditingController();
  final unitCostController = TextEditingController();
}

class CreatePurchaseOrderScreen extends StatefulWidget {
  final String branchId;

  const CreatePurchaseOrderScreen({super.key, required this.branchId});

  @override
  State<CreatePurchaseOrderScreen> createState() => _CreatePurchaseOrderScreenState();
}

class _CreatePurchaseOrderScreenState extends State<CreatePurchaseOrderScreen> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  List<Product> _products = [];
  List<Vendor> _vendors = [];
  Vendor? _selectedVendor;
  final List<_DraftItem> _items = [_DraftItem()];

  bool _isLoadingOptions = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([_apiClient.getProducts(), _apiClient.getVendors()]);
      setState(() {
        _products = results[0] as List<Product>;
        _vendors = results[1] as List<Vendor>;
        _isLoadingOptions = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoadingOptions = false;
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    if (_selectedVendor == null) {
      setState(() => _error = 'Select a vendor');
      return;
    }

    final items = <Map<String, dynamic>>[];
    for (final draft in _items) {
      final quantity = int.tryParse(draft.quantityController.text.trim());
      if (draft.product == null || quantity == null || quantity <= 0 || draft.unitCostController.text.trim().isEmpty) {
        setState(() => _error = 'Complete every item row (product, quantity, unit cost)');
        return;
      }
      items.add({
        'productId': draft.product!.id,
        'quantity': quantity,
        'unitCost': draft.unitCostController.text.trim(),
      });
    }

    setState(() => _isSubmitting = true);
    try {
      await _apiClient.createPurchaseOrder(
        branchId: widget.branchId,
        vendorId: _selectedVendor!.id,
        items: items,
      );
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.quantityController.dispose();
      item.unitCostController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New purchase order')),
      body: _isLoadingOptions
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<Vendor>(
                  value: _selectedVendor,
                  decoration: const InputDecoration(labelText: 'Vendor'),
                  items: _vendors
                      .map((vendor) => DropdownMenuItem(value: vendor, child: Text(vendor.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedVendor = value),
                ),
                const SizedBox(height: 16),
                Text('Items', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                ..._items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final draft = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<Product>(
                            value: draft.product,
                            decoration: const InputDecoration(labelText: 'Product'),
                            items: _products
                                .map((product) =>
                                    DropdownMenuItem(value: product, child: Text(product.name)))
                                .toList(),
                            onChanged: (value) => setState(() => draft.product = value),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: draft.quantityController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(labelText: 'Quantity'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: draft.unitCostController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(labelText: 'Unit cost'),
                                ),
                              ),
                              if (_items.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => setState(() => _items.removeAt(index)),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add another item'),
                  onPressed: () => setState(() => _items.add(_DraftItem())),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Place purchase order'),
                ),
              ],
            ),
    );
  }
}
