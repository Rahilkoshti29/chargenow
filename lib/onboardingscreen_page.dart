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

  Future<void> _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('seen_onboarding', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
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
      titleTextStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
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
          title: "Welcome To ChargeNow",
          body:
              "Your Smart EV Charging Companion \n"
              "Find Nearby Charging Operators And Power Your Journey With Ease..",
          image: _buildImage('Intro1.png'),
          decoration: pageDecoration.copyWith(bodyFlex: 2, imageFlex: 3),
        ),
        PageViewModel(
          title: "Seamless Booking & Service",
          body:
              "Connect Users, Van Operators For \n Hassle Free Remote EV Charging From \nStart To Finish..",
          image: _buildImage('Intro2.png'),
          decoration: pageDecoration.copyWith(bodyFlex: 2, imageFlex: 3),
        ),
        PageViewModel(
          title: "Operators powering Your EV",
          body:
              "Find Available Charging Services,\n"
              "View And Book Remotely With Fingertips..",
          image: _buildImage('Intro3.png'),
          decoration: pageDecoration.copyWith(bodyFlex: 2, imageFlex: 3),
        ),
      ],

      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),

      showSkipButton: true,
      showBackButton: false,

      skip: Text(
        "Skip",
        style: TextStyle(
          color: Color(0xFF2ECC71),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      next: CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFF2ECC71),
        child: Icon(Icons.arrow_forward, color: Colors.white),
      ),
      done: CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFF2ECC71),
        child: Text(
          "Done",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),

      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: EdgeInsets.all(16),
      controlsPadding: kIsWeb
          ? EdgeInsets.all(12)
          : EdgeInsets.fromLTRB(8, 4, 8, 4),

      dotsDecorator: DotsDecorator(
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
