import 'package:chargenow/login_page.dart';
import 'package:chargenow/vanoperator/avaibility_page.dart';
import 'package:chargenow/vanoperator/booking_page.dart';
import 'package:chargenow/vanoperator/feedback_page.dart';
import 'package:chargenow/vanoperator/payment_page.dart';
import 'package:chargenow/vanoperator/request_page.dart';
import 'package:chargenow/vanoperator/vanoperator_profile_page.dart';
import 'package:chargenow/vanoperator/vanoperator_van_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


class VanOperatorDashboard extends StatelessWidget {
  const VanOperatorDashboard({super.key});

  static const Color primaryGreen = Color(0xFF2ECC71);

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
              child: SvgPicture.asset("assets/images/logo.svg", height: 350),
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
          // My Van Page
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
              child: Icon(Icons.electric_car, color: Colors.black, size: 25),
            ),
          ),
          const SizedBox(width: 16),

          // Profile Page
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
              child:
              Icon(Icons.person_outline, color: Colors.black, size: 25),
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
        _card(context, Icons.wifi_tethering, "Available",
            const OperatorAvailabilityPage()),
        _card(context, Icons.mail_outline, "Requests",
            const OperatorRequestPage()),
        _card(context, Icons.calendar_today, "Bookings",
            const OperatorBooking()),
        _card(context, Icons.credit_card, "Payments",
            const OperatorPaymentsPage()),
        _card(context, Icons.chat_bubble_outline, "Feedback",
            const OperatorFeedbackPage()),
        _logoutCard(context),
      ],
    );
  }

  // ================= CARD WIDGET =================
  Widget _card(BuildContext context, IconData icon, String title, Widget page) {
    const Color iconColor = primaryGreen;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
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
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
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
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                },
                child: const Text("Cancel",style: TextStyle(color: Colors.black),),
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
                    MaterialPageRoute(builder: (_) =>  LoginPage()),
                  );
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
          children:  [
            CircleAvatar(
              radius: 26,
              backgroundColor: primaryGreen.withOpacity(0.15),
              child: Icon(Icons.logout, color: primaryGreen, size: 26),
            ),
            SizedBox(height: 12),
            Text(
              "Logout",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
