import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';

class ReceiveStockScreen extends StatefulWidget {
  final String branchId;

  const ReceiveStockScreen({super.key, required this.branchId});

  @override
  State<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends State<ReceiveStockScreen> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  final _quantityController = TextEditingController();
  final _unitCostController = TextEditingController();
  final _batchNumberController = TextEditingController();

  List<Product> _products = [];
  List<Vendor> _vendors = [];
  Product? _selectedProduct;
  Vendor? _selectedVendor;
  DateTime? _expiryDate;

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

    final quantity = int.tryParse(_quantityController.text.trim());
    if (_selectedProduct == null || quantity == null || quantity <= 0) {
      setState(() => _error = 'Select a product and enter a valid quantity');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _apiClient.receiveStock(
        branchId: widget.branchId,
        productId: _selectedProduct!.id,
        quantity: quantity,
        unitCost: _unitCostController.text.trim().isEmpty ? null : _unitCostController.text.trim(),
        batchNumber: _batchNumberController.text.trim(),
        expiryDate: _expiryDate,
        vendorId: _selectedVendor?.id,
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
    _quantityController.dispose();
    _unitCostController.dispose();
    _batchNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive stock')),
      body: _isLoadingOptions
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<Product>(
                  value: _selectedProduct,
                  decoration: const InputDecoration(labelText: 'Product'),
                  items: _products
                      .map((product) =>
                          DropdownMenuItem(value: product, child: Text('${product.name} (${product.sku})')))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedProduct = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Vendor?>(
                  value: _selectedVendor,
                  decoration: const InputDecoration(labelText: 'Vendor (optional)'),
                  items: [
                    const DropdownMenuItem<Vendor?>(value: null, child: Text('Not specified')),
                    ..._vendors.map((vendor) => DropdownMenuItem(value: vendor, child: Text(vendor.name))),
                  ],
                  onChanged: (value) => setState(() => _selectedVendor = value),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity received'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _unitCostController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Unit cost (optional)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _batchNumberController,
                  decoration: const InputDecoration(labelText: 'Batch number (optional)'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                    );
                    if (picked != null) setState(() => _expiryDate = picked);
                  },
                  child: Text(_expiryDate == null
                      ? 'Set expiry date (optional)'
                      : 'Expires: ${_expiryDate!.year}-${_expiryDate!.month.toString().padLeft(2, '0')}-${_expiryDate!.day.toString().padLeft(2, '0')}'),
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
                      : const Text('Receive stock'),
                ),
              ],
            ),
    );
  }
}
