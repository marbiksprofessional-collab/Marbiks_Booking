import 'package:flutter/material';
import 'dashboard_screen.dart';
import 'http_client.dart'; // Importing our live Network Client Layer

class MarbiksLoginScreen extends StatefulWidget {
  const MarbiksLoginScreen({super.key});

  @override
  State<MarbiksLoginScreen> createState() => _MarbiksLoginScreenState();
}

class _MarbiksLoginScreenState extends State<MarbiksLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final MarbiksHttpClient _httpClient = MarbiksHttpClient(); // Instance created
  
  bool _isOtpSent = false;
  bool _isLoading = false;

  // 📱 Pushing Real-time Request to NestJS Backend via Client Abstraction
  Future<void> _handleOtpRequest() async {
    if (_phoneController.text.length < 10) {
      _showSnackbar('Please enter a valid 10-digit phone number.');
      return;
    }
    setState(() => _isLoading = true);
    
    final response = await _httpClient.requestOtpToken(_phoneController.text);
    
    setState(() => _isLoading = false);
    if (response['message'] != null && response['status'] != 'error') {
      setState(() => _isOtpSent = true);
      _showSnackbar('🎉 Secure verification OTP sent to your device.');
    } else {
      _showSnackbar(response['message'] ?? 'Connection to OTP Server failed.');
    }
  }

  // 🔑 Confirming Security Key directly with the Central Auth Router
  Future<void> _handleOtpVerification() async {
    if (_otpController.text.length < 6) {
      _showSnackbar('Please enter the 6-digit OTP code.');
      return;
    }
    setState(() => _isLoading = true);

    final response = await _httpClient.verifyOtpToken(_phoneController.text, _otpController.text);
    
    setState(() => _isLoading = false);
    if (response['success'] == true) {
      if (!mounted) return;
      // Route smoothly into the central luxury dashboard layer
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MarbiksDashboardScreen()),
      );
    } else {
      _showSnackbar(response['message'] ?? 'Incorrect OTP code validation failed.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.workspace_premium, size: 64, color: Color(0xFFD4AF37)),
                  const SizedBox(height: 16),
                  const Text(
                    'MARBIKS ENTERPRISE',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.white),
                  ),
                  const SizedBox(height: 48),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    enabled: !_isOtpSent,
                    decoration: InputDecoration(
                      labelText: 'Registered Mobile Number',
                      labelStyle: const TextStyle(color: Color(0xFFA6A6A6)),
                      prefixIcon: const Icon(Icons.phone_android, color: Color(0xFFD4AF37)),
                      filled: true,
                      fillColor: const Color(0xFF1A1A1A),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isOtpSent) ...[
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(color: Colors.white, letterSpacing: 4),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: '6-Digit Security OTP Code',
                        labelStyle: const TextStyle(color: Color(0xFFA6A6A6)),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFD4AF37)),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ElevatedButton(
                    onPressed: _isLoading 
                        ? null 
                        : (_isOtpSent ? _handleOtpVerification : _handleOtpRequest),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                        : Text(_isOtpSent ? 'VERIFY IDENTITY' : 'REQUEST ACCESS KEY', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
