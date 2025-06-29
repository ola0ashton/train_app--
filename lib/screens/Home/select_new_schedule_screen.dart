// ignore_for_file: use_super_parameters, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'review_reschedule_summary_screen.dart';
import 'select_seat_screen.dart';
import 'select_departure_date_screen.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import your train data source and ReviewSummaryScreen as needed

class SelectNewScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> oldTrip;
  const SelectNewScheduleScreen({Key? key, required this.oldTrip}) : super(key: key);

  @override
  State<SelectNewScheduleScreen> createState() => _SelectNewScheduleScreenState();
}

class _SelectNewScheduleScreenState extends State<SelectNewScheduleScreen> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> availableTrains = [];
  List<Map<String, dynamic>> userBookings = [];
  bool showMyBookings = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() { isLoading = true; });
    await Future.wait([
      _fetchAvailableTrains(),
      _fetchUserBookings(),
    ]);
    setState(() { isLoading = false; });
  }

  Future<void> _fetchAvailableTrains() async {
    // Try to fetch from Firestore 'trains' collection
    try {
      final query = await FirebaseFirestore.instance.collection('trains')
        .where('departureStation', isEqualTo: widget.oldTrip['departureStation'])
        .where('arrivalStation', isEqualTo: widget.oldTrip['arrivalStation'])
        .where('departureDate', isEqualTo: DateFormat('d MMM yyyy').format(selectedDate))
        .get();
      availableTrains = query.docs.map((doc) => doc.data()).toList();
      if (availableTrains.isEmpty) {
        // fallback to mock data
        availableTrains = _generateRandomResults(selectedDate);
      }
    } catch (e) {
      // fallback to mock data
      availableTrains = _generateRandomResults(selectedDate);
    }
  }

  Future<void> _fetchUserBookings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final query = await FirebaseFirestore.instance.collection('bookings')
      .where('userId', isEqualTo: user.uid)
      .where('departureStation', isEqualTo: widget.oldTrip['departureStation'])
      .where('arrivalStation', isEqualTo: widget.oldTrip['arrivalStation'])
      .where('departureDate', isEqualTo: DateFormat('d MMM yyyy').format(selectedDate))
      .get();
    userBookings = query.docs.map((doc) => doc.data()).toList();
  }

  List<Map<String, dynamic>> _generateRandomResults(DateTime date) {
    // Copied from SearchResultsScreen
    final random = Random();
    final trainNames = [
      'Lagos-Ibadan Express',
      'Warri-Itakpe Express',
      'Abuja-Kaduna Express',
      'Port Harcourt-Maiduguri Express',
      'Lagos-Kano Express',
      'Calabar-Lagos Express',
      'Kano-Port Harcourt Express',
      'Maiduguri-Lagos Express',
      'Enugu-Port Harcourt Express',
      'Kaduna-Lagos Express',
      'Abuja-Lagos Express',
      'Lagos-Abuja Express',
      'Port Harcourt-Abuja Express',
      'Kano-Lagos Express',
      'Benin-Lagos Express',
      'Ibadan-Abuja Express',
      'Kano-Abuja Express',
      'Port Harcourt-Lagos Express',
      'Maiduguri-Abuja Express',
      'Calabar-Port Harcourt Express',
      'Enugu-Abuja Express',
      'Warri-Lagos Express',
      'Kaduna-Port Harcourt Express',
      'Benin-Abuja Express',
      'Abuja-Jos Express',
      'Lagos-Akure Express',
      'Port Harcourt-Yenagoa Express',
      'Kano-Sokoto Express',
      'Abuja-Makurdi Express',
      'Lagos-Abeokuta Express',
      'Port Harcourt-Uyo Express',
      'Kano-Gombe Express',
      'Abuja-Lokoja Express',
      'Lagos-Ilorin Express',
      'Port Harcourt-Owerri Express',
      'Kano-Katsina Express',
      'Abuja-Minna Express',
      'Lagos-Ondo Express',
      'Port Harcourt-Asaba Express',
      'Kano-Bauchi Express',
      'Abuja-Yola Express',
      'Lagos-Osun Express',
      'Port Harcourt-Aba Express',
      'Kano-Jalingo Express',
      'Abuja-Birnin Kebbi Express',
      'Lagos-Ekiti Express',
      'Port Harcourt-Akwa Ibom Express',
      'Kano-Dutse Express',
      'Abuja-Ogoja Express',
      'Lagos-Edo Express',
      'Port Harcourt-Bayelsa Express',
      'Kano-Damaturu Express',
    ];
    final logos = [
      'https://upload.wikimedia.org/wikipedia/commons/8/89/Amtrak_logo.svg',
      'https://upload.wikimedia.org/wikipedia/commons/3/3e/PRR_logo.svg',
      'https://upload.wikimedia.org/wikipedia/commons/7/7e/Kansas_City_Southern_logo.svg',
      'https://upload.wikimedia.org/wikipedia/commons/6/6b/NYC_Transit_logo.png',
      'https://upload.wikimedia.org/wikipedia/commons/2/2c/Union_Pacific_Logo.png',
      'https://upload.wikimedia.org/wikipedia/commons/4/4a/BNSF_logo.svg',
      'https://upload.wikimedia.org/wikipedia/commons/7/7d/Brightline_logo.svg',
      'https://upload.wikimedia.org/wikipedia/commons/7/7e/Caltrain_logo.svg',
      'https://upload.wikimedia.org/wikipedia/commons/7/7e/Metra_logo.svg',
    ];
    final classes = ['Economy', 'Business', 'Executive'];
    final from = widget.oldTrip['departureStation'] ?? 'Apex Square';
    final to = widget.oldTrip['arrivalStation'] ?? 'Proxima';
    final List<Map<String, dynamic>> trains = [];
    for (int i = 0; i < 5; i++) {
      final idx = random.nextInt(trainNames.length);
      final logoIdx = idx < logos.length ? idx : 0;
      final startHour = 6 + random.nextInt(10); // 6:00 to 15:00
      final startMinute = [0, 15, 30, 45][random.nextInt(4)];
      final durationMin = 60 + random.nextInt(61); // 1h to 2h
      final depart = DateTime(date.year, date.month, date.day, startHour, startMinute);
      final arrive = depart.add(Duration(minutes: durationMin));
      final price = 5000 + random.nextInt(5001); // ₦5,000 to ₦10,000
      trains.add({
        'logo': logos[logoIdx],
        'trainName': trainNames[idx],
        'trainClass': classes[random.nextInt(classes.length)],
        'price': price.toDouble(),
        'status': 'Available',
        'departureStation': from,
        'arrivalStation': to,
        'departureTime': DateFormat('HH:mm').format(depart),
        'arrivalTime': DateFormat('HH:mm').format(arrive),
        'duration': '${(durationMin ~/ 60)}h ${durationMin % 60}m',
        'departureDate': DateFormat('d MMM yyyy').format(date),
        'arrivalDate': DateFormat('d MMM yyyy').format(date),
      });
    }
    return trains;
  }

  Future<void> _pickDate() async {
    final picked = await Navigator.push<DateTime>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectDepartureDateScreen(initialDate: selectedDate),
      ),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
      await _fetchData();
    }
  }

  void _onTrainSelected(Map<String, dynamic> newTrip) async {
    // Mock contact and passenger data
    final contact = {
      'name': 'Andrew Ainsley',
      'email': 'andrew.ainsley@you.com',
      'phone': '+1 111 467 378 399',
    };
    final passengers = [
      {'name': 'Andrew Ainsley', 'carriage': 2, 'seat': '', 'type': 'Adult'},
    ];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SelectSeatScreen(
          train: newTrip,
          passengers: passengers,
          contactName: contact['name']!,
          contactEmail: contact['email']!,
          contactPhone: contact['phone']!,
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      // result should contain selectedCarriage, selectedSeat, passengers
      final selectedPassengers = result['passengers'] ?? passengers;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReviewRescheduleSummaryScreen(
            oldTrip: widget.oldTrip,
            newTrip: newTrip,
            passengers: selectedPassengers,
            contact: contact,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final trainsToShow = showMyBookings ? userBookings : availableTrains;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Select New Schedule', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                const Text('Departure Date:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _pickDate,
                  child: Text(DateFormat('d MMM yyyy').format(selectedDate), style: const TextStyle(color: Colors.white)),
                ),
                const Spacer(),
                ToggleButtons(
                  isSelected: [!showMyBookings, showMyBookings],
                  onPressed: (index) {
                    setState(() { showMyBookings = index == 1; });
                  },
                  children: const [
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('All Available Trains')),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('My Booked Trains')),
                  ],
                ),
              ],
            ),
          ),
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (!isLoading)
            Expanded(
              child: trainsToShow.isEmpty
                  ? const Center(child: Text('No trains found for this date.'))
                  : ListView.builder(
                      itemCount: trainsToShow.length,
                      itemBuilder: (context, index) {
                        final train = trainsToShow[index];
                        return GestureDetector(
                          onTap: () => _onTrainSelected(train),
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      train['logo'] != null && train['logo'].toString().isNotEmpty
                                          ? Image.network(train['logo'], height: 32, width: 32, errorBuilder: (context, error, stackTrace) => const Icon(Icons.train, size: 32, color: Color(0xFF2563EB)))
                                          : const Icon(Icons.train, size: 32, color: Color(0xFF2563EB)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(train['trainName'] ?? train['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                            Text(train['trainClass'] ?? train['class'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 15)),
                                          ],
                                        ),
                                      ),
                                      Text(train['status'] ?? 'Available', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      Text('₦${(train['price'] is num) ? train['price'].toStringAsFixed(2) : train['price'] ?? ''}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
                                    ],
                                  ),
                                  const Divider(height: 28),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(train['departureStation'] ?? train['from'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const Icon(Icons.train, color: Color(0xFF2563EB)),
                                      Text(train['arrivalStation'] ?? train['to'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(train['departureTime'] ?? train['depart'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB))),
                                      Text('Duration ${train['duration'] ?? ''}', style: const TextStyle(color: Colors.grey, fontSize: 15)),
                                      Text(train['arrivalTime'] ?? train['arrive'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2563EB))),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(train['departureDate'] ?? (train['date'] != null ? DateFormat('d MMM yyyy').format(train['date']) : ''), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                      Text(train['arrivalDate'] ?? (train['date'] != null ? DateFormat('d MMM yyyy').format(train['date']) : ''), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
} 