import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;

  const GoogleMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {

  GoogleMapController? mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Location")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(widget.latitude, widget.longitude),
          zoom: 15,
        ),
        markers: {
          Marker(
            markerId: const MarkerId("userLocation"),
            position: LatLng(widget.latitude, widget.longitude),
          )
        },
        onMapCreated: (controller) {
          mapController = controller;
        },
      ),
    );
  }
}
