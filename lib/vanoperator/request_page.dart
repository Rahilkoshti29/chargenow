import 'package:flutter/material.dart';
class OperatorRequestPage extends StatefulWidget {
  const OperatorRequestPage({super.key});

  @override
  State<OperatorRequestPage> createState() => _OperatorRequestPageState();
}

class _OperatorRequestPageState extends State<OperatorRequestPage> {
  bool isLoading = true;
  List requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    // CALL YOUR API HERE
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      requests = ["Req 1", "Req 2"];
      isLoading = false;
    });
  }

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
          "My Requests",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff2ecc71),
      ),
      body: Center(child: Text("My Requests content")),
    );
  }
}
