import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';

class FootballScoreboard extends StatefulWidget {
  const FootballScoreboard({super.key});

  @override
  State<FootballScoreboard> createState() => _FootballScoreboardState();
}

// 🔹 Dummy list of group members (image, name, role)

int selectedIndex = 0;

class _FootballScoreboardState extends State<FootballScoreboard> {
  // List<String> balls = ["0", "1", "W", "4", "Wd", "6"];
  Duration remaining = const Duration(minutes: 1);
  Timer? _timer;
  bool isRunning = false;
  List<String> balls = [];
  final keys = [
    {"label": "0", "desc": "Dot Ball"},
    {"label": "1", "desc": "Single Run"},
    {"label": "2", "desc": "Two Runs"},
    {"label": "3", "desc": "Three Runs"},
    {"label": "4", "desc": "Boundary Four"},
    {"label": "6", "desc": "Six Runs"},
    {"label": "W", "desc": "Wicket"},
    {"label": "NB", "desc": "No Ball"},
    {"label": "WD", "desc": "Wide Ball"},
    {"label": "B", "desc": "Byes"},
    {"label": "LB", "desc": "Leg Byes"},
    {"label": "Undo", "desc": "Undo"},
  ];

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() => isRunning = false);
      }
      setState(() {
        remaining = Duration(seconds: remaining.inSeconds - 1);
      });
    });
  }

  void toggleTimer() {
    if (isRunning) {
      _timer?.cancel();
    } else {
      startTimer();
    }
    setState(() => isRunning = !isRunning);
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      remaining = const Duration(minutes: 30);
      isRunning = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatTime(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes);
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";

        return Scaffold(
          body: Stack(
            // Stack is used to overlap top header and white sheet
            children: [
              // 🔹 Green header background
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),

                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 40,
                      left: 10,
                      right: 10,
                    ),
                    child: Row(
                      children: [
                        // 🔙 Back button
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Icons.arrow_back_ios_new,
                            size: Reusable.getDeviceWidth(context, W: 25),
                            color: isDark
                                ? Reusable.getDarkModeBlack()
                                : Reusable.getWhite(),
                          ),
                        ),
                        SizedBox(width: 5),
                        // 🔹 Title text
                        Text(
                          "Football Scoreboard",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Reusable.getDarkModeBlack()
                                : Reusable.getWhite(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 🔹 White rounded bottom sheet (Main content area)
              Positioned(
                top:
                    (MediaQuery.of(context).size.height) *
                    0.097192, // pushes down from top
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Reusable.getDarkModeBlack()
                        : Reusable.getWhite(),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      // 🔹 toggle
                      Container(
                        height: Reusable.getDeviceHeight(context, H: 50),
                        width: Reusable.getDeviceWidth(context, W: 388),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 30),
                          ),
                        ),
                        child: Container(
                          height: Reusable.getDeviceHeight(context, H: 50),
                          width: Reusable.getDeviceWidth(context, W: 388),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Reusable.getDarkModeGrey()
                                : Reusable.getWhite(),
                            borderRadius: BorderRadius.all(Radius.circular(25)),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.25),
                                spreadRadius: 0,
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              //toggle 3 options
                              Padding(
                                padding: EdgeInsets.only(
                                  left: Reusable.getDeviceWidth(context, W: 5),
                                ),
                                //upcoming
                                child: GestureDetector(
                                  onTap: () {
                                    selectedIndex = 0;
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 189,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: selectedIndex == 0
                                          ? LinearGradient(
                                              colors: [
                                                isDark
                                                    ? Color.fromRGBO(
                                                        164,
                                                        255,
                                                        0,
                                                        1,
                                                      )
                                                    : Color.fromRGBO(
                                                        35,
                                                        140,
                                                        62,
                                                        1,
                                                      ),
                                                isDark
                                                    ? Color.fromRGBO(
                                                        46,
                                                        204,
                                                        0,
                                                        1,
                                                      )
                                                    : Color.fromRGBO(
                                                        0,
                                                        200,
                                                        83,
                                                        1,
                                                      ),
                                              ],
                                              begin: Alignment.bottomRight,
                                              end: Alignment.topLeft,
                                            )
                                          : LinearGradient(
                                              colors: [
                                                isDark
                                                    ? Reusable.getDarkModeGrey()
                                                    : Colors.white,
                                                isDark
                                                    ? Reusable.getDarkModeGrey()
                                                    : Colors.white,
                                              ],
                                              begin: Alignment.bottomRight,
                                              end: Alignment.topLeft,
                                            ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Team A",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: selectedIndex == 0
                                              ? isDark
                                                    ? Reusable.getDarkModeBlack()
                                                    : Reusable.getWhite()
                                              : isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getDarkGrey(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(
                                  // left: Reusable.getDeviceWidth(context, W: 5)
                                ),
                                //past
                                child: GestureDetector(
                                  onTap: () {
                                    selectedIndex = 1;
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 189,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: selectedIndex == 1
                                          ? LinearGradient(
                                              colors: [
                                                isDark
                                                    ? Color.fromRGBO(
                                                        164,
                                                        255,
                                                        0,
                                                        1,
                                                      )
                                                    : Color.fromRGBO(
                                                        35,
                                                        140,
                                                        62,
                                                        1,
                                                      ),
                                                isDark
                                                    ? Color.fromRGBO(
                                                        46,
                                                        204,
                                                        0,
                                                        1,
                                                      )
                                                    : Color.fromRGBO(
                                                        0,
                                                        200,
                                                        83,
                                                        1,
                                                      ),
                                              ],
                                              begin: Alignment.bottomRight,
                                              end: Alignment.topLeft,
                                            )
                                          : LinearGradient(
                                              colors: [
                                                isDark
                                                    ? Reusable.getDarkModeGrey()
                                                    : Colors.white,
                                                isDark
                                                    ? Reusable.getDarkModeGrey()
                                                    : Colors.white,
                                              ],
                                              begin: Alignment.bottomRight,
                                              end: Alignment.topLeft,
                                            ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Team B",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: selectedIndex == 1
                                              ? isDark
                                                    ? Reusable.getDarkModeBlack()
                                                    : Reusable.getWhite()
                                              : isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getDarkGrey(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "1 - 0",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getBlack(),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 10),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            // width: Reusable.getDeviceWidth(context, W: 200),
                            height: Reusable.getDeviceHeight(context, H: 40),
                            // padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),),
                            ),
                            child: Padding(
                              padding:  EdgeInsets.all(7),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.timer, size: Reusable.getDeviceWidth(context, W: 25),color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),),
                                    SizedBox(width: Reusable.getDeviceWidth(context, W: 10),),
                                  Text(
                                    formatTime(remaining),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getGreen(),
                                    ),
                                  ),
                                  
                                ],
                              ),
                            ),
                          ),
                          //  SizedBox(width: Reusable.getDeviceWidth(context, W: 20)),
                                IconButton(
                                  // iconSize: 30,
                                  icon: Icon(
                                    isRunning ? Icons.pause : Icons.play_arrow,
                                    size: 30,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
                                  ),
                                  onPressed: toggleTimer,
                                ),
                          //  SizedBox(width: Reusable.getDeviceWidth(context, W: 20)),
                                IconButton(
                                  // iconSize: 30,
                                  icon: Icon(
                                    Icons.refresh,
                                    size: 30,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
                                  ),
                                  onPressed: resetTimer,
                                ),
                        ],
                      ),
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      
                      

                   
                      Align(
                        alignment: Alignment.bottomCenter,
                        child:  Container(
                                height: Reusable.getDeviceHeight(
                                  context,
                                  H: 60,
                                ),
                                width: Reusable.getDeviceWidth(
                                  context,
                                  W: 388,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                  borderRadius: BorderRadius.circular(
                                    Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Finish & Set Target",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Reusable.getDarkModeBlack()
                                            : Reusable.getWhite(),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                           ,
                      ),
                      SizedBox(
                        height: Reusable.getDeviceHeight(
                          context,
                          H: 40,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Bottom sheet to update member roles
}
