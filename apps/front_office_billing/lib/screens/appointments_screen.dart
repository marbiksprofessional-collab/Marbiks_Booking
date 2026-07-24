import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';
import '../utils/date_utils.dart';
import 'booking_form_screen.dart';
import 'checkout_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  final String branchId;

  const AppointmentsScreen({super.key, required this.branchId});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _selectedDate = DateTime.now();
  late Future<List<Appointment>> _appointmentsFuture;

  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _load();
  }

  Future<List<Appointment>> _load() {
    return _apiClient.getAppointments(
      branchId: widget.branchId,
      date: formatDateForApi(_selectedDate),
    );
  }

  void _refresh() {
    setState(() => _appointmentsFuture = _load());
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(formatDateReadable(_selectedDate)),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthSession>().logout(),
          ),
        ],
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load appointments: ${snapshot.error}'));
          }
          final appointments = snapshot.data ?? [];
          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments for this day.'));
          }
          return ListView.separated(
            itemCount: appointments.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return ListTile(
                leading: CircleAvatar(child: Text(formatTime(appointment.startTime).substring(0, 2))),
                title: Text('${formatTime(appointment.startTime)} - ${formatTime(appointment.endTime)}'),
                subtitle: Text(appointment.status),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CheckoutScreen(
                        appointment: appointment,
                        branchId: widget.branchId,
                      ),
                    ),
                  );
                  _refresh();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('New booking'),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BookingFormScreen(
                branchId: widget.branchId,
                initialDate: _selectedDate,
              ),
            ),
          );
          _refresh();
        },
      ),
    );
  }
}
