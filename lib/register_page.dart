import 'dart:convert';
import 'dart:io';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/CommonWidget/textfomfield.dart';
import 'package:chargenow/login_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum RegisterType { user, operator }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  RegisterType selectedType = RegisterType.user;

  // controllers
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController userEmailController = TextEditingController();
  final TextEditingController userPhoneController = TextEditingController();
  final TextEditingController userAddressController = TextEditingController();
  final TextEditingController userPasswordController = TextEditingController();

  final TextEditingController operatorNameController = TextEditingController();
  final TextEditingController operatorEmailController = TextEditingController();
  final TextEditingController operatorPhoneController = TextEditingController();
  final TextEditingController operatorPasswordController =
      TextEditingController();
  final TextEditingController operatorLicenseController =
      TextEditingController();
  bool isLoading = false;
  bool hidePassword = true;
  final Color primaryGreen = const Color(0xFF2ECC71);
  PlatformFile? pickedFile;

  Future<void> registerUser(BuildContext context) async {
    setState(() => isLoading = true);

    final url = Uri.parse('${Apiconst.base_url}auth/user/register/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_name": userNameController.text.trim(),
          "user_email": userEmailController.text.trim(),
          "user_password": userPasswordController.text.trim(),
          "user_phone": userPhoneController.text.trim(),
          "user_address": userAddressController.text.trim(),
        }),
      );
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            // backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(Duration(milliseconds: 800));

        Navigator.pop(context);
      } else {
        String errorMessage = 'Registration failed';
        if (data.containsKey('user_email')) {
          errorMessage = data['user_email'][0];
        } else if (data.containsKey('message')) {
          errorMessage = data['message'];
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> registerOperator(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    if (pickedFile == null || pickedFile!.path == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Please upload license document")));
      return;
    }

    setState(() => isLoading = true);

    final uri = Uri.parse('${Apiconst.base_url}auth/operator/register/');

    try {
      final request = http.MultipartRequest('POST', uri);

      request.fields['operator_name'] = operatorNameController.text.trim();
      request.fields['operator_email'] = operatorEmailController.text.trim();
      request.fields['operator_phone'] = operatorPhoneController.text.trim();
      request.fields['operator_password'] = operatorPasswordController.text
          .trim();

      request.files.add(
        await http.MultipartFile.fromPath(
          'operator_license_doc',
          pickedFile!.path!,
        ),
      );

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();

      debugPrint("Status Code: ${streamedResponse.statusCode}");
      debugPrint("Body: $responseBody");

      final data = jsonDecode(responseBody);

      if (streamedResponse.statusCode == 201 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));

        await Future.delayed(Duration(milliseconds: 800));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      } else {
        String errorMsg = 'Registration failed';

        //  FILE ERROR (PDF / SIZE / TYPE)
        if (data.containsKey('operator_license_doc')) {
          errorMsg = data['operator_license_doc'][0];
        }
        //  EMAIL ALREADY EXISTS
        else if (data.containsKey('operator_email')) {
          errorMsg = data['operator_email'][0];
        }
        //  GENERIC MESSAGE
        else if (data.containsKey('message')) {
          errorMsg = data['message'];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            // backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Operator Register Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Something went wrong"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickLicenseFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
        operatorLicenseController.text = pickedFile!.name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xff2ecc71)))
          : Column(
              children: [
                Container(
                  height: 230,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: primaryGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 10),
                        Text(
                          "Power Up Your Journey",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Set Up Your Profile & Start Charging Smarter",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // ROLE SELECTOR
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    roleChip("User", RegisterType.user),
                    SizedBox(width: 12),
                    roleChip("Operator", RegisterType.operator),
                  ],
                ),

                SizedBox(height: 20),

                //  FORM
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      key: _formKey,
                      child: selectedType == RegisterType.user
                          ? userForm()
                          : operatorForm(),
                    ),
                  ),
                ),

                //  REGISTER BUTTON
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ), //

                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (selectedType == RegisterType.user) {
                                registerUser(context); // 👤 User API
                              } else {
                                registerOperator(context);
                              }
                            }
                          },
                          child: Text(
                            selectedType == RegisterType.user
                                ? "Register as User"
                                : "Register as Operator",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 14),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: "Already have an account? "),
                              TextSpan(
                                text: "Login",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff2ecc71),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  //  ROLE CHIP
  Widget roleChip(String text, RegisterType type) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 26, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: primaryGreen),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : primaryGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // USER FORM
  Widget userForm() {
    return Column(
      children: [
        CommonTextFormField(
          controller: userNameController,
          hintText: "User Name",
          prefixIcon: Icons.person,
          validator: (v) =>
              v == null || v.isEmpty ? "Enter a Valid Name" : null,
        ),
        SizedBox(height: 20),
        CommonTextFormField(
          controller: userEmailController,
          hintText: "User Email",
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return "Enter Email";
            final regex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            );
            return regex.hasMatch(v) ? null : "Enter Valid Email";
          },
        ),
        SizedBox(height: 20),
        CommonTextFormField(
          controller: userPhoneController,
          hintText: "User Phone",
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (v) {
            if (v == null || v.isEmpty) return "Enter Phone";
            final regex = RegExp(r'^\+?[0-9]{10,15}$');
            return regex.hasMatch(v) ? null : "Invalid Phone";
          },
        ),
        SizedBox(height: 20),
        CommonTextFormField(
          controller: userAddressController,
          hintText: "User Address",
          prefixIcon: Icons.home,
          validator: (v) => v == null || v.isEmpty ? "Enter Address" : null,
        ),
        SizedBox(height: 20),
        CommonTextFormField(
          controller: userPasswordController,
          hintText: "User Password",
          prefixIcon: Icons.lock,
          obscureText: hidePassword,
          suffixIcon: IconButton(
            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                hidePassword = !hidePassword;
              });
            },
          ),
          // validator: (v) {
          //   if (v == null || v.isEmpty) return "Enter Password";
          //   final regex = RegExp(
          //       r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$');
          //   return regex.hasMatch(v) ? null : "Weak Password";
          // },
        ),
      ],
    );
  }

  //  OPERATOR FORM
  Widget operatorForm() {
    return Column(
      children: [
        CommonTextFormField(
          controller: operatorNameController,
          hintText: "Operator Name",
          prefixIcon: Icons.person,
          validator: (v) => v == null || v.isEmpty ? "Enter Name" : null,
        ),
        SizedBox(height: 20),
        CommonTextFormField(
          controller: operatorEmailController,
          hintText: "Operator Email",
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return "Enter Email";
            final regex = RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            );
            return regex.hasMatch(v) ? null : "Invalid Email";
          },
        ),
        SizedBox(height: 20),
        CommonTextFormField(
          controller: operatorPhoneController,
          hintText: "Operator Phone",
          prefixIcon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (v) {
            if (v == null || v.isEmpty) return "Enter Phone";
            final regex = RegExp(r'^\+?[0-9]{10,15}$');
            return regex.hasMatch(v) ? null : "Invalid Phone";
          },
        ),
        SizedBox(height: 20),
        CommonTextFormField(
          controller: operatorPasswordController,
          hintText: "Operator Password",
          prefixIcon: Icons.lock,
          obscureText: hidePassword,
          suffixIcon: IconButton(
            icon: Icon(hidePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                hidePassword = !hidePassword;
              });
            },
          ),
          // validator: (v) {
          //   if (v == null || v.isEmpty) return "Enter Password";
          //   final regex = RegExp(
          //     r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$',
          //   );
          //   return regex.hasMatch(v) ? null : "Weak Password";
          // },
        ),
        SizedBox(height: 20),
        CommonTextFormField(
          controller: operatorLicenseController,
          hintText: "Upload License",
          prefixIcon: Icons.document_scanner,
          validator: (v) => v == null || v.isEmpty ? "Upload License" : null,
          readOnly: true,
          showCursor: false,
          keyboardType: TextInputType.none,
          suffixIcon: IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: pickLicenseFile,
          ),
        ),

        if (pickedFile != null &&
            ['jpg', 'jpeg', 'png'].contains(pickedFile!.extension))
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Image.file(File(pickedFile!.path!), height: 120),
          ),
      ],
    );
  }
}
