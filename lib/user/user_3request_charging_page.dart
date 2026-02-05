import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestChargingPage extends StatefulWidget {
  final VoidCallback onBack;
  final int? preselectedVehicleId;

  const RequestChargingPage({
    super.key,
    required this.onBack,
    this.preselectedVehicleId,
  });

  @override
  State<RequestChargingPage> createState() => _RequestChargingPageState();
}

class _RequestChargingPageState extends State<RequestChargingPage> {
  static const Color cnGreen = Color(0xFF1DB954);
  static const Color cnLightGreen = Color(0xFFE8F7EE);

  double currentLevel = 10;
  double requiredLevel = 90;

  int? selectedVehicleId;
  List<Map<String, dynamic>> vehicles = [];

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  // ---------------- API CALL ----------------
  Future<List<Map<String, dynamic>>> fetchVehicles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      debugPrint("TOKEN: $token");

      if (token == null || token.isEmpty) {
        debugPrint("❌ Token missing");
        return [];
      }

      final response = await http.get(
        Uri.parse('${Apiconst.base_url}user/vehicles/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("STATUS CODE: ${response.statusCode}");
      debugPrint("RAW BODY: ${response.body}");

      if (response.statusCode != 200) {
        debugPrint("❌ API failed");
        return [];
      }

      final decoded = jsonDecode(response.body);

      // 🔴 IMPORTANT CHECK
      if (decoded is! Map) {
        debugPrint("❌ Response is not a Map");
        return [];
      }

      if (decoded['success'] == true && decoded['data'] is List) {
        return List<Map<String, dynamic>>.from(decoded['data']);
      }

      debugPrint("❌ No vehicle data found");
      return [];
    } catch (e, stack) {
      debugPrint("❌ fetchVehicles ERROR: $e");
      debugPrint(stack.toString());
      return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cnLightGreen,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: cnGreen,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: const Text(
          "Request ChargeNow",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label("Select Car"),
                  _vehicleDropdown(),
                  const SizedBox(height: 16),
                  _label("Charging Location"),
                  _locationField(),
                  const SizedBox(height: 20),
                  _label("Battery Level"),
                  _batteryCard(),
                ],
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  // ---------------- VEHICLE DROPDOWN ----------------
  Widget _vehicleDropdown() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchVehicles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _emptyBox("No vehicles found");
        }

        final vehicles = snapshot.data!;

        // ✅ AUTO-SELECT FROM PREVIOUS PAGE
        if (selectedVehicleId == null && widget.preselectedVehicleId != null) {
          final match = vehicles.any(
                (v) => v['vehicle_id'] == widget.preselectedVehicleId,
          );

          if (match) {
            selectedVehicleId = widget.preselectedVehicleId;
          }
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: _boxDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              hint: const Text("Select Vehicle"),
              isExpanded: true,
              value: selectedVehicleId,
              items: vehicles.map((v) {
                return DropdownMenuItem<int>(
                  value: v['vehicle_id'], // ✅ ONLY ID
                  child: Text(
                    "${v['vehicle_company']} ${v['vehicle_name']} (${v['vehicle_number']})",
                  ),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  selectedVehicleId = val;
                });
              },
            ),
          ),
        );
      },
    );
  }


  // ---------------- LOCATION ----------------
  Widget _locationField() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _boxDecoration(),
      child: Row(
        children: const [
          Icon(Icons.location_on, color: cnGreen),
          SizedBox(width: 8),
          Text("Select a Location"),
        ],
      ),
    );
  }

  // ---------------- BATTERY ----------------
  Widget _batteryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          _sliderRow("Current Level", currentLevel),
          Slider(
            value: currentLevel,
            min: 0,
            max: 100,
            activeColor: cnGreen,
            onChanged: (v) => setState(() => currentLevel = v),
          ),
          _sliderRow("Required Level", requiredLevel),
          Slider(
            value: requiredLevel,
            min: 0,
            max: 100,
            activeColor: cnGreen,
            onChanged: (v) => setState(() => requiredLevel = v),
          ),
        ],
      ),
    );
  }

  Widget _sliderRow(String title, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        Text("${value.toInt()}%"),
      ],
    );
  }

  // ---------------- BOTTOM ----------------
  Widget _bottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("₹ 923 Approx",
              style: TextStyle(fontWeight: FontWeight.w600)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: cnGreen),
            onPressed: () {
              if (selectedVehicleId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select a vehicle")),
                );
                return;
              }
              // proceed booking
            },
            child: const Text("Book"),
          ),
        ],
      ),
    );
  }

  // ---------------- HELPERS ----------------
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text,
        style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
      )
    ],
  );

  Widget _emptyBox(String text) => Container(
    padding: const EdgeInsets.all(14),
    decoration: _boxDecoration(),
    child: Text(text),
  );
}
