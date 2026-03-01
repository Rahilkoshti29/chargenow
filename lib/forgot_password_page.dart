import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/CommonWidget/textfomfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${Apiconst.base_url}auth/forgot-password/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "new_password": confirmPasswordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));

        Future.delayed( Duration(seconds: 1), () {
          Navigator.pop(context);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Something went wrong"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
          content: Text("Server error. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
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
          "Forgot Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xff2ecc71),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xff2ecc71)))
          : SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 25,
                right: 25,
                top: 40,
                bottom: MediaQuery.of(context).viewInsets.bottom + 30,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Enter your email and set a new password",
                      style: TextStyle(color: Colors.grey),
                    ),

                    SizedBox(height: 35),

                    CommonTextFormField(
                      controller: emailController,
                      hintText: "Email",
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Email is required";
                        }
                        if (!v.contains('@')) {
                          return "Enter valid email";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 20),

                    CommonTextFormField(
                      controller: passwordController,

                      hintText: "New Password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: hidePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            hidePassword = !hidePassword;
                          });
                        },
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Password is required";
                        }

                        if (v.length < 8) {
                          return "Must be at least 8 characters";
                        }

                        if (!RegExp(r'[A-Z]').hasMatch(v)) {
                          return "Must contain at least 1 uppercase letter";
                        }

                        if (!RegExp(r'[a-z]').hasMatch(v)) {
                          return "Must contain at least 1 lowercase letter";
                        }

                        if (!RegExp(r'[0-9]').hasMatch(v)) {
                          return "Must contain at least 1 number";
                        }

                        if (!RegExp(r'[!@#\$&*~]').hasMatch(v)) {
                          return "Must contain at least 1 special character (!@#\$&*~)";
                        }

                        return null;
                      },
                    ),

                    SizedBox(height: 20),

                    CommonTextFormField(
                      controller: confirmPasswordController,
                      hintText: "Confirm Password",
                      prefixIcon: Icons.lock_outline,
                      obscureText: hideConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          hideConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            hideConfirmPassword = !hideConfirmPassword;
                          });
                        },
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return "Confirm your password";
                        }
                        if (v != passwordController.text) {
                          return "Passwords do not match";
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: 35),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff2ecc71),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: resetPassword,
                        child: Text(
                          "Reset Password",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
