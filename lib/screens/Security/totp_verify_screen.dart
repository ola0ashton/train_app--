// NOTE: Make sure to add 'otp: ^3.1.4' to your pubspec.yaml
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
// import 'package:otp/otp.dart'; // Uncomment when package is added

class TotpVerifyScreen extends StatefulWidget {
  final String secret;
  const TotpVerifyScreen({Key? key, required this.secret}) : super(key: key);

  @override
  State<TotpVerifyScreen> createState() => _TotpVerifyScreenState();
}

class _TotpVerifyScreenState extends State<TotpVerifyScreen> {
  final _codeController = TextEditingController();
  String? _error;
  bool _loading = false;

  Future<void> _verifyCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final code = _codeController.text.trim();
    if (widget.secret.isEmpty || code.length != 6) {
      setState(() {
        _error = 'Enter a valid 6-digit code.';
        _loading = false;
      });
      return;
    }
    try {
      // Uncomment the next line when the otp package is available
      // final generated = OTP.generateTOTPCodeString(widget.secret, DateTime.now().millisecondsSinceEpoch, interval: 30);
      // For now, always fail with a message
      final generated = '000000'; // Placeholder
      if (code == generated) {
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() {
          _error = 'Invalid code. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'OTP package not available. Add otp: ^3.1.4 to pubspec.yaml.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text('Authenticator Code',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter the 6-digit code from your Authenticator app:'),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '6-digit code'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _verifyCode,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Verify'),
            ),
            const SizedBox(height: 16),
            const Text(
                'NOTE: Add otp: ^3.1.4 to pubspec.yaml for real verification.'),
          ],
        ),
      ),
    );
  }
}
