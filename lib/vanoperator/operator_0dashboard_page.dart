import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/login_page.dart';
import 'package:chargenow/vanoperator/operator_1avaibility_page.dart';
import 'package:chargenow/vanoperator/operator_3booking_page.dart';
import 'package:chargenow/vanoperator/operator_5feedback_page.dart';
import 'package:chargenow/vanoperator/operator_4payment_page.dart';
import 'package:chargenow/vanoperator/operator_2request_page.dart';
import 'package:chargenow/vanoperator/operator_7profile_page.dart';
import 'package:chargenow/vanoperator/operator_6van_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class VanOperatorDashboard extends StatelessWidget {
  const VanOperatorDashboard({super.key});

  static const Color primaryGreen = Color(0xFF2ECC71);

  // ================= LOGOUT HANDLER =================
  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final isAvailable = prefs.getBool('operator_available') ?? false;

    // If operator is available → turn OFF before logout
    if (isAvailable && token != null) {
      try {
        await http.put(
          Uri.parse('${Apiconst.base_url}operator/status/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'status': 0}),
        );
        await prefs.setBool('operator_available', false);
      } catch (_) {
        // even if API fails, proceed with logout
      }
    }

    // Clear everything
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFFAF3),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        titleSpacing: 12,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: SvgPicture.asset("assets/images/logo.svg", height: 32),
            ),
            const SizedBox(width: 8),
            const Text(
              "ChargeNow",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyVanPage()),
              );
            },
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(Icons.electric_car, color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OperatorProfilePage()),
              );
            },
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline, color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBanner(),
            const SizedBox(height: 20),
            _buildDashboardGrid(context),
          ],
        ),
      ),
    );
  }

  // ================= BANNER =================
  Widget _buildBanner() {
    return Container(
      height: 140,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            "Operator Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "Manage charging vans & requests",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ================= GRID =================
  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.1,
      children: [
        _card(
          context,
          Icons.wifi_tethering,
          "Available",
          const OperatorAvailabilityPage(),
        ),
        _card(
          context,
          Icons.mail_outline,
          "Requests",
          const OperatorRequestPage(),
        ),
        _card(
          context,
          Icons.calendar_today,
          "Bookings",
          const OperatorBooking(),
        ),
        _card(
          context,
          Icons.credit_card,
          "Payments",
          const OperatorPaymentsPage(),
        ),
        _card(
          context,
          Icons.chat_bubble_outline,
          "Feedback",
          const OperatorFeedbackPage(),
        ),
        _logoutCard(context),
      ],
    );
  }

  // ================= CARD =================
  Widget _card(BuildContext context, IconData icon, String title, Widget page) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: primaryGreen.withOpacity(0.15),
              child: Icon(icon, color: primaryGreen),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LOGOUT CARD =================
  Widget _logoutCard(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        final isAvailable = prefs.getBool('operator_available') ?? false;

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Logout"),
            backgroundColor: Colors.white,
            content: Text(
              isAvailable
                  ? "You are currently available. Logging out will turn OFF availability. Continue?"
                  : "Are you sure you want to logout?",
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
                  _handleLogout(context);
                },
                child: const Text("Yes", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: primaryGreen.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: primaryGreen.withOpacity(0.15),
              child: const Icon(Icons.logout, color: primaryGreen),
            ),
            const SizedBox(height: 12),
            const Text(
              "Logout",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
