import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';

class CricketScoreboard extends StatefulWidget {
  List<TextEditingController?> teamAPlayers;
  List<TextEditingController?> teamBPlayers;
  int? totalOvers;
  int? totalPlayers;

  CricketScoreboard({
    super.key,
    required this.teamAPlayers,
    required this.teamBPlayers,
    required this.totalOvers,
    required this.totalPlayers
  });

  @override
  State<CricketScoreboard> createState() => _CricketScoreboardState();
}

// 🔹 Dummy list of group members (image, name, role)
class PlayerScore {
  String name;
  int runs;
  int balls;
  int fours;
  int sixes;


  int ballsBowled;
  int maidens;
  int runsConceded;
  int wickets;


  PlayerScore({
    required this.name,
    this.runs = 0,
    this.balls = 0,
    this.fours = 0,
    this.sixes = 0,
    this.maidens=0,
    this.ballsBowled=0,
    this.runsConceded=0,
    this.wickets=0
  });

  int get strikeRate => balls > 0 ? (runs ~/ balls) * 100 : 0;
  int get economyRate =>
      ballsBowled > 0 ? (runsConceded ~/ (ballsBowled / 6)) : 0;
}

List<PlayerScore> teamAData = [];
List<PlayerScore> teamBData = [];
bool isFinished = false;
int selectedTeam = 0;

class _CricketScoreboardState extends State<CricketScoreboard> {
  int teamAIndex = 1;
  int teamACurrent = 0;
  int teamACurrentPlayer1 = 0;
  int teamACurrentPlayer2 = 1;
  int teamAScore = 0;
  int teamAWickets = 0;
  int teamAOvers = 0;
  int teamAballoutof6 = 0;

int innings=1;

    int teamBIndex = 1;
  int teamBCurrent = 0;
  int teamBCurrentPlayer1 = 0;
  int teamBCurrentPlayer2 = 1;
  int teamBScore = 0;
  int teamBWickets = 0;
  int teamBOvers = 0;
  int teamBballoutof6 = 0;



