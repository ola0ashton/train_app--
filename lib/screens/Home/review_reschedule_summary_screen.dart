// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class ReviewRescheduleSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> oldTrip;
  final Map<String, dynamic> newTrip;
  final List<Map<String, dynamic>> passengers;
  final Map<String, String> contact;
  const ReviewRescheduleSummaryScreen({Key? key, required this.oldTrip, required this.newTrip, required this.passengers, required this.contact}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final oldPrice = oldTrip['price'] ?? 40.0;
    final newPrice = newTrip['price'] ?? 42.0;
    final priceDiff = (newPrice - oldPrice).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Review Summary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // New Departure Train
          const Text('New Departure Train', style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.train, size: 32, color: Color(0xFF2563EB)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(newTrip['trainName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(newTrip['trainClass'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 15)),
                          ],
                        ),
                      ),
                      const Text('Available', style: TextStyle(color: Colors.green)),
                      const SizedBox(width: 8),
                      Text(' 24${newTrip['price']?.toStringAsFixed(2) ?? ''}', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(newTrip['departureStation'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Icon(Icons.train, color: Color(0xFF2563EB)),
                      Text(newTrip['arrivalStation'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(newTrip['departureTime'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Duration ${newTrip['duration'] ?? ''}', style: const TextStyle(color: Colors.grey)),
                      Text(newTrip['arrivalTime'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(newTrip['departureDate'] ?? '', style: const TextStyle(color: Colors.grey)),
                      Text(newTrip['arrivalDate'] ?? '', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Contact Details
          const Text('Contact Details', style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Full Name'), Text(contact['name'] ?? '')]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Email'), Text(contact['email'] ?? '')]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Phone Number'), Text(contact['phone'] ?? '')]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Passenger(s)
          const Text('Passenger(s)', style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(32),
                  1: FlexColumnWidth(),
                  2: FixedColumnWidth(64),
                  3: FixedColumnWidth(48),
                },
                children: [
                  const TableRow(
                    children: [
                      Text('No.', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Carriage', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Seat', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ...List.generate(passengers.length, (i) => TableRow(
                    children: [
                      Text('${i + 1}.'),
                      Text(passengers[i]['name'] ?? ''),
                      Text(passengers[i]['carriage'].toString()),
                      Text(passengers[i]['seat'] ?? ''),
                    ],
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Payment Method
          const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Color(0xFF2563EB)),
                  const SizedBox(width: 12),
                  const Text('My Wallet'),
                  const Spacer(),
                  TextButton(onPressed: () {}, child: const Text('Change')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Price Details
          const Text('Price Details', style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Old Ticket Price (Adult x 1)'), Text(' 24${oldPrice.toStringAsFixed(2)}')]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('New Ticket Price (Adult x 1)'), Text(' 24${newPrice.toStringAsFixed(2)}')]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Price Conversion Difference'), Text(' 24$priceDiff')]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Price'), Text(' 24$priceDiff', style: const TextStyle(fontWeight: FontWeight.bold))]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('- The remaining price shortfall will be charged from your account.'),
          const Text('- Discounts cannot be used for re-scheduled tickets, and paid taxes will not be returned to your account.'),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF2563EB), size: 64),
                      const SizedBox(height: 16),
                      const Text('Re-Schedule Trip Successful!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2563EB))),
                      const SizedBox(height: 12),
                      const Text('You have successfully made a payment transaction and re-scheduled a ticket. You can access tickets through the My Ticket menu.', textAlign: TextAlign.center),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          Navigator.pop(context); // Go back to previous screen
                        },
                        child: const Text('View Transaction'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        child: const Text('Back to Home', style: TextStyle(color: Color(0xFF2563EB))),
                      ),
                    ],
                  ),
                ),
              );
            },
            child: const Text('Confirm New Schedule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
    );
  }
} 