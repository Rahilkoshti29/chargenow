import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OperatorVanPage extends StatefulWidget {
  const OperatorVanPage({super.key});

  @override
  State<OperatorVanPage> createState() => _OperatorVanPage();
}

class _OperatorVanPage extends State<OperatorVanPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF2FFF7);

  bool isLoading = true;
  bool hasVan = false;

  String vanNumber = '';
  String batteryCapacity = '';
  String? token;

  @override
  void initState() {
    super.initState();
    loadTokenAndFetchVan();
  }

  // Load token
  Future<void> loadTokenAndFetchVan() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null || token!.isEmpty) {
      setState(() {
        isLoading = false;
        hasVan = false;
      });
      return;
    }

    await fetchAssignedVan();
  }

  // Fetch van
  Future<void> fetchAssignedVan() async {
    try {
      final response = await http.get(
        Uri.parse('${Apiconst.base_url}operator/van/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data['success'] == true &&
          data['data'] != null) {
        setState(() {
          hasVan = true;
          vanNumber = data['data']['van_number'] ?? '';
          batteryCapacity = data['data']['battery_capacity'] ?? '';
          isLoading = false;
        });
      } else {
        setState(() {
          hasVan = false;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Van fetch error: $e");
      setState(() {
        hasVan = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "My Assigned Van",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : RefreshIndicator(
              color: primaryGreen,
              onRefresh: fetchAssignedVan,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [hasVan ? _buildVanCard() : _buildNoVanView()],
              ),
            ),
    );
  }

  // ================= UI =================

  Widget _buildVanCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.electric_car, size: 90, color: primaryGreen),
          const SizedBox(height: 16),
          const Text(
            "Assigned Charging Van",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _infoRow("Van Number", vanNumber),
          const SizedBox(height: 10),
          _infoRow("Battery Capacity", batteryCapacity),
        ],
      ),
    );
  }

  Widget _buildNoVanView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(height: 60),
        Icon(Icons.car_rental_outlined, size: 80, color: Colors.grey),
        SizedBox(height: 16),
        Text(
          "No Van Assigned",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Please contact the admin to allocate a charging van to your account.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
