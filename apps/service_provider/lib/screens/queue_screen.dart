import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';
import '../utils/date_utils.dart';
import 'appointment_detail_screen.dart';

class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  late Future<List<Appointment>> _queueFuture;
  Future<AttendanceRecord?>? _statusFuture;
  bool _isTogglingAttendance = false;

  @override
  void initState() {
    super.initState();
    _queueFuture = _loadQueue();
    _statusFuture = _apiClient.getAttendanceStatus();
  }

  Future<List<Appointment>> _loadQueue() {
    return _apiClient.getMyAppointments(date: formatDateForApi(DateTime.now()));
  }

  void _refresh() {
    setState(() {
      _queueFuture = _loadQueue();
      _statusFuture = _apiClient.getAttendanceStatus();
    });
  }

  Future<void> _toggleAttendance(AttendanceRecord? current) async {
    final branchId = context.read<AuthSession>().user?.branchId;
    if (branchId == null) return;

    setState(() => _isTogglingAttendance = true);
    try {
      if (current != null && current.isClockedIn) {
        await _apiClient.clockOut();
      } else {
        await _apiClient.clockIn(branchId);
      }
      _refresh();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _isTogglingAttendance = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Today's queue"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthSession>().logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          FutureBuilder<AttendanceRecord?>(
            future: _statusFuture,
            builder: (context, snapshot) {
              final record = snapshot.data;
              final isClockedIn = record?.isClockedIn ?? false;
              return Container(
                width: double.infinity,
                color: isClockedIn ? Colors.green.withOpacity(0.12) : Colors.grey.withOpacity(0.15),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(isClockedIn ? Icons.check_circle : Icons.access_time,
                        color: isClockedIn ? Colors.green : null),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isClockedIn
                            ? 'Clocked in since ${formatTime(record!.clockInAt)}'
                            : 'Not clocked in',
                      ),
                    ),
                    FilledButton(
                      onPressed: _isTogglingAttendance ? null : () => _toggleAttendance(record),
                      child: Text(isClockedIn ? 'Clock out' : 'Clock in'),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<Appointment>>(
              future: _queueFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Failed to load queue: ${snapshot.error}'));
                }
                final appointments = snapshot.data ?? [];
                if (appointments.isEmpty) {
                  return const Center(child: Text('No appointments assigned to you today.'));
                }
                return ListView.separated(
                  itemCount: appointments.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final appointment = appointments[index];
                    return ListTile(
                      leading: const Icon(Icons.spa_outlined),
                      title: Text(
                          '${formatTime(appointment.startTime)} - ${formatTime(appointment.endTime)}'),
                      subtitle: Text(appointment.status),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AppointmentDetailScreen(appointment: appointment),
                          ),
                        );
                        _refresh();
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
