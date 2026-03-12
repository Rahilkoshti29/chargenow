import 'package:chargenow/user/user_0dashboard_page_notification_page.dart';
import 'package:chargenow/user/user_1home_page.dart';
import 'package:chargenow/user/user_2request_charging_page.dart';
import 'package:chargenow/user/user_3request_history_page.dart';
import 'package:chargenow/user/user_4profile_page.dart';
import 'package:flutter/material.dart';

class UserDashboardPage extends StatefulWidget {
  final int initialIndex;
  const UserDashboardPage({super.key, this.initialIndex = 0});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _currentIndex = 0;
  int? selectedVehicleId;
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void goToHome() {
    setState(() => _currentIndex = 0);
  }

  static const Color primaryGreen = Color(0xFF2ECC71);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF7),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // -------- HOME --------
          UserHomePage(
            onTabChange: (int index, {int? vehicleId}) {
              setState(() {
                _currentIndex = index;
                selectedVehicleId = vehicleId;
              });
            },
            onNotificationTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationPage()),
              );
            },
          ),

          // -------- REQUEST (REBUILT WITH ID) --------
          RequestChargingPage(
            key: ValueKey(selectedVehicleId), //  VERY IMPORTANT
            onBack: goToHome,
            preselectedVehicleId: selectedVehicleId,
          ),

          RequestHistoryPage(onBack: goToHome),
          UserProfilePage(onBack: goToHome),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.08,
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() => _currentIndex = index);
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: primaryGreen,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.white,
                iconSize: 27,
                selectedFontSize: 13,
                unselectedFontSize: 12,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.flash_on),
                    label: 'Request',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: 'History',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.more_horiz_outlined),
                    label: 'More',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
