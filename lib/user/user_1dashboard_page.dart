import 'package:chargenow/user/notification.dart';
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
  void goToHome() {
    setState(() => _currentIndex = 0);
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        onTabChange: (index) {
          setState(() => _currentIndex = index);
        },
        onNotificationTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NotificationPage()),
          );
        },
      ),

      RequestChargingPage(onBack: goToHome),
      BookingHistoryPage(onBack: goToHome),
      UserProfilePage(onBack: goToHome),
    ];
  }

  static const Color primaryGreen = Color(0xFF2ECC71);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FFF7),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: SizedBox(
            height: 70,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },

              type: BottomNavigationBarType.fixed,
              backgroundColor: primaryGreen,

              showSelectedLabels: true,
              showUnselectedLabels: true,

              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.white,

              selectedFontSize: 11,
              unselectedFontSize: 11,

              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 26),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.flash_on, size: 26),
                  label: 'Request',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history, size: 26),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz_outlined, size: 26),
                  label: 'More',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
