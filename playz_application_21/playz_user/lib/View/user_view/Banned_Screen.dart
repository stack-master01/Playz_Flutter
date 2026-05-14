import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';
import 'package:playz_user/View/navigationformodules.dart';



class BannedScreen extends StatefulWidget { // ⬅️ Renamed class
  const BannedScreen({super.key});

  @override
  State<BannedScreen> createState() => _BannedScreenState();
}

class _BannedScreenState extends State<BannedScreen> {
  // State variable for the countdown
  int _countdown = 5;
  Timer? _timer;
  bool _timerStarted = false; 

  // Function to start the 1-second interval timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        // Countdown finished - perform logout/clear data and navigate
        _timer?.cancel();
        log('BANNED: Redirecting user after ban screen timeout.');
        
        // Final actions: Clear user data and navigate to the login/dummy screen
        await UserSettings.clearAllSettings();
        await TrainerSettings.clearAllSettings();
        await WorkerSettings.clearAllSettings();
        await OwnerSettings.clearAllSettings();
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context){
          return const DummyNavigatorScreen();
        }), (Route<dynamic> route)=>false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Start timer logic (as requested, outside of initState)
    if (!_timerStarted) {
      Future.microtask(() {
        if (mounted) {
          _startTimer();
          _timerStarted = true;
        }
      });
    }

    // ⭐️ Danger Colors and UI improvements
    const Color primaryDangerColor = Color(0xFFC62828); // Deep Red
    const Color secondaryDangerColor = Color(0xFFEF5350); // Light Red
    const Color onDangerColor = Colors.white;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Use a subtle gradient for a more "regit" feel
          gradient: LinearGradient(
            colors: [primaryDangerColor, Color(0xFFB71C1C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ⭐️ Block Icon and Shadow for impact
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: secondaryDangerColor.withOpacity(0.8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.gavel, // Authority icon
                color: onDangerColor,
                size: 70,
              ),
            ),
            const SizedBox(height: 30),
            
            // ⭐️ Ban Message
            const Text(
              "ACCESS DENIED",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onDangerColor,
                fontSize: 32,
                fontWeight: FontWeight.w900, // Extra bold
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You have been banned from the PlayZ platform.", // ⭐️ New message
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onDangerColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 40),

            // ⭐️ Countdown Label
            Text(
              "Session will expire in:",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: onDangerColor.withOpacity(0.8),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            
            // ⭐️ Countdown Timer
            Text(
              "$_countdown", // The live countdown display
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: onDangerColor,
                fontSize: 64,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()], // Keeps numbers aligned during countdown
              ),
            ),
          ],
        ),
      ),
    );
  }
}