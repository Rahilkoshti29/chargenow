import 'package:chargenow/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("User Dashboard page")),
      body: Center(child: Column(
        children: [
          Text("User Dashboard page"),
          ElevatedButton( child: Text("Logout"),
          onPressed: () async {
            final pref = await SharedPreferences.getInstance();
            await pref.clear();
            await pref.setBool('seen', true);
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => LoginScreen()),
                    (Route<dynamic> route) => false);
            // Add logout functionality here
          },
      ),
        ],
      )
    ),
    );
  }
}
