import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ContactSupportPage extends StatelessWidget {
  const ContactSupportPage({super.key});

  static const Color primaryGreen = Color(0xff2ecc71);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2FFF7),

      appBar: AppBar(
        backgroundColor: primaryGreen,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "CONTACT US",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [

            Text(
              "Reach out to us in various ways!",
              style: TextStyle(fontSize: 15),
            ),

            SizedBox(height: 22),

            // ================= CORPORATE ADDRESS =================
            _InfoRow(
              icon: Icons.location_on,
              title: "Corporate Address",
              text:
              "ChargeNow Pvt Ltd,\n"
                  "5th Floor, Shapath-4, Near Karnavati Club,\n"
                  "SG Highway, Ahmedabad, Gujarat – 380015.",
            ),


            SizedBox(height: 18),

            // ================= REGIONAL ADDRESS =================
            // ================= REGIONAL ADDRESS =================
            _InfoRow(
              icon: Icons.apartment,
              title: "Regional Office Address",
              text:
              "Ahmedabad: 12th Floor, Sun WestBank, Near Vallabh Sadan Riverfront, Aashram Road, Ahmedabad – 380009.\n\n"
                  "Surat: 4th Floor, Gaurav Tower, Ring Road, Surat – 395002.\n\n"
                  "Vadodara: Office No. 302, Alkapuri Plaza, Alkapuri, Vadodara – 390007.\n\n"
                  "Rajkot: 3rd Floor, Gopal Complex, Race Course Road, Rajkot – 360001.\n\n"
                  "Bhavnagar: 2nd Floor, Ocean Plaza, Waghawadi Road, Bhavnagar – 364001.",
            ),


            SizedBox(height: 18),

            // ================= EMAIL =================
            _InfoRow(
              icon: Icons.email,
              title: "Email",
              text: "support@chargenow.com",
            ),

            SizedBox(height: 18),

            // ================= MOBILE =================
            _InfoRow(
              icon: Icons.call,
              title: "Mobile",
              text: "+91 98765 43210",
            ),

            SizedBox(height: 25),

            // ================= SOCIAL ICONS =================
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(FontAwesomeIcons.facebook, color: Colors.blue, size: 28),
                SizedBox(width: 18),
                Icon(FontAwesomeIcons.instagram, color: Colors.pink, size: 28),
                SizedBox(width: 18),
                Icon(FontAwesomeIcons.linkedin, color: Colors.blueAccent, size: 28),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.text,
  });

  static const Color primaryGreen = Color(0xff2ecc71);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryGreen, size: 26),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                text,
                style: const TextStyle(fontSize: 14, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
