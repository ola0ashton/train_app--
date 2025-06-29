// ignore_for_file: use_super_parameters, avoid_print

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class RecentTransactionsScreen extends StatefulWidget {
  const RecentTransactionsScreen({Key? key}) : super(key: key);

  @override
  State<RecentTransactionsScreen> createState() => _RecentTransactionsScreenState();
}

class _RecentTransactionsScreenState extends State<RecentTransactionsScreen> {
  List<Map<String, dynamic>> _allTransactions = [];
  bool _isLoading = true;
  final nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

  @override
  void initState() {
    super.initState();
    _fetchAllTransactions();
  }

  Future<void> _fetchAllTransactions() async {
    setState(() { _isLoading = true; });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() { _isLoading = false; });
      return;
    }

    try {
      final transactionQuery = await FirebaseFirestore.instance
          .collection('transactions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .get();
      _allTransactions = transactionQuery.docs.map((doc) => doc.data()).toList();

    } catch (e) {
      print('Error fetching all transactions: $e');
      // Fallback to mock data or handle error gracefully
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
        title: const Text('Recent Transaction', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allTransactions.isEmpty
              ? const Center(child: Text('No transactions found.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _allTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _allTransactions[index];
                    final isCredit = transaction['isCredit'] ?? false;
                    final amountColor = isCredit ? Colors.green : Colors.red;
                    final sign = isCredit ? '+' : '-';
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(transaction['icon'] as IconData? ?? Icons.error, color: const Color(0xFF2563EB)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(transaction['type'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('${transaction['date']} • ${transaction['time']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                ],
                              ),
                            ),
                            Text('$sign ${nairaFormat.format(transaction['amount'] ?? 0.0)}', style: TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 