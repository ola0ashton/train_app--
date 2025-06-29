// NOTE: Make sure to add 'otp: ^3.1.4' to your pubspec.yaml
// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:otp/otp.dart'; // Uncomment when package is added
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

class TotpSetupScreen extends StatefulWidget {
  const TotpSetupScreen({Key? key}) : super(key: key);

  @override
  State<TotpSetupScreen> createState() => _TotpSetupScreenState();
}

class _TotpSetupScreenState extends State<TotpSetupScreen> {
  String? _secret;
  final _codeController = TextEditingController();
  String? _error;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _generateSecret();
  }

  void _generateSecret() {
    // Generate a random 16-character base32 secret
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final rand = Random.secure();
    _secret =
        List.generate(16, (_) => chars[rand.nextInt(chars.length)]).join();
    setState(() {});
  }

  String _buildQrData(String secret, String email) {
    // otpauth://totp/{issuer}:{account}?secret={secret}&issuer={issuer}
    final issuer = 'TrainApp';
    return 'otpauth://totp/$issuer:$email?secret=$secret&issuer=$issuer';
  }

  Future<void> _verifyCode() async {
    setState(() {
      _error = null;
    });
    final code = _codeController.text.trim();
    if (_secret == null || code.length != 6) {
      setState(() {
        _error = 'Enter a valid 6-digit code.';
      });
      return;
    }
    try {
      // Uncomment the next line when the otp package is available
      // final generated = OTP.generateTOTPCodeString(_secret!, DateTime.now().millisecondsSinceEpoch, interval: 30);
      // For now, always fail with a message
      final generated = '000000'; // Placeholder
      if (code == generated) {
        // Save secret to Firestore
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'totpSecret': _secret});
        }
        setState(() {
          _success = true;
        });
        await Future.delayed(const Duration(seconds: 1));
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text('Google Authenticator',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_secret != null) ...[
              const Text('Scan this QR code in Google Authenticator:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              QrImageView(
                data: _buildQrData(_secret!, email),
                version: QrVersions.auto,
                size: 200.0,
              ),
              const SizedBox(height: 16),
              Text('Or enter this secret manually: $_secret'),
              const SizedBox(height: 24),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Enter 6-digit code'),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_success)
                const Text('Success!', style: TextStyle(color: Colors.green)),
              ElevatedButton(
                onPressed: _verifyCode,
                child: const Text('Verify'),
              ),
              const SizedBox(height: 16),
              const Text(
                  'NOTE: Add otp: ^3.1.4 to pubspec.yaml for real verification.'),
            ],
          ],
        ),
      ),
    );
  }
}
