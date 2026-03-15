import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/user/razorpay_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BookingHistoryPage extends StatefulWidget {
  const BookingHistoryPage({super.key});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF2FFF7);

  bool isLoading = true;
  List<Map<String, dynamic>> bookings = [];

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

    final response = await http.get(
      Uri.parse('${Apiconst.base_url}user/bookings/'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      List<Map<String, dynamic>> list = List<Map<String, dynamic>>.from(
        decoded['data'],
      );

      list.sort(
        (a, b) => (b['booking_id'] ?? 0).compareTo(a['booking_id'] ?? 0),
      );

      setState(() => bookings = list);
    }

    setState(() => isLoading = false);
  }

  // ================= CALCULATE CHARGING DURATION =================
  String getDuration(String? start, String? end) {
    if (start == null || end == null) {
      return "Charging Running";
    }

    DateTime startTime = DateTime.parse(start).toLocal();
    DateTime endTime = DateTime.parse(end).toLocal();

    Duration diff = endTime.difference(startTime);

    int minutes = diff.inMinutes;
    int seconds = diff.inSeconds % 60;

    if (minutes > 0) {
      return "$minutes min $seconds sec";
    } else {
      return "$seconds sec";
    }
  }

  // ================= STATUS TEXT =================
  String statusText(int status) {
    switch (status) {
      case 1:
        return 'Started';
      case 2:
        return 'Completed';
      default:
        return 'In Progress';
    }
  }

  // ================= STATUS COLOR =================
  Color statusColor(int status) {
    switch (status) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  // ================= BOOKING CARD =================
  Widget bookingCard(Map<String, dynamic> booking) {
    final int status = booking['booking_status'] ?? 0;

    bool isPaid = false;

    if (booking['payments'] != null && booking['payments'].isNotEmpty) {
      for (var p in booking['payments']) {
        if (p['payment_status'] == 1) {
          isPaid = true;
          break;
        }
      }
    }

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
          // ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Booking #${booking['booking_id']}",
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

              Text("${booking['vehicle_name'] ?? 'N/A'}"),
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

              Text("${booking['operator_name'] ?? 'N/A'}"),
            ],
          ),

          const SizedBox(height: 8),

          // ================= BOOKING TIME =================
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: primaryGreen),

              const SizedBox(width: 8),

              const Text(
                "Booking Time : ",
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

          const SizedBox(height: 8),

          // ================= CHARGING DURATION =================
          if (booking['start_time'] != null)
            Row(
              children: [
                const Icon(Icons.timer, size: 18, color: primaryGreen),

                const SizedBox(width: 8),

                const Text(
                  "Charging Duration : ",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),

                Text(getDuration(booking['start_time'], booking['end_time'])),
              ],
            ),

          const SizedBox(height: 15),

          // ================= PAYMENT BUTTON =================
          if (status == 2)
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPaid ? Colors.grey : primaryGreen,

                  padding: const EdgeInsets.symmetric(vertical: 12),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                onPressed: isPaid
                    ? null
                    : () async {
                        final result = await Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) => RazorpayPage(
                              bookingId: booking['booking_id'],
                              operatorId: booking['operator'],
                              amount: double.parse(
                                booking['amount'].toString(),
                              ),
                            ),
                          ),
                        );

                        if (result == true) {
                          setState(() {
                            booking['payments'] = [
                              {"payment_status": 1},
                            ];
                          });
                        }
                      },

                child: Text(
                  isPaid ? "Paid" : "Pay Now",
                  style: const TextStyle(
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

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
              onRefresh: fetchBookings,
              color: primaryGreen,
              child: bookings.isEmpty
                  ? const Center(child: Text("No Bookings Found"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),

                      itemCount: bookings.length,

                      itemBuilder: (_, i) => bookingCard(bookings[i]),
                    ),
            ),
    );
  }
}
