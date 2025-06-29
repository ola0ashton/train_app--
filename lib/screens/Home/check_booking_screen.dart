// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction_details_screen.dart';

class CheckBookingScreen extends StatefulWidget {
  const CheckBookingScreen({Key? key}) : super(key: key);

  @override
  State<CheckBookingScreen> createState() => _CheckBookingScreenState();
}

class _CheckBookingScreenState extends State<CheckBookingScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isButtonEnabled = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkBooking() async {
    setState(() {
      _isLoading = true;
    });
    final bookingId = _controller.text.trim();
    try {
      final query = await FirebaseFirestore.instance
          .collection('bookings')
          .where('bookingId', isEqualTo: bookingId)
          .limit(1)
          .get();
      setState(() {
        _isLoading = false;
      });
      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailsScreen(
              bookingId: data['bookingId'],
              transactionId: data['transactionId'],
              merchantId: data['merchantId'],
              paymentMethod: data['paymentMethod'],
              status: data['status'],
              trainName: data['trainName'],
              trainClass: data['trainClass'],
              departureStation: data['departureStation'],
              arrivalStation: data['arrivalStation'],
              departureTime: data['departureTime'],
              arrivalTime: data['arrivalTime'],
              departureDate: data['departureDate'],
              arrivalDate: data['arrivalDate'],
              duration: data['duration'],
              price: (data['price'] is int) ? (data['price'] as int).toDouble() : (data['price'] as num?)?.toDouble() ?? 0.0,
              tax: (data['tax'] is int) ? (data['tax'] as int).toDouble() : (data['tax'] as num?)?.toDouble() ?? 0.0,
              totalPrice: (data['totalPrice'] is int) ? (data['totalPrice'] as int).toDouble() : (data['totalPrice'] as num?)?.toDouble() ?? 0.0,
              passengers: (data['passengers'] as List?)?.map((p) => Map<String, String>.from(p as Map)).toList() ?? [],
            ),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Not Found'),
            content: const Text('No booking found with that ID.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to fetch booking: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
        title: const Text('Check Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booking ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ex. VZ56JRX',
                hintStyle: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 18),
                border: UnderlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 24.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1746D6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _isButtonEnabled && !_isLoading ? _checkBooking : null,
            child: const Text('Check', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
} 