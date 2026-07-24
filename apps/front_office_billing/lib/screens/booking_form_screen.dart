import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';

class BookingFormScreen extends StatefulWidget {
  final String branchId;
  final DateTime initialDate;

  const BookingFormScreen({super.key, required this.branchId, required this.initialDate});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _phoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  List<ServiceItem> _services = [];
  List<ResourceModel> _resources = [];
  ServiceItem? _selectedService;
  ResourceModel? _selectedResource;
  Customer? _customer;

  late DateTime _date;
  TimeOfDay _time = const TimeOfDay(hour: 10, minute: 0);

  bool _isLoadingOptions = true;
  bool _isSearchingCustomer = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _date = widget.initialDate;
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([
        _apiClient.getServices(),
        _apiClient.getResources(widget.branchId),
      ]);
      setState(() {
        _services = results[0] as List<ServiceItem>;
        _resources = results[1] as List<ResourceModel>;
        _isLoadingOptions = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoadingOptions = false;
      });
    }
  }

  Future<void> _findOrPrepareCustomer() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;

    setState(() {
      _isSearchingCustomer = true;
      _customer = null;
    });

    try {
      final matches = await _apiClient.searchCustomers(phone);
      setState(() {
        _customer = matches.isNotEmpty ? matches.first : null;
      });
      if (matches.isEmpty && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No existing customer found - fill in the details below to create one.')),
        );
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isSearchingCustomer = false);
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    if (_selectedService == null) {
      setState(() => _error = 'Please select a service');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      var customer = _customer;
      customer ??= await _apiClient.createCustomer(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      );

      final startTime = DateTime(
        _date.year,
        _date.month,
        _date.day,
        _time.hour,
        _time.minute,
      );

      await _apiClient.createAppointment(
        branchId: widget.branchId,
        customerId: customer.id,
        serviceId: _selectedService!.id,
        startTime: startTime,
        resourceId: _selectedResource?.id,
        notes: _notesController.text.trim(),
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
    _phoneController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New booking')),
      body: _isLoadingOptions
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Customer', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone number'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _isSearchingCustomer ? null : _findOrPrepareCustomer,
                      child: const Text('Find'),
                    ),
                  ],
                ),
                if (_customer != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Found: ${_customer!.fullName} (${_customer!.loyaltyPoints} loyalty pts)'),
                  )
                else ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _fullNameController,
                    decoration: const InputDecoration(labelText: 'Full name (for new customer)'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email (optional)'),
                  ),
                ],
                const SizedBox(height: 24),
                Text('Service', style: Theme.of(context).textTheme.titleMedium),
                DropdownButtonFormField<ServiceItem>(
                  initialValue: _selectedService,
                  items: _services
                      .map((service) => DropdownMenuItem(
                            value: service,
                            child: Text('${service.name} (${service.durationMinutes} min, ₹${service.price})'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedService = value),
                ),
                const SizedBox(height: 16),
                Text('Chair / room (optional)', style: Theme.of(context).textTheme.titleMedium),
                DropdownButtonFormField<ResourceModel?>(
                  initialValue: _selectedResource,
                  items: [
                    const DropdownMenuItem<ResourceModel?>(value: null, child: Text('Not specified')),
                    ..._resources.map(
                      (resource) => DropdownMenuItem(value: resource, child: Text(resource.name)),
                    ),
                  ],
                  onChanged: (value) => setState(() => _selectedResource = value),
                ),
                const SizedBox(height: 24),
                Text('Date & time', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime.now().subtract(const Duration(days: 1)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) setState(() => _date = picked);
                        },
                        child: Text('${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showTimePicker(context: context, initialTime: _time);
                          if (picked != null) setState(() => _time = picked);
                        },
                        child: Text(_time.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 2,
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
                      : const Text('Confirm booking'),
                ),
              ],
            ),
    );
  }
}
