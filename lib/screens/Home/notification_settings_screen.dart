// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final Map<String, bool> _prefs = {
    'ticketOrder': true,
    'payment': true,
    'cancelOrder': true,
    'offers': false,
    'news': false,
    'appSystem': true,
    'guidance': false,
    'survey': false,
  };
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    setState(() {
      _loading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = doc.data();
    if (data != null && data['notificationPreferences'] != null) {
      final np = Map<String, dynamic>.from(data['notificationPreferences']);
      for (final key in _prefs.keys) {
        if (np.containsKey(key)) _prefs[key] = np[key] == true;
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _savePrefs() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'notificationPreferences': _prefs,
    });
  }

  Widget _buildSwitch(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
          ),
          Switch(
            value: _prefs[key]!,
            onChanged: (val) {
              setState(() {
                _prefs[key] = val;
              });
              _savePrefs();
            },
            activeColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
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
        title: const Text('Notification',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                const SizedBox(height: 8),
                const Text('Notify me when...',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 16),
                _buildSwitch('I made a train ticket order', 'ticketOrder'),
                _buildSwitch('I made a payment', 'payment'),
                _buildSwitch('I canceled my train trip order', 'cancelOrder'),
                _buildSwitch('There are special offers/discounts', 'offers'),
                _buildSwitch('There is new news', 'news'),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text('System',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const SizedBox(height: 16),
                _buildSwitch('App System', 'appSystem'),
                _buildSwitch('Guidance, tips, and tricks', 'guidance'),
                _buildSwitch('Participate in a survey', 'survey'),
              ],
            ),
    );
  }
}
