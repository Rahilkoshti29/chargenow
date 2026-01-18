import 'package:chargenow/login_page.dart';
import 'package:chargenow/onboardingscreen_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chargenow/user/user_1dashboard_page.dart';
import 'package:chargenow/vanoperator/vanoperator_1dashboard_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();

    final bool seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
    final String? token = prefs.getString('token');
    final int? role = prefs.getInt('role');

    if (!mounted) return;

    // 🔹 FIRST TIME → ONBOARDING
    if (!seenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OnBoardingPage()),
      );
      return;
    }

    // 🔹 USER ALREADY LOGGED IN
    if (token != null && role != null) {
      if (role == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => UserDashboard()),
        );
      } else if (role == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => VanoperatorDashboard()),
        );
      }
    } else {
      // 🔹 NOT LOGGED IN
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/images/logo.svg", height: 220),
            SizedBox(height: 25),
            CircularProgressIndicator(color: Color(0xff2ecc71)),
          ],
        ),
      ),
    );
  }
}
