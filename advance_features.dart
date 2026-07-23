import 'package:flutter/material';

class MarbiksAdvancedFeaturesScreen extends StatefulWidget {
  const MarbiksAdvancedFeaturesScreen({super.key});

  @override
  State<MarbiksAdvancedFeaturesScreen> createState() => _MarbiksAdvancedFeaturesScreenState();
}

class _MarbiksAdvancedFeaturesScreenState extends State<MarbiksAdvancedFeaturesScreen> {
  bool _isScanningBarcode = false;
  bool _isWebSocketConnected = false;
  String _barcodeResult = "Scan a Product Barcode / QR Code";
  String _liveNotification = "No Active System Notifications";

  void _simulateBarcodeScan() {
    setState(() {
      _isScanningBarcode = true;
      _barcodeResult = "Initializing Tablet Camera Layer...";
    });
    Future.delayed(const Duration(seconds: 2.5), () {
      setState(() {
        _isScanningBarcode = false;
        _barcodeResult = "🎉 Barcode Detected [EAN-13]: 8901030753214\nProduct: L\'Oreal Hair Treatment Serum\nStock Status: Updated (+1)";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📦 Inventory count successfully incremented via Barcode Scan.')),
      );
    });
  }

  void _toggleWebSocketStream() {
    setState(() {
      _isWebSocketConnected = !_isWebSocketConnected;
      if (_isWebSocketConnected) {
        _liveNotification = "🟢 Real-time WebSockets Connected to NestJS Server.\nListening for global branch sync events...";
      } else {
        _liveNotification = "🔴 WebSockets Disconnected. Offline sync queue monitoring active.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Premium Jet Black
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: const Text(
          '⚡ ADVANCED CHANNELS & IOT',
          style: TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 📡 Real-time WebSockets & Live Messaging Control Block
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1A1A1A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WEBSOCKET REAL-TIME LIVE NOTIFICATION GATEWAY', style: TextStyle(color: Color(0xFFA6A6A6), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF0A0A0A), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      _liveNotification,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _toggleWebSocketStream,
                    icon: Icon(_isWebSocketConnected ? Icons.flash_off : Icons.flash_on, size: 18),
                    label: Text(_isWebSocketConnected ? 'DISCONNECT ENGINE' : 'CONNECT REAL-TIME ENGINE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isWebSocketConnected ? Colors.redAccent : const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 📦 Automated Hardware Barcode / QR Code Scanner Module
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1A1A1A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HARDWARE INTERACTION: BARCODE / QR SCANNER', style: TextStyle(color: Color(0xFFA6A6A6), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: const Color(0xFF0A0A0A), borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      _barcodeResult,
                      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isScanningBarcode ? null : _simulateBarcodeScan,
                    icon: _isScanningBarcode 
                        ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.qr_code_scanner),
                    label: Text(_isScanningBarcode ? 'SCANNING CAMERA MATRIX...' : 'LAUNCH BARCODE HARDWARE SCANNER'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
