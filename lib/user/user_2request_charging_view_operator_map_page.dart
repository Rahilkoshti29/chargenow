import 'dart:convert';
import 'package:chargenow/user/user_0dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../CommonWidget/apiconst.dart';

class OperatorMapPage extends StatefulWidget {
  final double userLat;
  final double userLng;
  final List operators;
  final int vehicleId;
  final double batteryNeeded;
  final double totalAmount;

  const OperatorMapPage({
    super.key,
    required this.userLat,
    required this.userLng,
    required this.operators,
    required this.vehicleId,
    required this.batteryNeeded,
    required this.totalAmount,
  });

  @override
  State<OperatorMapPage> createState() => _OperatorMapPageState();
}

class _OperatorMapPageState extends State<OperatorMapPage> {
  GoogleMapController? _controller;
  Set<Marker> markers = {};

  static const Color primaryGreen = Color(0xFF2ECC71); // ChargeNow green

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  void _loadMarkers() {
    // User Marker
    markers.add(
      Marker(
        markerId: const MarkerId("user"),
        position: LatLng(widget.userLat, widget.userLng),
        infoWindow: const InfoWindow(title: "Your Location"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Operator Markers
    for (var op in widget.operators) {
      markers.add(
        Marker(
          markerId: MarkerId(op['operator_id'].toString()),
          position: LatLng(
            double.parse(op['latitude'].toString()),
            double.parse(op['longitude'].toString()),
          ),
          infoWindow: InfoWindow(
            title: op['operator_name'],
            snippet: "${op['distance_km']} km away",
          ),
          onTap: () {
            _showBottomSheet(op);
          },
        ),
      );
    }

    setState(() {});
  }

  void _showBottomSheet(Map operator) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                operator['operator_name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text("Distance: ${operator['distance_km']} km"),
              const SizedBox(height: 5),
              Text(
                "Amount: ₹ ${widget.totalAmount.toStringAsFixed(2)}",
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _createRequest(operator);
                  },
                  child: const Text(
                    "Request Charging",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _createRequest(Map operator) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse("${Apiconst.base_url}user/requests/"),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "vehicle": widget.vehicleId,
        "operator": operator['operator_id'],
        "amount": widget.totalAmount.toInt(),
        "user_latitude": double.parse(widget.userLat.toStringAsFixed(6)),
        "user_longitude": double.parse(widget.userLng.toStringAsFixed(6)),
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request Sent Successfully")),
      );

      //  Redirect to Request History Page
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => UserDashboardPage(initialIndex: 2)),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${response.body}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Near by Operators",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.userLat, widget.userLng),
          zoom: 14,
        ),
        markers: markers,
        onMapCreated: (controller) {
          _controller = controller;
        },
      ),
    );
  }
}
