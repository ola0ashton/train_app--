// ignore_for_file: use_super_parameters, prefer_const_declarations, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/otp_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String maskedEmail;
  const OTPVerificationScreen({Key? key, required this.email, required this.maskedEmail}) : super(key: key);

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  List<String> otpDigits = ['', '', '', ''];
  int selectedIndex = 0;
  bool isVerifying = false;
  String error = '';
  int resendSeconds = 60;
  Timer? _timer;
  String get enteredOTP => otpDigits.join();
  final OtpService otpService = OtpService();

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  void startResendTimer() {
    resendSeconds = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        resendSeconds--;
        if (resendSeconds == 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void onKeyTap(String key) {
    setState(() {
      if (key == '<') {
        for (int i = 3; i >= 0; i--) {
          if (otpDigits[i].isNotEmpty) {
            otpDigits[i] = '';
            selectedIndex = i;
            break;
          }
        }
      } else if (selectedIndex < 4 && RegExp(r'^[0-9]$').hasMatch(key)) {
        otpDigits[selectedIndex] = key;
        selectedIndex = (selectedIndex + 1).clamp(0, 4);
      }
      error = '';
    });
  }

  Future<void> verifyOTP() async {
    setState(() { isVerifying = true; });
    final success = await otpService.verifyOtp(widget.email, enteredOTP);
    setState(() { isVerifying = false; });
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP verified!')),
      );
      // TODO: Navigate to reset password screen
    } else {
      setState(() { error = 'Incorrect OTP. Please try again.'; });
    }
  }

  Future<void> resendOTP() async {
    final sent = await otpService.sendOtp(widget.email);
    if (sent) {
      startResendTimer();
      setState(() {
        otpDigits = ['', '', '', ''];
        selectedIndex = 0;
        error = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A new OTP has been sent.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to resend OTP. Please try again.')),
      );
    }
  }

  Widget buildKey(String label) {
    return GestureDetector(
      onTap: () {
        if (label == '<') {
          onKeyTap('<');
        } else if (selectedIndex < 4 && RegExp(r'^[0-9]$').hasMatch(label)) {
          onKeyTap(label);
        }
      },
      child: Container(
        width: 64,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: label == '<'
            ? const Icon(Icons.backspace_outlined, size: 28)
            : Text(label, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF2962FF);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        toolbarHeight: 70,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Text(
                  'OTP code verification ',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text('🔒', style: TextStyle(fontSize: 28)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'We have sent an OTP code to your email\n${widget.maskedEmail}. Enter the OTP code below to verify.',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (i) => Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedIndex == i ? themeColor : Colors.grey.shade300,
                    width: selectedIndex == i ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.grey.shade100,
                ),
                child: Text(
                  otpDigits[i],
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              )),
            ),
          ),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12.0, left: 24.0, right: 24.0),
              child: Text(error, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            ),
          const SizedBox(height: 18),
          const Center(
            child: Text(
              "Didn't receive email?",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          Center(
            child: resendSeconds > 0
                ? Text(
                    'You can resend code in $resendSeconds s',
                    style: TextStyle(fontSize: 16, color: themeColor, fontWeight: FontWeight.w500),
                  )
                : TextButton(
                    onPressed: resendOTP,
                    child: Text('Resend code', style: TextStyle(color: themeColor, fontWeight: FontWeight.bold)),
                  ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...['1','2','3'].map(buildKey),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...['4','5','6'].map(buildKey),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ...['7','8','9'].map(buildKey),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    buildKey('*'),
                    buildKey('0'),
                    buildKey('<'),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: enteredOTP.length == 4 && !isVerifying ? verifyOTP : null,
                    child: isVerifying
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Verify', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
