import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  Future<void> updateRequest(int requestId, String action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await http.put(
      Uri.parse('${Apiconst.base_url}operator/requests/$requestId/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"action": action}),
    );

    fetchRequests();
  }

  // ================= REQUEST CARD =================
  Widget requestCard(dynamic req) {
    final int requestId = int.tryParse(
      (req['request_id'] ?? req['id'] ?? '').toString(),
    ) ?? 0;

    final int status = int.tryParse(
      (req['request_status'] ?? '0').toString(),
    ) ?? 0;

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
          Text("Request ID: $requestId"),
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              Text(
                "User ID : ${req['user_id']}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.electric_car, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              Text(
                "Vehicle ID : ${req['vehicle_id']}",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text("Latitude : ${req['user_latitude']}"),
          Text("Longitude : ${req['user_longitude']}"),
          const SizedBox(height: 14),

          if (status == 0)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () =>
                        updateRequest(requestId, "accept"),
                    child: const Text("Accept",style: TextStyle(color: Colors.white),),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () =>
                        updateRequest(requestId, "reject"),
                    child: const Text("Reject"),
                  ),
                ),
              ],
            ),

          if (status == 1)
            const Text("Accepted",
                style: TextStyle(color: Colors.green)),

          if (status == 2)
            const Text("Rejected",
                style: TextStyle(color: Colors.red)),
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
          onPressed: (){
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
          ? const Center(
        child: CircularProgressIndicator(color: primaryGreen),
      )
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
