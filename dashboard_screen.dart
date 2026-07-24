import 'package:flutter/material';
import 'http_client.dart'; // Importing our live Network Client Layer

class MarbiksDashboardScreen extends StatefulWidget {
  const MarbiksDashboardScreen({super.key});

  @override
  State<MarbiksDashboardScreen> createState() => _MarbiksDashboardScreenState();
}

class _MarbiksDashboardScreenState extends State<MarbiksDashboardScreen> {
  final MarbiksHttpClient _httpClient = MarbiksHttpClient();
  bool _isBookingLoading = false;

  // 📅 Executing Real-time Smart Booking Request to NestJS Backend via Client Abstraction
  Future<void> _triggerSmartBooking() async {
    setState(() => _isBookingLoading = true);

    // Dynamic payload configuration matching core PostgreSQL Schema definitions
    final bookingPayload = {
      "branchId": "7b2e9c1a-8f5d-4c3b-2a1e-0f9e8d7c6b5a", // Sample verified branch UUID context
      "customerId": "1a2b3c4d-5e6f-7a8b-9c0d-1e2f3a4b5c6d",
      "technicianId": "technician_vivek_id",
      "resourceType": "chair",
      "requestedStart": "${DateTime.now().toIso8601String().split('T')[0]}T10:30:00Z",
      "requestedEnd": "${DateTime.now().toIso8601String().split('T')[0]}T11:30:00Z"
    };

    final response = await _httpClient.executeSmartBooking(bookingPayload);

    setState(() => _isBookingLoading = false);

    if (!mounted) return;
    
    if (response['status'] == 'conflict') {
      _showDialog('AI Conflict Warning', response['message'] ?? 'The requested resource or technician is already allocated.');
    } else if (response['syncStatus'] == 'queued_offline') {
      _showDialog('Offline Sync Status', 'Network connection unavailable. Booking safely saved into local cache queue container.');
    } else {
      _showDialog('Booking Verified', '🎉 Appointment securely routed and synchronized directly into Core ERP Database!');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: Text(title, style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFFD4AF37))),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: const Text(
          '👑 MARBIKS DASHBOARD',
          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF262626)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.psychology, size: 40, color: Color(0xFFD4AF37)),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('AI LIVE INSIGHT', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 12)),
                        SizedBox(height: 4),
                        Text(
                          'System connected live to NestJS Gateways. AI conflict routing checks active.',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isBookingLoading ? null : _triggerSmartBooking,
              icon: _isBookingLoading 
                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.add_task),
              label: const Text('TEST LIVE AI BOOKING ROUTE', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
