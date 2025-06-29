// ignore_for_file: unused_import, use_super_parameters, unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'select_payment_method_screen.dart';

class TopUpWalletScreen extends StatefulWidget {
  const TopUpWalletScreen({Key? key}) : super(key: key);

  @override
  State<TopUpWalletScreen> createState() => _TopUpWalletScreenState();
}

class _TopUpWalletScreenState extends State<TopUpWalletScreen> {
  String _amount = '0.00';
  final nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

  void _updateAmount(String value) {
    setState(() {
      if (value == 'x') {
        if (_amount.length > 1) {
          _amount = _amount.substring(0, _amount.length - 1);
        } else {
          _amount = '0.00'; // Reset to 0.00 if all digits removed
        }
      } else if (value == '.') {
        if (!_amount.contains('.')) {
          _amount += '.';
        }
      } else {
        if (_amount == '0.00') {
          _amount = value; // Replace 0.00 with the first digit
        } else if (_amount.length < 9) { // Limit input length to prevent overflow
          _amount += value;
        }
      }
      // Ensure proper decimal formatting (max 2 decimal places)
      if (_amount.contains('.')) {
        List<String> parts = _amount.split('.');
        if (parts.length > 1 && parts[1].length > 2) {
          _amount = '${parts[0]}.${parts[1].substring(0, 2)}';
        }
      }
    });
  }

  void _selectPresetAmount(double value) {
    setState(() {
      _amount = value.toStringAsFixed(2);
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayedAmount = double.tryParse(_amount) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Top Up Wallet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Enter the amount of top up',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Text(
                        nairaFormat.format(displayedAmount),
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      final amounts = [10.0, 20.0, 50.0, 100.0, 200.0, 250.0, 500.0, 750.0, 1000.0];
                      final amount = amounts[index];
                      return ElevatedButton(
                        onPressed: () => _selectPresetAmount(amount),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB), backgroundColor: Colors.blue.shade50,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Text(nairaFormat.format(amount), style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: displayedAmount > 0 ? () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SelectPaymentMethodScreen(amount: displayedAmount)));
                      } : null, // Disable if amount is 0
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Numeric Keypad
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                for (var i = 0; i < 4; i++) // Rows of keys
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(3, (j) {
                        final keyIndex = i * 3 + j;
                        final List<String> keys = [
                          '1', '2', '3',
                          '4', '5', '6',
                          '7', '8', '9',
                          '*', '0', 'x'
                        ];
                        final String key = keys[keyIndex];
                        return SizedBox(
                          width: MediaQuery.of(context).size.width / 4, // Adjust key size
                          height: 60,
                          child: TextButton(
                            onPressed: () => _updateAmount(key),
                            child: Center(
                              child: key == 'x'
                                  ? const Icon(Icons.backspace_outlined, color: Colors.black54)
                                  : Text(key, style: const TextStyle(fontSize: 24, color: Colors.black87)),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 