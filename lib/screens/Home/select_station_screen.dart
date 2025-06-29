// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';

class SelectStationScreen extends StatefulWidget {
  final List<String> stations;
  final String title;
  const SelectStationScreen({Key? key, required this.stations, this.title = 'Select Origin'}) : super(key: key);

  @override
  State<SelectStationScreen> createState() => _SelectStationScreenState();
}

class _SelectStationScreenState extends State<SelectStationScreen> {
  late List<String> filteredStations;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredStations = widget.stations;
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      filteredStations = widget.stations
          .where((station) => station.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search station',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filteredStations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final station = filteredStations[index];
                return ListTile(
                  title: Text(station, style: const TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pop(context, station),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 