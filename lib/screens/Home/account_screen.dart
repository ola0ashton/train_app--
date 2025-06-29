// ignore_for_file: unused_import, avoid_print, deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'manage_payment_methods_screen.dart';
import 'my_tickets_screen.dart';
import 'my_wallet_screen.dart';
import 'home_screen.dart';
import '../../screens/Passengers/passengers_list_screen.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../screens/Profile/personal_info_screen.dart';
import 'notification_settings_screen.dart';
import '../Security/security_settings_screen.dart';
import '../Language/language_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import '../../screens/HelpCenter/help_center_screen.dart';
import 'package:train_app/screens/Home/privacypolicy.dart';
import 'package:train_app/Auth/SignIn/sign_in_screen.dart';
import 'dart:ui';

class AccountScreen extends StatefulWidget {
  final void Function(Locale) setLocale;
  const AccountScreen({super.key, required this.setLocale});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _selectedLanguage = 'English (US)';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadLanguage();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      _userData = userDoc.data();
    } catch (e) {
      print('Error fetching user data: $e');
      _userData = {}; // Fallback to empty data on error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English (US)';
    });
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final userName = _userData?['displayName'] ?? 'User';
    final userEmail = _userData?['email'] ?? 'your_email@domain.com';
    final userPhotoUrl = _userData?['photoURL'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Account',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // User Profile Section
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          userPhotoUrl != null && userPhotoUrl.isNotEmpty
                              ? NetworkImage(userPhotoUrl)
                              : null,
                      child: userPhotoUrl == null || userPhotoUrl.isEmpty
                          ? const Icon(Icons.person,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName,
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(userEmail,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon:
                          const Icon(Icons.qr_code_scanner, color: Colors.grey),
                      onPressed: () async {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;
                        final qrData = user
                            .uid; // You can encode more profile info if needed
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          isScrollControlled: true,
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('My QR Code',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22)),
                                  const SizedBox(height: 16),
                                  QrImageView(
                                    data: qrData,
                                    version: QrVersions.auto,
                                    size: 220.0,
                                    backgroundColor: Colors.white,
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.share,
                                          color: Color(0xFF2563EB)),
                                      label: const Text('Share',
                                          style: TextStyle(
                                              color: Color(0xFF2563EB),
                                              fontWeight: FontWeight.bold)),
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color(0xFF2563EB)),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                      ),
                                      onPressed: () async {
                                        await Share.share(
                                            'Scan my Yemitrain QR: $qrData');
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('General',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const Divider(),
                _buildListTile(
                  context: context,
                  icon: Icons.person_outline,
                  title: 'Personal Info',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PersonalInfoScreen()));
                  },
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.group_outlined,
                  title: 'Passengers List',
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const PassengersListScreen()));
                  },
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.credit_card,
                  title: 'Payment Methods',
                  onTap: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const ManagePaymentMethodsScreen()));
                    _fetchUserData(); // Refresh data if anything changed after returning
                  },
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.notifications_none,
                  title: 'Notification',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const NotificationSettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.security,
                  title: 'Security',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecuritySettingsScreen(),
                      ),
                    );
                  },
                ),
                _buildListTileWithSubTitle(
                  context: context,
                  icon: Icons.language,
                  title: 'Language',
                  subtitle: _selectedLanguage,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LanguageScreen(
                            currentLanguage: _selectedLanguage,
                            setLocale: widget.setLocale),
                      ),
                    );
                    if (result != null && result is Map) {
                      setState(() {
                        _selectedLanguage = result['lang'];
                      });
                      widget.setLocale(result['locale']);
                    }
                  },
                ),
                _buildListTileWithToggle(
                  context: context,
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  value: context.watch<ThemeProvider>().isDarkMode,
                  onChanged: (value) {
                    context.read<ThemeProvider>().toggleTheme();
                  },
                ),
                const SizedBox(height: 24),
                const Text('About',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
                const Divider(),
                _buildListTile(
                  context: context,
                  icon: Icons.help_outline,
                  title: 'Help Center',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpCenterScreen(),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.lock_outline,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyPolicyScreen(),
                      ),
                    );
                  },
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.info_outline,
                  title: 'About Yemitrain',
                  onTap: () {/* TODO: Navigate to About Screen */},
                ),
                _buildListTile(
                  context: context,
                  icon: Icons.logout,
                  title: 'Logout',
                  isRed: true,
                  onTap: () async {
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: 'Logout',
                      barrierColor: Colors.black.withOpacity(0.2),
                      pageBuilder: (context, anim1, anim2) {
                        return Stack(
                          children: [
                            // Blurred background
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                              child: Container(
                                color: Colors.black.withOpacity(0),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(32),
                                  ),
                                ),
                                padding:
                                    const EdgeInsets.fromLTRB(24, 24, 24, 32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 4,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Divider(),
                                    const SizedBox(height: 18),
                                    const Text(
                                      'Are you sure you want to log out?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 28),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              side: const BorderSide(
                                                  color: Color(0xFF2563EB)),
                                              backgroundColor:
                                                  const Color(0xFFF4F7FF),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                            ),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: Color(0xFF2563EB),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color(0xFF2563EB),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 16),
                                            ),
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              await signOut();
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const SignInScreen()),
                                                (Route<dynamic> route) => false,
                                              );
                                            },
                                            child: const Text(
                                              'Yes, Logout',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      transitionBuilder: (context, anim1, anim2, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: anim1,
                            curve: Curves.easeOutCubic,
                          )),
                          child: child,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        currentIndex: 3, // 'Account' is the fourth item (index 3)
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst); // Go to Home
          } else if (index == 1) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyTicketsScreen()));
          } else if (index == 2) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MyWalletScreen()));
          } else if (index == 3) {
            // Already on AccountScreen, do nothing or refresh
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num), label: 'My Ticket'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'My Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isRed = false,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: isRed ? Colors.red : Colors.black87),
          title: Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isRed ? Colors.red : Colors.black87)),
          trailing:
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildListTileWithSubTitle({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey)),
          trailing:
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildListTileWithToggle({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.black87),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: Switch(
            value: value,
            onChanged: onChanged,
            thumbColor: MaterialStateProperty.all(const Color(0xFF2563EB)),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
