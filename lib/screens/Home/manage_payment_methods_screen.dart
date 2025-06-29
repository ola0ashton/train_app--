// ignore_for_file: unused_local_variable, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_new_payment_method_screen.dart'; // To be created next

class ManagePaymentMethodsScreen extends StatefulWidget {
  const ManagePaymentMethodsScreen({super.key});

  @override
  State<ManagePaymentMethodsScreen> createState() => _ManagePaymentMethodsScreenState();
}

class _ManagePaymentMethodsScreenState extends State<ManagePaymentMethodsScreen> {
  List<Map<String, dynamic>> _paymentMethods = [];
  bool _isLoading = true;

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
          .orderBy('timestamp', descending: true) // Order by latest added
          .get();
      _paymentMethods = querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching payment methods: $e');
      // Fallback to mock data if needed for testing, or keep empty
      _paymentMethods = [];
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
        title: const Text('Manage Payment Methods', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _paymentMethods.isEmpty
                    ? const Center(child: Text('No payment methods added yet.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _paymentMethods.length,
                        itemBuilder: (context, index) {
                          final method = _paymentMethods[index];
                          final String cardType = method['cardType'] ?? 'Unknown';
                          final String last4 = method['last4'] ?? '';
                          final String type = method['type'] ?? 'card';
                          final String iconUrl = _getCardIcon(type == 'card' ? cardType : type);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cardType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        if (type == 'card' && last4.isNotEmpty)
                                          Text('**** **** **** $last4', style: const TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  // TODO: Add options like set as default, edit, delete
                                  IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () {
                                      // Options menu
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddNewPaymentMethodScreen()));
                  _fetchPaymentMethods(); // Refresh methods after adding a new one
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Add New Payment Method', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 