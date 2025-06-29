// ignore_for_file: use_super_parameters, prefer_final_fields, depend_on_referenced_packages, use_build_context_synchronously, sort_child_properties_last, deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math';
import 'SignIn/sign_in_screen.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Dot extends StatelessWidget {
  final Color color;
  final double size;
  const Dot({required this.color, required this.size, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({Key? key}) : super(key: key);

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  List<String> _pin = ['', '', '', ''];
  int _currentIndex = 0;

  void _onKeyTap(String value) {
    setState(() {
      if (_currentIndex < 4) {
        _pin[_currentIndex] = value;
        _currentIndex++;
      }
    });
  }

  void _onDelete() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
        _pin[_currentIndex] = '';
      }
    });
  }

  void _onConfirm() async {
  if (_pin.every((digit) => digit.isNotEmpty)) {
    final pin = _pin.join();
    // Hash the PIN using SHA-256
    final bytes = utf8.encode(pin);
    final hashedPin = sha256.convert(bytes).toString();
    try {
      final user = AuthService().currentUser;
      if (user == null) throw Exception('User not logged in');
      await FirestoreService().updateUserProfile(user.uid, {'pin': hashedPin});
      _showSuccessModal();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PIN: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a 4-digit PIN.', style: TextStyle(fontFamily: 'Urbanist'))),
    );
  }
}


  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
            elevation: 0,
            backgroundColor: Colors.white,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: Color(0xFF2962FF),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x1A2962FF),
                              blurRadius: 18,
                              spreadRadius: 2,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 48),
                      ),
                      // Floating dots
                      const Positioned(top: 12, left: 18, child: Dot(color: Color(0xFF2962FF), size: 8)),
                      const Positioned(top: 0, right: 18, child: Dot(color: Color(0xFF2962FF), size: 6)),
                      const Positioned(bottom: 16, right: 18, child: Dot(color: Color(0xFF2962FF), size: 7)),
                      const Positioned(bottom: 0, left: 20, child: Dot(color: Color(0xFF2962FF), size: 6)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Sign up Successful!',
                    style: TextStyle(
                      color: Color(0xFF2962FF),
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Urbanist',
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Please wait...\nYou will be directed to the homepage.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF23252E),
                      fontSize: 15,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CustomLoadingIndicator(),
                ],
              ),
            ),
          ),
        );
      },
    );
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    });
  }

  Widget _buildPinField(int index) {
    bool isActive = _currentIndex == index;
    return Container(
      width: 60,
      height: 60,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF2962FF) : Colors.transparent,
          width: 2,
        ),
        color: const Color(0xFFF7F7F7),
      ),
      child: _pin[index].isEmpty
          ? const SizedBox.shrink()
          : isActive
              ? Text(
                  _pin[index],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                    color: Color(0xFF2962FF),
                  ),
                )
              : const Icon(Icons.circle, size: 18, color: Colors.black),
    );
  }

  Widget _buildKey(String value) {
    return GestureDetector(
      onTap: () => _onKeyTap(value),
      child: Container(
        alignment: Alignment.center,
        height: 60,
        child: Text(
          value,
          style: const TextStyle(fontSize: 28, fontFamily: 'Urbanist'),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    List<List<String>> keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', 'del'],
    ];
    return Column(
      children: keys.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            if (key == 'del') {
              return GestureDetector(
                onTap: _onDelete,
                child: Container(
                  alignment: Alignment.center,
                  height: 60,
                  width: 60,
                  child: const Icon(Icons.backspace_outlined, size: 28, color: Colors.black),
                ),
              );
            }
            return SizedBox(
              width: 60,
              child: _buildKey(key),
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_pin.every((digit) => digit.isNotEmpty)) {
          return true; // allow pop
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must create a PIN to continue.', style: TextStyle(fontFamily: 'Urbanist'))),
          );
          return false; // block pop
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF2196F3),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1.0, // Full progress
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        const Text(
                          'Create new PIN ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Urbanist',
                            color: Colors.black,
                          ),
                        ),
                        Icon(Icons.lock, color: Colors.amber[700], size: 28),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Add a PIN number to make your account more secure. You will also need this PIN to make ticket booking transactions.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    const SizedBox(height: 36),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(4, (index) => _buildPinField(index)),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2962FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _pin.every((digit) => digit.isNotEmpty) ? _onConfirm : null,
                        child: const Text('Confirm', style: TextStyle(fontSize: 18, fontFamily: 'Urbanist')),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildKeypad(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    )); // <-- closes Scaffold
  }
}

class CustomLoadingIndicator extends StatefulWidget {
  const CustomLoadingIndicator({Key? key}) : super(key: key);

  @override
  State<CustomLoadingIndicator> createState() => _CustomLoadingIndicatorState();
}

class _CustomLoadingIndicatorState extends State<CustomLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double angle = _controller.value * 2 * 3.1415926535;
          return Transform.rotate(
            angle: angle,
            child: Stack(
              alignment: Alignment.center,
              children: List.generate(8, (i) {
                final double rad = (3.1415926535 * 2 / 8) * i;
                final double dx = 18 * (1.15 * (i % 2 == 0 ? 1.0 : 0.8)) * cos(rad);
                final double dy = 18 * (1.15 * (i % 2 == 0 ? 1.0 : 0.8)) * sin(rad);
                final double size = i % 2 == 0 ? 10.0 : 7.0;
                final Color color = Color.lerp(const Color(0xFF2962FF), const Color(0xFF4F8CFF), i / 8)!;
                return Positioned(
                  left: 24 + dx,
                  top: 24 + dy,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
