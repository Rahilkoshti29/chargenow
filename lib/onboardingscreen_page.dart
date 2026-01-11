import 'package:chargenow/login_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final introKey = GlobalKey<IntroductionScreenState>();

  /// ✅ This is the MOST IMPORTANT method
  Future<void> _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // 🔥 Mark onboarding as completed
    await prefs.setBool('seen_onboarding', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Widget _buildImage(String assetName, [double width = 320]) {
    return Image.asset(
      'assets/images/$assetName',
      width: width,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 18);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      pageColor: Colors.white,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: true,
      autoScrollDuration: 4000,
      infiniteAutoScroll: true,

      pages: [
        PageViewModel(
          title: "Welcome to ChargeNow",
          body:
          "Your smart EV charging companion ⚡\n"
              "Find nearby charging stations and power your journey with ease.",
          image: _buildImage('Intro1.png'),
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 3,
          ),
        ),
        PageViewModel(
          title: "Charge Smarter, Drive Further",
          body:
          "Locate verified charging stations in real-time.\n"
              "No waiting. No confusion. Just seamless charging.",
          image: _buildImage('Intro2.png'),
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 3,
          ),
        ),
        PageViewModel(
          title: "Built for Drivers & Operators",
          body:
          "Whether you’re an EV driver or a station operator,\n"
              "ChargeNow connects everyone on one platform.",
          image: _buildImage('Intro3.png'),
          decoration: pageDecoration.copyWith(
            bodyFlex: 2,
            imageFlex: 3,
          ),
        ),
      ],

      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),

      showSkipButton: true,
      showBackButton: false,

      skip: const Text(
        "Skip",
        style: TextStyle(
          color: Color(0xFF2ECC71),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      next: const CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFF2ECC71),
        child: Icon(Icons.arrow_forward, color: Colors.white),
      ),
      done: const CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFF2ECC71),
        child: Text(
          "Done",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),

      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? const EdgeInsets.all(12)
          : const EdgeInsets.fromLTRB(8, 4, 8, 4),

      dotsDecorator: const DotsDecorator(
        size: Size(10, 10),
        color: Color(0xFF2ECC71),
        activeSize: Size(22, 10),
        activeColor: Colors.grey,
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
      ),
    );
  }
}
