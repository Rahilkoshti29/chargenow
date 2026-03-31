import 'dart:async';
import 'dart:convert';
import 'package:chargenow/CommonWidget/textfomfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../CommonWidget/apiconst.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  static const Color primaryGreen = Color(0xFF2ECC71);

  int step = 1;
  bool loading = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool hidePassword = true;

  List<TextEditingController> otpControllers =
  List.generate(6, (_) => TextEditingController());

  List<FocusNode> focusNodes =
  List.generate(6, (_) => FocusNode());

  int seconds = 60;
  Timer? timer;

  String getOTP() {
    return otpControllers.map((c) => c.text).join();
  }

  void startTimer() {
    seconds = 60;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (seconds == 0) {
        timer.cancel();
      } else {
        setState(() => seconds--);
      }
    });
  }

  // SEND OTP
  Future sendOTP() async {
    setState(() => loading = true);

    final response = await http.post(
      Uri.parse("${Apiconst.base_url}auth/send-otp/"),
      body: {"email": emailController.text.trim()},
    );

    final data = jsonDecode(response.body);

    setState(() => loading = false);

    if (data["success"]) {
      startTimer();
      setState(() => step = 2);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(data["message"])));
    }
  }

  // VERIFY OTP
  Future verifyOTP() async {
    setState(() => loading = true);

    final response = await http.post(
      Uri.parse("${Apiconst.base_url}auth/verify-otp/"),
      body: {
        "email": emailController.text.trim(),
        "otp": getOTP(),
      },
    );

    final data = jsonDecode(response.body);

    setState(() => loading = false);

    if (data["success"]) {
      setState(() => step = 3);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(data["message"])));
    }
  }

  // RESET PASSWORD
  Future resetPassword() async {
    setState(() => loading = true);

    final response = await http.post(
      Uri.parse("${Apiconst.base_url}auth/reset-password/"),
      body: {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
      },
    );

    final data = jsonDecode(response.body);

    setState(() => loading = false);

    if (data["success"]) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password Updated Successfully")),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(data["message"])));
    }
  }

  Widget otpBox(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        cursorColor: primaryGreen,
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryGreen),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
            const BorderSide(color: primaryGreen, width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context)
                .requestFocus(focusNodes[index + 1]);
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context)
                .requestFocus(focusNodes[index - 1]);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF2FFF7),

      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Forgot Password",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.8),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ICON + LOADER (FIXED CENTER)
                  Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.lock_reset,
                          size: 90,
                          color: primaryGreen,
                        ),
                        const SizedBox(height: 10),

                        AnimatedSwitcher(
                          duration:
                          const Duration(milliseconds: 300),
                          child: loading
                              ? const SizedBox(
                            width: 30,
                            height: 30,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 3,
                              color: primaryGreen,
                            ),
                          )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // STEP 1: EMAIL
                  if (step == 1)
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          CommonTextFormField(
                            controller: emailController,
                            hintText: "Enter Email",
                            prefixIcon: Icons.email_outlined,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty) {
                                return "Email is required";
                              }

                              final regex = RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

                              if (!regex.hasMatch(value)) {
                                return "Enter valid email";
                              }

                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loading
                                  ? null
                                  : () {
                                if (formKey.currentState!
                                    .validate()) {
                                  sendOTP();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                padding:
                                const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                "Send OTP",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // STEP 2: OTP
                  if (step == 2)
                    Column(
                      children: [
                        const Text("Enter OTP",
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children:
                          List.generate(6, otpBox),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                            loading ? null : verifyOTP,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              padding:
                              const EdgeInsets.symmetric(
                                  vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              "Verify OTP",
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        seconds == 0
                            ? TextButton(
                          onPressed: sendOTP,
                          child: const Text(
                            "Resend OTP",
                            style: TextStyle(
                                color: primaryGreen,
                                fontWeight:
                                FontWeight.bold),
                          ),
                        )
                            : Text(
                          "Resend OTP in $seconds sec",
                          style: const TextStyle(
                              color: primaryGreen),
                        ),
                      ],
                    ),

                  // STEP 3: RESET PASSWORD
                  if (step == 3)
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          CommonTextFormField(
                            controller: passwordController,
                            hintText: "New Password",
                            prefixIcon: Icons.lock,
                            obscureText: hidePassword,
                            suffixIcon: IconButton(
                              icon: Icon(hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  hidePassword =
                                  !hidePassword;
                                });
                              },
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "Password required";
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

                          const SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: loading
                                  ? null
                                  : () {
                                if (formKey.currentState!
                                    .validate()) {
                                  resetPassword();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                padding:
                                const EdgeInsets.symmetric(
                                    vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                "Reset Password",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
