import 'package:chargenow/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chargenow/user/user_1dashboard_page.dart';
import 'package:chargenow/vanoperator/vanoperator_1dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(milliseconds: 1000)); // splash delay

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getInt('role');

    if (!mounted) return;

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2ecc71),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ev_station, size: 90, color: Colors.white),
            SizedBox(height: 20),
            Text(
              "ChargeNow",
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 25),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
