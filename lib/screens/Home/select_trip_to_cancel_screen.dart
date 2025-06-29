// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cancel_trip_screen.dart';

class SelectTripToCancelScreen extends StatefulWidget {
  const SelectTripToCancelScreen({Key? key}) : super(key: key);

  @override
  State<SelectTripToCancelScreen> createState() => _SelectTripToCancelScreenState();
}

class _SelectTripToCancelScreenState extends State<SelectTripToCancelScreen> {
  late Future<List<Map<String, dynamic>>> _futureTrips;

  @override
  void initState() {
    super.initState();
    _futureTrips = _fetchTrips();
  }

  Future<List<Map<String, dynamic>>> _fetchTrips() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final query = await FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();
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
        title: const Text('Select Trip to Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CancelTripScreen(trip: trip),
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
              );
            },
          );
        },
      ),
    );
  }
} 