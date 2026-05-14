import 'package:flutter/material.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';

// Main Stateful widget for displaying sports groups
class PrefNotification extends StatefulWidget {
  const PrefNotification({super.key});

  @override
  State<PrefNotification> createState() => _PrefNotificationState();
}

class _PrefNotificationState extends State<PrefNotification> {

  bool isGameUpdates = false;
  bool isGroupUpdates = false;
  bool isActivityFriends = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
valueListenable: appSettingsNotifier, // listen for changes
builder: (context, settings, _) {
bool isDark = settings.theme == "Dark";
    return Scaffold(
      body: Stack(
        children: [
          // Green background with top bar
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
                    // Back button
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        size: Reusable.getDeviceWidth(context, W: 25),
color: isDark?Reusable.getDarkModeBlack():Reusable.getWhite(),
                      ),
                    ),
                    SizedBox(width: 5),
                    // Page title
                    ValueListenableBuilder<String>(
  valueListenable: appLanguageNotifier,
  builder: (context, lang, _) {
    return FutureBuilder<String>(
      future: getTranslatedText(
        "Notifications",
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

          // White rounded container at bottom (acts like bottom sheet)
          Positioned(
            top: (MediaQuery.of(context).size.height) * 0.097192,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
color: isDark?Reusable.getDarkModeBlack():Reusable.getWhite(),
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
                  // Space
                  SizedBox(height: Reusable.getDeviceHeight(context, H: 40)),

                  Padding(
                    padding: EdgeInsets.only(
                      left: Reusable.getDeviceWidth(context, W: 30),
                      right: Reusable.getDeviceWidth(context, W: 30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<String>(
  valueListenable: appLanguageNotifier,
  builder: (context, lang, _) {
    return FutureBuilder<String>(
      future: getTranslatedText(
        "Cricket",
        lang,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            "Error",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
            ),
          );
        } else {
          return Text(
            snapshot.data ?? "",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
            ),
          );
        }
      },
    );
  },
),


                        StatefulBuilder(
                          builder: (context, setStateCheck) {
                            return Checkbox(
                              value:
                                  isGameUpdates, // <-- define this as a bool in your state
                              activeColor:
                                   isDark?Reusable.getLightGreen():Reusable.getGreen(),
                                  focusColor:   isDark?Reusable.getDarkModeBlack():Reusable.getWhite(),

 // ✅ custom green
                              checkColor:   isDark?Reusable.getDarkModeBlack():Reusable.getWhite(),
 // tick colorc
                              onChanged: (bool? value) {
                                setState(() {
                                  isGameUpdates = value ?? false;
                                });
                                setStateCheck(() {}); // update local UI
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Reusable.getDeviceHeight(context, H: 10)),

                  Padding(
                    padding: EdgeInsets.only(
                      left: Reusable.getDeviceWidth(context, W: 30),
                      right: Reusable.getDeviceWidth(context, W: 30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<String>(
  valueListenable: appLanguageNotifier,
  builder: (context, lang, _) {
    return FutureBuilder<String>(
      future: getTranslatedText(
        "Badminton",
        lang,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            "Error",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
            ),
          );
        } else {
          return Text(
            snapshot.data ?? "",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
            ),
          );
        }
      },
    );
  },
),


                        StatefulBuilder(
                          builder: (context, setStateCheck) {
                            return Checkbox(
                              value:
                                  isGroupUpdates, // <-- define this as a bool in your state
                              activeColor:
                                   isDark?Reusable.getLightGreen():Reusable.getGreen(),
focusColor:   isDark?Reusable.getDarkModeBlack():Reusable.getWhite(),

 // ✅ custom green
                              checkColor:   isDark?Reusable.getDarkModeBlack():Reusable.getWhite(),                              onChanged: (bool? value) {
                                setState(() {
                                  isGroupUpdates = value ?? false;
                                });
                                setStateCheck(() {}); // update local UI
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Reusable.getDeviceHeight(context, H: 10)),

                  Padding(
                    padding: EdgeInsets.only(
                      left: Reusable.getDeviceWidth(context, W: 30),
                      right: Reusable.getDeviceWidth(context, W: 30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder<String>(
  valueListenable: appLanguageNotifier,
  builder: (context, lang, _) {
    return FutureBuilder<String>(
      future: getTranslatedText(
        "Football",
        lang,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            "...",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
            ),
          );
        } else if (snapshot.hasError) {
          return Text(
            "Error",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
            ),
          );
        } else {
          return Text(
            snapshot.data ?? "",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
            ),
          );
        }
      },
    );
  },
),


                        StatefulBuilder(
                          builder: (context, setStateCheck) {
                            return Checkbox(
                              value:
                                  isActivityFriends, // <-- define this as a bool in your state
                              activeColor:
                                   isDark?Reusable.getLightGreen():Reusable.getGreen(),
focusColor:   isDark?Reusable.getDarkModeBlack():Reusable.getWhite(),

 // ✅ custom green
                              checkColor:   isDark?Reusable.getDarkModeBlack():Reusable.getWhite(),                                  onChanged: (bool? value) {
                                setState(() {
                                  isActivityFriends = value ?? false;
                                });
                                setStateCheck(() {}); // update local UI
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: Reusable.getDeviceHeight(context, H: 10)),
                ],
              ),
            ),
          ),

          // (TODO: Bottom navigation can be added here if needed)
        ],
      ),
    );
  });}
}
