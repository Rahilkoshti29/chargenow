import 'package:chargenow/user/user_profile_3my_payments_2give_feedback_page.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserPaymentsPage extends StatefulWidget {
  const UserPaymentsPage({super.key});

  @override
  State<UserPaymentsPage> createState() => _UserPaymentsPageState();
}

class _UserPaymentsPageState extends State<UserPaymentsPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF2FFF7);

  late Future<List<dynamic>> paymentFuture;

  @override
  void initState() {
    super.initState();
    paymentFuture = fetchPayments();
  }

  void _refreshPayments() {
    setState(() {
      paymentFuture = fetchPayments();
    });
  }

  // ---------------- API CALL ----------------
  Future<List<dynamic>> fetchPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${Apiconst.base_url}user/payments/'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final decoded = jsonDecode(response.body);

    if (decoded['success'] == true) {
      return decoded['data'] ?? [];
    } else {
      return [];
    }
  }

  // ---------------- METHOD LABEL ----------------
  String getMethod(int? method) {
    switch (method) {
      case 0:
        return "Cash";
      case 1:
        return "Card";
      case 2:
        return "UPI";
      default:
        return "Unknown";
    }
  }

  // ---------------- STATUS LABEL ----------------
  String getStatus(int? status) {
    switch (status) {
      case 1:
        return "Completed";
      case 0:
        return "Pending";
      default:
        return "Unknown";
    }
  }

  Color getStatusColor(int? status) {
    switch (status) {
      case 1:
        return Colors.green;
      case 0:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ---------------- DATE FORMAT ----------------
  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "";
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  // ---------------- PAYMENT CARD ----------------
  Widget _paymentCard(dynamic payment) {
    final status = payment['payment_status'];
    final method = payment['payment_method'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Booking #${payment['booking_id'] ?? ''}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: getStatusColor(status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  getStatus(status),
                  style: TextStyle(
                    color: getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.electric_car, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              const Text(
                "Operator : ",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(payment['operator_name'] ?? ''),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.payment, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              const Text(
                "Method : ",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(getMethod(method)),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹ ${payment['amount'] ?? 0}",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatDate(payment['created_at']),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ================= GIVE FEEDBACK BUTTON =================
          if (status == 1)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GiveFeedbackPage()),
                  );
                },
                child: const Text(
                  "Give Feedback",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- UI ----------------
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
          "My Payments",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
      ),
      body: RefreshIndicator(
        color: primaryGreen,
        onRefresh: () async => _refreshPayments(),
        child: FutureBuilder<List<dynamic>>(
          future: paymentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryGreen),
              );
            }

            if (snapshot.hasError) {
              return const Center(child: Text("Something went wrong"));
            }

            final payments = snapshot.data ?? [];

            if (payments.isEmpty) {
              return const Center(
                child: Text(
                  "No Payments Found",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: payments.length,
              itemBuilder: (context, index) {
                return _paymentCard(payments[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
