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
    _refreshVehicles(); // 🔥 ALWAYS load from API
  }

  // ---------------- LOAD USER ----------------

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'User';
    });
  }

  // ---------------- REFRESH VEHICLES ----------------

  void _refreshVehicles() {
    setState(() {
      vehicleFuture = _fetchVehicles();
    });
  }

  // ---------------- FETCH VEHICLES ----------------

  Future<List<dynamic>> _fetchVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token missing');
    }

    final response = await http.get(
      Uri.parse('${Apiconst.base_url}user/vehicles/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Server error ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    return decoded['data'] ?? [];
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF7),

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF2FFF7),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Hello, $userName 👋',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        actions: const [
          Icon(Icons.notifications_none, size: 26, color: Colors.black),
          SizedBox(width: 16),
          Icon(Icons.person_outline, size: 26, color: Colors.black),
          SizedBox(width: 18),
        ],
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: RefreshIndicator(
          color: primaryGreen,
          onRefresh: () async {
            _refreshVehicles();
          },
          child: FutureBuilder<List<dynamic>>(
            future: vehicleFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: primaryGreen),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    snapshot.error.toString(),
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              final vehicles = snapshot.data ?? [];

              // 👇 IMPORTANT: ListView for RefreshIndicator
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  vehicles.isEmpty
                      ? _emptyDashboard()
                      : _vehicleDashboard(vehicles[0]),
                ],
              );
            },
          ),
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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

  // ================= EMPTY DASHBOARD =================

  Widget _emptyDashboard() {
    return Column(
      children: [
        _noVehicleCard(),
        const SizedBox(height: 28),
        _offersRow(),
      ],
    );
  }

  Widget _noVehicleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 14),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_car,
                size: 60, color: primaryGreen),
          ),
          const SizedBox(height: 18),
          const Text(
            'No cars to charge',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a car to get started',
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
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {
                // Navigate to Add Vehicle Page
              },
              child: const Text('Add a car'),
            ),
          ),
        ],
      ),
    );
  }

  // ================= VEHICLE DASHBOARD =================

  Widget _vehicleDashboard(dynamic vehicle) {
    return Column(
      children: [
        _vehicleCard(vehicle),
        const SizedBox(height: 28),
        _offersRow(),
      ],
    );
  }

  Widget _vehicleCard(dynamic vehicle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 14),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('See Details'),
            ),
          ),
          const Icon(Icons.directions_car,
              size: 70, color: primaryGreen),
          const SizedBox(height: 12),
          Text(
            '${vehicle['vehicle_company']} ${vehicle['vehicle_name']}',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(vehicle['vehicle_number']),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () {},
              child: const Text('Request ChargeNow'),
            ),
          ),
        ],
      ),
    );
  }

  // ================= OFFERS =================

  Widget _offersRow() {
    return Row(
      children: [
        _offerCard('Save upto 30%', 'with ChargeNow', Icons.percent),
        const SizedBox(width: 16),
        _offerCard('Fast Charging', 'Nearby operators', Icons.flash_on),
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
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: primaryGreen),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
