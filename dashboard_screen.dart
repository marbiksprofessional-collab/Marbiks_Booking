import 'package:flutter/material';

class MarbiksDashboardScreen extends StatelessWidget {
  const MarbiksDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Premium Jet Black
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: const Text(
          '👑 MARBIKS DASHBOARD',
          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          const CircleAvatar(
            backgroundColor: Color(0xFFD4AF37),
            radius: 16,
            child: Text('M', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Business Insights Panel Layout
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
                          'Next 2 Hours Demand High. Suggesting 1 Early Shift Extension for Technician Vivek.',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'TODAY\'S CHAIR ALLOCATION GRID',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1),
            ),
            const SizedBox(height: 16),
            
            // Smart Calendar Grid Content Block
            Expanded(
              child: ListView(
                children: [
                  _buildGridRow('09:00 AM', 'Chair 01: [John Doe]', 'Laser Room: [Skin Therapy]', const Color(0xFFD4AF37)),
                  _buildGridRow('10:30 AM', 'Chair 01: [Available]', 'Laser Room: [Maintenance]', Colors.grey),
                  _buildGridRow('12:00 PM', 'Chair 01: [Mary Com]', 'Laser Room: [Available]', const Color(0xFFD4AF37)),
                  _buildGridRow('02:00 PM', 'Chair 01: [Alex Smith]', 'Laser Room: [Hair Treatment]', const Color(0xFFD4AF37)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridRow(String time, String chairStatus, String roomStatus, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1A1A1A)),
        ),
        child: Row(
          children: [
            Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(chairStatus, style: TextStyle(color: accentColor, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(roomStatus, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}
