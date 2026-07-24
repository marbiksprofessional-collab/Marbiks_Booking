import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';
import '../utils/date_utils.dart';
import 'booking_detail_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  late Future<List<Appointment>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _bookingsFuture = _apiClient.getMyBookings();
  }

  void _refresh() {
    setState(() => _bookingsFuture = _apiClient.getMyBookings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My bookings'),
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh)],
      ),
      body: FutureBuilder<List<Appointment>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load bookings: ${snapshot.error}'));
          }
          final bookings = snapshot.data ?? [];
          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings yet - tap "Book" to get started.'));
          }
          // Most recent first.
          final sorted = [...bookings]..sort((a, b) => b.startTime.compareTo(a.startTime));
          return ListView.separated(
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final booking = sorted[index];
              return ListTile(
                leading: Icon(_iconFor(booking.status)),
                title: Text('${formatDateReadable(booking.startTime)} · ${formatTime(booking.startTime)}'),
                subtitle: Text(booking.status),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => BookingDetailScreen(appointment: booking)),
                  );
                  _refresh();
                },
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconFor(String status) {
    switch (status) {
      case 'COMPLETED':
        return Icons.check_circle_outline;
      case 'CANCELLED':
      case 'NO_SHOW':
        return Icons.cancel_outlined;
      default:
        return Icons.event_available_outlined;
    }
  }
}
