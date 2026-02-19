import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/CommonWidget/textfomfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  static const Color primaryGreen = Color(0xFF2ECC71);

  final _formKey = GlobalKey<FormState>();

  final TextEditingController companyCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController modelCtrl = TextEditingController();
  final TextEditingController numberCtrl = TextEditingController();

  bool isLoading = false;

  // ================= ADD VEHICLE API =================

  Future<void> _addVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('${Apiconst.base_url}user/vehicles/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "vehicle_company": companyCtrl.text.trim(),
        "vehicle_name": nameCtrl.text.trim(),
        "vehicle_model": modelCtrl.text.trim(),
        "vehicle_number": numberCtrl.text.trim(),
      }),
    );

    final decoded = jsonDecode(response.body);

    setState(() => isLoading = false);

    if (decoded['success'] == true) {
      Fluttertoast.showToast(
        msg: decoded['message'] ?? "Vehicle added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        fontSize: 16,
      );
      Navigator.pop(context, true); // refresh dashboard
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(decoded['message'] ?? 'Failed to add vehicle')),
      );
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2FFF7),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Add Vehicle",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff2ecc71),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xff2ecc71)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Container(
                padding: EdgeInsets.all(22),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ================= ICON =================
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.directions_car,
                          size: 60,
                          color: primaryGreen,
                        ),
                      ),

                      SizedBox(height: 30),

                      CommonTextFormField(
                        controller: companyCtrl,
                        hintText: 'Vehicle Company',
                        prefixIcon: Icons.business,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter vehicle company'
                            : null,
                      ),

                      SizedBox(height: 14),

                      CommonTextFormField(
                        controller: nameCtrl,
                        hintText: 'Vehicle Name',
                        prefixIcon: Icons.directions_car,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter vehicle name'
                            : null,
                      ),

                      SizedBox(height: 14),

                      CommonTextFormField(
                        controller: modelCtrl,
                        hintText: 'Vehicle Model',
                        prefixIcon: Icons.settings,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter vehicle model'
                            : null,
                      ),

                      SizedBox(height: 14),

                      CommonTextFormField(
                        controller: numberCtrl,
                        hintText: 'Vehicle Number',
                        prefixIcon: Icons.confirmation_number,
                        keyboardType: TextInputType.text,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Enter vehicle number'
                            : null,
                      ),

                      SizedBox(height: 28),
                      // ================= BUTTON =================
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(26),
                            ),
                          ),
                          onPressed: isLoading ? null : _addVehicle,
                          child: isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
