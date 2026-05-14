import 'package:flutter/material.dart';
import 'package:playz_user/View/user_view/home(sport)/scoreboard/cricketscoreboardinfo.dart';
import 'package:playz_user/View/user_view/home(sport)/scoreboard/footballscoreboardinfo.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';

class Scoreboard extends StatefulWidget {
  const Scoreboard({super.key});

  @override
  State<Scoreboard> createState() => _ScoreboardState();
}

// 🔹 Dummy list of group members (image, name, role)
List<Map<String, dynamic>> upcomingItems = [
  {
    "image": "https://img.freepik.com/free-vector/gradient-ipl-cricket-illustration_23-2149205212.jpg?semt=ais_incoming&w=740&q=80",
    "turf_name": "Arena 51",
    "day_date": "FRI, 14-08-2025",
    "time_slot": "9:00 AM - 10:00 AM",
    "turf_address":
        "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground",
  },
  {
    "image": "https://thumbs.dreamstime.com/b/soccer-game-players-faceless-silhouettes-football-match-championship-background-vector-illustration-141598590.jpg",
    "turf_name": "Arena 51",
    "day_date": "FRI, 14-08-2025",
    "time_slot": "9:00 AM - 10:00 AM",
    "turf_address":
        "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground",
  },
];

List<Map<String, dynamic>> pastItems = [
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "turf_name": "Arena 51",
    "day_date": "FRI, 14-08-2025",
    "time_slot": "9:00 AM - 10:00 AM",
    "turf_address":
        "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground",
  },
];

List<Map<String, dynamic>> cancelledItems = [
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "turf_name": "Arena 51",
    "day_date": "FRI, 14-08-2025",
    "time_slot": "9:00 AM - 10:00 AM",
    "turf_address":
        "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground",
  },
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "turf_name": "Arena 51",
    "day_date": "FRI, 14-08-2025",
    "time_slot": "9:00 AM - 10:00 AM",
    "turf_address":
        "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground",
  },
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "turf_name": "Arena 51",
    "day_date": "FRI, 14-08-2025",
    "time_slot": "9:00 AM - 10:00 AM",
    "turf_address":
        "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground",
  },
];

int selectedIndex = 0;
List<Map<String, dynamic>> currentList = [];

