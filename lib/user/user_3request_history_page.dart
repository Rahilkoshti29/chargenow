import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class RequestHistoryPage extends StatefulWidget {
  final VoidCallback onBack;
  const RequestHistoryPage({super.key, required this.onBack});

  @override
  State<RequestHistoryPage> createState() => _RequestHistoryPageState();
}

class _RequestHistoryPageState extends State<RequestHistoryPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF2FFF7);

  bool isLoading = true;
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${Apiconst.base_url}user/requests/'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        decoded['data'],
      );

      list.sort(
        (a, b) => (b['request_id'] ?? 0).compareTo(a['request_id'] ?? 0),
      );

      setState(() => requests = list);
    }

    setState(() => isLoading = false);
  }

  String statusText(int status) {
    switch (status) {
      case 1:
        return 'Accepted';
      case 2:
        return 'Rejected';
      case 3:
        return 'Completed';
      default:
        return 'Pending';
    }
  }

  Color statusColor(int status) {
    switch (status) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.red;
      case 3:
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  Widget requestCard(Map<String, dynamic> req) {
    final int status = req['request_status'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ================= HEADER ROW (Like Booking Page) =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Request #${req['request_id'] ?? 'N/A'}",
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
                  color: statusColor(status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText(status),
                  style: TextStyle(
                    color: statusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ================= VEHICLE =================
          Row(
            children: [
              const Icon(Icons.directions_car, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              const Text(
                "Vehicle Name : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text("${req['vehicle_name'] ?? 'N/A'}"),
            ],
          ),

          const SizedBox(height: 8),

          // ================= OPERATOR =================
          Row(
            children: [
              const Icon(Icons.electric_car, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              const Text(
                "Operator Name : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text("${req['operator_name'] ?? 'N/A'}"),
            ],
          ),

          const SizedBox(height: 8),

          // ================= REQUEST TIME =================
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              const Text(
                "Request Time : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                req['created_at'] != null
                    ? DateFormat('dd MMM yyyy, hh:mm a')
                    .format(DateTime.parse(req['created_at']).toLocal())
                    : 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text(
          "My Requests",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchRequests,
              child: requests.isEmpty
                  ? const Center(child: Text("No Requests Found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      itemBuilder: (_, i) => requestCard(requests[i]),
                    ),
            ),
    );
  }
}
