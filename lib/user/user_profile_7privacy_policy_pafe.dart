import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
          "PRIVACY POLICY",
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
              "At ChargeNow, your privacy is important to us. This Privacy Policy explains how we collect, use, and protect your personal information while using our mobile charging services.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "INFORMATION WE COLLECT",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "We may collect basic information such as your name, contact number, email address, vehicle details, location, and booking history to provide seamless doorstep EV charging services.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "HOW WE USE YOUR INFORMATION",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Your information is used to manage charging requests, assign nearby charging vans, improve service quality, send booking updates, and ensure secure transactions.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "DATA SECURITY",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "ChargeNow uses secure systems and industry-standard practices to protect your data from unauthorized access or misuse.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "USER CONSENT",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "By using the ChargeNow application, you agree to the collection and use of information as described in this policy.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "THIRD-PARTY SHARING",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "We do not share your personal information with third parties except for authorized service providers, legal requirements, or with your explicit consent.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "COOKIES & ANALYTICS",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "We may use cookies, analytics, and similar technologies to monitor app performance, enhance user experience, and understand user preferences.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "USER RIGHTS",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "Users have the right to access, correct, or delete their personal information by contacting our support team. You may also withdraw consent to data collection at any time.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "DATA RETENTION",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "We retain personal data only as long as necessary for providing our services or to comply with legal obligations. Unused data is securely deleted after this period.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "CHANGES TO PRIVACY POLICY",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "ChargeNow may update this Privacy Policy from time to time. Users will be notified of major changes through the app.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),

            Text(
              "CONTACT INFORMATION",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              "For questions regarding this Privacy Policy, please contact us at support@chargenow.com.",
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
