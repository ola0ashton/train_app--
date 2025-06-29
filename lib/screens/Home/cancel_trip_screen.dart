import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CancelTripScreen extends StatefulWidget {
  final Map<String, dynamic> trip;
  const CancelTripScreen({super.key, required this.trip});

  @override
  State<CancelTripScreen> createState() => _CancelTripScreenState();
}

class _CancelTripScreenState extends State<CancelTripScreen> {
  String? selectedReason;
  bool isCancelling = false;

  final List<String> reasons = [
    'Sudden change in plans',
    'Weather conditions',
    'Health concerns',
    'Budget constraints',
    'Travel restrictions',
    'Unforeseen circumstances',
    'Mechanical issues',
    'Personal preferences',
    'Another reason',
  ];

  Future<void> _cancelTrip() async {
    if (selectedReason == null) return;
    setState(() { isCancelling = true; });
    final bookingId = widget.trip['bookingId'];
    if (bookingId == null) return;
    await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
      'status': 'Cancelled',
      'cancellationReason': selectedReason,
      'cancellationDate': DateTime.now().toIso8601String(),
    });
    setState(() { isCancelling = false; });
    _showSuccessModal();
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Confirm Cancellation', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to cancel the trip?\n\nOnly 80% of funds will be returned to your account based on our terms and policies.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Don\'t Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            onPressed: () {
              Navigator.pop(context);
              _cancelTrip();
            },
            child: const Text('Yes, Cancel My Trip'),
          ),
        ],
      ),
    );
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF5A8BFF), Color(0xFF233A7D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Color(0xFF2563EB), size: 40),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Cancel Trip Successful!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2563EB))),
              const SizedBox(height: 12),
              const Text('You have successfully canceled the trip. 80% of the funds have been returned to your account.', textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to trip list
                  Navigator.pop(context); // Go back to home
                },
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Cancel Trip', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Trip Details', style: TextStyle(fontWeight: FontWeight.bold)),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      trip['logo'] != null && trip['logo'].toString().isNotEmpty
                          ? Image.network(trip['logo'], height: 32, width: 32, errorBuilder: (context, error, stackTrace) => const Icon(Icons.train, size: 32, color: Color(0xFF2563EB)))
                          : const Icon(Icons.train, size: 32, color: Color(0xFF2563EB)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trip['trainName'] ?? trip['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            Text(trip['trainClass'] ?? trip['class'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 15)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: (trip['status'] ?? '') == 'Paid' ? const Color(0xFFD1FAE5) : Colors.red[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(trip['status'] ?? '', style: TextStyle(color: (trip['status'] ?? '') == 'Paid' ? Colors.blue : Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(trip['departureStation'] ?? trip['from'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Icon(Icons.train, color: Color(0xFF2563EB)),
                      Text(trip['arrivalStation'] ?? trip['to'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(trip['departureTime'] ?? trip['depart'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB))),
                      Text('Duration ${trip['duration'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 15)),
                      Text(trip['arrivalTime'] ?? trip['arrive'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(trip['departureDate'] ?? (trip['date'] ?? ''), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      Text(trip['arrivalDate'] ?? (trip['date'] ?? ''), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Reason for Cancellation:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...reasons.map((reason) => RadioListTile<String>(
                value: reason,
                groupValue: selectedReason,
                onChanged: isCancelling ? null : (v) => setState(() => selectedReason = v),
                title: Text(reason),
              )),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: isCancelling || selectedReason == null ? null : _showConfirmDialog,
            child: isCancelling
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Cancel Trip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ],
      ),
    );
  }
} 