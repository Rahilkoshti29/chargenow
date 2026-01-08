import 'package:flutter/material.dart';

class VanoperatorDashboard extends StatefulWidget {
  const VanoperatorDashboard({super.key});

  @override
  State<VanoperatorDashboard> createState() => _VanoperatorDashboardState();
}

class _VanoperatorDashboardState extends State<VanoperatorDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("VanoperatorDashboard page"),),
      body: Center(
        child: Text("VanoperatorDashboardState page"),
      ),
    );
  }
}
