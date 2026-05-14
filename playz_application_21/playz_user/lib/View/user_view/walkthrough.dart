import 'dart:async';
import 'package:flutter/material.dart';
import 'package:playz_user/View/user_view/Login_Screen.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WalkthroughPage extends StatefulWidget {
  @override
  _WalkthroughPageState createState() => _WalkthroughPageState();
}

class _WalkthroughPageState extends State<WalkthroughPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Color> walkthroughColors = [Colors.blueAccent, Colors.greenAccent];
  final List<String> walkthroughImages = [
    "assets/Images/players_link.png",
    "assets/Images/sports_map.png",
  ];
  // Texts corresponding to each page
  final List<String> walkthroughTexts = [
    "Connect with trainers and players easily.",
    "Book slots and enjoy your game anytime!",
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < walkthroughColors.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier,
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";

        return Scaffold(
          body: Column(
            children: [
              // PageView at top
              SizedBox(
                height: screenHeight * 0.6,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: walkthroughColors.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(color: Reusable.getLightGrey()),
                      child: Image.asset(
                        walkthroughImages[index],
                        fit: BoxFit.fitWidth,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              SmoothPageIndicator(
                controller: _pageController,
                count: walkthroughColors.length,
                effect: WormEffect(
                  activeDotColor: Reusable.getGreen(),
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 8,
                ),
              ),
              SizedBox(height: 20),
              // Texts below the dots
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  walkthroughTexts[_currentPage],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Reusable.getDarkModeBlack()
                        : Reusable.getDarkModeBlack(),
                  ),
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => UserLoginScreen(),
                        ),
                        (Route<dynamic> route) =>
                            false, // remove all previous routes
                      );
                    },

                    child: Container(
                      height: Reusable.getDeviceHeight(context, H: 60),
                      width: Reusable.getDeviceWidth(context, W: 388),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Reusable.getGreen()
                            : Reusable.getGreen(),
                        borderRadius: BorderRadius.circular(
                          Reusable.getDeviceWidth(context, W: 30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Get Started",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Reusable.getWhite()
                                  : Reusable.getWhite(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}
