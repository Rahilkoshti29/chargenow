import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/user/user_profile_4myprofile_detail_page.dart';
import 'package:chargenow/user/user_1home_page_add_vehicle_page.dart';
import 'package:chargenow/user/user_1home_page_vehicle_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserHomePage extends StatefulWidget {
  final Function(int index, {int? vehicleId}) onTabChange;
  final VoidCallback onNotificationTap;

  const UserHomePage({
    super.key,
    required this.onNotificationTap,
    required this.onTabChange,
  });

  @override
  State<UserHomePage> createState() => _UserHomePage();
}

class _UserHomePage extends State<UserHomePage> {
  static const Color primaryGreen = Color(0xFF2ECC71);

  late Future<List<dynamic>> vehicleFuture;
  String userName = 'User';


  @override
  void initState() {
    super.initState();
    _loadUserName();
    _refreshVehicles();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('name') ?? 'User';
    setState(() {});
  }

  void _refreshVehicles() {
    vehicleFuture = _fetchVehicles();
    setState(() {});
  }

  Future<List<dynamic>> _fetchVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${Apiconst.base_url}user/vehicles/'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final decoded = jsonDecode(response.body);
    return decoded['data'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    _loadUserName();
    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF7),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        titleSpacing: 30,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello',
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            Text(
              '$userName !',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          // GestureDetector(
          //   onTap: widget.onNotificationTap,
          //   child: const CircleAvatar(
          //     radius: 22,
          //     backgroundColor: Colors.white,
          //     child: Icon(
          //       Icons.notifications_none,
          //       color: Colors.black,
          //       size: 25,
          //     ),
          //   ),
          // ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const UserProfileDetailPage(),
                ),
              );

              _loadUserName();
            },


            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline, color: Colors.black, size: 25),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),

      // ================= BODY =================
      body: RefreshIndicator(
        color: primaryGreen,
        onRefresh: () async => _refreshVehicles(),
        child: FutureBuilder<List<dynamic>>(
          future: vehicleFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryGreen),
              );
            }

            final vehicles = snapshot.data ?? [];

            return ListView(
              padding: const EdgeInsets.all(18),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (vehicles.isEmpty) ...[
                  _emptyCenterCard(),
                  const SizedBox(height: 28),
                  _offersRow(),
                ] else ...[
                  SizedBox(
                    height: 360,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: vehicles.length + 1,
                      itemBuilder: (context, index) {
                        if (index < vehicles.length) {
                          return _vehicleCard(vehicles[index]);
                        } else {
                          return _addVehicleCard();
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 28),
                  _offersRow(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= VEHICLE CARD =================
  Widget _vehicleCard(dynamic vehicle) {
    return Container(
      width: 330,
      margin: const EdgeInsets.only(right: 18),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehicleDetailsPage(vehicle: vehicle),
                  ),
                );
                if (result == true) _refreshVehicles();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Icon(Icons.directions_car, size: 90, color: primaryGreen),
          const SizedBox(height: 16),
          Text(
            '${vehicle['vehicle_company']} ${vehicle['vehicle_name']}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            vehicle['vehicle_number'],
            style: const TextStyle(color: Colors.black54),
          ),
          const Spacer(),

          // BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: () {
                // ONLY switch tab & pass vehicleId
                widget.onTabChange(1, vehicleId: vehicle['vehicle_id']);
              },
              child: const Text(
                'Request ChargeNow',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= EMPTY CARD =================
  Widget _emptyCenterCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car,
              size: 70,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No Cars to Charge',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add a Car to Get Started',
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddVehiclePage()),
                );
                if (result == true) _refreshVehicles();
              },
              child: const Text(
                'Add a Car',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= ADD VEHICLE CARD =================
  Widget _addVehicleCard() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AddVehiclePage()),
        );
        if (result == true) _refreshVehicles();
      },
      child: Container(
        width: 330,
        margin: const EdgeInsets.only(right: 18),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 70, color: primaryGreen),
            ),
            const SizedBox(height: 24),
            const Text(
              'Add Vehicle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add Another Car to ChargeNow',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // ================= OFFERS =================
  Widget _offersRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _offerBox(
                Icons.celebration,
                'First Charge',
                'Special welcome offer',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _offerBox(Icons.ev_station, 'Doorstep', 'Charging'),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _offerBox(
                Icons.percent,
                'Save Upto 30%',
                'With ChargeNow',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _offerBox(
                Icons.flash_on,
                'Fast Charging',
                'Nearby Operators',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _offerBox(IconData icon, String title, String subtitle) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: primaryGreen, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
