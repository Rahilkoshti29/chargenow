import 'package:flutter/material.dart';

class RequestChargingPage extends StatefulWidget {
  final VoidCallback onBack;

  const RequestChargingPage({super.key, required this.onBack});

  @override
  State<RequestChargingPage> createState() => _RequestChargingPageState();
}

class _RequestChargingPageState extends State<RequestChargingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FFF7),
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onBack,
          icon: Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Request ChargeNow",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff2ecc71),
      ),
      body: Center(child: Text("Request ChargeNow content")),
    );
  }
}
