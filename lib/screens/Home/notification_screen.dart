// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final List<Map<String, dynamic>> notifications = [
    {
      'icon': Icons.verified_user,
      'iconColor': Color(0xFFEEF2FF),
      'title': 'Security Updates!',
      'subtitle': 'Now Railify has a Two-Factor Authentication. Try it now to make your account more secure.',
      'date': 'Today',
      'time': '09:24 AM',
      'isNew': true,
    },
    {
      'icon': Icons.credit_card,
      'iconColor': Color(0xFFFFF3ED),
      'title': 'Multiple Card Features!',
      'subtitle': 'Now you can also connect Railify with multiple MasterCard & Visa. Try the service now.',
      'date': '1 day ago',
      'time': '14:43 PM',
      'isNew': true,
    },
    {
      'icon': Icons.info,
      'iconColor': Color(0xFFFFEDED),
      'title': 'New Updates Available!',
      'subtitle': 'Update Railify now to get access to the latest features for easier in making train ticket booking.',
      'date': '2 days ago',
      'time': '10:29 AM',
      'isNew': false,
    },
    {
      'icon': Icons.credit_score,
      'iconColor': Color(0xFFF2F2FF),
      'title': 'Credit Card Connected!',
      'subtitle': 'Your credit card has been successfully linked with Railify. Enjoy our services.',
      'date': '3 days ago',
      'time': '15:38 PM',
      'isNew': false,
    },
    {
      'icon': Icons.check_circle,
      'iconColor': Color(0xFFE6FFFA),
      'title': 'Account Setup Successful!',
      'subtitle': 'Your account creation is successful, you can now experience our services.',
      'date': '20 Dec, 2023',
      'time': '14:27 PM',
      'isNew': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) => SizedBox(height: 18),
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: n['iconColor'],
                child: Icon(n['icon'], color: Color(0xFF2563EB)),
                radius: 24,
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n['title'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        if (n['isNew'])
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('New', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${n['date']}   |   ${n['time']}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    SizedBox(height: 6),
                    Text(
                      n['subtitle'],
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 