import 'package:flutter/material.dart';

class BookingHistoryPage extends StatefulWidget {
  final VoidCallback onBack;

  const BookingHistoryPage({super.key, required this.onBack});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
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
        title: Text(
          "Booking History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xff2ecc71),
      ),
      body: Center(child: Text("Booking history content")),
    );
  }
}
