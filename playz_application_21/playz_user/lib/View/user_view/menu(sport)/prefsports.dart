import 'package:flutter/material.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';

// Main Stateful widget for displaying sports groups
class PrefSports extends StatefulWidget {
  const PrefSports({super.key});

  @override
  State<PrefSports> createState() => _PrefSportsState();
}

class _PrefSportsState extends State<PrefSports> {
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
                        // Back button
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
                        // Page title
                        ValueListenableBuilder<String>(
                          valueListenable: appLanguageNotifier,
                          builder: (context, lang, _) {
                            return FutureBuilder<String>(
                              future: getTranslatedText("Sports", lang),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    "...",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text(
                                    "Error",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                    ),
                                  );
                                } else {
                                  return Text(
                                    snapshot.data ?? "",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
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
                      // Space
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      // Search bar for groups
                      Container(
                        height: Reusable.getDeviceHeight(context, H: 60),
                        width: Reusable.getDeviceWidth(context, W: 388),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 30),
                          ),
                        ),
                        child: TextField(
                          style: TextStyle(
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getDarkGrey(),
                          ),
                          cursorColor: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getGreen(),
                          decoration: InputDecoration(
                            hintText: "Search by Sport",
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getLightGrey(),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Reusable.getDarkModeBlack()
                                : Reusable.getWhite(), // background color
                            // 🔍 Search icon
                            suffixIcon: Icon(
                              Icons.search,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                              size: Reusable.getDeviceWidth(context, W: 30),
                            ),

                            // Borders
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: isDark
                                    ? Reusable.getLightGrey()
                                    : Reusable.getLightGrey(),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                Reusable.getDeviceWidth(context, W: 30),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                Reusable.getDeviceWidth(context, W: 30),
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.orange,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                color: Colors.purple,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

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
                                  future: getTranslatedText("Cricket", lang),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        "...",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        "Error",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        snapshot.data ?? "",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),

                            Icon(
                              Icons.close,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                              size: Reusable.getDeviceWidth(context, W: 30),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

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
                                  future: getTranslatedText("Badminton", lang),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        "...",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        "Error",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        snapshot.data ?? "",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),

                            Icon(
                              Icons.close,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                              size: Reusable.getDeviceWidth(context, W: 30),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

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
                                  future: getTranslatedText("Football", lang),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        "...",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        "Error",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        snapshot.data ?? "",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                        ),
                                      );
                                    }
                                  },
                                );
                              },
                            ),

                            Icon(
                              Icons.close,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                              size: Reusable.getDeviceWidth(context, W: 30),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),
                    ],
                  ),
                ),
              ),

              // (TODO: Bottom navigation can be added here if needed)
            ],
          ),
        );
      },
    );
  }
}
