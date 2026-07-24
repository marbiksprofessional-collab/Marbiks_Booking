import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';
import '../utils/date_utils.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  late Future<List<Appointment>> _historyFuture;
  late Appointment _appointment;
  bool _isCompleting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    _historyFuture = _apiClient.getCustomerHistory(_appointment.customerId);
  }

  Future<void> _markComplete() async {
    setState(() {
      _isCompleting = true;
      _error = null;
    });
    try {
      final updated = await _apiClient.completeAppointment(_appointment.id);
      setState(() => _appointment = updated);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = _appointment;

    return Scaffold(
      appBar: AppBar(title: const Text('Appointment')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Status: ${appointment.status}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '${formatDateReadable(appointment.startTime)} · '
            '${formatTime(appointment.startTime)} - ${formatTime(appointment.endTime)}',
          ),
          if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Notes: ${appointment.notes}'),
          ],
          const SizedBox(height: 16),
          if (appointment.status != 'COMPLETED' && appointment.status != 'CANCELLED')
            FilledButton(
              onPressed: _isCompleting ? null : _markComplete,
              child: _isCompleting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Mark service complete'),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 24),
          Text('Customer treatment history', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          FutureBuilder<List<Appointment>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return Text('Failed to load history: ${snapshot.error}');
              }
              final history = snapshot.data ?? [];
              if (history.isEmpty) {
                return const Text('No previous visits on record.');
              }
              return Column(
                children: history
                    .map(
                      (visit) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.history),
                        title: Text(formatDateReadable(visit.startTime)),
                        subtitle: Text(visit.status),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
