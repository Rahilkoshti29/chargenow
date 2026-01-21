import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF7),

      // ================= APP BAR =================
      appBar: AppBar(
        automaticallyImplyActions: false,
        backgroundColor: const Color(0xFF2ECC71),
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text(
            'Hello, $userName 👋',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black),
          SizedBox(width: 16),
          Icon(Icons.person_outline, color: Colors.black),
          SizedBox(width: 16),
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
                // ================= EMPTY STATE =================
                if (vehicles.isEmpty) ...[
                  _emptyCenterCard(),
                  const SizedBox(height: 28),
                  _offersRow(),
                ]
                // ================= VEHICLE LIST =================
                else ...[
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

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.arrow_back), label: ''),
        ],
      ),
    );
  }

  // ================= EMPTY CENTER CARD =================

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
              onPressed: () {},
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Details',
                style: TextStyle(fontWeight: FontWeight.bold),
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
              onPressed: () {},
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

  // ================= ADD VEHICLE CARD =================

  Widget _addVehicleCard() {
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
    );
  }

  // ================= OFFERS =================

  Widget _offersRow() {
    return Row(
      children: [
        _offerCard('Save Upto 30%', 'With ChargeNow', Icons.percent),
        const SizedBox(width: 16),
        _offerCard('Fast Charging', 'Nearby Operators', Icons.flash_on),
      ],
    );
  }

  Widget _offerCard(String title, String subtitle, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryGreen),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
