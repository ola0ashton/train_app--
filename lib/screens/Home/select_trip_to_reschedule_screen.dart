// ignore_for_file: unused_import, use_super_parameters

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_details_screen.dart';
import 'select_new_schedule_screen.dart';

class SelectTripToRescheduleScreen extends StatefulWidget {
  const SelectTripToRescheduleScreen({Key? key}) : super(key: key);

  @override
  State<SelectTripToRescheduleScreen> createState() => _SelectTripToRescheduleScreenState();
}

class _SelectTripToRescheduleScreenState extends State<SelectTripToRescheduleScreen> {
  late Future<List<Map<String, dynamic>>> _futureTrips;

  @override
  void initState() {
    super.initState();
    _futureTrips = _fetchTrips();
  }

  Future<List<Map<String, dynamic>>> _fetchTrips() async {
    // You may want to filter by user ID if available
    final query = await FirebaseFirestore.instance.collection('bookings').orderBy('createdAt', descending: true).get();
    return query.docs.map((doc) => doc.data()).toList();
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
        title: const Text('Select Trip to Re-Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futureTrips,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No trips found.'));
          }
          final trips = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectNewScheduleScreen(oldTrip: trip),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  margin: const EdgeInsets.only(bottom: 18),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (trip['passengers'] != null && trip['passengers'] is List && trip['passengers'].isNotEmpty && trip['passengers'][0]['logo'] != null && trip['passengers'][0]['logo'].toString().isNotEmpty)
                              Image.network(trip['passengers'][0]['logo'], height: 32, width: 32, errorBuilder: (context, error, stackTrace) => const Icon(Icons.train, size: 32, color: Color(0xFF2563EB))),
                            if (!(trip['passengers'] != null && trip['passengers'] is List && trip['passengers'].isNotEmpty && trip['passengers'][0]['logo'] != null && trip['passengers'][0]['logo'].toString().isNotEmpty))
                              const Icon(Icons.train, size: 32, color: Color(0xFF2563EB)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(trip['trainName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text(trip['trainClass'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 15)),
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
                            Text(trip['departureStation'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const Icon(Icons.train, color: Color(0xFF2563EB)),
                            Text(trip['arrivalStation'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(trip['departureTime'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB))),
                            Text('Duration ${trip['duration'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 15)),
                            Text(trip['arrivalTime'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(trip['departureDate'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                            Text(trip['arrivalDate'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 14)),
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
      ),
    );
  }
} 