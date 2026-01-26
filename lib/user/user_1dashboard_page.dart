import 'package:chargenow/user/user_2home_page.dart';
import 'package:chargenow/user/user_3request_charging_page.dart';
import 'package:chargenow/user/user_4booking_history_page.dart';
import 'package:chargenow/user/user_5profile_page.dart';
import 'package:flutter/material.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
   HomePage(),
    RequestChargingPage(),
    BookingHistoryPage(),
   UserProfilePage(),
  ];

  static const Color primaryGreen = Color(0xFF2ECC71);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FFF7),
      body: _pages[_currentIndex], // Show the selected page
      bottomNavigationBar: Container(
        height: 78,
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: primaryGreen,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _navItem(Icons.home, 'Home', 0),
            _navItem(Icons.flash_on, 'Request', 1),
            _navItem(Icons.history, 'History', 2),
            _navItem(Icons.person, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 26, color: _currentIndex == index ? Colors.black : Colors.white),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: _currentIndex == index ? Colors.black : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
