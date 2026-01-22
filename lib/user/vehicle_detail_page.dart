import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/CommonWidget/textfomfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VehicleDetailsPage extends StatefulWidget {
  final dynamic vehicle;

  const VehicleDetailsPage({super.key, required this.vehicle});

  @override
  State<VehicleDetailsPage> createState() => _VehicleDetailsPageState();
}

class _VehicleDetailsPageState extends State<VehicleDetailsPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);

  final _formKey = GlobalKey<FormState>();

  late TextEditingController companyCtrl;
  late TextEditingController nameCtrl;
  late TextEditingController modelCtrl;
  late TextEditingController numberCtrl;

  bool isEditing = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    companyCtrl = TextEditingController(
      text: widget.vehicle['vehicle_company'],
    );
    nameCtrl = TextEditingController(text: widget.vehicle['vehicle_name']);
    modelCtrl = TextEditingController(text: widget.vehicle['vehicle_model']);
    numberCtrl = TextEditingController(text: widget.vehicle['vehicle_number']);
  }

  // ================= UPDATE VEHICLE API =================
  Future<void> _updateVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url =
        '${Apiconst.base_url}user/vehicles/${widget.vehicle['vehicle_id']}/';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "vehicle_company": companyCtrl.text.trim(),
        "vehicle_name": nameCtrl.text.trim(),
        "vehicle_model": modelCtrl.text.trim(),
        "vehicle_number": numberCtrl.text.trim(),
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded['success'] == true) {
        Fluttertoast.showToast(
          msg: decoded['message'] ?? "Vehicle updated successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          fontSize: 16,
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pop(context, true);
        });
      } else {
        Fluttertoast.showToast(
          msg: decoded['message'] ?? "Update failed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          textColor: Colors.white,
          backgroundColor: Colors.red,
          fontSize: 16,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Server error. Please try again',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        backgroundColor: Colors.red,
        fontSize: 16,
      );
    }
  }

  // ================= DELETE VEHICLE API =================
  Future<void> _deleteVehicle() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url =
        '${Apiconst.base_url}user/vehicles/${widget.vehicle['vehicle_id']}/';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 204) {
        try {
          final decoded = jsonDecode(response.body);
          Fluttertoast.showToast(
            msg: decoded['message'] ?? 'Vehicle deleted successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            fontSize: 16,
          );
        } catch (e) {
          Fluttertoast.showToast(
            msg: 'Vehicle deleted successfully',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white,
            fontSize: 16,
          );
        }

        Future.delayed(const Duration(milliseconds: 800), () {
          Navigator.pop(context, true);
        });
      } else {
        final decoded = jsonDecode(response.body);
        Fluttertoast.showToast(
          msg: decoded['message'] ?? 'Failed to delete vehicle',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,

          textColor: Colors.white,
          fontSize: 16,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      Fluttertoast.showToast(
        msg: 'Server error. Please try again',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        fontSize: 16,
      );
    }
  }

  // ================= ALERT DIALOG =================
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // White background
          title: const Text("Delete Vehicle"),
          content: const Text("Are you sure you want to delete this vehicle?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text("No", style: TextStyle(color: Colors.black)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                _deleteVehicle(); // Call delete API
              },
              child: const Text("Yes", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_sharp,
            color: Colors.white,
          ), // optional if icon is single-color
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "My Vehicle Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff2ecc71),
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(22),
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_car,
                          size: 60,
                          color: primaryGreen,
                        ),
                      ),

                      const SizedBox(height: 30),

                      CommonTextFormField(
                        controller: companyCtrl,
                        hintText: 'Vehicle Company',
                        prefixIcon: Icons.business,
                        readOnly: !isEditing,
                        showCursor: isEditing,
                      ),

                      const SizedBox(height: 14),

                      CommonTextFormField(
                        controller: nameCtrl,
                        hintText: 'Vehicle Name',
                        prefixIcon: Icons.directions_car,
                        readOnly: !isEditing,
                        showCursor: isEditing,
                      ),

                      const SizedBox(height: 14),

                      CommonTextFormField(
                        controller: modelCtrl,
                        hintText: 'Vehicle Model',
                        prefixIcon: Icons.settings,
                        readOnly: !isEditing,
                        showCursor: isEditing,
                      ),

                      const SizedBox(height: 14),

                      CommonTextFormField(
                        controller: numberCtrl,
                        hintText: 'Vehicle Number',
                        prefixIcon: Icons.confirmation_number,
                        readOnly: !isEditing,
                        showCursor: isEditing,
                      ),

                      const SizedBox(height: 30),

                      Column(
                        children: [
                          // ================= SUBMIT BUTTON =================
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
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (!isEditing) {
                                        setState(() => isEditing = true);
                                      } else {
                                        _updateVehicle();
                                      }
                                    },
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      isEditing
                                          ? "Submit Changes"
                                          : "Change Vehicle Details",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ================= DELETE BUTTON =================
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(26),
                                ),
                              ),
                              onPressed: isLoading ? null : _confirmDelete,
                              child: const Text(
                                'Delete Vehicle',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
