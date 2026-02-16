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
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Booking #${payment['booking_id'] ?? ''}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

          const SizedBox(height: 8),

          Text(
            "Operator: ${payment['operator_name'] ?? ''}",
            style: const TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 4),

          Text(
            "Method: ${getMethod(method)}",
            style: const TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 8),

          const Divider(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "₹ ${payment['amount'] ?? 0}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatDate(payment['created_at']),
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
            ],
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
              return const Center(
                child: Text("Something went wrong"),
              );
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
