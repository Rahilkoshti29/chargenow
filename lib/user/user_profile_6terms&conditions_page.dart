import 'package:flutter/material.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  static const Color primaryGreen = Color(0xFF2ECC71);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF7),
      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "TERMS & CONDITIONS",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "These Terms and Conditions govern your use of the ChargeNow mobile application and services.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "SERVICE OVERVIEW",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "ChargeNow provides doorstep electric vehicle charging through mobile charging vans operated by authorized partners.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "BOOKING POLICY",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Bookings are subject to availability of nearby charging vans. Estimated arrival times may vary due to traffic or operational conditions.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "USER RESPONSIBILITY",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Users must provide accurate vehicle and location details to ensure successful charging service.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "PAYMENTS",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "All payments made through ChargeNow are final and subject to applicable taxes and service charges.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "CANCELLATIONS & REFUNDS",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Cancellations can be made through the app before the scheduled service time. Refunds may apply according to the cancellation policy.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "PRIVACY",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "We collect and process personal data in accordance with our Privacy Policy. User information will not be shared with unauthorized third parties.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "LIABILITY",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "ChargeNow is not liable for damages resulting from improper vehicle use, inaccurate information, or unforeseen service interruptions.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "INTELLECTUAL PROPERTY",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "All content, logos, and designs within the ChargeNow app are the property of ChargeNow and may not be used without prior written permission.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "CHANGES TO TERMS",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "We reserve the right to modify these terms at any time. Users will be notified of significant changes through the app.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "CONTACT INFORMATION",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "For questions regarding these Terms and Conditions, please contact us at support@chargenow.com",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
