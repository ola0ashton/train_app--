// ignore_for_file: prefer_const_declarations, use_super_parameters, prefer_const_constructors, deprecated_member_use, avoid_types_as_parameter_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_screen.dart';
import 'select_station_screen.dart';
import 'select_departure_date_screen.dart';
import 'package:intl/intl.dart';
import 'search_results_screen.dart';
import 'check_booking_screen.dart';
import 'select_trip_to_reschedule_screen.dart';
import 'select_trip_to_cancel_screen.dart';
import 'my_tickets_screen.dart';
import 'my_wallet_screen.dart';
import 'account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _discountPageController;
  late PageController _newsPageController;
  int _discountPage = 0;
  int _newsPage = 0;
  late final List<Widget> _discountCards;
  late final List<Widget> _newsCards;
  Timer? _discountTimer;
  Timer? _newsTimer;
  String? _selectedOrigin;
  String? _selectedDestination;
  DateTime? _selectedDepartureDate;
  String? _selectedTrainClass;
  int _selectedAdults = 0;
  Map<String, dynamic>? _userData;
  bool _userLoading = true;
  final List<String> _stations = [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'FCT Abuja',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
  ];
  final List<String> _destinationStations = [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'FCT Abuja',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
  ];
  final List<String> _trainClasses = [
    'All Class',
    'Executive',
    'Business',
    'Economy',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _discountPageController = PageController();
    _newsPageController = PageController();
    _discountCards = [
      _discountCard(),
      _discountCard(),
    ];
    _newsCards = [
      _newsCard(),
      _newsCard(),
    ];
    _discountTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_discountCards.length <= 1) return;
      _discountPage = (_discountPage + 1) % _discountCards.length;
      _discountPageController.animateToPage(
        _discountPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
    _newsTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_newsCards.length <= 1) return;
      _newsPage = (_newsPage + 1) % _newsCards.length;
      _newsPageController.animateToPage(
        _newsPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
    _fetchUserDataOnce();
  }

  Future<void> _fetchUserDataOnce() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (mounted) {
      setState(() {
        _userData = doc.data();
        _userLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _discountPageController.dispose();
    _newsPageController.dispose();
    _discountTimer?.cancel();
    _newsTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) {
        return 'Good Morning!';
      } else if (hour < 17) {
        return 'Good Afternoon!';
      } else {
        return 'Good Evening!';
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Stack(
        children: [
          // Blue geometric background
          Container(
            height: screenHeight * 0.42,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Fixed Header
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.02),
                  child: Row(
                    children: [
                      _userLoading
                          ? const CircleAvatar(
                              radius: 24, backgroundColor: Colors.grey)
                          : CircleAvatar(
                              backgroundImage: _userData != null &&
                                      _userData!['photoURL'] != null
                                  ? NetworkImage(_userData!['photoURL'])
                                  : null,
                              radius: 24,
                              child: _userData == null ||
                                      _userData!['photoURL'] == null
                                  ? const Icon(Icons.person,
                                      color: Colors.white)
                                  : null,
                            ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${getGreeting()} 👋',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14)),
                          Text(
                            _userLoading
                                ? 'User'
                                : (_userData?['displayName'] ?? 'User'),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.notifications,
                              color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NotificationScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: screenHeight * 0.02),
                          // Search Card
                          Center(
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.07),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // TabBar
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F8FA),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: TabBar(
                                      controller: _tabController,
                                      indicatorColor: const Color(0xFF2563EB),
                                      labelColor: const Color(0xFF2563EB),
                                      unselectedLabelColor: Colors.grey,
                                      labelStyle: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                      unselectedLabelStyle: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18),
                                      indicatorWeight: 4,
                                      tabs: const [
                                        Tab(text: 'One-Way'),
                                        Tab(text: 'Round Trip'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  // Origin
                                  const Text('Origin',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black)),
                                  const SizedBox(height: 4),
                                  _buildOriginField(screenWidth),
                                  const Divider(
                                      thickness: 1, color: Color(0xFFF1F1F1)),
                                  // Destination
                                  const SizedBox(height: 8),
                                  const Text('Destination',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black)),
                                  const SizedBox(height: 4),
                                  _buildDestinationField(screenWidth),
                                  const Divider(
                                      thickness: 1, color: Color(0xFFF1F1F1)),
                                  // Departure Date
                                  const SizedBox(height: 8),
                                  const Text('Departure Date',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black)),
                                  const SizedBox(height: 4),
                                  _buildDepartureDateField(screenWidth),
                                  const Divider(
                                      thickness: 1, color: Color(0xFFF1F1F1)),
                                  // Train Class & Passenger
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Train Class',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black)),
                                          const SizedBox(height: 4),
                                          _buildTrainClassField(screenWidth),
                                        ],
                                      )),
                                      const SizedBox(width: 16),
                                      Expanded(
                                          child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text('Passenger',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black)),
                                          const SizedBox(height: 4),
                                          _buildPassengerField(screenWidth),
                                        ],
                                      )),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2563EB),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(14)),
                                      ),
                                      onPressed: (_selectedOrigin != null &&
                                              _selectedDestination != null &&
                                              _selectedDepartureDate != null &&
                                              _selectedTrainClass != null &&
                                              _selectedAdults > 0)
                                          ? () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SearchResultsScreen(
                                                    origin: _selectedOrigin!,
                                                    destination:
                                                        _selectedDestination!,
                                                    departureDate:
                                                        _selectedDepartureDate!,
                                                    trainClass:
                                                        _selectedTrainClass!,
                                                    adults: _selectedAdults,
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      child: const Text('Search Trains',
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.025),
                          // Quick Actions
                          _buildQuickActions(screenWidth),
                          SizedBox(height: screenHeight * 0.025),
                          // Special Discounts
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Special Discounts for you',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey[400]),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 140,
                            child: PageView.builder(
                              controller: _discountPageController,
                              itemCount: _discountCards.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _discountPage = index;
                                });
                              },
                              itemBuilder: (context, index) =>
                                  _discountCards[index],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _discountCards.length,
                              (index) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _discountPage == index
                                      ? const Color(0xFF2563EB)
                                      : Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.025),
                          // News & Stories
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Our News & Stories',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey[400]),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 180,
                            child: PageView.builder(
                              controller: _newsPageController,
                              itemCount: _newsCards.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _newsPage = index;
                                });
                              },
                              itemBuilder: (context, index) =>
                                  _newsCards[index],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _newsCards.length,
                              (index) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _newsPage == index
                                      ? const Color(0xFF2563EB)
                                      : Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num), label: 'My Ticket'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet), label: 'My Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            // Already on Home screen, do nothing or refresh
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyTicketsScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyWalletScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AccountScreen(
                        setLocale: (Locale locale) {
                          setState(() {
                            // Update locale in HomeScreen if needed
                          });
                        },
                      )),
            );
          }
        },
      ),
    );
  }

  Widget _buildOriginField(double screenWidth) {
    final hintStyle = TextStyle(
        color: Colors.grey[400], fontWeight: FontWeight.w600, fontSize: 16);
    final labelStyle = const TextStyle(
        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => SelectStationScreen(stations: _stations),
          ),
        );
        if (result != null) {
          setState(() {
            _selectedOrigin = result;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            const Icon(Icons.train, color: Color(0xFFBFC8D7)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedOrigin ?? 'Origin',
                style: _selectedOrigin == null ? hintStyle : labelStyle,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFBFC8D7)),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationField(double screenWidth) {
    final hintStyle = TextStyle(
        color: Colors.grey[400], fontWeight: FontWeight.w600, fontSize: 16);
    final labelStyle = const TextStyle(
        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) => SelectStationScreen(
              stations: _destinationStations,
              title: 'Select Destination',
            ),
          ),
        );
        if (result != null) {
          setState(() {
            _selectedDestination = result;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            const Icon(Icons.train, color: Color(0xFFBFC8D7)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedDestination ?? 'Destination',
                style: _selectedDestination == null ? hintStyle : labelStyle,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFBFC8D7)),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartureDateField(double screenWidth) {
    final hintStyle = TextStyle(
        color: Colors.grey[400], fontWeight: FontWeight.w600, fontSize: 16);
    final labelStyle = const TextStyle(
        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final result = await Navigator.push<DateTime>(
          context,
          MaterialPageRoute(
            builder: (context) => SelectDepartureDateScreen(
              initialDate: _selectedDepartureDate,
            ),
          ),
        );
        if (result != null) {
          setState(() {
            _selectedDepartureDate = result;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedDepartureDate != null
                    ? DateFormat('EEE, MMM d, yyyy')
                        .format(_selectedDepartureDate!)
                    : 'Departure Date',
                style: _selectedDepartureDate == null ? hintStyle : labelStyle,
              ),
            ),
            const Icon(Icons.calendar_today, color: Color(0xFFBFC8D7)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainClassField(double screenWidth) {
    final hintStyle = TextStyle(
        color: Colors.grey[400], fontWeight: FontWeight.w600, fontSize: 16);
    final labelStyle = const TextStyle(
        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final result = await showModalBottomSheet<String>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildTrainClassModal(),
        );
        if (result != null) {
          setState(() {
            _selectedTrainClass = result;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            const Icon(Icons.train, color: Color(0xFFBFC8D7)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedTrainClass ?? 'Train Class',
                style: _selectedTrainClass == null ? hintStyle : labelStyle,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFBFC8D7)),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerField(double screenWidth) {
    final labelStyle = const TextStyle(
        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black);
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        final result = await showModalBottomSheet<int>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildPassengerModal(),
        );
        if (result != null && result > 0) {
          setState(() {
            _selectedAdults = result;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            const Icon(Icons.person, color: Color(0xFFBFC8D7)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _selectedAdults == 0
                    ? '0 Adult'
                    : _selectedAdults == 1
                        ? '1 Adult'
                        : '$_selectedAdults Adults',
                style: labelStyle,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: Color(0xFFBFC8D7)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(double screenWidth) {
    final actions = [
      {'icon': Icons.assignment_turned_in, 'label': 'Check Booking'},
      {'icon': Icons.schedule, 'label': 'Re-Schedule'},
      {'icon': Icons.cancel, 'label': 'Train Cancellation'},
      {'icon': Icons.restaurant, 'label': 'Order Train Food'},
      {'icon': Icons.event_seat, 'label': 'Check Seat Availability'},
      {'icon': Icons.train, 'label': 'Train Live Status'},
      {'icon': Icons.calendar_today, 'label': 'Train Schedule'},
      {'icon': Icons.info, 'label': 'Train Route Information'},
      {'icon': Icons.attach_money, 'label': 'Train Fare'},
      {'icon': Icons.money_off, 'label': 'Refund Calculation'},
      {'icon': Icons.alarm, 'label': 'Station Alarm'},
      {'icon': Icons.local_shipping, 'label': 'Shipping Rates'},
    ];
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          final action = actions[index];
          return GestureDetector(
            onTap: () {
              if (action['label'] == 'Check Booking') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CheckBookingScreen()),
                );
              }
              if (action['label'] == 'Re-Schedule') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const SelectTripToRescheduleScreen()),
                );
              }
              if (action['label'] == 'Train Cancellation') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SelectTripToCancelScreen()),
                );
              }
              // Add other actions here as needed
            },
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFF1F6FF),
                  radius: 28,
                  child: Icon(action['icon'] as IconData,
                      color: const Color(0xFF2563EB), size: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  action['label'] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222B45)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrainClassModal() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_trainClasses.length, (index) {
            final trainClass = _trainClasses[index];
            return Column(
              children: [
                if (index != 0)
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
                ListTile(
                  title: Text(
                    trainClass,
                    style: const TextStyle(
                        fontFamily: 'Urbanist-Bold', fontSize: 18),
                  ),
                  onTap: () => Navigator.pop(context, trainClass),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPassengerModal() {
    final options = List.generate(7, (i) => i + 1);
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...options.map((count) => Column(
                  children: [
                    if (count != 1)
                      const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    ListTile(
                      title: Text(
                        count == 1 ? '1 Adult' : '$count Adults',
                        style: const TextStyle(
                            fontFamily: 'Urbanist-Bold', fontSize: 18),
                      ),
                      onTap: () => Navigator.pop(context, count),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 24),
                    ),
                  ],
                )),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            ListTile(
              title: const Text('Other...',
                  style: TextStyle(fontFamily: 'Urbanist-Bold', fontSize: 18)),
              onTap: () async {
                final custom = await showDialog<int>(
                  context: context,
                  builder: (context) => _buildCustomAdultDialog(),
                );
                if (custom != null && custom > 0) {
                  Navigator.pop(context, custom);
                }
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAdultDialog() {
    final controller = TextEditingController();
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Enter number of adults',
          style: TextStyle(fontFamily: 'Urbanist-Bold')),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(hintText: 'Number of adults'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel',
              style: TextStyle(fontFamily: 'Urbanist-Bold')),
        ),
        TextButton(
          onPressed: () {
            final value = int.tryParse(controller.text);
            if (value != null && value > 0) {
              Navigator.pop(context, value);
            }
          },
          child:
              const Text('OK', style: TextStyle(fontFamily: 'Urbanist-Bold')),
        ),
      ],
    );
  }

  // Discount Card Widget
  static Widget _discountCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Container(
          width: width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0FE),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Get 25% OFF on Ticket Book...',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Limited time offer', style: TextStyle(fontSize: 12)),
                    SizedBox(height: 8),
                    Chip(label: Text('8XK5D')),
                  ],
                ),
              ),
              const Icon(Icons.card_giftcard,
                  color: Color(0xFF2563EB), size: 36),
            ],
          ),
        );
      },
    );
  }

  // News Card Widget
  static Widget _newsCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Container(
          width: width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
                  height: 90,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Train App Launches New Feature to Help Commuters ...',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('5 hours ago',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
