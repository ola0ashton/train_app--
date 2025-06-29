// ignore_for_file: no_leading_underscores_for_local_identifiers, unnecessary_import

import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'eticket_screen.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'select_trip_to_reschedule_screen.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final String? bookingId;
  final String transactionId;
  final String merchantId;
  final String paymentMethod;
  final String status;
  final String trainName;
  final String trainClass;
  final String departureStation;
  final String arrivalStation;
  final String departureTime;
  final String arrivalTime;
  final String departureDate;
  final String arrivalDate;
  final String duration;
  final double price;
  final double tax;
  final double totalPrice;
  final List<Map<String, String>> passengers;

  const TransactionDetailsScreen({
    super.key,
    this.bookingId,
    required this.transactionId,
    required this.merchantId,
    required this.paymentMethod,
    required this.status,
    required this.trainName,
    required this.trainClass,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureDate,
    required this.arrivalDate,
    required this.duration,
    required this.price,
    required this.tax,
    required this.totalPrice,
    required this.passengers,
  });

  String _generateBookingId() {
    // Simple random booking ID generator
    return List.generate(6, (index) => String.fromCharCode(65 + (DateTime.now().millisecondsSinceEpoch + index) % 26)).join();
  }

  String _barcodeData() {
    final data = {
      'bookingId': bookingId ?? _generateBookingId(),
      'trainName': trainName,
      'trainClass': trainClass,
      'departureStation': departureStation,
      'arrivalStation': arrivalStation,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'departureDate': departureDate,
      'arrivalDate': arrivalDate,
      'duration': duration,
      'passengers': passengers,
    };
    return jsonEncode(data);
  }

  @override
  Widget build(BuildContext context) {
    final _bookingId = bookingId ?? _generateBookingId();
    final nairaFormat = NumberFormat.currency(locale: 'en_NG', symbol: '₦');

    Future<void> saveTransaction() async {
      final doc = FirebaseFirestore.instance.collection('bookings').doc(_bookingId);
      final snapshot = await doc.get();
      if (!snapshot.exists) {
        await doc.set({
          'bookingId': _bookingId,
          'transactionId': transactionId,
          'merchantId': merchantId,
          'paymentMethod': paymentMethod,
          'status': status,
          'trainName': trainName,
          'trainClass': trainClass,
          'departureStation': departureStation,
          'arrivalStation': arrivalStation,
          'departureTime': departureTime,
          'arrivalTime': arrivalTime,
          'departureDate': departureDate,
          'arrivalDate': arrivalDate,
          'duration': duration,
          'price': price,
          'tax': tax,
          'totalPrice': totalPrice,
          'passengers': passengers,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }

    return FutureBuilder<void>(
      future: saveTransaction(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            backgroundColor: const Color(0xFF2563EB),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Transaction Details', style: TextStyle(color: Colors.white, fontFamily: 'Urbanist-Bold')),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Booking ID:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Row(
                      children: [
                        Text(_bookingId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _bookingId));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking ID copied!')));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Column(
                      children: [
                        BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: _barcodeData(),
                          width: 320,
                          height: 100,
                          drawText: false,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You are obligated to present your e-boarding pass when boarding a train trip or during inspecting train passengers.',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text('Trip Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (passengers.isNotEmpty && passengers[0]['logo'] != null && passengers[0]['logo']!.isNotEmpty)
                              Image.network(passengers[0]['logo']!, height: 32, width: 32, errorBuilder: (context, error, stackTrace) => const Icon(Icons.train, size: 32, color: Color(0xFF2563EB))),
                            if (!(passengers.isNotEmpty && passengers[0]['logo'] != null && passengers[0]['logo']!.isNotEmpty))
                              const Icon(Icons.train, size: 32, color: Color(0xFF2563EB)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(trainName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text(trainClass, style: const TextStyle(color: Colors.grey, fontSize: 15)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(departureStation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Icon(Icons.train, color: Color(0xFF2563EB)),
                            Text(arrivalStation, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(departureTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('Duration $duration', style: const TextStyle(color: Colors.grey, fontSize: 15)),
                            Text(arrivalTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(departureDate, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            Text(arrivalDate, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text('Payment Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Price (Adult x ${passengers.length})', style: const TextStyle(fontSize: 16)),
                            Text(nairaFormat.format(price), style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax', style: TextStyle(fontSize: 16)),
                            Text(nairaFormat.format(tax), style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(nairaFormat.format(totalPrice), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Status', style: TextStyle(fontSize: 16)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: status == 'Paid' ? const Color(0xFFD1FAE5) : Colors.red[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(status, style: TextStyle(color: status == 'Paid' ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Booking ID', style: TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                Text(_bookingId, style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: _bookingId));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Booking ID copied!')));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Transaction ID', style: TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                Text(transactionId, style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: transactionId));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction ID copied!')));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Merchant ID', style: TextStyle(fontSize: 16)),
                            Row(
                              children: [
                                Text(merchantId, style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.copy, size: 18),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: merchantId));
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Merchant ID copied!')));
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Payment Method', style: TextStyle(fontSize: 16)),
                            Text(paymentMethod, style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text('Passenger(s)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(height: 8),
              ...passengers.asMap().entries.map((entry) {
                final idx = entry.key + 1;
                final dynamic raw = entry.value;
                final Map<String, String> p = raw is Map<String, String>
                    ? raw
                    : raw.map((key, value) => MapEntry(key.toString(), value?.toString() ?? ''));
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person, color: Color(0xFF2563EB)),
                              const SizedBox(width: 8),
                              Text('Passenger $idx', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.black54),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Full Name', style: TextStyle(fontSize: 15)),
                              Text(p['name'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ID Type', style: TextStyle(fontSize: 15)),
                              Text(p['idType'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ID Number', style: TextStyle(fontSize: 15)),
                              Text(p['idNumber'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Passenger Type', style: TextStyle(fontSize: 15)),
                              Text(p['type'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Seat', style: TextStyle(fontSize: 15)),
                              Text(p['seat'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ETicketScreen(
                                      bookingId: _bookingId,
                                      trainName: trainName,
                                      trainClass: trainClass,
                                      departureStation: departureStation,
                                      arrivalStation: arrivalStation,
                                      departureTime: departureTime,
                                      arrivalTime: arrivalTime,
                                      departureDate: departureDate,
                                      arrivalDate: arrivalDate,
                                      duration: duration,
                                      passenger: p,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Show E-Ticket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
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
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Unavailable'),
                              content: const Text('Beta version only'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text('Order Train Food'),
                      ),
                    ),
                    const SizedBox(height: 12),
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SelectTripToRescheduleScreen(),
                            ),
                          );
                        },
                        child: const Text('Re-Schedule Ticket'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F6FF),
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {},
                        child: const Text('Cancel Ticket'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
} 