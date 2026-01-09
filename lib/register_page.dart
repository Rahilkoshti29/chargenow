import 'dart:convert';
import 'dart:io';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/CommonWidget/textfomfield.dart';
import 'package:chargenow/login_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  // ================= CONTROLLERS =================
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
  final ImagePicker _picker = ImagePicker();
  XFile? pickedFile;

  Future<void> registerUser(BuildContext context) async {
    setState(() => isLoading = true);

    final url = Uri.parse('${Apiconst.base_url}auth/user/register/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "user_name": userNameController.text.trim(),
          "user_email": userEmailController.text.trim(),
          "user_password": userPasswordController.text.trim(),
          "user_phone": userPhoneController.text.trim(),
          "user_address": userAddressController.text.trim(),
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      // ✅ SUCCESS
      if (response.statusCode == 201 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
           // backgroundColor: Colors.green,
          ),
        );

        // ⏳ small delay so user sees success msg
        await Future.delayed(const Duration(milliseconds: 800));

        // 🔙 BACK TO LOGIN PAGE
        Navigator.pop(context);
      }

      else {
        String errorMessage = 'Registration failed';

        if (data.containsKey('user_email')) {
          errorMessage = data['user_email'][0];
        } else if (data.containsKey('message')) {
          errorMessage = data['message'];
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }



  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      setState(() {
        pickedFile = image;
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
            // ================= HEADER =================
            Container(
              height: 230,
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Center(
                child: Text(
                  "Register Now !!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ================= ROLE SELECTOR =================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                roleChip("User", RegisterType.user),
                const SizedBox(width: 12),
                roleChip("Operator", RegisterType.operator),
              ],
            ),

            const SizedBox(height: 20),

            // ================= FORM =================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: selectedType == RegisterType.user
                      ? userForm()
                      : operatorForm(),
                ),
              ),
            ),

            // ================= REGISTER BUTTON =================
            Padding(
              padding: const EdgeInsets.all(20),
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
                      ),//

                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (selectedType == RegisterType.user) {
                            registerUser(context);      // 👤 User API
                          } else {
                           // registerOperator();  // 🚐 Operator API
                          }
                        }
                      },
                      child: Text(
                        selectedType == RegisterType.user
                            ? "Register as User"
                            : "Register as Operator",style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text.rich(
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

  // ================= ROLE CHIP =================
  Widget roleChip(String text, RegisterType type) {
    final isSelected = selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
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

  // ================= USER FORM =================
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
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
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
          validator: (v) =>
          v == null || v.isEmpty ? "Enter Address" : null,
        ),
        SizedBox(height: 20),
        CommonTextFormField(
          controller: userPasswordController,
          hintText: "User Password",
          prefixIcon: Icons.lock,
          obscureText: hidePassword,
          suffixIcon: IconButton(
            icon: Icon(
                hidePassword ? Icons.visibility_off : Icons.visibility),
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

  // ================= OPERATOR FORM =================
  Widget operatorForm() {
    return Column(
      children: [
        CommonTextFormField(
          controller: operatorNameController,
          hintText: "Operator Name",
          prefixIcon: Icons.person,
          validator: (v) =>
          v == null || v.isEmpty ? "Enter Name" : null,
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
                r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
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
            icon: Icon(
                hidePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () {
              setState(() {
                hidePassword = !hidePassword;
              });
            },
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return "Enter Password";
            final regex = RegExp(
                r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$');
            return regex.hasMatch(v) ? null : "Weak Password";
          },
        ),
        SizedBox(height: 20),
        CommonTextFormField(
          controller: operatorLicenseController,
          hintText: "Upload License",
          prefixIcon: Icons.document_scanner,
          validator: (v) =>
          v == null || v.isEmpty ? "Upload License" : null,
          suffixIcon: IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: pickImage,
          ),
        ),
        if (pickedFile != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Image.file(
              File(pickedFile!.path),
              height: 120,
            ),
          ),
      ],
    );
  }
}

// Future<void> registerOperatorApi() async {
//   if (!_formKey.currentState!.validate()) return;
//
//   if (pickedFile == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("Please upload license document")),
//     );
//     return;
//   }
//
//   final mimeTypeData =
//   lookupMimeType(pickedFile!.path)?.split('/');
//
//   final request = http.MultipartRequest(
//     'POST',
//     Uri.parse("YOUR_API_URL_HERE"),
//   );
//
//   request.fields['operator_name'] = operatorNameController.text;
//   request.fields['operator_email'] = operatorEmailController.text;
//   request.fields['operator_phone'] = operatorPhoneController.text;
//   request.fields['operator_password'] = operatorPasswordController.text;
//
//   request.files.add(
//     await http.MultipartFile.fromPath(
//       'operator_license_doc',
//       pickedFile!.path,
//       contentType: MediaType(
//         mimeTypeData![0],
//         mimeTypeData[1],
//       ),
//     ),
//   );
//
//   try {
//     final response = await request.send();
//     final responseBody = await response.stream.bytesToString();
//
//     final data = jsonDecode(responseBody);
//
//     if (response.statusCode == 200 && data['error'] == false) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(data['message'])),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(data['message'] ?? "Registration failed")),
//       );
//     }
//   } catch (e) {
//     debugPrint("API Error: $e");
//   }
// }

// Future<void> registerUserApi() async {
//   if (!_formKey.currentState!.validate()) return;
//
//   try {
//     final response = await http.post(
//       Uri.parse("YOUR_API_URL_HERE"),
//       body: {
//         'user_name': userNameController.text,
//         'user_email': userEmailController.text,
//         'user_phone': userPhoneController.text,
//         'user_address': userAddressController.text,
//         'user_password': userPasswordController.text,
//       },
//     );
//
//     final data = jsonDecode(response.body);
//
//     if (data['error'] == false) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(data['message'])),
//       );
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(data['message'])),
//       );
//     }
//   } catch (e) {
//     debugPrint("User API Error: $e");
//   }
// }


