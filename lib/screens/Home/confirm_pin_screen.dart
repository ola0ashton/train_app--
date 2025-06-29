// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'transaction_details_screen.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ConfirmPinScreen extends StatefulWidget {
  final Map<String, dynamic> train;
  final List<Map<String, dynamic>> passengers;
  final int carriage;
  final String seat;
  final String paymentMethod;
  final String contactName;
  final String contactEmail;
  final String contactPhone;

  const ConfirmPinScreen({
    super.key,
    required this.train,
    required this.passengers,
    required this.carriage,
    required this.seat,
    required this.paymentMethod,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
  });

  @override
  State<ConfirmPinScreen> createState() => _ConfirmPinScreenState();
}

class _ConfirmPinScreenState extends State<ConfirmPinScreen> {
  final int pinLength = 4;
  String? correctPin;
  bool isLoading = true;
  List<String> input = [];
  String error = '';
  bool pinValidated = false;

  @override
  void initState() {
    super.initState();
    _fetchUserPin();
  }

  Future<void> _fetchUserPin() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final pin = doc.data()?['pin']?.toString();
        setState(() {
          correctPin = pin;
          isLoading = false;
        });
        if (pin == null || pin.isEmpty) {
          setState(() {
            error = 'No PIN set for this account. Please set a PIN in your profile.';
          });
        }
      } else {
        setState(() {
          correctPin = null;
          isLoading = false;
          error = 'User not logged in.';
        });
      }
    } catch (e) {
      setState(() {
        correctPin = null;
        isLoading = false;
        error = 'Failed to fetch PIN. Please check your connection or try again later.';
      });
    }
  }

  void _onKeyTap(String value) {
    if (input.length < pinLength) {
      setState(() {
        input.add(value);
        error = '';
      });
      if (input.length == pinLength) {
        _validatePin();
      }
    }
  }

  void _onBackspace() {
    if (input.isNotEmpty) {
      setState(() {
        input.removeLast();
        error = '';
      });
    }
  }

  void _validatePin() {
    final enteredPin = input.join();
    final enteredHash = sha256.convert(utf8.encode(enteredPin)).toString();
    if (enteredHash == correctPin) {
      setState(() {
        pinValidated = true;
        error = '';
      });
      // Do not proceed here, wait for Confirm button press
    } else {
      setState(() {
        error = 'Incorrect PIN. Please try again.';
        input.clear();
        pinValidated = false;
      });
    }
  }

  void _showSuccessModal() {
    String generateBookingId() {
      const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final rand = Random();
      return List.generate(7, (index) => chars[rand.nextInt(chars.length)]).join();
    }
    final bookingId = generateBookingId();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // Blue gradient circle
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF5A8BFF), Color(0xFF233A7D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // White checkmark
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Color(0xFF2563EB), size: 40),
                  ),
                  // Decorative blue dots
                  Positioned(
                    top: 8,
                    left: 12,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8CAFFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 24,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB3C9FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 24,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFB3C9FF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 16,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: Color(0xFF8CAFFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Ticket Booking\nSuccessful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Color(0xFF2563EB),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'You have successfully made a payment transaction and booked a ticket. You can access tickets through the My Ticket menu.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TransactionDetailsScreen(
                          bookingId: bookingId,
                          transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
                          merchantId: UniqueKey().toString(),
                          paymentMethod: widget.paymentMethod,
                          status: 'Paid',
                          trainName: widget.train['name'],
                          trainClass: widget.train['class'],
                          departureStation: widget.train['from'],
                          arrivalStation: widget.train['to'],
                          departureTime: widget.train['depart'],
                          arrivalTime: widget.train['arrive'],
                          departureDate: widget.train['date'] != null ? DateFormat('d MMM yyyy').format(widget.train['date']) : '',
                          arrivalDate: widget.train['date'] != null ? DateFormat('d MMM yyyy').format(widget.train['date']) : '',
                          duration: widget.train['duration'],
                          price: double.tryParse(widget.train['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
                          tax: 0.05 * (double.tryParse(widget.train['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0),
                          totalPrice: 1.05 * (double.tryParse(widget.train['price'].toString().replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0),
                          passengers: widget.passengers.map((p) => {
                            'name': (p['name'] ?? '').toString(),
                            'idType': (p['idType'] ?? '').toString(),
                            'idNumber': (p['idNumber'] ?? '').toString(),
                            'type': (p['passengerType'] ?? '').toString(),
                            'seat': 'Carriage ${widget.carriage} / ${widget.seat}',
                            'logo': (widget.train['logo'] ?? '').toString(),
                          }).toList().cast<Map<String, String>>(),
                        ),
                      ),
                    );
                  },
                  child: const Text('View Transaction', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F6FF),
                    foregroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false); // Go to HomeScreen
                  },
                  child: const Text('Back to Home', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinBoxes() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pinLength, (i) {
        final isActive = i == input.length;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFF1F5F9) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? const Color(0xFF2563EB) : Colors.grey.shade300,
              width: isActive ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: input.length > i
              ? const Icon(Icons.circle, size: 20, color: Colors.black)
              : isActive
                  ? null
                  : const SizedBox.shrink(),
        );
      }),
    );
  }

  Widget _buildNumberPad() {
    final keys = [
      '1', '2', '3',
      '4', '5', '6',
      '7', '8', '9',
      '*', '0', '<',
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: keys.length,
      itemBuilder: (context, idx) {
        final key = keys[idx];
        if (key == '<') {
          return IconButton(
            icon: const Icon(Icons.backspace_outlined),
            onPressed: _onBackspace,
          );
        }
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
            side: const BorderSide(color: Color(0xFFF1F5F9)),
          ),
          onPressed: key == '*' ? null : () => _onKeyTap(key),
          child: Text(key, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final pinEntryDisabled = correctPin == null || correctPin!.isEmpty || error == 'User not logged in.' || error == 'Failed to fetch PIN. Please check your connection or try again later.';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Confirm PIN', style: TextStyle(color: Colors.white, fontFamily: 'Urbanist-Bold')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 48),
            const Text(
              'Enter your PIN to confirm your train ticket booking.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            _buildPinBoxes(),
            if (error.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(error, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: pinEntryDisabled || input.length != pinLength ? null : () {
                  _validatePin();
                  if (pinValidated) {
                    _showSuccessModal();
                  }
                },
                child: const Text('Confirm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
            if (!pinEntryDisabled)
              Expanded(child: _buildNumberPad()),
          ],
        ),
      ),
    );
  }
} 