import 'package:flutter/material.dart';

class OperatorPaymentsPage extends StatefulWidget {
  const OperatorPaymentsPage({super.key});

  @override
  State<OperatorPaymentsPage> createState() => _OperatorPaymentsPageState();
}

class _OperatorPaymentsPageState extends State<OperatorPaymentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FFF7),
      appBar: AppBar(
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "My Payments",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff2ecc71),
      ),
      body: Center(child: Text("My Payments content")),
    );
  }
}
