// ignore_for_file: use_super_parameters, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_new_payment_method_screen.dart'; // Import AddNewPaymentMethodScreen

class SelectPaymentMethodScreen extends StatefulWidget {
  final double amount;

  const SelectPaymentMethodScreen({Key? key, required this.amount}) : super(key: key);

  @override
  State<SelectPaymentMethodScreen> createState() => _SelectPaymentMethodScreenState();
}

class _SelectPaymentMethodScreenState extends State<SelectPaymentMethodScreen> {
  String? _selectedPaymentMethodId; // Changed to store document ID
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = true;
  final nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    setState(() { _isLoading = true; });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() { _isLoading = false; });
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentMethods')
          .orderBy('timestamp', descending: true)
          .get();
      _paymentMethods = querySnapshot.docs.map((doc) => {
        ...
        doc.data(),
        'id': doc.id // Store document ID for selection
      }).toList();

      // Optionally pre-select a default/primary method if available
      if (_paymentMethods.isNotEmpty) {
        _selectedPaymentMethodId = _paymentMethods.first['id'];
      }
    } catch (e) {
      print('Error fetching payment methods: $e');
      _paymentMethods = []; // Ensure empty list on error
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  String _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return 'https://static.cdnlogo.com/logos/v/71/visa.svg';
      case 'mastercard':
        return 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg';
      case 'paypal':
        return 'https://upload.wikimedia.org/wikipedia/commons/b/b5/PayPal.svg';
      case 'google_pay':
        return 'https://upload.wikimedia.org/wikipedia/commons/f/fa/Google_Pay_Logo.svg';
      case 'apple_pay':
        return 'https://upload.wikimedia.org/wikipedia/commons/3/31/Apple_Pay_logo.png';
      default:
        return 'https://static.cdnlogo.com/logos/v/71/visa.svg'; // Default to Visa for unknown
    }
  }

  void _showTopUpSuccessModal() {
    // This will now also update the user's balance in Firestore
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.check, color: Colors.blue, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Top Up Successful!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
              const SizedBox(height: 10),
              Text(
                'A total of ${nairaFormat.format(widget.amount)} has been added to your wallet.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Update user's balance in Firestore
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      try {
                        final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
                        await userRef.update({
                          'balance': FieldValue.increment(widget.amount),
                        });
                        // Add a transaction record
                        await FirebaseFirestore.instance.collection('transactions').add({
                          'userId': user.uid,
                          'type': 'Top Up Wallet',
                          'amount': widget.amount,
                          'isCredit': true,
                          'timestamp': FieldValue.serverTimestamp(),
                          'date': DateFormat('dd MMM, yyyy').format(DateTime.now()),
                          'time': DateFormat('HH:mm').format(DateTime.now()),
                          'icon': Icons.arrow_downward.codePoint, // Store icon codepoint
                        });
                      } catch (e) {
                        print('Error updating balance or adding transaction: $e');
                      }
                    }
                    Navigator.pop(context); // Close the modal, corrected from Navigator.pop(r)
                    Navigator.pop(context); // Go back to MyWalletScreen (which will refresh)
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
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
        title: const Text('Select Payment Method', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        if (_paymentMethods.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            child: Text('No payment methods added. Please add one.', style: TextStyle(color: Colors.grey)),
                          ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _paymentMethods.length,
                          itemBuilder: (context, index) {
                            final method = _paymentMethods[index];
                            final String id = method['id'] ?? '';
                            final String type = method['type'] ?? 'card';
                            final String cardType = method['cardType'] ?? '';
                            final String last4 = method['last4'] ?? '';
                            final String title = type == 'card' && last4.isNotEmpty ? '**** **** **** $last4' : (type == 'paypal' ? 'PayPal' : type == 'google_pay' ? 'Google Pay' : type == 'apple_pay' ? 'Apple Pay' : 'Unknown Method');
                            final String iconUrl = _getCardIcon(type == 'card' ? cardType : type);

                            return _buildPaymentOption(
                              context: context,
                              value: id,
                              groupValue: _selectedPaymentMethodId,
                              onChanged: (value) => setState(() => _selectedPaymentMethodId = value),
                              title: title,
                              icon: iconUrl,
                              isNetworkImage: true, // All icons will be network images now
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNewPaymentMethodScreen()));
                              _fetchPaymentMethods(); // Refresh methods after adding a new one
                            },
                            icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                            label: const Text('Add New Payment', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2563EB)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedPaymentMethodId != null ? _showTopUpSuccessModal : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String value,
    required String? groupValue,
    required ValueChanged<String?> onChanged,
    required String title,
    required String icon, // Still required for potential future use, but not displayed
    bool isNetworkImage = false,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // Removed Image.network/Image.asset for card icon as it was causing issues
            const SizedBox(width: 16), // Adjusted spacing
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: const Color(0xFF2563EB),
            ),
          ],
        ),
      ),
    );
  }
} 