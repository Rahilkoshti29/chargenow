import 'package:flutter/material.dart';

class OperatorFeedbackPage extends StatefulWidget {
  const OperatorFeedbackPage({super.key});

  @override
  State<OperatorFeedbackPage> createState() => _OperatorFeedbackPageState();
}

class _OperatorFeedbackPageState extends State<OperatorFeedbackPage> {
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
          "My FeedBacks",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff2ecc71),
      ),
      body: Center(child: Text("My FeedBacks content")),
    );
  }
}
