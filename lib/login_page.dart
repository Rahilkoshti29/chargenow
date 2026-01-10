import 'dart:convert';
import 'package:chargenow/user/user_1dashboard_page.dart';
import 'package:chargenow/vanoperator/vanoperator_1dashboard_page.dart';
import 'package:http/http.dart' as http;
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:chargenow/CommonWidget/textfomfield.dart';
import 'package:chargenow/register_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  Future<void> login(BuildContext context) async {
    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${Apiconst.base_url}auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      setState(() => isLoading = false);

      if (response.statusCode == 200 && data['success'] == true) {
        await _handleLoginSuccess(context, data);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Invalid email or password"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleLoginSuccess(BuildContext context, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('token', data['token']);
    await prefs.setInt('role', data['user']['role']);
    await prefs.setString('email', data['user']['email']);
    await prefs.setString('name', data['user']['name']);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(data['message'])));

    await Future.delayed(const Duration(milliseconds: 400));

    if (data['user']['role'] == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => UserDashboard()),
      );
    } else if (data['user']['role'] == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => VanoperatorDashboard()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff2ecc71)),
            )
          : Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xff2ecc71), Color(0xff27ae60)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.ev_station, color: Colors.white, size: 80),
                        SizedBox(height: 10),
                        Text(
                          "ChargeNow",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Transform.translate(
                    offset: const Offset(0, -30),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(35),
                      ),
                      child: Container(
                        color: Colors.white,
                        padding: const EdgeInsets.fromLTRB(25, 40, 25, 25),
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                const Text(
                                  "Welcome Back!",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 30),
                                CommonTextFormField(
                                  controller: emailController,
                                  hintText: "Email",
                                  prefixIcon: Icons.email_outlined,
                                  validator: (v) {
                                    if (v!.isEmpty) return "Email required";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                CommonTextFormField(
                                  controller: passwordController,
                                  hintText: "Password",
                                  prefixIcon: Icons.lock_outline,
                                  obscureText: hidePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      hidePassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () => setState(
                                      () => hidePassword = !hidePassword,
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v!.isEmpty) return "Password required";
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xff2ecc71),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        login(context);
                                      }
                                    },
                                    child: const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 25,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RegisterPage(),
                                      ),
                                    );
                                  },
                                  child: const Text.rich(
                                    TextSpan(
                                      text: "Don't have an account? ",
                                      children: [
                                        TextSpan(
                                          text: "Sign Up",
                                          style: TextStyle(
                                            color: Color(0xff2ecc71),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
