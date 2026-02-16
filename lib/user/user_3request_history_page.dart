import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestHistoryPage extends StatefulWidget {
  final VoidCallback onBack;
  const RequestHistoryPage({super.key, required this.onBack,});

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

  // ================= FETCH REQUESTS =================
  Future<void> fetchRequests() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        debugPrint("❌ Token missing");
        setState(() => isLoading = false);
        return;
      }

      final response = await http.get(
        Uri.parse('${Apiconst.base_url}user/requests/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      debugPrint("STATUS: ${response.statusCode}");
      debugPrint("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded['success'] == true && decoded['data'] is List) {
          List<Map<String, dynamic>> list =
          List<Map<String, dynamic>>.from(decoded['data']);

          // 🔥 Latest request_id first
          list.sort((a, b) =>
              (b['request_id'] ?? 0).compareTo(a['request_id'] ?? 0));

          setState(() {
            requests = list;
          });
        }
      }
    } catch (e) {
      debugPrint("❌ fetchRequests error: $e");
    }

    setState(() => isLoading = false);
  }

  // ================= STATUS HELPERS =================
  String requestStatusText(int status) {
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

  Color requestStatusColor(int status) {
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

  IconData requestStatusIcon(int status) {
    switch (status) {
      case 1:
        return Icons.check_circle_outline;
      case 2:
        return Icons.cancel_outlined;
      case 3:
        return Icons.done_all;
      default:
        return Icons.hourglass_bottom;
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: Text(
          "My Requests",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff2ecc71),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: primaryGreen),
      )
          : RefreshIndicator(
        color: primaryGreen,
        onRefresh: fetchRequests,
        child: requests.isEmpty
            ? ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 250),
            Center(
              child: Text(
                'No requests found',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        )
            : ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final req = requests[index];
            final int status = req['request_status'] ?? 0;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Request #${req['request_id']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.directions_car,
                          color: primaryGreen),
                      const SizedBox(width: 8),
                      Text(
                        'Vehicle ID : ${req['vehicle_id']}',
                        style:
                        const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        requestStatusIcon(status),
                        color: requestStatusColor(status),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        requestStatusText(status),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color:
                          requestStatusColor(status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
