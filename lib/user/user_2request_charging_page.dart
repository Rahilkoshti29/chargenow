import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/user/OperatorMapPage.dart';
import 'package:chargenow/user/user_select_location_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF2FFF7);

  List<Map<String, dynamic>> vehicles = [];
  bool isLoading = true;

  int? selectedVehicleId;

  double currentLevel = 10;
  double requiredLevel = 90;

  final double ratePerPercent = 12;
  final double gstRate = 0.18;

  String? selectedAddress;
  double? selectedLat;
  double? selectedLng;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${Apiconst.base_url}user/vehicles/'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final decoded = jsonDecode(response.body);
    vehicles = List<Map<String, dynamic>>.from(decoded['data']);

    if (widget.preselectedVehicleId != null) {
      final exists = vehicles.any(
        (v) => v['vehicle_id'] == widget.preselectedVehicleId,
      );
      if (exists) {
        selectedVehicleId = widget.preselectedVehicleId;
      }
    }

    setState(() => isLoading = false);
  }

  Future<void> _findNearbyOperators() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(
        "${Apiconst.base_url}user/nearby-operators/?lat=$selectedLat&lng=$selectedLng",
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded['success'] != true ||
          decoded['data'] == null ||
          decoded['data'].isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No operators found")),
        );
        return;
      }

      final List operators = decoded['data'];   // ✅ THIS WAS MISSING

      print("Operators List: $operators");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OperatorMapPage(
            userLat: selectedLat!,
            userLng: selectedLng!,
            operators: operators,   // ✅ now correct
            vehicleId: selectedVehicleId!,
            batteryNeeded: batteryNeeded,
            totalAmount: totalAmount,
          ),
        ),
      );
    } else {
      print("SERVER ERROR");
    }
  }

  double get batteryNeeded => (requiredLevel - currentLevel).clamp(0, 100);
  double get baseAmount => batteryNeeded * ratePerPercent;
  double get gstAmount => baseAmount * gstRate;
  double get totalAmount => baseAmount + gstAmount;

  Widget _locationField() => GestureDetector(
    onTap: () async {
      final LatLng? result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SelectLocationPage()),
      );

      if (!mounted) return;

      if (result != null) {
        setState(() {
          selectedLat = result.latitude;
          selectedLng = result.longitude;
          selectedAddress = "Lat: ${result.latitude}, Lng: ${result.longitude}";
        });
      }
    },
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: _boxDecoration(),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: primaryGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              selectedAddress ?? "Select a Location",
              style: TextStyle(
                color: selectedAddress == null ? Colors.black54 : Colors.black,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: const Text(
          "Request ChargeNow",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : Column(
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
                        const SizedBox(height: 16),
                        _label("Battery Level"),
                        _batteryCard(),
                        const SizedBox(height: 16),
                        _label("Price Details"),
                        _priceCard(),
                      ],
                    ),
                  ),
                ),
                _requestButton(),
              ],
            ),
    );
  }

  Widget _vehicleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _boxDecoration(),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          hint: const Text("Select Vehicle"),
          value: selectedVehicleId,
          items: vehicles.map((v) {
            return DropdownMenuItem<int>(
              value: v['vehicle_id'],
              child: Text("${v['vehicle_company']} ${v['vehicle_name']}"),
            );
          }).toList(),
          onChanged: (v) => setState(() => selectedVehicleId = v),
        ),
      ),
    );
  }

  Widget _batteryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          _slider(
            "Current Level",
            currentLevel,
            (v) => setState(() => currentLevel = v),
          ),
          _slider(
            "Required Level",
            requiredLevel,
            (v) => setState(() => requiredLevel = v),
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(label), Text("${value.toInt()}%")],
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          activeColor: primaryGreen,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _priceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _boxDecoration(),
      child: Column(
        children: [
          _priceRow("Battery Needed", "${batteryNeeded.toInt()}%"),
          _priceRow("Base Amount", "₹ ${baseAmount.toStringAsFixed(2)}"),
          _priceRow("GST (18%)", "₹ ${gstAmount.toStringAsFixed(2)}"),
          const Divider(),
          _priceRow(
            "Total Amount",
            "₹ ${totalAmount.toStringAsFixed(2)}",
            bold: true,
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
        ),
      ],
    );
  }

  Widget _requestButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () async {
          if (selectedVehicleId == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select vehicle")),
            );
            return;
          }

          if (selectedLat == null || selectedLng == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please select location")),
            );
            return;
          }

          await _findNearbyOperators();
        },
        child: const Text(
          "Find Near by Operator",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _label(String t) =>
      Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(t));

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
    ],
  );
}
