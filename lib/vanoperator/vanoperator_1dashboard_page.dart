import 'package:chargenow/login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VanoperatorDashboard extends StatefulWidget {
  const VanoperatorDashboard({super.key});

  @override
  State<VanoperatorDashboard> createState() => _VanoperatorDashboardState();
}

class _VanoperatorDashboardState extends State<VanoperatorDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("Vanoperator Dashboard page")),
      body: Center(child: Column(
          children: [
            Text("Vanoperator DashboardState page"),
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
          ]
          )),
    );
  }
}
