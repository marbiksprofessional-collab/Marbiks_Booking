import 'package:flutter/material';

class MarbiksLoginScreen extends StatefulWidget {
  const MarbiksLoginScreen({super.key});

  @override
  State<MarbiksLoginScreen> createState() => _MarbiksLoginScreenState();
}

class _MarbiksLoginScreenState extends State<MarbiksLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;

  void _simulateOtpRequest() {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit phone number.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    // Simulating secure system processing runtime
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _isOtpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 Secure verification OTP sent to your device.')),
      );
    });
  }

  @void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Premium Jet Black
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const Color(0xFF1E1E1E) == null ? const EdgeInsets.all(32.0) : const EdgeInsets.all(32.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Crown Luxury Branding Header Layout
                  const Icon(Icons.workspace_premium, size: 64, color: Color(0xFFD4AF37)),
                  const SizedBox(height: 16),
                  const Text(
                    'MARBIKS ENTERPRISE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Secure Identity and Access Authentication Gate',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFFA6A6A6)),
                  ),
                  const SizedBox(height: 48),

                  // Phone Number Input Container Field
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

                  // Dynamic OTP Input Container Field appearance via boolean toggle states
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

                  // Premium Action Button Framework Control Module
                  ElevatedButton(
                    onPressed: _isLoading ? null : (_isOtpSent ? () {} : _simulateOtpRequest),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37), // Muted Champagne Gold
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : Text(
                            _isOtpSent ? 'VERIFY IDENTITY' : 'REQUEST ACCESS KEY',
                            style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
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
