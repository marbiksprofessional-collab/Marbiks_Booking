import 'package:flutter/material';

class MarbiksInventoryScreen extends StatelessWidget {
  const MarbiksInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Premium Jet Black
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: const Text(
          '📦 INVENTORY & STOCK CONTROL',
          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Critical Alerts Banner Module
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0x1FFF3B30), // Soft Red Translucent Opacity
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF3B30)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFFF3B30), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'CRITICAL ALERT: 3 Items are running below safety stock levels in Cuttack Central.',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'REAL-TIME STOCK CONSUMPTION TRACKER',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1),
            ),
            const SizedBox(height: 16),

            // Inventory Item Cards Configuration
            Expanded(
              child: ListView(
                children: [
                  _buildInventoryItem('Premium Hair Serum (Batch A)', '42 Units Remaining', 'Status: Stable', const Color(0xFFD4AF37)),
                  _buildInventoryItem('Skin Therapy Facial Mask', '5 Units Remaining', 'Status: LOW STOCK', const Color(0xFFFF3B30)),
                  _buildInventoryItem('Advanced Keratin Treatment Solution', '2 Units Remaining', 'Status: CRITICAL REORDER', const Color(0xFFFF3B30)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryItem(String title, String stockCount, String statusText, Color indicatorColor) {
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
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text(stockCount, style: const TextStyle(color: Color(0xFFA6A6A6), fontSize: 13)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: indicatorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: TextStyle(color: indicatorColor, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
