import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OperatorAvailabilityPage extends StatefulWidget {
  const OperatorAvailabilityPage({super.key});

  @override
  State<OperatorAvailabilityPage> createState() =>
      _OperatorAvailabilityPageState();
}

class _OperatorAvailabilityPageState extends State<OperatorAvailabilityPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF2FFF7);

  bool isAvailable = false;
  bool isLoading = false;
  String? token;

  @override
  void initState() {
    super.initState();
    loadToken();
  }

  /// 🔑 Load token
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    // ✅ LOAD AVAILABILITY
    setState(() {
      isAvailable = prefs.getBool('operator_available') ?? false;
    });
  }


  /// 🔄 Update availability status
  Future<void> updateStatus(bool value) async {
    if (token == null) return;

    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();

    final int statusValue = value ? 1 : 0;

    try {
      final response = await http.put(
        Uri.parse('${Apiconst.base_url}operator/status/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': statusValue}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // ✅ SAVE LOCALLY
        await prefs.setBool('operator_available', value);

        setState(() {
          isAvailable = value;
          isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );
      } else {
        _showError(data['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      _showError("Something went wrong. Try again.");
    }
  }


  void _showError(String msg) {
    setState(() => isLoading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Availability",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withOpacity(0.15),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Turn On Availability",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryGreen,
                      ),
                    )
                  : Switch(
                      value: isAvailable,
                      activeColor: primaryGreen,
                      onChanged: updateStatus,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