  int legalballs = 0;
  int currentBowler = 0;
  // List<String> balls = ["0", "1", "W", "4", "Wd", "6"];
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
  @override
  void initState() {
    super.initState();

    // ❌ WRONG: you cannot use teamAPlayers directly here
    // teamAData = teamAPlayers.map((c) => PlayerScore(name: c!.text)).toList();

    // ✅ Correct way: use widget.teamAPlayers
    teamAData = widget.teamAPlayers
        .where((c) => c != null)
        .map((c) => PlayerScore(name: c!.text))
        .toList();

    teamBData = widget.teamBPlayers
        .where((c) => c != null)
        .map((c) => PlayerScore(name: c!.text))
        .toList();
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
                          "Cricket Scoreboard",
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
                                    selectedTeam = 0;
                                    // if (selectedTeam == 0) {
                                    //   balls.removeRange(0, balls.length);
                                    // }
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
                                      gradient: selectedTeam == 0
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
                                          color: selectedTeam == 0
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
                                    selectedTeam = 1;
                                    // if (selectedTeam == 1) {
                                    //   balls.removeRange(0, balls.length);
                                    // }
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
                                      gradient: selectedTeam == 1
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
                                          color: selectedTeam == 1
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
                           selectedTeam == 0? "$teamAScore/$teamAWickets" : "$teamBScore/$teamBWickets" ,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getBlack(),
                            ),
                          ),
                          SizedBox(
                            width: Reusable.getDeviceWidth(context, W: 10),
                          ),

                          Text(
                           selectedTeam == 0? "(${teamAballoutof6 ~/ 6}.${teamAballoutof6 % 6})":"(${teamBballoutof6 ~/ 6}.${teamBballoutof6 % 6})",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Reusable.getLightGrey()
                                  : Reusable.getDarkGrey(),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 10),
                      ),
                      selectedTeam != 0?
                      Container(
                        width: Reusable.getDeviceWidth(context, W: 388),
                        height: Reusable.getDeviceHeight(context, H: 50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 25),
                          ),
                          border: Border.all(
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getGreen(),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Reusable.getDeviceWidth(context, W: 10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Target: ${teamAScore+1} runs | Required runs: ${teamAScore+1} in ${widget.totalOvers!*6} balls",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getDarkGrey(),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ):SizedBox(),
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 10),
                      ),

                      Table(
                        border: TableBorder.all(
                          color: Colors.grey,
                        ), // optional borders
                        columnWidths: {
                          0: FlexColumnWidth(
                            3,
                          ), // first column wider for Batsman names
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(1),
                          5: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      'Batsman',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Reusable.getDarkModeBlack()
                                            : Reusable.getWhite(),
                                      ),
                                    ),
                                    Icon(
                                      Icons.replay_outlined,
                                      size: Reusable.getDeviceWidth(
                                        context,
                                        W: 20,
                                      ),
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'R',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'B',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '4s',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  '6s',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'SR',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamAData[teamACurrentPlayer1].name}${teamACurrent == teamACurrentPlayer1 ? "*" : ""}':'${teamBData[teamBCurrentPlayer1].name}${teamBCurrent == teamBCurrentPlayer1 ? "*" : ""}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamAData[teamACurrentPlayer1].runs}':'${teamBData[teamBCurrentPlayer1].runs}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamAData[teamACurrentPlayer1].balls}':'${teamBData[teamBCurrentPlayer1].balls}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamAData[teamACurrentPlayer1].fours}':'${teamBData[teamBCurrentPlayer1].fours}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamAData[teamACurrentPlayer1].sixes}':'${teamBData[teamBCurrentPlayer1].sixes}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamAData[teamACurrentPlayer1].strikeRate}':'${teamBData[teamBCurrentPlayer1].strikeRate}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamAData[teamACurrentPlayer2].name}${teamACurrent == teamACurrentPlayer2 ? "*" : ""}':'${teamBData[teamBCurrentPlayer2].name}${teamBCurrent == teamBCurrentPlayer2 ? "*" : ""}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                 selectedTeam == 0?'${teamAData[teamACurrentPlayer2].runs}':'${teamBData[teamBCurrentPlayer2].runs}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamAData[teamACurrentPlayer2].balls}':'${teamBData[teamBCurrentPlayer2].balls}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamAData[teamACurrentPlayer2].fours}':'${teamBData[teamBCurrentPlayer2].fours}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                 selectedTeam == 0?'${teamAData[teamACurrentPlayer2].sixes}':'${teamBData[teamBCurrentPlayer2].sixes}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamAData[teamACurrentPlayer2].strikeRate}':'${teamBData[teamBCurrentPlayer2].strikeRate}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 30),
                      ),

                      Table(
                        border: TableBorder.all(
                          color: Colors.grey,
                        ), // optional borders
                        columnWidths: {
                          0: FlexColumnWidth(
                            3,
                          ), // first column wider for Batsman names
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                          3: FlexColumnWidth(1),
                          4: FlexColumnWidth(1),
                          5: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    _changeBowler(isDark,selectedTeam == 0? teamBData:teamAData);
                                  },
                                  child: Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Bowler',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Reusable.getDarkModeBlack()
                                                : Reusable.getWhite(),
                                          ),
                                        ),
                                        Icon(
                                          Icons.replay_outlined,
                                          size: Reusable.getDeviceWidth(
                                            context,
                                            W: 20,
                                          ),
                                          color: isDark
                                              ? Reusable.getDarkModeBlack()
                                              : Reusable.getWhite(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'O',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'M',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'R',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'W',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'EC',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamBData[currentBowler].name}*':'${teamAData[currentBowler].name}*',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamBData[currentBowler].ballsBowled~/6}.${teamBData[currentBowler].ballsBowled%6}':'${teamAData[currentBowler].ballsBowled~/6}.${teamAData[currentBowler].ballsBowled%6}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                   selectedTeam == 0?'${teamBData[currentBowler].maidens}':'${teamAData[currentBowler].maidens}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                 selectedTeam == 0?'${teamBData[currentBowler].runsConceded}':'${teamAData[currentBowler].runsConceded}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamBData[currentBowler].wickets}':'${teamAData[currentBowler].wickets}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  selectedTeam == 0?'${teamBData[currentBowler].economyRate}':'${teamAData[currentBowler].economyRate}',
                                  style: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 30),
                      ),
                      balls.isNotEmpty
                          ? Wrap(
                              spacing: 8, // horizontal space between balls
                              runSpacing: 8, // if wrapping to new line
                              children: balls.map((ball) {
                                Color bgColor = isDark
                                    ? Reusable.getDarkModeGrey()
                                    : Reusable.getDarkGrey();

                                Color textColor = Colors.white;

                                // Color coding (you can customize)
                                if (ball == "W") {
                                  bgColor = Colors.red; // wicket
                                  textColor = isDark
                                      ? Reusable.getDarkModeBlack()
                                      : Reusable.getWhite();
                                } else if (ball == "6" || ball == "4") {
                                  bgColor = isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen();
                                  textColor = isDark
                                      ? Reusable.getDarkModeBlack()
                                      : Reusable.getWhite();
                                } else if (ball == "Wd" || ball == "Nb") {
                                  bgColor = Colors.orange; // extra
                                  textColor = isDark
                                      ? Reusable.getDarkModeBlack()
                                      : Reusable.getWhite();
                                } else {
                                  bgColor = isDark
                                      ? Reusable.getDarkModeGrey()
                                      : Reusable.getDarkGrey(); // normal run or dot
                                  // textColor = isDark?Reusable.getDarkModeBlack():Reusable.getWhite();
                                }

                                return CircleAvatar(
                                  radius: 20,
                                  backgroundColor: bgColor,
                                  child: Text(
                                    ball,
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                            )
                          : SizedBox(),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 30),
                      ),
teamAballoutof6~/6 < widget.totalOvers! || isFinished?
                      Expanded(
                        child: SingleChildScrollView(
                          // physics: CarouselScrollPhysics(),
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              GridView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap:
                                    true, // so it doesn’t take infinite space
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: keys.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5, // 3 buttons in a row
                                      mainAxisSpacing: 6,
                                      crossAxisSpacing: 6,
                                      childAspectRatio:
                                          1.5, // square-ish buttons
                                    ),
                                itemBuilder: (context, index) {
                                  final key = keys[index];
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getGreen(),

                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      // key["label"]! != "Undo"
                                      //     ? balls.add(key["label"]!)
                                      //     : balls.removeLast();

                                      log(key["label"]!);
                                      //0
                                      if (key["label"] == "0") {
                                        teamBData[currentBowler].ballsBowled+=1;
                                        legalballs++;
                                        if (legalballs ==7) {
                                          teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;
                                          balls.removeRange(0, balls.length);
                                          legalballs=1;
                                        }
                                        balls.add(key["label"]!);
                                        teamAballoutof6++;
                                        teamAData[teamACurrent].balls += 1;

                                      } 
                                      //1
                                      else if (key["label"] == "1") {
                                        teamBData[currentBowler].ballsBowled+=1;
                                        teamBData[currentBowler].runsConceded+=1;
                                        legalballs++;
                                        if (legalballs ==7) {
                                          teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;
                                          balls.removeRange(0, balls.length);
                                          legalballs=1;
                                        }
                                        balls.add(key["label"]!);
                                        teamAScore++;
                                        teamAballoutof6++;
                                        teamAData[teamACurrent].runs += 1;
                                        teamAData[teamACurrent].balls += 1;
                                        log(
                                          "${teamAData[teamACurrent].name}: ${teamAData[teamACurrent].runs}",
                                        );
                                        teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;
                                      }//2 
                                      else if (key["label"] == "2") {
                                        teamBData[currentBowler].ballsBowled+=1;
                                        teamBData[currentBowler].runsConceded+=2;
                                        legalballs++;
                                        if (legalballs ==7) {
                                          teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;
                                          balls.removeRange(0, balls.length);
                                          legalballs=1;
                                        }
                                        balls.add(key["label"]!);
                                        teamAData[teamACurrent].runs += 2;
                                        teamAData[teamACurrent].balls += 1;
                                        teamAScore += 2;
                                        teamAballoutof6++;
                                      }//3 
                                      else if (key["label"] == "3") {
                                        teamBData[currentBowler].ballsBowled+=1;
                                        teamBData[currentBowler].runsConceded+=3;
                                        legalballs++;
                                        if (legalballs ==7) {
                                          teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;
                                          balls.removeRange(0, balls.length);
                                          legalballs=1;
                                        }
                                        balls.add(key["label"]!);
                                        teamAData[teamACurrent].runs += 3;
                                        teamAData[teamACurrent].balls += 1;
                                        teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;

                                        teamAScore += 3;
                                        teamAballoutof6++;
                                      }//4 
                                      else if (key["label"] == "4") {
                                        teamBData[currentBowler].ballsBowled+=1;
                                        teamBData[currentBowler].runsConceded+=4;
                                        legalballs++;
                                        if (legalballs ==7) {
                                          teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;
                                          balls.removeRange(0, balls.length);
                                          legalballs=1;
                                        }
                                        balls.add(key["label"]!);
                                        teamAData[teamACurrent].runs += 4;
                                        teamAData[teamACurrent].balls += 1;
                                        teamAData[teamACurrent].fours += 1;
                                        teamAScore += 4;
                                        teamAballoutof6++;
                                      }//6 
                                      else if (key["label"] == "6") {
                                        teamBData[currentBowler].ballsBowled+=1;
                                        teamBData[currentBowler].runsConceded+=6;
                                        legalballs++;
                                        if (legalballs ==7) {
                                          teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;
                                          balls.removeRange(0, balls.length);
                                          legalballs=1;
                                        }
                                        balls.add(key["label"]!);
                                        teamAData[teamACurrent].runs += 6;
                                        teamAData[teamACurrent].balls += 1;
                                        teamAData[teamACurrent].sixes += 1;
                                        teamAScore += 6;
                                        teamAballoutof6++;
                                      }//w
                                      else if (key["label"] == "W") {
                                        // teamAWickets++;
                                        if (teamAWickets >= widget.totalPlayers!-1) {
                                          isFinished = true;
                                        }
                                        teamBData[currentBowler].ballsBowled+=1;
                                        teamBData[currentBowler].wickets+=1;
                                        legalballs++;
                                        // teamACurrent=teamAIndex;

                                        //  teamACurrent == teamACurrentPlayer1
                                        //     ? teamACurrent = teamACurrentPlayer2
                                        //     : teamACurrent =
                                        //           teamACurrentPlayer1;

                                          if (legalballs ==7) {
                                          teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;
                                          balls.removeRange(0, balls.length);
                                          legalballs=1;
                                        }

                                          if ( teamACurrent == teamACurrentPlayer1) {
                                            teamACurrentPlayer1 = ++teamAIndex;
                                            teamACurrent = teamACurrentPlayer1;
                                          }else{
                                            teamACurrentPlayer2 = ++teamAIndex;
                                            teamACurrent = teamACurrentPlayer2;
                                          }

                                        
                                        balls.add(key["label"]!);
                                        teamAData[teamACurrent].balls += 1;
                                        teamAWickets += 1;
                                        teamAballoutof6++;
                                      }//noball
                                      else if (key["label"] == "NB") {
                                        teamBData[currentBowler].runsConceded+=1;
                                        if (legalballs ==7) {
                                          teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;
                                          balls.removeRange(0, balls.length);
                                          legalballs=1;
                                        }
                                        balls.add(key["label"]!);
                                        teamAScore += 1;
                                      }//wide ball
                                      else if (key["label"] == "WD") {
                                        teamBData[currentBowler].runsConceded+=1;
                                        if (legalballs ==7) {
                                          teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;
                                          balls.removeRange(0, balls.length);
                                          legalballs=1;
                                        }
                                        balls.add(key["label"]!);
                                        teamAScore += 1;
                                      }//bye
                                      else if (key["label"] == "B") {
                                        legalballs++;
                                        teamAballoutof6++;
                                        teamBData[currentBowler].runsConceded+=1;
                                        teamBData[currentBowler].ballsBowled+=1;
                                        if (legalballs ==7) {
                                          teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;
                                          balls.removeRange(0, balls.length);
                                          legalballs=1;
                                        }
                                        balls.add(key["label"]!);
                                        teamAScore += 1;
                                      }//leg bye
                                      else if (key["label"] == "LB") {
                                        legalballs++;
                                        teamAballoutof6++;
                                        teamBData[currentBowler].runsConceded+=1;
                                        teamBData[currentBowler].ballsBowled+=1;
                                        if (legalballs ==7) {
                                          teamACurrent == teamACurrentPlayer1
                                            ? teamACurrent = teamACurrentPlayer2
                                            : teamACurrent =
                                                  teamACurrentPlayer1;
                                          balls.removeRange(0, balls.length);
                                          legalballs=1;
                                        }
                                        balls.add(key["label"]!);
                                        teamAScore += 1;
                                      }

                                      setState(() {});
                                    },
                                    child: key["label"]! != "Undo"
                                        ? Text(
                                            key["label"]!,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? Reusable.getDarkModeBlack()
                                                  : Reusable.getWhite(),
                                            ),
                                            textAlign: TextAlign.center,
                                          )
                                        : Icon(
                                            Icons.undo,
                                            size: Reusable.getDeviceWidth(
                                              context,
                                              W: 20,
                                            ),
                                            color: isDark
                                                ? Reusable.getDarkModeBlack()
                                                : Reusable.getWhite(),
                                          ),
                                  );
                                },
                              ),

                              SizedBox(
                                height: Reusable.getDeviceHeight(
                                  context,
                                  H: 30,
                                ),
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
                      ):SizedBox(),
                      // Align(
                      //           alignment: Alignment.bottomCenter,
                      //           child:teamAWickets >= widget.totalPlayers!-1 || teamAballoutof6/6 >= widget.totalOvers!
                      //               ? GestureDetector(
                      //                 onTap: () {
                      //                   // selectedTeam = 1;
                      //                 },
                      //                 child: Container(
                      //                     height: Reusable.getDeviceHeight(
                      //                       context,
                      //                       H: 60,
                      //                     ),
                      //                     width: Reusable.getDeviceWidth(
                      //                       context,
                      //                       W: 388,
                      //                     ),
                      //                     decoration: BoxDecoration(
                      //                       color: isDark
                      //                           ? Reusable.getLightGreen()
                      //                           : Reusable.getGreen(),
                      //                       borderRadius: BorderRadius.circular(
                      //                         Reusable.getDeviceWidth(
                      //                           context,
                      //                           W: 30,
                      //                         ),
                      //                       ),
                      //                     ),
                      //                     child: Row(
                      //                       mainAxisAlignment:
                      //                           MainAxisAlignment.center,
                      //                       children: [
                      //                         Text(
                      //                           "Finish & Set Target",
                      //                           style: TextStyle(
                      //                             fontSize: 16,
                      //                             fontWeight: FontWeight.w500,
                      //                             color: isDark
                      //                                 ? Reusable.getDarkModeBlack()
                      //                                 : Reusable.getWhite(),
                      //                           ),
                      //                         ),
                      //                       ],
                      //                     ),
                      //                   ),
                      //               )
                      //               : SizedBox(),
                      //         ),
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

// 🔹 Function to open bottom sheet
  void _changeBowler(bool isDark,List<PlayerScore> teamData) async {
    int? selected = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView.builder(
          itemCount: teamData.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                teamData[index].name,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              trailing: index == currentBowler
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.pop(context, index); // return the selected index
              },
            );
          },
        );
      },
    );

    if (selected != null && selected != currentBowler) {
      setState(() {
        currentBowler = selected;
      });
    }
  }
}
