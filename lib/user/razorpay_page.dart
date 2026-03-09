import 'dart:convert';

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

  static const Color primaryGreen = Color(0xFF2ECC71);
  late Razorpay _razorpay;


  Future<void> recordPayment() async {

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
        "payment_method": 2
      }),
    );

    print(response.body);

    if (response.statusCode == 201) {

      print("Payment Stored Successfully");

    } else {

      print("Payment Failed");
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
        'upi': true
      },
      'prefill': {
        'contact': '9999999999',
        'email': 'user@email.com'
      },
      'theme': {
        'color': '#2ECC71'
      }
    };

    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async{
    await recordPayment();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Successful"),
        content: Text("Payment ID: ${response.paymentId}"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Failed"),
        content: Text(response.message ?? "Error occurred"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
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
      appBar: AppBar(
        title: const Text("Processing Payment"),
        backgroundColor: primaryGreen,
      ),
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
