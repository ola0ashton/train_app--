// ignore_for_file: unused_field, use_super_parameters, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AddNewPaymentMethodScreen extends StatefulWidget {
  const AddNewPaymentMethodScreen({Key? key}) : super(key: key);

  @override
  State<AddNewPaymentMethodScreen> createState() => _AddNewPaymentMethodScreenState();
}

class _AddNewPaymentMethodScreenState extends State<AddNewPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _cardHolderName = '';
  String _expiryDate = '';
  String _cvv = '';
  String _cardType = ''; // To store Visa, Mastercard etc.
  bool _isLoading = false;

  // Basic card type detection (for demo purposes)
  String _detectCardType(String cardNumber) {
    if (cardNumber.startsWith('4')) {
      return 'Visa';
    } else if (cardNumber.startsWith('5')) {
      return 'Mastercard';
    } else {
      return 'Unknown';
    }
  }

  Future<void> _savePaymentMethod() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in.')));
      setState(() { _isLoading = false; });
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentMethods')
          .add({
        'last4': _cardNumber.substring(_cardNumber.length - 4), // Store last 4 digits
        'cardType': _cardType, // Store detected card type
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'card', // Indicate it's a card payment method
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment method added successfully!')));
      Navigator.pop(context); // Go back to ManagePaymentMethodsScreen

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding payment method: $e')));
      print('Error adding payment method: $e');
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Add New Payment Method', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        hintText: 'Enter card number',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 16,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        setState(() {
                          _cardNumber = value;
                          _cardType = _detectCardType(value);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 16) {
                          return 'Please enter a valid 16-digit card number.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Card Holder Name',
                        hintText: 'Enter card holder name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => _cardHolderName = value,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter card holder name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Expiry Date',
                              hintText: 'MM/YY',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 5,
                            inputFormatters: [ // Custom formatter for MM/YY
                              FilteringTextInputFormatter.digitsOnly,
                              _ExpiryDateFormatter(),
                            ],
                            onChanged: (value) => _expiryDate = value,
                            validator: (value) {
                              if (value == null || value.isEmpty || value.length < 5 || !value.contains('/')) {
                                return 'Please enter a valid expiry date (MM/YY).';
                              }
                              // Basic validation for month/year (can be more robust)
                              final parts = value.split('/');
                              final month = int.tryParse(parts[0]);
                              final year = int.tryParse(parts[1]);
                              if (month == null || month < 1 || month > 12) {
                                return 'Invalid month.';
                              }
                              if (year == null || year < DateTime.now().year % 100) {
                                return 'Invalid year.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              hintText: 'XXX',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 3,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (value) => _cvv = value,
                            validator: (value) {
                              if (value == null || value.isEmpty || value.length < 3) {
                                return 'Please enter a valid 3-digit CVV.';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _savePaymentMethod,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Save Payment Method', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

// Custom formatter for MM/YY expiry date input
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var newText = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 2 == 0 && nonZeroIndex != newText.length) {
        buffer.write('/');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
} 