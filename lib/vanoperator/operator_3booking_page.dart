import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/vanoperator/operator_0dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class OperatorBooking extends StatefulWidget {
  const OperatorBooking({super.key});

  @override
  State<OperatorBooking> createState() => _OperatorBookingState();
}

class _OperatorBookingState extends State<OperatorBooking> {
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF2FFF7);

  bool isLoading = true;
  List<dynamic> bookings = [];

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  // ================= FETCH BOOKINGS =================
  Future<void> fetchBookings() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final response = await http.get(
      Uri.parse('${Apiconst.base_url}operator/bookings/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      List<dynamic> data = decoded['data'] ?? [];

      //  Latest booking on top
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
        bookings = data;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  // ================= START / COMPLETE CHARGING =================
  Future<void> updateCharging(int bookingId, String action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await http.put(
      Uri.parse('${Apiconst.base_url}operator/charging/$bookingId/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"action": action}),
    );

    fetchBookings();
  }

  // ================= BOOKING CARD =================
  Widget bookingCard(dynamic booking) {
    final int bookingId =
        int.tryParse((booking['booking_id'] ?? '').toString()) ?? 0;

    final int requestId =
        int.tryParse((booking['request_id'] ?? '').toString()) ?? 0;

    final int status =
        int.tryParse((booking['booking_status'] ?? '0').toString()) ?? 0;

    if (bookingId == 0) return const SizedBox();

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
          // ================= BOOKING ID =================
          // Text(
          //   "Booking #$bookingId",
          //   style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          // ),
          //
          // const SizedBox(height: 10),

          // ================= USER NAME =================
          Row(
            children: [
              const Icon(Icons.person, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              Text(
                "User : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                booking['user_name'] ?? "Unknown User",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ================= VEHICLE =================
          Row(
            children: [
              const Icon(Icons.directions_car, size: 18, color: primaryGreen),
              const SizedBox(width: 8),
              Text(
                "Vehicle : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              Text(
                "${booking['vehicle_name'] ?? 'Unknown Vehicle'} "
                "(${booking['vehicle_number'] ?? ''})",
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),

          // const SizedBox(height: 8),
          //
          // /// ================= REQUEST ID =================
          // Row(
          //   children: [
          //     const Icon(Icons.receipt_long, size: 18, color: primaryGreen),
          //     const SizedBox(width: 8),
          //     Text(
          //       "Request ID : $requestId",
          //       style: const TextStyle(fontSize: 14),
          //     ),
          //   ],
          // ),
          const SizedBox(height: 8),

          // ================= DATE =================
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: primaryGreen),
              const SizedBox(width: 8),

              const Text(
                "Request Time : ",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),

              Text(
                booking['created_at'] != null
                    ? DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(DateTime.parse(booking['created_at']).toLocal())
                    : 'N/A',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ================= ACTION BUTTONS =================
          if (status == 0)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => updateCharging(bookingId, "start"),
                child: const Text(
                  "Start Charging",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          if (status == 1)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => updateCharging(bookingId, "complete"),
                child: const Text(
                  "Complete Charging",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

          if (status == 2)
            const Center(
              child: Text(
                "Charging Completed",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => VanOperatorDashboard()),
              (route) => false,
            );
          },
        ),

        centerTitle: true,
        title: const Text(
          "My Bookings",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : RefreshIndicator(
              color: primaryGreen,
              onRefresh: fetchBookings,
              child: bookings.isEmpty
                  ? const Center(child: Text("No Bookings Found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) =>
                          bookingCard(bookings[index]),
                    ),
            ),
    );
  }
}
