import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectDepartureDateScreen extends StatefulWidget {
  final DateTime? initialDate;
  const SelectDepartureDateScreen({super.key, this.initialDate});

  @override
  State<SelectDepartureDateScreen> createState() => _SelectDepartureDateScreenState();
}

class _SelectDepartureDateScreenState extends State<SelectDepartureDateScreen> {
  late DateTime selectedDate;
  late DateTime firstDate;
  late DateTime lastDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate ?? DateTime.now();
    firstDate = DateTime(DateTime.now().year, DateTime.now().month);
    lastDate = DateTime(DateTime.now().year, DateTime.now().month + 11, 0); // 12 months
  }

  @override
  Widget build(BuildContext context) {
    final months = <DateTime>[];
    for (int i = 0; i < 12; i++) {
      months.add(DateTime(firstDate.year, firstDate.month + i));
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Departure Date', style: TextStyle(color: Colors.white, fontFamily: 'Urbanist-Bold')),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        itemCount: months.length,
        itemBuilder: (context, index) {
          final month = months[index];
          return _buildMonthCard(month);
        },
      ),
    );
  }

  Widget _buildMonthCard(DateTime month) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    final days = <DateTime?>[];
    // Fill leading empty days
    for (int i = 1; i < firstWeekday; i++) {
      days.add(null);
    }
    // Fill actual days
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }
    // Fill trailing empty days to complete the last week
    while (days.length % 7 != 0) {
      days.add(null);
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy').format(month),
            style: const TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 20),
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mo', style: TextStyle(fontFamily: 'Urbanist-Bold')),
              Text('Tu', style: TextStyle(fontFamily: 'Urbanist-Bold')),
              Text('We', style: TextStyle(fontFamily: 'Urbanist-Bold')),
              Text('Th', style: TextStyle(fontFamily: 'Urbanist-Bold')),
              Text('Fr', style: TextStyle(fontFamily: 'Urbanist-Bold')),
              Text('Sa', style: TextStyle(fontFamily: 'Urbanist-Bold')),
              Text('Su', style: TextStyle(fontFamily: 'Urbanist-Bold')),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 0,
              childAspectRatio: 1.2,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              if (day == null) {
                return const SizedBox();
              }
              final isSelected = day.year == selectedDate.year && day.month == selectedDate.month && day.day == selectedDate.day;
              final isPast = day.isBefore(DateTime.now().subtract(const Duration(days: 1)));
              return GestureDetector(
                onTap: isPast
                    ? null
                    : () {
                        setState(() {
                          selectedDate = day;
                        });
                        Navigator.pop(context, day);
                      },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2563EB) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isPast
                          ? Colors.grey[400]
                          : isSelected
                              ? Colors.white
                              : Colors.black,
                      fontFamily: 'Urbanist-Bold',
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
} 