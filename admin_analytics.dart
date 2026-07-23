import 'package:flutter/material';

class MarbiksAdminAnalyticsScreen extends StatelessWidget {
  const MarbiksAdminAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Premium Jet Black
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: const Text(
          '📊 ENTERPRISE ANALYTICS',
          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Global Business Performance Matrix Cards
            Row(
              children: [
                Expanded(child: _buildKPIValueCard('Total Revenue', '₹14.2 L', const Color(0xFFD4AF37))),
                const SizedBox(width: 16),
                Expanded(child: _buildKPIValueCard('Active Bookings', '1,240', Colors.white)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildKPIValueCard('Net GST Collected', '₹2.55 L', Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildKPIValueCard('Active Branches', '512 / 512', Colors.green)),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'BRANCH PROFITABILITY LEADERBOARD',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
            ),
            const SizedBox(height: 16),

            // Simulated Multi-branch Performance Streams
            Expanded(
              child: ListView(
                children: [
                  _buildBranchPerformanceRow('01. Cuttack Central', '₹4.20 L revenue', '+12% growth', const Color(0xFFD4AF37)),
                  _buildBranchPerformanceRow('02. Bhubaneswar Hub', '₹3.85 L revenue', '+8% growth', const Color(0xFFD4AF37)),
                  _buildBranchPerformanceRow('03. Puri Coastal Resort', '₹2.10 L revenue', '-2% lag', Colors.redAccent),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPIValueCard(String title, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A1A1A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: accentColor, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBranchPerformanceRow(String branch, String revenue, String metrics, Color indicatorColor) {
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(branch, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(revenue, style: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 13)),
              ],
            ),
            Text(
              metrics,
              style: TextStyle(color: indicatorColor, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
