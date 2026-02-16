import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OperatorPaymentsPage extends StatefulWidget {
  const OperatorPaymentsPage({super.key});

  @override
  State<OperatorPaymentsPage> createState() => _OperatorPaymentsPageState();
}

class _OperatorPaymentsPageState extends State<OperatorPaymentsPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF2FFF7);

  bool isLoading = true;
  List<dynamic> payments = [];

  @override
  void initState() {
    super.initState();
    fetchPayments();
  }

  // ================= FETCH PAYMENTS =================
  Future<void> fetchPayments() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('${Apiconst.base_url}operator/payments/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      List<dynamic> data = decoded['data'] ?? [];

      // 🔥 Latest payment on top
      data.sort((a, b) {
        final aTime =
            DateTime.tryParse(a['payment_time'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bTime =
            DateTime.tryParse(b['payment_time'] ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

      setState(() {
        payments = data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // ================= HELPERS =================
  String paymentMethodText(int value) {
    switch (value) {
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

  String paymentStatusText(int value) {
    return value == 1 ? "Completed" : "Pending";
  }

  Color paymentStatusColor(int value) {
    return value == 1 ? Colors.green : Colors.orange;
  }

  // ================= PAYMENT CARD =================
  Widget paymentCard(dynamic payment) {
    final int paymentId =
        int.tryParse((payment['payment_id'] ?? '').toString()) ?? 0;

    final int bookingId =
        int.tryParse((payment['booking_id'] ?? '').toString()) ?? 0;

    final double amount =
        double.tryParse((payment['amount'] ?? '0').toString()) ?? 0;

    final int method =
        int.tryParse((payment['payment_method'] ?? '0').toString()) ?? 0;

    final int status =
        int.tryParse((payment['payment_status'] ?? '0').toString()) ?? 0;

    final String userName = payment['user_name'] ?? "Unknown User";

    if (paymentId == 0) return const SizedBox();

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
          /// USER
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

          /// BOOKING ID
          Row(
            children: [
              const Icon(Icons.receipt_long, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              const Text(
                "Booking ID : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text("#$bookingId"),
            ],
          ),

          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.payment, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              const Text(
                "Method : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                method == 0
                    ? "Cash"
                    : method == 1
                    ? "Card"
                    : method == 2
                    ? "UPI"
                    : "Unknown",
              ),
            ],
          ),
          const SizedBox(height: 8),
          /// AMOUNT
          Row(
            children: [
              const Icon(Icons.currency_rupee, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              const Text(
                "Amount : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                "₹ ${amount.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// PAYMENT METHOD




          /// DATE (Formatted)
          Row(
            children: const [
              Icon(
                Icons.info_outline,
                size: 18,
                color: primaryGreen,
              ),
              SizedBox(width: 8),
              Text("Status : ",style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),),
              Text(
                "Completed",   // or "Pending" if you want dynamic text
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),


          const SizedBox(height: 12),

          /// STATUS BADGE

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
          "My Payments",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : RefreshIndicator(
              color: primaryGreen,
              onRefresh: fetchPayments,
              child: payments.isEmpty
                  ? const Center(child: Text("No Payments Found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: payments.length,
                      itemBuilder: (context, index) =>
                          paymentCard(payments[index]),
                    ),
            ),
    );
  }
}
