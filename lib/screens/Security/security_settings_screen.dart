// ignore_for_file: use_super_parameters, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'sms_mfa_setup_screen.dart';
import 'totp_setup_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({Key? key}) : super(key: key);

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool rememberMe = true;
  bool biometricId = false;
  bool faceId = false;
  bool smsAuth = false;
  bool googleAuth = false;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? true;
      biometricId = prefs.getBool('biometricId') ?? false;
      faceId = prefs.getBool('faceId') ?? false;
      smsAuth = prefs.getBool('smsAuth') ?? false;
      googleAuth = prefs.getBool('googleAuth') ?? false;
    });
  }

  Future<void> _savePref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _toggleBiometric(bool value) async {
    bool canCheck = await auth.canCheckBiometrics;
    if (!canCheck) {
      _showInfoDialog('Biometric not available on this device.');
      return;
    }
    final available = await auth.getAvailableBiometrics();
    if (available.isEmpty) {
      _showInfoDialog('No biometrics enrolled.');
      return;
    }
    setState(() {
      biometricId = value;
    });
    _savePref('biometricId', value);
  }

  Future<void> _toggleFaceId(bool value) async {
    final available = await auth.getAvailableBiometrics();
    if (!available.contains(BiometricType.face)) {
      _showInfoDialog('Face ID not available on this device.');
      return;
    }
    setState(() {
      faceId = value;
    });
    _savePref('faceId', value);
  }

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Info'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _handleSmsAuthToggle(bool value) async {
    if (value) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SmsMfaSetupScreen()),
      );
      if (result == true) {
        setState(() => smsAuth = true);
        _savePref('smsAuth', true);
        _updateUserMfa('smsAuth', true);
      } else {
        setState(() => smsAuth = false);
        _savePref('smsAuth', false);
        _updateUserMfa('smsAuth', false);
      }
    } else {
      setState(() => smsAuth = false);
      _savePref('smsAuth', false);
      _updateUserMfa('smsAuth', false);
    }
  }

  Future<void> _handleGoogleAuthToggle(bool value) async {
    if (value) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const TotpSetupScreen()),
      );
      if (result == true) {
        setState(() => googleAuth = true);
        _savePref('googleAuth', true);
        _updateUserMfa('googleAuth', true);
      } else {
        setState(() => googleAuth = false);
        _savePref('googleAuth', false);
        _updateUserMfa('googleAuth', false);
      }
    } else {
      setState(() => googleAuth = false);
      _savePref('googleAuth', false);
      _updateUserMfa('googleAuth', false);
    }
  }

  Future<void> _updateUserMfa(String key, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({key: value});
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
        title: const Text('Security',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          _buildSwitchRow('Remember me', rememberMe, (val) {
            setState(() => rememberMe = val);
            _savePref('rememberMe', val);
          }),
          _buildSwitchRow(
              'Biometric ID', biometricId, (val) => _toggleBiometric(val)),
          _buildSwitchRow('Face ID', faceId, (val) => _toggleFaceId(val)),
          _buildSwitchRow('SMS Authenticator', smsAuth, _handleSmsAuthToggle),
          _buildSwitchRow(
              'Google Authenticator', googleAuth, _handleGoogleAuthToggle),
          _buildDeviceManagementRow(context),
          const SizedBox(height: 32),
          _buildChangePasswordButton(context),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2563EB),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceManagementRow(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DeviceManagementScreen()));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Device Management',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
            Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _buildChangePasswordButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8EFFF),
            foregroundColor: const Color(0xFF2563EB),
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: const Text('Change Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// Device Management Screen
class DeviceManagementScreen extends StatefulWidget {
  const DeviceManagementScreen({Key? key}) : super(key: key);
  @override
  State<DeviceManagementScreen> createState() => _DeviceManagementScreenState();
}

class _DeviceManagementScreenState extends State<DeviceManagementScreen> {
  List<Map<String, dynamic>> _devices = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    setState(() {
      _loading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .get();
    _devices = snap.docs.map((d) => d.data()).toList();
    setState(() {
      _loading = false;
    });
  }

  Future<void> _signOutDevice(String deviceId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('devices')
        .doc(deviceId)
        .delete();
    _fetchDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text('Device Management',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _devices.isEmpty
              ? const Center(child: Text('No devices found.'))
              : ListView.separated(
                  itemCount: _devices.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    final d = _devices[i];
                    return ListTile(
                      leading: const Icon(Icons.devices),
                      title: Text(d['platform'] ?? 'Unknown Device'),
                      subtitle: Text('Last active: ${d['lastActive'] ?? ''}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: () => _signOutDevice(d['deviceId']),
                      ),
                    );
                  },
                ),
    );
  }
}

// Change Password Screen
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
      _success = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not logged in');
      // Re-authenticate user
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newPasswordController.text.trim());
      setState(() {
        _success = 'Password changed successfully!';
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to change password: ${e.toString()}';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        title: const Text('Change Password',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration:
                    const InputDecoration(labelText: 'Current Password'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter current password' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min 6 characters' : null,
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              if (_success != null)
                Text(_success!, style: const TextStyle(color: Colors.green)),
              ElevatedButton(
                onPressed: _loading ? null : _changePassword,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// TODO: Implement SMS Authenticator (MFA) and Google Authenticator (TOTP) integration next.
