import 'dart:async';
import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/vanoperator/operator_3booking_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OperatorGmapPage extends StatefulWidget {
  final double latitude;
  final double longitude;
  final int requestId;

  const OperatorGmapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.requestId,
  });

  @override
  State<OperatorGmapPage> createState() => _OperatorGmapPage();
}

class _OperatorGmapPage extends State<OperatorGmapPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF2FFF7);

  GoogleMapController? mapController;

  LatLng? operatorLocation;
  late LatLng userLocation;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  bool isTravelling = false;
  bool hasArrived = false;

  Timer? movementTimer;

  @override
  void initState() {
    super.initState();
    userLocation = LatLng(widget.latitude, widget.longitude);
    getOperatorLocation();
  }

  @override
  void dispose() {
    movementTimer?.cancel();
    super.dispose();
  }

  // ================= GET OPERATOR LOCATION =================
  Future<void> getOperatorLocation() async {
    await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    operatorLocation = LatLng(position.latitude, position.longitude);

    updateMap();
  }

  // ================= UPDATE MAP =================
  void updateMap() {
    if (operatorLocation == null) return;

    setState(() {
      markers = {
        Marker(
          markerId: const MarkerId("user"),
          position: userLocation,
          infoWindow: const InfoWindow(title: "User Location"),
        ),

        Marker(
          markerId: const MarkerId("operator"),
          position: operatorLocation!,
          infoWindow: const InfoWindow(title: "Your Location"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      };

      polylines = {
        Polyline(
          polylineId: const PolylineId("route"),
          points: [operatorLocation!, userLocation],
          color: primaryGreen,
          width: 5,
        ),
      };
    });
  }

  // ================= ACCEPT / REJECT =================
  Future<void> updateRequest(String action) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    await http.put(
      Uri.parse('${Apiconst.base_url}operator/requests/${widget.requestId}/'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"action": action}),
    );

    if (action == "accept") {
      startMovingToUser();
    } else {
      Navigator.pop(context);
    }
  }

  // ================= 10 SECOND SMOOTH MOVEMENT =================
  void startMovingToUser() {
    if (operatorLocation == null) return;

    setState(() {
      isTravelling = true;
    });

    const totalDuration = 10; // 10 seconds
    const intervalMs = 100; // update every 100ms
    final totalSteps = (totalDuration * 1000) ~/ intervalMs;

    final startLat = operatorLocation!.latitude;
    final startLng = operatorLocation!.longitude;

    final latStep = (userLocation.latitude - startLat) / totalSteps;
    final lngStep = (userLocation.longitude - startLng) / totalSteps;

    int currentStep = 0;

    movementTimer = Timer.periodic(const Duration(milliseconds: intervalMs), (
      timer,
    ) {
      currentStep++;

      if (currentStep >= totalSteps) {
        timer.cancel();

        setState(() {
          operatorLocation = userLocation;
          hasArrived = true;
        });

        updateMap();

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OperatorBooking()),
          );
        });

        return;
      }

      operatorLocation = LatLng(
        operatorLocation!.latitude + latStep,
        operatorLocation!.longitude + lngStep,
      );

      updateMap();
    });
  }

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
          "User Location",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: userLocation,
              zoom: 14,
            ),
            markers: markers,
            polylines: polylines,
            onMapCreated: (controller) {
              mapController = controller;
            },
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
          ),

          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: isTravelling
                ? Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!hasArrived) ...[
                          const CircularProgressIndicator(color: primaryGreen,),
                          const SizedBox(height: 12),
                          const Text(
                            "On the way to user...",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text("Estimated arrival: 10 seconds"),
                        ] else ...[
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 40,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Arrived at location!",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => updateRequest("accept"),
                          child: const Text(
                            "Accept",
                            style: TextStyle(color: Colors.white),
                          ),
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
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => updateRequest("reject"),
                          child: const Text("Reject"),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
