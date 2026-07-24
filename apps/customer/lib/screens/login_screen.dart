import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../session/auth_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _otpSent = false;
  String? _devCodeHint;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _requestOtp(AuthSession session) async {
    if (_phoneController.text.trim().isEmpty) return;
    final devCode = await session.requestOtp(_phoneController.text.trim());
    if (session.error == null) {
      setState(() {
        _otpSent = true;
        _devCodeHint = devCode;
      });
    } else {
      setState(() {});
    }
  }

  Future<void> _verifyOtp(AuthSession session) async {
    await session.verifyOtp(
      phone: _phoneController.text.trim(),
      code: _codeController.text.trim(),
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSession>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Marbiks Professional',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Book your next appointment',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _phoneController,
                    enabled: !_otpSent,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Phone number'),
                  ),
                  if (!_otpSent) ...[
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: session.isBusy ? null : () => _requestOtp(session),
                      child: session.isBusy
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Send OTP'),
                    ),
                  ] else ...[
                    const SizedBox(height: 16),
                    if (_devCodeHint != null)
                      Text(
                        'Dev mode - no SMS gateway configured. Your code is $_devCodeHint',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: '6-digit code'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Full name (first time only)'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email (optional)'),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: session.isBusy ? null : () => _verifyOtp(session),
                      child: session.isBusy
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Verify & continue'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _otpSent = false;
                        _codeController.clear();
                      }),
                      child: const Text('Use a different number'),
                    ),
                  ],
                  if (session.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      session.error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
