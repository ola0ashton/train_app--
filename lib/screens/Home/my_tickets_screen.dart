// ignore_for_file: use_super_parameters, unused_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'transaction_details_screen.dart';
import 'home_screen.dart'; // Import HomeScreen for navigation
import 'my_wallet_screen.dart';
import 'account_screen.dart';

class MyTicketsScreen extends StatefulWidget {
  final int
      initialTabIndex; // To set the initial tab if navigating from a specific context
  const MyTicketsScreen({Key? key, this.initialTabIndex = 0}) : super(key: key);

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _statuses = ['Active', 'Completed', 'Cancelled'];
  bool _showTickets = true; // Toggle between Tickets and Services

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> _getTicketsStream(String status) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }
    String firestoreStatus = status == 'Active' ? 'Paid' : status;
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: firestoreStatus)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Paid':
      case 'Active':
        return const Color(0xFF2563EB);
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16.0), // Adjust padding as needed
          child: Icon(Icons.train, color: Colors.white, size: 30),
        ),
        title: const Text('My Ticket',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(100.0), // Height for TabBar and Toggle
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey[400],
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                tabs: const [
                  Tab(text: 'Active'),
                  Tab(text: 'Completed'),
                  Tab(text: 'Canceled'),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showTickets
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          foregroundColor: _showTickets
                              ? Colors.white
                              : const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            _showTickets = true;
                          });
                        },
                        child: const Text('Tickets',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_showTickets
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          foregroundColor: !_showTickets
                              ? Colors.white
                              : const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            _showTickets = false;
                          });
                        },
                        child: const Text('Services',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _statuses.map((status) {
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: _getTicketsStream(status),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No tickets found.'));
              }
              final tickets = snapshot.data!;
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailsScreen(
                            bookingId: ticket['bookingId'],
                            transactionId: ticket['transactionId'] ?? '',
                            merchantId: ticket['merchantId'] ?? '',
                            paymentMethod: ticket['paymentMethod'] ?? '',
                            status: ticket['status'] ?? '',
                            trainName:
                                ticket['trainName'] ?? ticket['name'] ?? '',
                            trainClass:
                                ticket['trainClass'] ?? ticket['class'] ?? '',
                            departureStation: ticket['departureStation'] ??
                                ticket['from'] ??
                                '',
                            arrivalStation:
                                ticket['arrivalStation'] ?? ticket['to'] ?? '',
                            departureTime: ticket['departureTime'] ??
                                ticket['depart'] ??
                                '',
                            arrivalTime:
                                ticket['arrivalTime'] ?? ticket['arrive'] ?? '',
                            departureDate: ticket['departureDate'] ??
                                (ticket['date'] ?? ''),
                            arrivalDate:
                                ticket['arrivalDate'] ?? (ticket['date'] ?? ''),
                            duration: ticket['duration'] ?? '',
                            price: (ticket['price'] is int)
                                ? (ticket['price'] as int).toDouble()
                                : (ticket['price'] as num?)?.toDouble() ?? 0.0,
                            tax: (ticket['tax'] is int)
                                ? (ticket['tax'] as int).toDouble()
                                : (ticket['tax'] as num?)?.toDouble() ?? 0.0,
                            totalPrice: (ticket['totalPrice'] is int)
                                ? (ticket['totalPrice'] as int).toDouble()
                                : (ticket['totalPrice'] as num?)?.toDouble() ??
                                    0.0,
                            passengers: (ticket['passengers'] as List?)
                                    ?.map((p) =>
                                        Map<String, String>.from(p as Map))
                                    .toList() ??
                                [],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      margin: const EdgeInsets.only(bottom: 18),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ticket['logo'] != null &&
                                        ticket['logo'].toString().isNotEmpty
                                    ? Image.network(ticket['logo'],
                                        height: 32,
                                        width: 32,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.train,
                                                    size: 32,
                                                    color: Color(0xFF2563EB)))
                                    : const Icon(Icons.train,
                                        size: 32, color: Color(0xFF2563EB)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          ticket['trainName'] ??
                                              ticket['name'] ??
                                              '',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                      Text(
                                          ticket['trainClass'] ??
                                              ticket['class'] ??
                                              '',
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(ticket['status'] ?? ''),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    ticket['status'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    ticket['departureStation'] ??
                                        ticket['from'] ??
                                        '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const Icon(Icons.train,
                                    color: Color(0xFF2563EB)),
                                Text(
                                    ticket['arrivalStation'] ??
                                        ticket['to'] ??
                                        '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    ticket['departureTime'] ??
                                        ticket['depart'] ??
                                        '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF2563EB))),
                                Text('Duration ${ticket['duration'] ?? ''}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 15)),
                                Text(
                                    ticket['arrivalTime'] ??
                                        ticket['arrive'] ??
                                        '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF2563EB))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    ticket['departureDate'] ??
                                        (ticket['date'] ?? ''),
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 14)),
                                Text(
                                    ticket['arrivalDate'] ??
                                        (ticket['date'] ?? ''),
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // 'My Ticket' is the second item (index 1)
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst); // Go to Home
          } else if (index == 1) {
            // Already on MyTicketsScreen, do nothing or refresh
          } else if (index == 2) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyWalletScreen()));
          } else if (index == 3) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        AccountScreen(setLocale: (locale) {})));
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
