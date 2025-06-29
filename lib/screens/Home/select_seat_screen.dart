// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'payment_method_screen.dart';

class SelectSeatScreen extends StatefulWidget {
  final Map<String, dynamic> train;
  final List<Map<String, dynamic>> passengers;
  final String contactName;
  final String contactEmail;
  final String contactPhone;

  const SelectSeatScreen({
    super.key,
    required this.train,
    required this.passengers,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
  });

  @override
  State<SelectSeatScreen> createState() => _SelectSeatScreenState();
}

class _SelectSeatScreenState extends State<SelectSeatScreen> {
  int selectedCarriage = 0;
  String? selectedSeat;

  // Static seat data for 3 carriages
  final List<List<List<Map<String, dynamic>>>> carriages = [
    // Carriage 1
    [
      [
        {'id': 'A1', 'status': 'occupied'},
        {'id': 'B1', 'status': 'occupied'},
        {'id': 'C1', 'status': 'available'},
        {'id': 'D1', 'status': 'occupied'},
      ],
      [
        {'id': 'A2', 'status': 'available'},
        {'id': 'B2', 'status': 'selected'}, // Will be set dynamically
        {'id': 'C2', 'status': 'occupied'},
        {'id': 'D2', 'status': 'available'},
      ],
      [
        {'id': 'A3', 'status': 'occupied'},
        {'id': 'B3', 'status': 'occupied'},
        {'id': 'C3', 'status': 'available'},
        {'id': 'D3', 'status': 'occupied'},
      ],
      [
        {'id': 'A4', 'status': 'available'},
        {'id': 'B4', 'status': 'occupied'},
        {'id': 'C4', 'status': 'available'},
        {'id': 'D4', 'status': 'available'},
      ],
      [
        {'id': 'A5', 'status': 'occupied'},
        {'id': 'B5', 'status': 'available'},
        {'id': 'C5', 'status': 'available'},
        {'id': 'D5', 'status': 'occupied'},
      ],
      [
        {'id': 'A6', 'status': 'available'},
        {'id': 'B6', 'status': 'occupied'},
        {'id': 'C6', 'status': 'occupied'},
        {'id': 'D6', 'status': 'occupied'},
      ],
      [
        {'id': 'A7', 'status': 'available'},
        {'id': 'B7', 'status': 'available'},
        {'id': 'C7', 'status': 'occupied'},
        {'id': 'D7', 'status': 'occupied'},
      ],
    ],
    // Carriage 2 (all available for demo)
    List.generate(
        7,
        (row) => List.generate(
            4,
            (col) => {
                  'id': String.fromCharCode(65 + col) + (row + 1).toString(),
                  'status': 'available',
                })),
    // Carriage 3 (all occupied for demo)
    List.generate(
        7,
        (row) => List.generate(
            4,
            (col) => {
                  'id': String.fromCharCode(65 + col) + (row + 1).toString(),
                  'status': 'occupied',
                })),
  ];

  @override
  Widget build(BuildContext context) {
    final seatRows = carriages[selectedCarriage];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Select Seat',
            style: TextStyle(color: Colors.white, fontFamily: 'Urbanist-Bold')),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Carriage Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                  3,
                  (index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ChoiceChip(
                          label: Text('Carriage ${index + 1}'),
                          selected: selectedCarriage == index,
                          selectedColor: const Color(0xFF2563EB),
                          backgroundColor: Colors.white,
                          labelStyle: TextStyle(
                            color: selectedCarriage == index
                                ? Colors.white
                                : const Color(0xFF2563EB),
                            fontWeight: FontWeight.bold,
                          ),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          onSelected: (_) {
                            setState(() {
                              selectedCarriage = index;
                              selectedSeat = null;
                            });
                          },
                        ),
                      )),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _legendBox(const Color(0xFF2563EB)),
                const SizedBox(width: 4),
                const Text('Selected'),
                const SizedBox(width: 16),
                _legendBox(const Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                const Text('Occupied'),
                const SizedBox(width: 16),
                _legendBox(const Color(0xFFF1F5F9)),
                const SizedBox(width: 4),
                const Text('Available'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Seat Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  // Header
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('A', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('B', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('C', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('D', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: seatRows.length,
                      itemBuilder: (context, rowIdx) {
                        final row = seatRows[rowIdx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(row.length, (colIdx) {
                              final seat = row[colIdx];
                              final seatId = seat['id'];
                              String status = seat['status'];
                              if (selectedSeat == seatId) status = 'selected';
                              return _seatBox(
                                seatId: seatId,
                                status: status,
                                onTap: status == 'occupied'
                                    ? null
                                    : () {
                                        setState(() {
                                          selectedSeat = seatId;
                                        });
                                      },
                              );
                            }),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Continue Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: selectedSeat == null
                    ? null
                    : () {
                        if (selectedSeat != null) {
                          final updatedPassengers = widget.passengers
                              .map((p) => {
                                    ...p,
                                    'carriage': selectedCarriage + 1,
                                    'seat': selectedSeat,
                                  })
                              .toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentMethodScreen(
                                train: widget.train,
                                passengers: updatedPassengers,
                                carriage: selectedCarriage + 1,
                                seat: selectedSeat!,
                                contactName: widget.contactName,
                                contactEmail: widget.contactEmail,
                                contactPhone: widget.contactPhone,
                              ),
                            ),
                          );
                        }
                      },
                child: const Text('Continue',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendBox(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _seatBox(
      {required String seatId, required String status, VoidCallback? onTap}) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'selected':
        bgColor = const Color(0xFF2563EB);
        textColor = Colors.white;
        break;
      case 'occupied':
        bgColor = const Color(0xFF94A3B8);
        textColor = Colors.white;
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF2563EB);
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: status == 'selected'
            ? const Icon(Icons.check, color: Colors.white)
            : Text(seatId,
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
