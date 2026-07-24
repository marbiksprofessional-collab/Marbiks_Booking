import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  List<Branch> _branches = [];
  List<ServiceItem> _services = [];
  Branch? _selectedBranch;
  ServiceItem? _selectedService;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 11, minute: 0);
  final _notesController = TextEditingController();

  bool _isLoadingOptions = true;
  bool _isSubmitting = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    try {
      final results = await Future.wait([_apiClient.getBranches(), _apiClient.getServices()]);
      setState(() {
        _branches = results[0] as List<Branch>;
        _services = results[1] as List<ServiceItem>;
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
    setState(() {
      _error = null;
      _success = null;
    });

    if (_selectedBranch == null || _selectedService == null) {
      setState(() => _error = 'Select a branch and a service');
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final startTime = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
      await _apiClient.bookMyAppointment(
        branchId: _selectedBranch!.id,
        serviceId: _selectedService!.id,
        startTime: startTime,
        notes: _notesController.text.trim(),
      );
      setState(() => _success = 'Booked! See it under "My bookings".');
      _notesController.clear();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book an appointment')),
      body: _isLoadingOptions
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<Branch>(
                  value: _selectedBranch,
                  decoration: const InputDecoration(labelText: 'Branch'),
                  items: _branches
                      .map((branch) => DropdownMenuItem(value: branch, child: Text(branch.name)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedBranch = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ServiceItem>(
                  value: _selectedService,
                  decoration: const InputDecoration(labelText: 'Service'),
                  items: _services
                      .map((service) => DropdownMenuItem(
                            value: service,
                            child: Text('${service.name} (${service.durationMinutes} min, ₹${service.price})'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedService = value),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 180)),
                          );
                          if (picked != null) setState(() => _date = picked);
                        },
                        child: Text(
                            '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
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
                  decoration: const InputDecoration(labelText: 'Anything we should know? (optional)'),
                  maxLines: 2,
                ),
                if (_success != null) ...[
                  const SizedBox(height: 16),
                  Text(_success!, style: const TextStyle(color: Colors.green)),
                ],
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
