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
  int? selectedVehicleId;

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
          HomePage(
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
            key: ValueKey(selectedVehicleId), // 🔥 VERY IMPORTANT
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
