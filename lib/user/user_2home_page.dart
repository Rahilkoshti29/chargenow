import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/user/myprofiledetails.dart';
import 'package:chargenow/user/user_3request_charging_page.dart';
import 'package:chargenow/user/user_6add_vehicle_page.dart';
import 'package:chargenow/user/user_7vehicle_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final Function(int index, {int? vehicleId}) onTabChange;
  final VoidCallback onNotificationTap;

  const HomePage({
    super.key,
    required this.onNotificationTap,
    required this.onTabChange,
  });
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color primaryGreen = Color(0xFF2ECC71);

  late Future<List<dynamic>> vehicleFuture;
  String userName = 'User';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _refreshVehicles();
  }
  int _currentIndex = 0;
  void goToHome() {
    setState(() => _currentIndex = 0);
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
    });
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
      backgroundColor: Color(0xFFF2FFF7),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        toolbarHeight: 70,
        automaticallyImplyLeading: false,
        titleSpacing: 30,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello',
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                wordSpacing: 150,
              ),
            ),
            Text(
              '$userName !',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: widget.onNotificationTap,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.notifications_none,
                color: Colors.black,
                size: 25,
              ),
            ),
          ),
          SizedBox(width: 16),

          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfileDetailPage()));
            },
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white,
              child: Icon(Icons.person_outline, color: Colors.black, size: 25),
            ),
          ),
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
              return Center(
                child: CircularProgressIndicator(color: primaryGreen),
              );
            }

            final vehicles = snapshot.data ?? [];

            return ListView(
              padding: EdgeInsets.all(18),
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                if (vehicles.isEmpty) ...[
                  _emptyCenterCard(),
                  SizedBox(height: 28),
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
                  SizedBox(height: 28),
                  _offersRow(),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  // ================= EMPTY CENTER CARD =================
  Widget _emptyCenterCard() {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
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
            padding: EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.directions_car, size: 70, color: primaryGreen),
          ),
          SizedBox(height: 18),
          Text(
            'No Cars to Charge',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            'Add a Car to Get Started',
            style: TextStyle(color: Colors.black54),
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding: EdgeInsets.symmetric(vertical: 16),
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
              child: Text(
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
      margin: EdgeInsets.only(right: 18),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
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
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
          ),
          SizedBox(height: 18),
          Icon(Icons.directions_car, size: 90, color: primaryGreen),
          SizedBox(height: 16),
          Text(
            '${vehicle['vehicle_company']} ${vehicle['vehicle_name']}',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            vehicle['vehicle_number'],
            style: TextStyle(color: Colors.black54),
          ),
          Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              onPressed: () {
                widget.onTabChange(1);
                vehicleId: vehicle['vehicle_id'];

              },
              child: Text(
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
        margin: EdgeInsets.only(right: 18),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
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
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 70, color: primaryGreen),
            ),
            SizedBox(height: 24),
            Text(
              'Add Vehicle',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Add Another Car to ChargeNow',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  // ================= OFFERS ROW =================
  Widget _offersRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 120,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.celebration, size: 28, color: primaryGreen),
                    SizedBox(height: 10),
                    Text(
                      'First Charge',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Special welcome offer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Container(
                height: 120,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ev_station, size: 34, color: primaryGreen),
                    SizedBox(height: 10),
                    Text(
                      'Doorstep',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Charging',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                height: 120,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.percent, color: primaryGreen, size: 28),
                    SizedBox(height: 10),
                    Text(
                      'Save Upto 30%',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'With ChargeNow',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Container(
                height: 120,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.flash_on, color: primaryGreen, size: 28),
                    SizedBox(height: 10),
                    Text(
                      'Fast Charging',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Nearby Operators',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
