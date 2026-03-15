import 'dart:convert';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/CommonWidget/textfomfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserProfileDetailPage extends StatefulWidget {
  const UserProfileDetailPage({super.key});

  @override
  State<UserProfileDetailPage> createState() => _UserProfileDetailPageState();
}

class _UserProfileDetailPageState extends State<UserProfileDetailPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);

  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController addressCtrl;

  bool isEditing = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    phoneCtrl = TextEditingController();
    addressCtrl = TextEditingController();
    _fetchProfile();
  }

  // ================= GET PROFILE =================
  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = '${Apiconst.base_url}user/profile/';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['success'] == true) {
          final data = decoded['data'];
          nameCtrl.text = data['user_name'] ?? '';
          emailCtrl.text = data['user_email'] ?? '';
          phoneCtrl.text = data['user_phone']?.toString() ?? '';
          addressCtrl.text = data['user_address'] ?? '';
        }
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load profile");
    }

    setState(() => isLoading = false);
  }

  // ================= UPDATE PROFILE =================
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = '${Apiconst.base_url}user/profile/';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        "user_name": nameCtrl.text.trim(),
        "user_email": emailCtrl.text.trim(),
        "user_phone": phoneCtrl.text.trim(),
        "user_address": addressCtrl.text.trim(),
      }),
    );

    setState(() => isLoading = false);

    final decoded = jsonDecode(response.body);

    if (response.statusCode == 200 && decoded['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', nameCtrl.text.trim());
      await prefs.setString('user_email', emailCtrl.text.trim());
      Fluttertoast.showToast(
        msg: decoded['message'] ?? "Profile updated successfully",
        textColor: Colors.white,
        fontSize: 16,
      );

      Navigator.pop(context, true);
      setState(() => isEditing = false);
      await _fetchProfile();
    } else {
      Fluttertoast.showToast(
        msg: decoded['message'] ?? "Update failed",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF7),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
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
                      // ===== ICON =====
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: primaryGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 60,
                          color: primaryGreen,
                        ),
                      ),

                      const SizedBox(height: 30),

                      CommonTextFormField(
                        controller: nameCtrl,
                        hintText: 'Full Name',
                        prefixIcon: Icons.person_outline,
                        readOnly: !isEditing,
                        showCursor: isEditing,
                      ),

                      const SizedBox(height: 14),

                      CommonTextFormField(
                        controller: emailCtrl,
                        hintText: 'Email',
                        prefixIcon: Icons.email_rounded,
                        readOnly: !isEditing,
                        showCursor: isEditing,
                      ),

                      const SizedBox(height: 14),

                      CommonTextFormField(
                        controller: phoneCtrl,
                        hintText: 'Phone Number',
                        prefixIcon: Icons.phone,
                        readOnly: !isEditing,
                        showCursor: isEditing,
                      ),

                      const SizedBox(height: 14),

                      CommonTextFormField(
                        controller: addressCtrl,
                        hintText: 'Address',
                        prefixIcon: Icons.location_on_outlined,
                        readOnly: !isEditing,
                        showCursor: isEditing,
                      ),

                      const SizedBox(height: 30),

                      // ===== BUTTON =====
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
                                    _updateProfile();
                                  }
                                },
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  isEditing ? "Submit Changes" : "Edit Profile",
                                  style: const TextStyle(
                                    fontSize: 18,
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
