import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/vanoperator/operator_8gmap_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OperatorRequestPage extends StatefulWidget {
  const OperatorRequestPage({super.key});

  @override
  State<OperatorRequestPage> createState() => _OperatorRequestPageState();
}

class _OperatorRequestPageState extends State<OperatorRequestPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF2FFF7);

  bool isLoading = true;
  List<dynamic> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  // ================= FETCH REQUESTS =================
  Future<void> fetchRequests() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('${Apiconst.base_url}operator/requests/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      setState(() {
        requests = List.from(decoded['data'] ?? []).reversed.toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // ================= ACCEPT / REJECT =================
  Future<bool> updateRequest(int requestId, String action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.put(
      Uri.parse('${Apiconst.base_url}operator/requests/$requestId/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"action": action}),
    );

    if (response.statusCode == 200) {
      fetchRequests();
      return true;
    }
    return false;
  }

  // ================= REQUEST CARD =================
  Widget requestCard(dynamic req) {
    final int requestId =
        int.tryParse((req['request_id'] ?? '').toString()) ?? 0;

    final int status =
        int.tryParse((req['request_status'] ?? '0').toString()) ?? 0;

    if (requestId == 0) return const SizedBox();

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
          // Text(
          //   "Request #$requestId",
          //   style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          // ),

          // const SizedBox(height: 10),

          //  USER NAME
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              Text(
                "User : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text("${req['user_name'] ?? 'N/A'}"),
            ],
          ),

          const SizedBox(height: 8),

          // VEHICLE NAME
          Row(
            children: [
              const Icon(Icons.electric_car, size: 18, color: primaryGreen),
              const SizedBox(width: 8),

              Text(
                "Vehicle : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),

              Text(
                "${req['vehicle_name'] ?? 'N/A'} "
                "(${req['vehicle_number'] ?? ''})",
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.currency_rupee, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              Text(
                "Amount : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                "₹${req['amount']}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: primaryGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

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
                    ? DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(DateTime.parse(req['created_at']).toLocal())
                    : 'N/A',
              ),
            ],
          ),
          const SizedBox(height: 8),

          if (status == 0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  double lat =
                      double.tryParse(req['user_latitude']?.toString() ?? '') ??
                      0.0;

                  double lng =
                      double.tryParse(
                        req['user_longitude']?.toString() ?? '',
                      ) ??
                      0.0;

                  if (lat != 0.0 && lng != 0.0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OperatorGmapPage(
                          latitude: lat,
                          longitude: lng,
                          requestId: requestId,
                        ),
                      ),
                    ).then((_) {
                      //  REFRESH AFTER RETURNING FROM MAP
                      fetchRequests();
                    });
                  }
                },
                icon: const Icon(Icons.map, color: Colors.white),
                label: const Text(
                  "View User Location",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          if (status == 1)
            Row(
              children: const [
                Icon(Icons.info_outline, size: 18, color: primaryGreen),
                SizedBox(width: 6),
                Text(
                  "Status : ",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  "Accepted",
                  style: TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

          if (status == 2)
            Row(
              children: const [
                Icon(Icons.info_outline, size: 18, color: primaryGreen),
                SizedBox(width: 6),
                Text(
                  "Status : ",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text("Rejected", style: TextStyle(color: Colors.red)),
              ],
            ),
          if (status == 3)
            Row(
              children: const [
                Icon(Icons.info_outline, size: 18, color: primaryGreen),
                SizedBox(width: 6),
                Text(
                  "Status : ",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text("Completed", style: TextStyle(color: Colors.orange)),
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
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Charging Requests",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff2ecc71),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : RefreshIndicator(
              color: primaryGreen,
              onRefresh: fetchRequests,
              child: requests.isEmpty
                  ? const Center(child: Text("No Requests Found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: requests.length,
                      itemBuilder: (context, index) =>
                          requestCard(requests[index]),
                    ),
            ),
    );
  }
}
