import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';

class StockActionsScreen extends StatefulWidget {
  final String branchId;
  final StockLevel stock;

  const StockActionsScreen({super.key, required this.branchId, required this.stock});

  @override
  State<StockActionsScreen> createState() => _StockActionsScreenState();
}

class _StockActionsScreenState extends State<StockActionsScreen> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  final _consumeQuantityController = TextEditingController();
  final _consumeNoteController = TextEditingController();
  final _transferQuantityController = TextEditingController();
  final _adjustQuantityController = TextEditingController();
  final _adjustReasonController = TextEditingController();

  List<Branch> _branches = [];
  Branch? _destinationBranch;
  bool _isLoadingBranches = true;
  bool _isBusy = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final branches = await _apiClient.getBranches();
      setState(() {
        _branches = branches.where((b) => b.id != widget.branchId).toList();
        _isLoadingBranches = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoadingBranches = false;
      });
    }
  }

  Future<void> _consume() async {
    final quantity = int.tryParse(_consumeQuantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      setState(() => _error = 'Enter a valid quantity to consume');
      return;
    }
    setState(() {
      _isBusy = true;
      _error = null;
      _success = null;
    });
    try {
      await _apiClient.consumeStock(
        branchId: widget.branchId,
        productId: widget.stock.productId,
        quantity: quantity,
        note: _consumeNoteController.text.trim(),
      );
      setState(() => _success = 'Recorded consumption of $quantity ${widget.stock.unit}');
      _consumeQuantityController.clear();
      _consumeNoteController.clear();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _transfer() async {
    final quantity = int.tryParse(_transferQuantityController.text.trim());
    if (quantity == null || quantity <= 0 || _destinationBranch == null) {
      setState(() => _error = 'Select a destination branch and a valid quantity');
      return;
    }
    setState(() {
      _isBusy = true;
      _error = null;
      _success = null;
    });
    try {
      await _apiClient.transferStock(
        fromBranchId: widget.branchId,
        toBranchId: _destinationBranch!.id,
        productId: widget.stock.productId,
        quantity: quantity,
      );
      setState(() => _success = 'Transferred $quantity ${widget.stock.unit} to ${_destinationBranch!.name}');
      _transferQuantityController.clear();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _adjust() async {
    final delta = int.tryParse(_adjustQuantityController.text.trim());
    if (delta == null || delta == 0 || _adjustReasonController.text.trim().isEmpty) {
      setState(() => _error = 'Enter a non-zero adjustment and a reason');
      return;
    }
    setState(() {
      _isBusy = true;
      _error = null;
      _success = null;
    });
    try {
      await _apiClient.adjustStock(
        branchId: widget.branchId,
        productId: widget.stock.productId,
        quantityDelta: delta,
        reason: _adjustReasonController.text.trim(),
      );
      setState(() => _success = 'Stock audit adjustment of $delta ${widget.stock.unit} recorded');
      _adjustQuantityController.clear();
      _adjustReasonController.clear();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    _consumeQuantityController.dispose();
    _consumeNoteController.dispose();
    _transferQuantityController.dispose();
    _adjustQuantityController.dispose();
    _adjustReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.stock.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'On hand: ${widget.stock.quantityOnHand} ${widget.stock.unit} · '
            'reorder at ${widget.stock.reorderLevel}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_success != null) ...[
            const SizedBox(height: 12),
            Text(_success!, style: const TextStyle(color: Colors.green)),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const Divider(height: 32),
          Text('Consume (usage / breakage)', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _consumeQuantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _consumeNoteController,
            decoration: const InputDecoration(labelText: 'Note (optional)'),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _isBusy ? null : _consume, child: const Text('Record consumption')),
          const Divider(height: 32),
          Text('Transfer to another branch', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          _isLoadingBranches
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<Branch>(
                  value: _destinationBranch,
                  decoration: const InputDecoration(labelText: 'Destination branch'),
                  items: _branches
                      .map((branch) => DropdownMenuItem(value: branch, child: Text(branch.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _destinationBranch = value),
                ),
          const SizedBox(height: 8),
          TextField(
            controller: _transferQuantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Quantity'),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _isBusy ? null : _transfer, child: const Text('Transfer stock')),
          const Divider(height: 32),
          Text('Stock audit adjustment', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _adjustQuantityController,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            decoration: const InputDecoration(labelText: 'Adjustment (+ found / - missing)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _adjustReasonController,
            decoration: const InputDecoration(labelText: 'Reason'),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: _isBusy ? null : _adjust, child: const Text('Record adjustment')),
        ],
      ),
    );
  }
}
