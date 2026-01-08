
import 'package:flutter/material.dart';

class USerDashboard extends StatefulWidget {
  const USerDashboard({super.key});

  @override
  State<USerDashboard> createState() => _USerDashboardState();
}

class _USerDashboardState extends State<USerDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("USerDashboard page"),),
      body: Center(
        child: Text("USerDashboard page"),
      ),
    );
  }
}
