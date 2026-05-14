import 'package:flutter/material.dart';
import 'package:playz_user/View/user_view/Login_Screen.dart';
import 'package:playz_user/View/user_view/navigation(sport).dart';
import 'package:playz_user/View/user_view/walkthrough.dart';

class SplashScreen_user extends StatefulWidget {
  const SplashScreen_user({super.key});

  @override
  State<SplashScreen_user> createState() => _SplashScreen_userState();
}

class _SplashScreen_userState extends State<SplashScreen_user> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>WalkthroughPage()));
        }
      });
    _controller.forward();
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.691588,
            height: MediaQuery.of(context).size.height * 0.475161,
            child: Image.asset("assets/Images/splash.png"),
          ),
        ),
      ),
    );
  }
}
