import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OperatorFeedbackPage extends StatefulWidget {
  const OperatorFeedbackPage({super.key});

  @override
  State<OperatorFeedbackPage> createState() => _OperatorFeedbackPageState();
}

class _OperatorFeedbackPageState extends State<OperatorFeedbackPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF2FFF7);

  bool isLoading = true;
  List<dynamic> feedbacks = [];

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }

  // ================= FETCH FEEDBACKS =================
  Future<void> fetchFeedbacks() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('${Apiconst.base_url}operator/feedback/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> data = decoded['data'] ?? [];

      //  Latest feedback first
      data.sort((a, b) {
        final aTime =
            DateTime.tryParse(a['created_at'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bTime =
            DateTime.tryParse(b['created_at'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      setState(() {
        feedbacks = data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // ================= STAR RATING UI =================
  Widget buildStars(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  // ================= FEEDBACK CARD =================
  Widget feedbackCard(dynamic feedback) {
    final int feedbackId =
        int.tryParse((feedback['feedback_id'] ?? '').toString()) ?? 0;

    final int rating =
        int.tryParse((feedback['rating'] ?? '0').toString()) ?? 0;

    final String comment = feedback['comments'] ?? '';

    final String userName = feedback['user_name'] ?? "Unknown User";

    if (feedbackId == 0) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // USER
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              const Text(
                "User : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(userName),
            ],
          ),

          const SizedBox(height: 8),

          // RATING
          Row(
            children: [
              const Icon(Icons.star, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              const Text(
                "Rating : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                "$rating / 5",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // STARS
          Row(
            children: List.generate(
              5,
              (index) => Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // COMMENT
          if (comment.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.comment, size: 18, color: primaryGreen),
                    SizedBox(width: 8),
                    Text(
                      "Comment : ",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),

          const SizedBox(height: 10),

          // DATE (Formatted)
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              const Text(
                "Feedback Time : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                feedback['created_at'] != null
                    ? DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(DateTime.parse(feedback['created_at']).toLocal())
                    : 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "My Feedbacks",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : RefreshIndicator(
              color: primaryGreen,
              onRefresh: fetchFeedbacks,
              child: feedbacks.isEmpty
                  ? const Center(child: Text("No Feedback Found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: feedbacks.length,
                      itemBuilder: (context, index) =>
                          feedbackCard(feedbacks[index]),
                    ),
            ),
    );
  }
}
