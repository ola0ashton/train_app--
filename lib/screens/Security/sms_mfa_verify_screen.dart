// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SmsMfaVerifyScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  const SmsMfaVerifyScreen(
      {Key? key, required this.phone, required this.verificationId})
      : super(key: key);

  @override
  State<SmsMfaVerifyScreen> createState() => _SmsMfaVerifyScreenState();
}

class _SmsMfaVerifyScreenState extends State<SmsMfaVerifyScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _verifyCode() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _codeController.text.trim(),
      );
      await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = 'Verification failed: ${e.toString()}';
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
        title: const Text('Verify SMS Code',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter the code sent to ${widget.phone}'),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Verification Code'),
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
          ],
        ),
      ),
    );
  }
}
