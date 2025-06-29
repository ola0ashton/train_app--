// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'select_seat_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> train;
  const BookingDetailsScreen({super.key, required this.train});

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final _contactNameController = TextEditingController(text: '');
  final _contactEmailController = TextEditingController(text: '');
  final _contactPhoneController = TextEditingController(text: '');

  List<Map<String, dynamic>> passengers = [
    {
      'sameAsContact': false,
      'name': '',
      'idType': null,
      'idNumber': '',
      'passengerType': null,
    },
  ];

  final List<String> idTypes = ['Passport', 'National ID', 'Driver License'];
  final List<String> passengerTypes = ['Adult', 'Child', 'Infant'];

  @override
  Widget build(BuildContext context) {
    final train = widget.train;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Booking Details', style: TextStyle(color: Colors.white, fontFamily: 'Urbanist-Bold')),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF7F8FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text('Trip Details', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 18)),
            ),
            _tripDetailsCard(train),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: const Text('Contact Details', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 18)),
            ),
            _contactDetailsCard(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: const Text('Passenger(s) Details', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 18)),
            ),
            ...List.generate(passengers.length, (i) => _passengerCard(i)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      passengers.add({
                        'sameAsContact': false,
                        'name': '',
                        'idType': null,
                        'idNumber': '',
                        'passengerType': null,
                      });
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Add More Passenger', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_validateFields()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectSeatScreen(
                            train: widget.train,
                            passengers: passengers,
                            contactName: _contactNameController.text,
                            contactEmail: _contactEmailController.text,
                            contactPhone: _contactPhoneController.text,
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill all required fields.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text('Continue', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tripDetailsCard(Map<String, dynamic> train) {
    return Container(
      margin: const EdgeInsets.all(20),
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
    );
  }

  Widget _contactDetailsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name
          const Text('Full Name', style: TextStyle(fontFamily: 'Urbanist-Bold')),
          const SizedBox(height: 4),
          TextField(
            controller: _contactNameController,
            decoration: const InputDecoration(
              hintText: 'yourname',
              hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.normal),
              prefixIcon: Icon(Icons.person_outline),
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
              filled: true,
              fillColor: Color(0xFFF7F8FA),
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
          ),
          const SizedBox(height: 16),
          // Email
          const Text('Email', style: TextStyle(fontFamily: 'Urbanist-Bold')),
          const SizedBox(height: 4),
          TextField(
            controller: _contactEmailController,
            decoration: const InputDecoration(
              hintText: 'yourname@yourdomain.com',
              hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.normal),
              suffixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
              filled: true,
              fillColor: Color(0xFFF7F8FA),
              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
          ),
          const SizedBox(height: 16),
          // Phone Number
          const Text('Phone Number', style: TextStyle(fontFamily: 'Urbanist-Bold')),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // This is a placeholder for the flag dropdown
                    const Icon(Icons.flag, size: 20),
                    const SizedBox(width: 4),
                    const Text('+234', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _contactPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '812 345 6789',
                    hintStyle: TextStyle(color: Colors.grey, fontStyle: FontStyle.normal),
                    border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
                    filled: true,
                    fillColor: Color(0xFFF7F8FA),
                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    suffixIcon: Icon(Icons.phone),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _passengerCard(int index) {
    final passenger = passengers[index];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              const Icon(Icons.event_seat, size: 28),
              const SizedBox(width: 8),
              Text('Passenger ${index + 1}', style: const TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
              const Spacer(),
              if (passengers.length > 1)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      passengers.removeAt(index);
                    });
                  },
                ),
            ],
          ),
          const Divider(),
          Row(
            children: [
              const Text('Same as contact details', style: TextStyle(fontFamily: 'Urbanist-Bold')),
              const Spacer(),
              Switch(
                value: passenger['sameAsContact'] ?? false,
                onChanged: (v) {
                  setState(() {
                    passenger['sameAsContact'] = v;
                    if (v) {
                      passenger['name'] = _contactNameController.text;
                    } else {
                      passenger['name'] = '';
                    }
                  });
                },
              ),
            ],
          ),
          const Divider(),
          TextField(
            enabled: !(passenger['sameAsContact'] ?? false),
            decoration: const InputDecoration(
              hintText: 'Full Name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (v) => passenger['name'] = v,
            controller: passenger['sameAsContact'] ? TextEditingController(text: _contactNameController.text) : null,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: passenger['idType'],
                  items: idTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => passenger['idType'] = v),
                  decoration: const InputDecoration(labelText: 'ID Type'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: 'ID Number'),
                  onChanged: (v) => passenger['idNumber'] = v,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: passenger['passengerType'],
            items: passengerTypes.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => passenger['passengerType'] = v),
            decoration: const InputDecoration(labelText: 'Passenger Type'),
          ),
        ],
      ),
    );
  }

  bool _validateFields() {
    if (_contactNameController.text.trim().isEmpty ||
        _contactEmailController.text.trim().isEmpty ||
        _contactPhoneController.text.trim().isEmpty) {
      return false;
    }
    for (var passenger in passengers) {
      if ((passenger['name'] as String).trim().isEmpty ||
          passenger['idType'] == null ||
          (passenger['idNumber'] as String).trim().isEmpty ||
          passenger['passengerType'] == null) {
        return false;
      }
    }
    return true;
  }
} 