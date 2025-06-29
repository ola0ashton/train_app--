// ignore_for_file: use_super_parameters, avoid_print, deprecated_member_use, unused_local_variable

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'top_up_wallet_screen.dart';
import 'recent_transactions_screen.dart';
import 'my_tickets_screen.dart'; // Corrected import path
import 'manage_payment_methods_screen.dart'; // Import the new screen
import 'account_screen.dart'; // Import the AccountScreen

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({Key? key}) : super(key: key);

  @override
  State<MyWalletScreen> createState() => _MyWalletScreenState();
}

class _MyWalletScreenState extends State<MyWalletScreen> {
  Map<String, dynamic>? _userData; // To store user balance and coins
  List<Map<String, dynamic>> _recentTransactions = [];
  Map<String, dynamic>?
      _primaryPaymentMethod; // To store primary payment method
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }

  Future<void> _fetchWalletData() async {
    setState(() {
      _isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Fetch user profile (for balance and coins)
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      _userData = userDoc.data();

      // Fetch primary payment method (assuming the first one for simplicity for now)
      final paymentMethodsQuery = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentMethods')
          .orderBy('timestamp',
              descending: true) // Get the latest added as primary for display
          .limit(1)
          .get();
      if (paymentMethodsQuery.docs.isNotEmpty) {
        _primaryPaymentMethod = paymentMethodsQuery.docs.first.data();
      } else {
        _primaryPaymentMethod = null; // No payment method found
      }

      // Fetch recent transactions
      final transactionQuery = await FirebaseFirestore.instance
          .collection('transactions') // Assuming a 'transactions' collection
          .where('userId', isEqualTo: user.uid)
          .orderBy('timestamp', descending: true)
          .limit(5) // Show only recent 5 transactions
          .get();
      _recentTransactions =
          transactionQuery.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching wallet data: $e');
      // Fallback to default empty/zero values
      _userData = {'balance': 0.0, 'coins': 0};
      _recentTransactions = []; // Ensure empty list on error
      _primaryPaymentMethod = null; // Ensure no payment method on error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getCardIcon(String cardType) {
    switch (cardType.toLowerCase()) {
      case 'visa':
        return 'https://static.cdnlogo.com/logos/v/71/visa.svg';
      case 'mastercard':
        return 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg';
      // Add more cases for other card types if needed
      default:
        return 'https://static.cdnlogo.com/logos/v/71/visa.svg'; // Default to Visa
    }
  }

  @override
  Widget build(BuildContext context) {
    final nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');
    final balance = (_userData?['balance'] as num?)?.toDouble() ?? 0.0;
    final coins = (_userData?['coins'] as int?) ?? 0;
    final userName = _userData?['displayName'] ?? '';

    final String? last4Digits = _primaryPaymentMethod?['last4'];
    final String? cardType = _primaryPaymentMethod?['cardType'];
    final String? cardIconUrl = (cardType != null && cardType.isNotEmpty)
        ? _getCardIcon(cardType)
        : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Wallet',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Wallet Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1B4FA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userName.isEmpty ? 'User' : userName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              if (last4Digits != null && last4Digits.isNotEmpty)
                                Text('•••• •••• •••• $last4Digits',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 16))
                              else
                                const Text('No card added',
                                    style: TextStyle(
                                        color: Colors.white70, fontSize: 14)),
                            ],
                          ),
                          // Removed Image.network for card icon as it was causing issues
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text('Your balance',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 14)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(nairaFormat.format(balance),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold)),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const TopUpWalletScreen()));
                              _fetchWalletData(); // Refresh data after top-up
                            },
                            icon:
                                const Icon(Icons.add, color: Color(0xFF2563EB)),
                            label: const Text('Top Up',
                                style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Manage Payment Methods Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ManagePaymentMethodsScreen()));
                      _fetchWalletData(); // Refresh data after managing payment methods
                    },
                    icon:
                        const Icon(Icons.credit_card, color: Color(0xFF2563EB)),
                    label: const Text('Manage Payment Methods',
                        style: TextStyle(
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Coins Section
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: Colors.orange, size: 28),
                        const SizedBox(width: 12),
                        Text('$coins Coins',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const Spacer(),
                        Expanded(
                          child: Text(
                            'You can use these coins for payment.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Recent Transactions Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Transaction',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(
                      icon: const Icon(Icons
                          .arrow_forward), // Arrow to view all transactions
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RecentTransactionsScreen()));
                        _fetchWalletData(); // Refresh data after viewing all transactions
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Recent Transactions List
                _recentTransactions.isEmpty
                    ? const Center(child: Text('No recent transactions.'))
                    : Column(
                        children: _recentTransactions.map((transaction) {
                          final isCredit = transaction['isCredit'] ?? false;
                          final amountColor =
                              isCredit ? Colors.green : Colors.red;
                          final sign = isCredit ? '+' : '-';
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(
                                      transaction['icon'] as IconData? ??
                                          Icons.error,
                                      color: const Color(0xFF2563EB)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(transaction['type'] ?? '',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Text(
                                            '${transaction['date']} • ${transaction['time']}',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                      '$sign ${nairaFormat.format(transaction['amount'] ?? 0.0)}',
                                      style: TextStyle(
                                          color: amountColor,
                                          fontWeight: FontWeight.bold)),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 16, color: Colors.grey),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // 'My Wallet' is the third item (index 2)
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst); // Go to Home
          } else if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyTicketsScreen()));
          } else if (index == 2) {
            // Already on MyWalletScreen, do nothing or refresh
          } else if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AccountScreen(setLocale: (locale) {}),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num), label: 'My Ticket'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'My Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}
