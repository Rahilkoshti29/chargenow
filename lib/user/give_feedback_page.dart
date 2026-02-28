import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chargenow/CommonWidget/textfomfield.dart';

class GiveFeedbackPage extends StatefulWidget {
  const GiveFeedbackPage({super.key});

  @override
  State<GiveFeedbackPage> createState() => _GiveFeedbackPageState();
}

class _GiveFeedbackPageState extends State<GiveFeedbackPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);

  int rating = 0;
  final TextEditingController commentController = TextEditingController();

  bool isSubmitting = false;

  // ---------------- SUBMIT FEEDBACK ----------------
  Future<void> submitFeedback() async {
    if (rating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select rating")));
      return;
    }

    setState(() => isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('${Apiconst.base_url}user/feedback/'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      // body: {
      //   'operator_id':
      //   widget.operatorId.toString(),
      //   'rating': rating.toString(),
      //   'comments': commentController.text,
      // },
    );

    final decoded = jsonDecode(response.body);

    setState(() => isSubmitting = false);

    if (decoded['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback Submitted Successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit feedback")),
      );
    }
  }

  // ---------------- STAR WIDGET ----------------
  Widget buildStar(int index) {
    return IconButton(
      onPressed: () {
        setState(() {
          rating = index;
        });
      },
      icon: Icon(
        Icons.star,
        size: 32,
        color: index <= rating ? Colors.amber : Colors.grey[300],
      ),
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Rate Your Experience",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => buildStar(index + 1)),
            ),

            const SizedBox(height: 25),

            const Text(
              "Comment",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 10),

            CommonTextFormField(
              controller: commentController,
              hintText: "Write your feedback...",
              prefixIcon: Icons.comment,
              keyboardType: TextInputType.multiline,
              maxLines: 4,
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: isSubmitting ? null : submitFeedback,
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit Feedback",
                        style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
