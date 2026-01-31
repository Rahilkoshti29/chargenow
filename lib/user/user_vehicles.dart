import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/user/user_6add_vehicle_page.dart';
import 'package:chargenow/user/user_7vehicle_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyVehiclesPage extends StatefulWidget {
  const MyVehiclesPage({super.key});

  @override
  State<MyVehiclesPage> createState() => _MyVehiclesPageState();
}

class _MyVehiclesPageState extends State<MyVehiclesPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);
  static const Color bgColor = Color(0xFFF2FFF7);

  bool isLoading = true;
  List vehicles = [];

  @override
  void initState() {
    super.initState();
    fetchVehicles();
  }

  Future<void> fetchVehicles() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('${Apiconst.base_url}user/vehicles/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        setState(() {
          vehicles = data['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        centerTitle: true,
        automaticallyImplyActions: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_sharp,
            color: Colors.white,
          ), // optional if icon is single-color
        ),
        title: const Text(
          "My Vehicles",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen,))
          : vehicles.isEmpty
          ? _emptyView()
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: primaryGreen,
                onRefresh: fetchVehicles,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: vehicles.length,
                  itemBuilder: (context, index) {
                    return _bigVehicleCard(vehicles[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        tooltip: "Add Car",
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddVehiclePage(),
            ),
          );
        },
        backgroundColor: primaryGreen,
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }

  /// BIG VEHICLE CARD
  Widget _bigVehicleCard(dynamic vehicle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// See Details
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VehicleDetailsPage(vehicle: vehicle),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Details',
                  style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          /// Car Icon
          Center(
            child: Icon(
              Icons.directions_car_filled,
              size: 90,
              color: primaryGreen,
            ),
          ),

          const SizedBox(height: 16),

          /// Vehicle Name
          Center(
            child: Text(
              "${vehicle['vehicle_company']} ${vehicle['vehicle_name']}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 6),

          /// Vehicle Number
          Center(
            child: Text(
              vehicle['vehicle_number'],
              style: const TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.directions_car_filled, size: 70, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "No Vehicles Added",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            "Add your electric vehicle to get started",
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
