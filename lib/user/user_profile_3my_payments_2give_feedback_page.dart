import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class GiveFeedbackPage extends StatefulWidget {

  final int operatorId;

  const GiveFeedbackPage({
    super.key,
    required this.operatorId,
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

    if (rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select rating")),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('${Apiconst.base_url}user/feedback/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        "operator": widget.operatorId,
        "rating": rating,
        "comments": commentController.text
      }),
    );

    setState(() {
      isSubmitting = false;
    });

    if (response.statusCode == 201) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Feedback Submitted Successfully")),
      );

      Navigator.pop(context, true);

    } else {
      print(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback Failed")),

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
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Write your feedback...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
