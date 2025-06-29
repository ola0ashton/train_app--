import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'confirm_pin_screen.dart';

class ReviewSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> train;
  final List<Map<String, dynamic>> passengers;
  final int carriage;
  final String seat;
  final String paymentMethod;
  final String contactName;
  final String contactEmail;
  final String contactPhone;

  const ReviewSummaryScreen({
    super.key,
    required this.train,
    required this.passengers,
    required this.carriage,
    required this.seat,
    required this.paymentMethod,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
  });

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
        title: const Text('Review Summary', style: TextStyle(color: Colors.white, fontFamily: 'Urbanist-Bold')),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Departure Train
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (train['logo'] != null)
                          Image.network(
                            train['logo'],
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.train, color: Colors.white),
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                train['name'] ?? 'Train',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(train['class'] ?? '', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        const Text('Available', style: TextStyle(color: Colors.green)),
                        const SizedBox(width: 8),
                        Text(
                          train['price'] ?? '',
                          style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(train['from'] ?? '', style: const TextStyle(fontFamily: 'Urbanist-Bold')),
                        const Icon(Icons.train, color: Color(0xFF2563EB)),
                        Text(train['to'] ?? '', style: const TextStyle(fontFamily: 'Urbanist-Bold')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(train['depart'] ?? '', style: const TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                        Text('Duration ${train['duration'] ?? ''}', style: const TextStyle(color: Colors.grey)),
                        Text(train['arrive'] ?? '', style: const TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          train['date'] != null ? DateFormat('d MMM yyyy').format(train['date']) : '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        Text(
                          train['date'] != null ? DateFormat('d MMM yyyy').format(train['date']) : '',
                          style: const TextStyle(color: Colors.grey),
                        ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Full Name'),
                        Text(contactName),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Email'),
                        Text(contactEmail),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Phone Number'),
                        Text(contactPhone),
                      ],
                    ),
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
                    4: FlexColumnWidth(),
                  },
                  children: [
                    const TableRow(
                      children: [
                        Text('No.', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Carriage', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Seat', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ...List.generate(passengers.length, (i) => TableRow(
                      children: [
                        Text('${i + 1}.'),
                        Text(passengers[i]['name'] ?? ''),
                        Text(carriage.toString()),
                        Text(seat),
                        Text(passengers[i]['passengerType'] ?? ''),
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
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF2563EB)),
                title: Text(paymentMethod, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Change', style: TextStyle(color: Color(0xFF2563EB))),
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
                child: Builder(
                  builder: (context) {
                    // Parse price from train['price'] (e.g. '₦40.00' or '₦41.00')
                    double pricePerAdult = 0.0;
                    double pricePerChild = 0.0;
                    double pricePerInfant = 0.0;
                    try {
                      final priceString = (train['price'] as String).replaceAll(RegExp(r'[^0-9.]'), '');
                      pricePerAdult = double.tryParse(priceString) ?? 0.0;
                      pricePerChild = train['priceChild'] != null ? double.tryParse((train['priceChild'] as String).replaceAll(RegExp(r'[^0-9.]'), '')) ?? pricePerAdult : pricePerAdult;
                      pricePerInfant = train['priceInfant'] != null ? double.tryParse((train['priceInfant'] as String).replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0 : 0.0;
                    } catch (_) {}
                    int numAdults = passengers.where((p) => (p['passengerType'] ?? '').toLowerCase().contains('adult')).length;
                    int numChildren = passengers.where((p) => (p['passengerType'] ?? '').toLowerCase().contains('child')).length;
                    int numInfants = passengers.where((p) => (p['passengerType'] ?? '').toLowerCase().contains('infant')).length;
                    final double subtotal = (numAdults * pricePerAdult) + (numChildren * pricePerChild) + (numInfants * pricePerInfant);
                    final double tax = subtotal * 0.05;
                    final double total = subtotal + tax;
                    String breakdown = [
                      if (numAdults > 0) 'Adult x $numAdults',
                      if (numChildren > 0) 'Child x $numChildren',
                      if (numInfants > 0) 'Infant x $numInfants',
                    ].join(', ');
                    String formatCurrency(double value) => '₦${NumberFormat('#,##0.00').format(value)}';
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Price ($breakdown)'),
                            Text(formatCurrency(subtotal)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tax'),
                            Text(formatCurrency(tax)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Price', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(formatCurrency(total), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConfirmPinScreen(
                        train: train,
                        passengers: passengers,
                        carriage: carriage,
                        seat: seat,
                        paymentMethod: paymentMethod,
                        contactName: contactName,
                        contactEmail: contactEmail,
                        contactPhone: contactPhone,
                      ),
                    ),
                  );
                },
                child: const Text('Confirm Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
