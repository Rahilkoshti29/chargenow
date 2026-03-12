import 'dart:convert';

import 'package:chargenow/user/user_profile_3my_1payments_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:chargenow/CommonWidget/apiconst.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RazorpayPage extends StatefulWidget {
  final int bookingId;
  final double amount;
  final int operatorId;

  const RazorpayPage({
    super.key,
    required this.bookingId,
    required this.operatorId,
    required this.amount,
  });

  @override
  State<RazorpayPage> createState() => _RazorpayPageState();
}

class _RazorpayPageState extends State<RazorpayPage> {
  static const Color bgColor = Color(0xFFF2FFF7);
  static const Color primaryGreen = Color(0xFF2ECC71);
  late Razorpay _razorpay;

  Future<void> recordPayment(String paymentId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('${Apiconst.base_url}user/payments/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "booking": widget.bookingId,
        "operator": widget.operatorId,
        "amount": widget.amount,
        "razorpay_payment_id": paymentId,
      }),
    );
    final decoded = jsonDecode(response.body);

    if (decoded['success'] == true) {
      Fluttertoast.showToast(
        msg: decoded['message'] ?? "Payment Successfull",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        fontSize: 16,
      );
    } else {
      Fluttertoast.showToast(
        msg: decoded['message'] ?? "Payment failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white,
        fontSize: 16,
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    openCheckout();
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_SPAXv54T6cAOHf',
      'amount': (widget.amount * 100).toInt(),
      'currency': 'INR',
      'name': 'ChargeNow',
      'description': 'EV Charging Payment',

      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true
      },

      'prefill': {
        'contact': '9999999999',
        'email': 'user@email.com'
      },

      'theme': {'color': '#2ECC71'}
    };


    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await recordPayment(response.paymentId!);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => UserPaymentsPage()),
      (route) => false,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "Payment Failed",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );

    Navigator.pop(context);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("Wallet: ${response.walletName}");
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
        centerTitle: true,
        title:  Text(
          "Processing Payment",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryGreen,
      ),
      body: const Center(child: CircularProgressIndicator(color: primaryGreen)),
    );
  }
}