class _ScoreboardState extends State<Scoreboard> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
valueListenable: appSettingsNotifier, // listen for changes
builder: (context, settings, _) {
bool isDark = settings.theme == "Dark";

    if (selectedIndex == 0) {
      currentList = upcomingItems;
    } else if (selectedIndex == 1) {
      currentList = pastItems;
    } else {
      currentList = cancelledItems;
    }
    return Scaffold(
      body: Stack(
        // Stack is used to overlap top header and white sheet
        children: [
          // 🔹 Green header background
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
color: isDark?Reusable.getLightGreen():Reusable.getGreen(),

            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
                child: Row(
                  children: [
                    // 🔙 Back button
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: Reusable.getDeviceWidth(context, W: 25),
color: isDark?Reusable.getDarkModeBlack():Reusable.getWhite(),
                      ),
                    ),
                    SizedBox(width: 5),
                    // 🔹 Title text
                    ValueListenableBuilder<String>(
  valueListenable: appLanguageNotifier,
  builder: (context, lang, _) {
    return FutureBuilder<String>(
      future: getTranslatedText(
        "Scoreboard",
        lang,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "...",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            "Error",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
            ),
          );
        } else {
          return Text(
            snapshot.data ?? "",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
            ),
          );
        }
      },
    );
  },
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
color: isDark?Reusable.getDarkModeBlack():Reusable.getWhite(),                borderRadius: BorderRadius.only(
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
                  SizedBox(height: Reusable.getDeviceHeight(context, H: 20)),

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
color: isDark?Reusable.getDarkModeGrey():Reusable.getWhite(),                        borderRadius: BorderRadius.all(Radius.circular(25)),
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
                                width: Reusable.getDeviceWidth(context, W: 126),
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
                                          colors: [isDark?Reusable.getDarkModeGrey():Colors.white, isDark?Reusable.getDarkModeGrey():Colors.white],
                                          begin: Alignment.bottomRight,
                                          end: Alignment.topLeft,
                                        ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      Reusable.getDeviceWidth(context, W: 25),
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: ValueListenableBuilder<String>(
  valueListenable: appLanguageNotifier,
  builder: (context, lang, _) {
    return FutureBuilder<String>(
      future: getTranslatedText(
        "My Score",
        lang,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selectedIndex == 0
                  ? isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()
                  : isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            "Error",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selectedIndex == 0
                  ? isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()
                  : isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
            ),
          );
        } else {
          return Text(
            snapshot.data ?? "",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selectedIndex == 0
                  ? isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()
                  : isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
            ),
          );
        }
      },
    );
  },
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
                                width: Reusable.getDeviceWidth(context, W: 126),
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
                                          colors: [isDark?Reusable.getDarkModeGrey():Colors.white, isDark?Reusable.getDarkModeGrey():Colors.white],
                                          begin: Alignment.bottomRight,
                                          end: Alignment.topLeft,
                                        ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      Reusable.getDeviceWidth(context, W: 25),
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: ValueListenableBuilder<String>(
  valueListenable: appLanguageNotifier,
  builder: (context, lang, _) {
    return FutureBuilder<String>(
      future: getTranslatedText(
        "Slot Score",
        lang,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selectedIndex == 1
                  ? isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()
                  : isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            "Error",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selectedIndex == 1
                  ? isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()
                  : isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
            ),
          );
        } else {
          return Text(
            snapshot.data ?? "",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selectedIndex == 1
                  ? isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()
                  : isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
            ),
          );
        }
      },
    );
  },
),

                                ),
                              ),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(
                              right: Reusable.getDeviceWidth(context, W: 5),
                            ),
                            //cancelled
                            child: GestureDetector(
                              onTap: () {
                                selectedIndex = 2;
                                setState(() {});
                              },
                              child: Container(
                                height: Reusable.getDeviceHeight(
                                  context,
                                  H: 40,
                                ),
                                width: Reusable.getDeviceWidth(context, W: 126),
                                decoration: BoxDecoration(
                                  gradient: selectedIndex == 2
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
                                          colors: [isDark?Reusable.getDarkModeGrey():Colors.white, isDark?Reusable.getDarkModeGrey():Colors.white],
                                          begin: Alignment.bottomRight,
                                          end: Alignment.topLeft,
                                        ),

                                  // color: Reusable.getWhite(),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      Reusable.getDeviceWidth(context, W: 25),
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: ValueListenableBuilder<String>(
  valueListenable: appLanguageNotifier,
  builder: (context, lang, _) {
    return FutureBuilder<String>(
      future: getTranslatedText(
        "Event Score",
        lang,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selectedIndex == 2
                  ? isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()
                  : isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            "Error",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selectedIndex == 2
                  ? isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()
                  : isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
            ),
          );
        } else {
          return Text(
            snapshot.data ?? "",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: selectedIndex == 2
                  ? isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()
                  : isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
            ),
          );
        }
      },
    );
  },
),

                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: Reusable.getDeviceHeight(context, H: 20)),

                  // 🔹 List of Group Members
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true, // prevents infinite height
                    itemCount: currentList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          // 🔹 Member card container
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => CricketApp(),
                                ),
                              );
                            },
                            child: Container(
                              height: Reusable.getDeviceHeight(context, H: 115),
                              width: Reusable.getDeviceWidth(context, W: 388),
                              decoration: BoxDecoration(
color: isDark?Reusable.getDarkModeGrey():Reusable.getWhite(),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 3,
                                    color: Color.fromRGBO(0, 0, 0, 0.25),
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),

                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Reusable.getDeviceWidth(
                                    context,
                                    W: 15,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // 🔹 Member details (Image + Name + Role)
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Profile image
                                        Container(
                                          height: Reusable.getDeviceHeight(
                                            context,
                                            H: 85,
                                          ),
                                          width: Reusable.getDeviceWidth(
                                            context,
                                            W: 85,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 35,
                                              ),
                                            ),
                                            color: Reusable.getBlack(),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 10,
                                              ),
                                            ),
                                            child: Image.network(
                                              currentList[index]['image'],
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: Reusable.getDeviceWidth(
                                            context,
                                            W: 15,
                                          ),
                                        ),
                                        // Name + Role
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            // Member name
                                            ValueListenableBuilder<String>(
  valueListenable: appLanguageNotifier,
  builder: (context, lang, _) {
    return FutureBuilder<String>(
      future: getTranslatedText(
        currentList[index]['turf_name'],
        lang,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "...",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? Reusable.getLightGreen() : Reusable.getBlack(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            "Error",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? Reusable.getLightGreen() : Reusable.getBlack(),
            ),
          );
        } else {
          return Text(
            snapshot.data ?? "",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? Reusable.getLightGreen() : Reusable.getBlack(),
            ),
          );
        }
      },
    );
  },
),

                                            SizedBox(
                                              height: Reusable.getDeviceHeight(
                                                context,
                                                H: 0,
                                              ),
                                            ),
                                            // Member role
                                            Text(
                                              currentList[index]['day_date'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
color: isDark?Reusable.getLightGrey():Reusable.getDarkGrey(),
                                              ),
                                            ),
                                            Text(
                                              currentList[index]['time_slot'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
color: isDark?Reusable.getLightGrey():Reusable.getDarkGrey(),                                              ),
                                            ),
                                            Container(
                                              width: Reusable.getDeviceWidth(
                                                context,
                                                W: 230,
                                              ),
                                              height: Reusable.getDeviceHeight(
                                                context,
                                                H: 20,
                                              ),
                                              child: Expanded(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: ValueListenableBuilder<String>(
  valueListenable: appLanguageNotifier,
  builder: (context, lang, _) {
    return FutureBuilder<String>(
      future: getTranslatedText(
        currentList[index]['turf_address'],
        lang,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "...",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(66, 132, 218, 1),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            "Error",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(66, 132, 218, 1),
            ),
          );
        } else {
          return Text(
            snapshot.data ?? "",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color.fromRGBO(66, 132, 218, 1),
            ),
          );
        }
      },
    );
  },
),

                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // 🔽 Dropdown icon (to change role)
                                    // IconButton(
                                    //   onPressed: () {
                                    //   },
                                    //   icon: Icon(
                                    //     Icons.arrow_drop_down,
                                    //     size: Reusable.getDeviceWidth(context, W: 40),
                                    //     color: Reusable.getDarkGrey(),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Space between cards
                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 15),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  });}

  // 🔹 Bottom sheet to update member roles
}
