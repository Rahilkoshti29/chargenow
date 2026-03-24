import 'dart:convert';
import 'package:chargenow/user/user_0dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GiveFeedbackPage extends StatefulWidget {
  final int bookingId;
  final int operatorId;

  const GiveFeedbackPage({
    super.key,
    required this.operatorId,
    required this.bookingId,
  });

  @override
  State<GiveFeedbackPage> createState() => _GiveFeedbackPageState();
}

class _GiveFeedbackPageState extends State<GiveFeedbackPage> {

  static const Color primaryGreen = Color(0xFF2ECC71);

  int rating = 0;

  bool isSubmitting = false;

  final TextEditingController commentController =
  TextEditingController();

  Future<void> submitFeedback() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('${Apiconst.base_url}user/feedback/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "operator": widget.operatorId,
        "booking": widget.bookingId,
        "rating": rating,
        "comments": commentController.text,
      }),
    );

    print(response.body);

    if (response.statusCode == 201) {

      Fluttertoast.showToast(
        msg: "Feedback submitted successfully",
        toastLength: Toast.LENGTH_SHORT,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const UserDashboardPage(initialIndex: 0),
        ),
            (route) => false,
      );

    } else {

      Fluttertoast.showToast(
        msg: "Feedback failed",
        toastLength: Toast.LENGTH_SHORT,
      );

    }
  }


  Widget buildStar(int index) {

    return IconButton(
      icon: Icon(
        Icons.star,
        size: 34,
        color: index <= rating
            ? Colors.amber
            : Colors.grey[300],
      ),
      onPressed: () {
        setState(() {
          rating = index;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF7),

      appBar: AppBar(
        backgroundColor: primaryGreen,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const UserDashboardPage(initialIndex: 3),
              ),
            );
          },
        ),
        title: const Text(
          "Give Feedback",
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Rate Your Experience",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
              List.generate(5, (index) => buildStar(index + 1)),
            ),

            const SizedBox(height: 30),

            const Text(
              "Comment",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: commentController,
              cursorColor: Colors.grey,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write your feedback...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey, width: 2),
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: isSubmitting
                    ? null
                    : submitFeedback,
                child: isSubmitting
                    ? const CircularProgressIndicator(

                    color: Colors.white)
                    : const Text(
                  "Submit Feedback",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
