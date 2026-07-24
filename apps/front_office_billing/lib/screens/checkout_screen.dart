import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:marbiks_api_client/marbiks_api_client.dart';

import '../session/auth_session.dart';
import '../utils/date_utils.dart';

class CheckoutScreen extends StatefulWidget {
  final Appointment appointment;
  final String branchId;

  const CheckoutScreen({super.key, required this.appointment, required this.branchId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  ApiClient get _apiClient => context.read<AuthSession>().apiClient;

  Invoice? _invoice;
  bool _isBusy = false;
  String? _error;

  Future<void> _generateInvoice() async {
    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final invoice = await _apiClient.createInvoiceFromAppointment(
        branchId: widget.branchId,
        customerId: widget.appointment.customerId,
        appointmentId: widget.appointment.id,
      );
      setState(() => _invoice = invoice);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _markPaid(String method) async {
    final invoice = _invoice;
    if (invoice == null) return;
    setState(() => _isBusy = true);
    try {
      final updated = await _apiClient.markInvoicePaid(invoice.id, method);
      setState(() => _invoice = updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded')),
        );
      }
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isBusy = false);
    }
  }

  Future<void> _cancelAppointment() async {
    setState(() => _isBusy = true);
    try {
      await _apiClient.cancelAppointment(widget.appointment.id);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointment = widget.appointment;
    final invoice = _invoice;

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
          const SizedBox(height: 24),
          if (invoice == null) ...[
            FilledButton(
              onPressed: _isBusy ? null : _generateInvoice,
              child: const Text('Generate invoice'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _isBusy ? null : _cancelAppointment,
              child: const Text('Cancel appointment'),
            ),
          ] else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(invoice.invoiceNumber, style: Theme.of(context).textTheme.titleMedium),
                    const Divider(),
                    ...invoice.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Text('${item.description} x${item.quantity}')),
                            Text('₹${item.total}'),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    _summaryRow('Subtotal', invoice.subtotal),
                    _summaryRow('Discount', '-${invoice.discountAmount}'),
                    _summaryRow('Tax', invoice.taxAmount),
                    _summaryRow('Total', invoice.total, bold: true),
                    const SizedBox(height: 8),
                    Text('Payment status: ${invoice.paymentStatus}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (invoice.paymentStatus != 'PAID')
              Wrap(
                spacing: 8,
                children: [
                  FilledButton(onPressed: _isBusy ? null : () => _markPaid('CASH'), child: const Text('Cash')),
                  FilledButton(onPressed: _isBusy ? null : () => _markPaid('CARD'), child: const Text('Card')),
                  FilledButton(onPressed: _isBusy ? null : () => _markPaid('UPI'), child: const Text('UPI')),
                ],
              ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text('₹$value', style: style),
        ],
      ),
    );
  }
}
