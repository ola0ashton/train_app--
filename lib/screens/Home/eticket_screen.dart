import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

class ETicketScreen extends StatelessWidget {
  final String bookingId;
  final String trainName;
  final String trainClass;
  final String departureStation;
  final String arrivalStation;
  final String departureTime;
  final String arrivalTime;
  final String departureDate;
  final String arrivalDate;
  final String duration;
  final Map<String, String> passenger;

  const ETicketScreen({
    super.key,
    required this.bookingId,
    required this.trainName,
    required this.trainClass,
    required this.departureStation,
    required this.arrivalStation,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureDate,
    required this.arrivalDate,
    required this.duration,
    required this.passenger,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2563EB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        title: const Text('E-Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: bookingId,
                  width: 260,
                  height: 260,
                  drawText: false,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Scan this QR Code at the gate before boarding pass',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const Divider(height: 32),
                Text(trainName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(trainClass, style: const TextStyle(color: Colors.grey, fontSize: 15)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(departureStation, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Icon(Icons.train, color: Color(0xFF2563EB)),
                    Text(arrivalStation, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(departureTime, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('Duration $duration', style: const TextStyle(color: Colors.grey)),
                    Text(arrivalTime, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(departureDate, style: const TextStyle(color: Colors.grey)),
                    Text(arrivalDate, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const Divider(height: 32),
                Text('Passenger: ${passenger['name'] ?? ''}'),
                Text('ID Number: ${passenger['idNumber'] ?? ''}'),
                Text('Passenger Type: ${passenger['type'] ?? ''}'),
                Text('Seat: ${passenger['seat'] ?? ''}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 