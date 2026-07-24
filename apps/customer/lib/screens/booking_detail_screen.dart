import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';
import '../utils/date_utils.dart';

class BookingDetailScreen extends StatefulWidget {
  final Appointment appointment;

  const BookingDetailScreen({super.key, required this.appointment});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  late Appointment _appointment;
  Invoice? _invoice;
  int _reviewRating = 5;
  final _reviewCommentController = TextEditingController();

  bool _isBusy = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _appointment = widget.appointment;
    if (_appointment.status == 'COMPLETED') {
      _loadInvoice();
    }
  }

  Future<void> _loadInvoice() async {
    try {
      final invoices = await _apiClient.getMyInvoices();
      final match = invoices.where((inv) => inv.appointmentId == _appointment.id);
      if (match.isNotEmpty && mounted) {
        setState(() => _invoice = match.first);
      }
    } on ApiException {
      // No invoice yet is a normal state - nothing to show, nothing to alarm the user with.
    }
  }

  Future<void> _reschedule() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _appointment.startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_appointment.startTime),
    );
    if (time == null) return;

    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final newStart = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      final updated = await _apiClient.rescheduleMyAppointment(_appointment.id, newStart);
      setState(() => _appointment = updated);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _cancel() async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final updated = await _apiClient.cancelMyAppointment(_appointment.id);
      setState(() => _appointment = updated);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _submitReview() async {
    setState(() {
      _isBusy = true;
      _error = null;
      _success = null;
    });
    try {
      await _apiClient.submitReview(
        appointmentId: _appointment.id,
        rating: _reviewRating,
        comment: _reviewCommentController.text.trim(),
      );
      setState(() => _success = 'Thanks for your feedback!');
    } on ApiException catch (e) {
      setState(() => _error = e.statusCode == 409 ? 'You already reviewed this visit.' : e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    _reviewCommentController.dispose();
    super.dispose();
  }

  bool get _canModify => _appointment.status == 'PENDING' || _appointment.status == 'CONFIRMED';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Status: ${_appointment.status}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            '${formatDateReadable(_appointment.startTime)} · '
            '${formatTime(_appointment.startTime)} - ${formatTime(_appointment.endTime)}',
          ),
          if (_appointment.notes != null && _appointment.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Notes: ${_appointment.notes}'),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          if (_success != null) ...[
            const SizedBox(height: 12),
            Text(_success!, style: const TextStyle(color: Colors.green)),
          ],
          if (_canModify) ...[
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isBusy ? null : _reschedule,
              child: const Text('Reschedule'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _isBusy ? null : _cancel,
              child: const Text('Cancel booking'),
            ),
          ],
          if (_appointment.status == 'COMPLETED') ...[
            const Divider(height: 32),
            if (_invoice != null) ...[
              Text('Invoice', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_invoice!.invoiceNumber),
                      const SizedBox(height: 4),
                      ..._invoice!.items.map((item) => Text('${item.description} — ₹${item.total}')),
                      const Divider(),
                      Text('Total: ₹${_invoice!.total}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('Payment: ${_invoice!.paymentStatus}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Text('Leave a review', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => IconButton(
                  icon: Icon(
                    index < _reviewRating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _reviewRating = index + 1),
                ),
              ),
            ),
            TextField(
              controller: _reviewCommentController,
              decoration: const InputDecoration(labelText: 'Comment (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _isBusy ? null : _submitReview,
              child: const Text('Submit review'),
            ),
          ],
        ],
      ),
    );
  }
}
