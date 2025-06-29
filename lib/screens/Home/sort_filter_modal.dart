import 'package:flutter/material.dart';

class SortFilterModal extends StatefulWidget {
  final Map<String, dynamic> initialValues;
  final List<Map<String, String>> trainList;
  const SortFilterModal({super.key, required this.initialValues, required this.trainList});

  @override
  State<SortFilterModal> createState() => _SortFilterModalState();
}

class _SortFilterModalState extends State<SortFilterModal> {
  late String sortBy;
  late RangeValues timeRange;
  late RangeValues priceRange;
  late String ticketAvailability;
  late String trainClass;
  late Set<String> selectedTrains;

  @override
  void initState() {
    super.initState();
    sortBy = widget.initialValues['sortBy'] ?? 'Default';
    timeRange = widget.initialValues['timeRange'] ?? const RangeValues(5, 21);
    priceRange = widget.initialValues['priceRange'] ?? const RangeValues(25, 100);
    ticketAvailability = widget.initialValues['ticketAvailability'] ?? 'Show Available Ticket';
    trainClass = widget.initialValues['trainClass'] ?? 'All Class';
    selectedTrains = Set<String>.from(widget.initialValues['selectedTrains'] ?? widget.trainList.map((t) => t['name']!));
  }

  void reset() {
    setState(() {
      sortBy = 'Default';
      timeRange = const RangeValues(5, 21);
      priceRange = const RangeValues(25, 100);
      ticketAvailability = 'Show Available Ticket';
      trainClass = 'All Class';
      selectedTrains = widget.trainList.map((t) => t['name']!).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF7F8FA),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Spacer(),
                  const Text('Sort & Filter', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 20, color: Colors.white)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sort by', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                  const Divider(),
                  ...['Default', 'Lowest Price', 'Highest Price', 'Shortest Duration', 'Longest Duration'].map((s) => RadioListTile<String>(
                    value: s,
                    groupValue: sortBy,
                    onChanged: (v) => setState(() => sortBy = v!),
                    title: Text(s, style: const TextStyle(fontFamily: 'Urbanist-Bold')),
                    contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
            ),
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Departing Time', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                  RangeSlider(
                    values: timeRange,
                    min: 0,
                    max: 23,
                    divisions: 23,
                    labels: RangeLabels(_formatTime(timeRange.start), _formatTime(timeRange.end)),
                    onChanged: (v) => setState(() => timeRange = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatTime(timeRange.start), style: const TextStyle(fontFamily: 'Urbanist-Bold')),
                      Text(_formatTime(timeRange.end), style: const TextStyle(fontFamily: 'Urbanist-Bold')),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ticket Price Range', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                  RangeSlider(
                    values: priceRange,
                    min: 0,
                    max: 200,
                    divisions: 40,
                    labels: RangeLabels('${priceRange.start.toInt()}', '${priceRange.end.toInt()}'),
                    onChanged: (v) => setState(() => priceRange = v),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${priceRange.start.toInt()}', style: const TextStyle(fontFamily: 'Urbanist-Bold')),
                      Text('${priceRange.end.toInt()}', style: const TextStyle(fontFamily: 'Urbanist-Bold')),
                    ],
                  ),
                ],
              ),
            ),
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ticket Availability', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                  ...['Show All Ticket', 'Show Available Ticket', 'Show Unavailable Ticket'].map((s) => RadioListTile<String>(
                    value: s,
                    groupValue: ticketAvailability,
                    onChanged: (v) => setState(() => ticketAvailability = v!),
                    title: Text(s, style: const TextStyle(fontFamily: 'Urbanist-Bold')),
                    contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
            ),
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Train Class', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                  ...['All Class', 'Executive', 'Business', 'Economy'].map((s) => RadioListTile<String>(
                    value: s,
                    groupValue: trainClass,
                    onChanged: (v) => setState(() => trainClass = v!),
                    title: Text(s, style: const TextStyle(fontFamily: 'Urbanist-Bold')),
                    contentPadding: EdgeInsets.zero,
                  )),
                ],
              ),
            ),
            _section(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Train', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            if (selectedTrains.length == widget.trainList.length) {
                              selectedTrains.clear();
                            } else {
                              selectedTrains = widget.trainList.map((t) => t['name']!).toSet();
                            }
                          });
                        },
                        child: Text(
                          selectedTrains.length == widget.trainList.length ? 'Deselect All' : 'Select All',
                          style: const TextStyle(fontFamily: 'Urbanist-Bold'),
                        ),
                      ),
                    ],
                  ),
                  ...widget.trainList.map((train) => CheckboxListTile(
                        value: selectedTrains.contains(train['name']),
                        onChanged: (v) {
                          setState(() {
                            if (v == true) {
                              selectedTrains.add(train['name']!);
                            } else {
                              selectedTrains.remove(train['name']!);
                            }
                          });
                        },
                        title: Row(
                          children: [
                            Image.network(
                              train['logo']!,
                              width: 24,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.train, size: 16, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                train['name']!,
                                style: const TextStyle(fontFamily: 'Urbanist-Bold'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: reset,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Reset', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'sortBy': sortBy,
                        'timeRange': timeRange,
                        'priceRange': priceRange,
                        'ticketAvailability': ticketAvailability,
                        'trainClass': trainClass,
                        'selectedTrains': selectedTrains,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Apply', style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _section({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  String _formatTime(double hour) {
    final h = hour.floor();
    final m = ((hour - h) * 60).round();
    final dt = TimeOfDay(hour: h, minute: m);
    return dt.format(context);
  }
} 