// ignore_for_file: prefer_const_declarations, unused_local_variable, use_super_parameters

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'sort_filter_modal.dart';
import 'booking_details_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  final String origin;
  final String destination;
  final DateTime departureDate;
  final String trainClass;
  final int adults;

  const SearchResultsScreen({
    Key? key,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.trainClass,
    required this.adults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final results = _generateRandomResults(departureDate);
    final days = List.generate(5, (i) => departureDate.add(Duration(days: i - 2)));
    final selectedDayIndex = 2;
    final trainList = [
      {'name': 'Lagos-Ibadan Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6e/Alaska_Railroad_logo.png'},
      {'name': 'Warri-Itakpe Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/8/89/Amtrak_logo.svg'},
      {'name': 'Abuja-Kaduna Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2d/Chicago_and_North_Western_Logo.png'},
      {'name': 'Port Harcourt-Maiduguri Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Kansas_City_Southern_logo.svg'},
      {'name': 'Lagos-Kano Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2e/Milwaukee_Road_logo.png'},
      {'name': 'Calabar-Lagos Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6b/NYC_Transit_logo.png'},
      {'name': 'Kano-Port Harcourt Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2a/New_Haven_McGinnis_logo.png'},
      {'name': 'Maiduguri-Lagos Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6a/New_York_Central_Railroad_logo.png'},
      {'name': 'Enugu-Port Harcourt Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2b/Pacific_Electric_Railway_logo.png'},
      {'name': 'Kaduna-Lagos Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/3/3e/PRR_logo.svg'},
      {'name': 'Abuja-Lagos Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2e/Tri-Rail_logo.png'},
      {'name': 'Lagos-Abuja Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2c/Union_Pacific_Logo.png'},
      {'name': 'Port Harcourt-Abuja Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Western_Pacific_Logo.png'},
      {'name': 'Kano-Lagos Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Wisconsin_and_Southern_Railroad_logo.png'},
      {'name': 'Benin-Lagos Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6e/Alaska_Railroad_logo.png'},
      {'name': 'Ibadan-Abuja Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/8/89/Amtrak_logo.svg'},
      {'name': 'Kano-Abuja Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2d/Chicago_and_North_Western_Logo.png'},
      {'name': 'Port Harcourt-Lagos Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Kansas_City_Southern_logo.svg'},
      {'name': 'Maiduguri-Abuja Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2e/Milwaukee_Road_logo.png'},
      {'name': 'Calabar-Port Harcourt Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6b/NYC_Transit_logo.png'},
      {'name': 'Enugu-Abuja Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2a/New_Haven_McGinnis_logo.png'},
      {'name': 'Warri-Lagos Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6a/New_York_Central_Railroad_logo.png'},
      {'name': 'Kaduna-Port Harcourt Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2b/Pacific_Electric_Railway_logo.png'},
      {'name': 'Benin-Abuja Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/3/3e/PRR_logo.svg'},
      {'name': 'Abuja-Jos Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6e/Alaska_Railroad_logo.png'},
      {'name': 'Lagos-Akure Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/8/89/Amtrak_logo.svg'},
      {'name': 'Port Harcourt-Yenagoa Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2d/Chicago_and_North_Western_Logo.png'},
      {'name': 'Kano-Sokoto Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Kansas_City_Southern_logo.svg'},
      {'name': 'Abuja-Makurdi Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2e/Milwaukee_Road_logo.png'},
      {'name': 'Lagos-Abeokuta Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6b/NYC_Transit_logo.png'},
      {'name': 'Port Harcourt-Uyo Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2a/New_Haven_McGinnis_logo.png'},
      {'name': 'Kano-Gombe Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6a/New_York_Central_Railroad_logo.png'},
      {'name': 'Abuja-Lokoja Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2b/Pacific_Electric_Railway_logo.png'},
      {'name': 'Lagos-Ilorin Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/3/3e/PRR_logo.svg'},
      {'name': 'Port Harcourt-Owerri Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2e/Tri-Rail_logo.png'},
      {'name': 'Kano-Katsina Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2c/Union_Pacific_Logo.png'},
      {'name': 'Abuja-Minna Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Western_Pacific_Logo.png'},
      {'name': 'Lagos-Ondo Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Wisconsin_and_Southern_Railroad_logo.png'},
      {'name': 'Port Harcourt-Asaba Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6e/Alaska_Railroad_logo.png'},
      {'name': 'Kano-Bauchi Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/8/89/Amtrak_logo.svg'},
      {'name': 'Abuja-Yola Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2d/Chicago_and_North_Western_Logo.png'},
      {'name': 'Lagos-Osun Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/7/7e/Kansas_City_Southern_logo.svg'},
      {'name': 'Port Harcourt-Aba Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2e/Milwaukee_Road_logo.png'},
      {'name': 'Kano-Jalingo Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6b/NYC_Transit_logo.png'},
      {'name': 'Abuja-Birnin Kebbi Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2a/New_Haven_McGinnis_logo.png'},
      {'name': 'Lagos-Ekiti Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/6/6a/New_York_Central_Railroad_logo.png'},
      {'name': 'Port Harcourt-Akwa Ibom Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2b/Pacific_Electric_Railway_logo.png'},
      {'name': 'Kano-Dutse Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/3/3e/PRR_logo.svg'},
      {'name': 'Abuja-Ogoja Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2e/Tri-Rail_logo.png'},
      {'name': 'Lagos-Edo Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2c/Union_Pacific_Logo.png'},
      {'name': 'Port Harcourt-Bayelsa Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Western_Pacific_Logo.png'},
      {'name': 'Kano-Damaturu Express', 'logo': 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Wisconsin_and_Southern_Railroad_logo.png'},
    ];
    Widget buildResultCard(Map<String, dynamic> train) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDetailsScreen(train: train),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
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
                          train['name'],
                          style: const TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(train['class'], style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                  Text(
                    train['price'],
                    style: const TextStyle(color: Color(0xFF2563EB), fontFamily: 'Urbanist-Bold', fontSize: 18),
                      ),
                      const Text('Available', style: TextStyle(color: Colors.green, fontFamily: 'Urbanist-Bold')),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(train['from'], style: const TextStyle(fontFamily: 'Urbanist-Bold')),
                  const Icon(Icons.train, color: Color(0xFF2563EB)),
                  Text(train['to'], style: const TextStyle(fontFamily: 'Urbanist-Bold')),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(train['depart'], style: const TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                  Text('Duration ${train['duration']}', style: const TextStyle(color: Colors.grey)),
                  Text(train['arrive'], style: const TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('d MMM yyyy').format(train['date']), style: const TextStyle(color: Colors.grey)),
                  Text(DateFormat('d MMM yyyy').format(train['date']), style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Search Results', style: TextStyle(color: Colors.white, fontFamily: 'Urbanist-Bold')),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => SortFilterModal(
                  initialValues: const {},
                  trainList: trainList,
                ),
              );
              // TODO: Apply filter/sort to results using 'result' if needed
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(days.length, (i) {
                final day = days[i];
                final isSelected = i == selectedDayIndex;
                return Column(
                  children: [
                    Text(
                      DateFormat('E').format(day),
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF2563EB) : Colors.black,
                        fontFamily: 'Urbanist-Bold',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d').format(day),
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF2563EB) : Colors.black,
                        fontFamily: 'Urbanist-Bold',
                        fontSize: 18,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        height: 3,
                        width: 32,
                        color: const Color(0xFF2563EB),
                      ),
                  ],
                );
              }),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              itemCount: results.length,
              itemBuilder: (context, index) => buildResultCard(results[index]),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _generateRandomResults(DateTime date) {
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
    final from = origin;
    final to = destination;
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
        'name': trainNames[idx],
        'class': classes[random.nextInt(classes.length)],
        'price': '₦${NumberFormat('#,###').format(price)}.00',
        'from': from,
        'to': to,
        'depart': DateFormat('HH:mm').format(depart),
        'arrive': DateFormat('HH:mm').format(arrive),
        'duration': '${(durationMin ~/ 60)}h ${durationMin % 60}m',
        'date': date,
      });
    }
    return trains;
  }
} 