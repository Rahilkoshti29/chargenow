import 'package:chargenow/login_page.dart';
import 'package:chargenow/user/user_profile_3my_1payments_page.dart';
import 'package:chargenow/user/user_profile_5contactus_page.dart';
import 'package:chargenow/user/user_profile_4myprofile_detail_page.dart';
import 'package:chargenow/user/user_profile_7privacy_policy_pafe.dart';
import 'package:chargenow/user/user_profile_6terms&conditions_page.dart';
import 'package:chargenow/user/user_profile_2my_bookings_page.dart';
import 'package:chargenow/user/user_profile_1my_vehicles_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  final VoidCallback onBack;

  const UserProfilePage({super.key, required this.onBack});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  static const Color primaryGreen = Color(0xFF2ECC71);

  String userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('name') ?? 'User';
    setState(() {});
  }

  void showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text("Logout"),
          content: const Text(
            "Are you sure you want to logout from ChargeNow?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => LoginPage()),
                );
              },
              child: const Text("Yes", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _loadUserName();
    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF7),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // ================= USER CARD =================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.25),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.black,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // -------- MAIN MENU --------
          _menuCard([
            _menuItem(
              Icons.directions_car,
              "My Vehicles",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MyVehiclesPage()),
                );
              },
            ),
            _menuItem(
              Icons.calendar_month,
              "My Bookings",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => BookingHistoryPage()),
                );
              },
            ),
            _menuItem(
              Icons.payment_rounded,
              "My Payments",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => UserPaymentsPage()),
                );
              },
            ),
            _menuItem(
              Icons.person_outline,
              "My Profile",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserProfileDetailPage(),
                  ),
                ).then((value) {
                  _loadUserName();
                });
              },
            ),
          ]),

          const SizedBox(height: 18),

          // -------- SUPPORT MENU --------
          _menuCard([
            _menuItem(
              Icons.call,
              "Contact Us",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactSupportPage()),
                );
              },
            ),

            _menuItem(
              Icons.description,
              "Terms & Conditions",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TermsConditionsPage(),
                  ),
                );
              },
            ),

            _menuItem(
              Icons.privacy_tip,
              "Privacy Policy",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
                );
              },
            ),

            _menuItem(
              Icons.logout,
              "Logout",
              isLogout: true,
              onTap: showLogoutDialog,
            ),
          ]),
        ],
      ),
    );
  }

  // ================== UI WIDGETS ==================

  Widget _menuCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(children: children),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title, {
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: isLogout ? Colors.red : primaryGreen),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isLogout ? Colors.red : Colors.black,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
