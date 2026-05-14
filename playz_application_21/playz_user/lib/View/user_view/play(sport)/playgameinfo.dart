import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/play(sport)/playinfoplayers.dart';
import 'package:playz_user/View/user_view/reusable.dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class PlayGameInfo extends StatefulWidget {
  Map<String, dynamic> currentPlayGameInfo;
  PlayGameInfo({super.key, required this.currentPlayGameInfo});

  @override
  State<PlayGameInfo> createState() => _PlayGameInfoState();
}

class _PlayGameInfoState extends State<PlayGameInfo> {
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  Map<String, dynamic> gameDataMap = {};

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Cricket",
      "11 a side",
      "4:00 PM - 6:00PM, 15th Aug, FRI",
      "42 Parkview Residency, Baner Road, Pune,Road, Pune,",
      "Additional Info",
      "Total Players",
      "Cost per Player",
      "Skill",
      "Rookie - Champion",
      "Cost Shared",
      "Carry Your Kit",
      "Players (5)",
      "Shriraj Deshpande",
      "HOST",
      "Pro",
      "All Players",
      "Queries (0)",
      "All Queries",
      "JOIN GAME",
      // END: Add default english text here
    };

    // 1. Existing logic for turfInfo (assuming it's still needed)
    List<Map<String, dynamic>> turfInfo = []; // Empty list for example
    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }

    // 2. Add strings from the soloGameMap by calling the recursive helper
    _extractStrings(widget.currentPlayGameInfo, keys);

    return keys.toList();
  }

  // Helper function to recursively extract all string values
  void _extractStrings(dynamic data, Set<String> keys) {
    if (data is String) {
      // Add the string if it's not empty and potentially not a URL/ID
      // For translation purposes, you might want to filter out IDs, URLs, etc.
      // For simplicity here, we add all strings.
      if (data.isNotEmpty) {
        keys.add(data);
      }
    } else if (data is Map) {
      data.values.forEach((value) => _extractStrings(value, keys));
    } else if (data is List) {
      data.forEach((item) => _extractStrings(item, keys));
    }
    // Ignore other types like int, double, bool, null, etc.
  }

  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;
    if (_currentLang == lang &&
        _translationsCache.keys.length == keysToLoad.length) {
      return;
    }

    _currentLang = lang;
    Map<String, String> newTranslations = {};

    for (String key in keysToLoad) {
      String translated = await getTranslatedText(
        key,
        lang,
      ); // Must be defined in your project
      newTranslations[key] = translated;
    }

    if (mounted) {
      setState(() {
        _translationsCache = newTranslations;
      });
    }
  }

  void _languageChangeListener() {
    _loadTranslations(appLanguageNotifier.value);
  }

  @override
  void initState() {
    super.initState();
    gameDataMap = widget.currentPlayGameInfo;
    // turfInfo.add(widget.currentPlayGameInfo);
    if (_currentLang != appLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadSelectedLocation();
    appLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    appLanguageNotifier.removeListener(_languageChangeListener);
    super.dispose();
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await ThemeSettings(
      theme: null,
    ).loadSelectedTheme();
    appSettingsNotifier.value = ThemeSettings(theme: selectedTheme);
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await ThemeSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    appLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet);
  }

  String _getTranslation(String key) => _translationsCache[key] ?? key;
  // ------------------------------------------------------------------

  String? selectedLocation;

  Future<void> _loadSelectedLocation() async {
    String? selected = await Appsharedpreferences().loadSelectedCity();
    selectedLocationNotifier.value = selected;
    log("city in home page: $selected");
    setState(() {
      selectedLocation = selected;
      // Trigger translation load if location text changes and needs translation
      _loadTranslations(appLanguageNotifier.value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          body: Stack(
            children: [
              // ✅ Green header background
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),

                // ✅ Top bar with back button, group info, and share button
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: Reusable.getDeviceHeight(context, H: 40),
                      left: Reusable.getDeviceHeight(context, H: 10),
                      right: Reusable.getDeviceHeight(context, H: 10),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // 🔙 Back button
                                IconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: Icon(
                                    Icons.arrow_back_ios_new,
                                    size: Reusable.getDeviceWidth(
                                      context,
                                      W: 25,
                                    ),
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                  ),
                                ),
                                SizedBox(
                                  width: Reusable.getDeviceWidth(context, W: 5),
                                ),

                                Row(
                                  children: [
                                    // sport name text
                                    Text(
                                      _getTranslation(
                                        gameDataMap['solo_Queue_Info']['sport'],
                                      ), // 🌍 Translated
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Reusable.getDarkModeBlack()
                                            : Reusable.getWhite(),
                                      ),
                                    ),

                                    SizedBox(
                                      width: Reusable.getDeviceWidth(
                                        context,
                                        W: 15,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Reusable.getDarkModeBlack()
                                            : Reusable.getWhite(),
                                        borderRadius: BorderRadius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 5,
                                          ),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: Reusable.getDeviceWidth(
                                            context,
                                            W: 5,
                                          ),
                                          right: Reusable.getDeviceWidth(
                                            context,
                                            W: 5,
                                          ),
                                        ),
                                        child: Text(
                                          _getTranslation(
                                            "11 a side",
                                          ), // 🌍 Translated
                                          style: TextStyle(
                                            fontSize: Reusable.getDeviceWidth(
                                              context,
                                              W: 14,
                                            ),
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Reusable.getLightGreen()
                                                : Reusable.getGreen(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // 📤 Share button (currently no action)
                            IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.share_outlined,
                                size: Reusable.getDeviceWidth(context, W: 30),
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 0),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: Reusable.getDeviceWidth(context, W: 20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getTranslation(
                                  gameDataMap['solo_Queue_Info']['date'],
                                ), // 🌍 Translated
                                style: TextStyle(
                                  fontSize: Reusable.getDeviceWidth(
                                    context,
                                    W: 14,
                                  ),
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Reusable.getDarkModeBlack()
                                      : Reusable.getWhite(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ✅ White bottom sheet for chat area
              Positioned(
                top: Reusable.getDeviceHeight(context, H: 120),
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Reusable.getDarkModeBlack()
                        : Reusable.getWhite(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        // 🔹 Space from top
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),

                        // 📌 Pinned message container
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
                            padding: EdgeInsets.only(
                              left: Reusable.getDeviceWidth(context, W: 10),
                              right: Reusable.getDeviceWidth(context, W: 10),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: Reusable.getDeviceWidth(context, W: 30),
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                ),
                                SizedBox(
                                  width: Reusable.getDeviceWidth(context, W: 5),
                                ),
                                // Pinned message text (truncated if too long)
                                Expanded(
                                  child: Text(
                                    _getTranslation(
                                      gameDataMap['solo_Queue_Info']['address'],
                                    ), // 🌍 Translated
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
                        ),

                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),

                        Container(
                          width: Reusable.getDeviceWidth(context, W: 388),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Reusable.getDarkModeGrey()
                                : Reusable.getWhite(),
                            borderRadius: BorderRadius.circular(
                              Reusable.getDeviceWidth(context, W: 10),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 3,
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: Reusable.getDeviceWidth(context, W: 15),
                              right: Reusable.getDeviceWidth(context, W: 15),
                              top: Reusable.getDeviceHeight(context, H: 10),
                              bottom: Reusable.getDeviceHeight(context, H: 10),
                            ),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _getTranslation(
                                      "Additional Info",
                                    ), // 🌍 Translated
                                    style: TextStyle(
                                      fontSize: Reusable.getDeviceWidth(
                                        context,
                                        W: 16,
                                      ),
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getBlack(),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 15,
                                  ),
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getTranslation(
                                        "Total Players",
                                      ), // 🌍 Translated
                                      style: TextStyle(
                                        fontSize: Reusable.getDeviceWidth(
                                          context,
                                          W: 14,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Reusable.getLightGrey()
                                            : Reusable.getDarkGrey(),
                                      ),
                                    ),

                                    Text(
                                      _getTranslation(
                                        gameDataMap['solo_Queue_Info']['total_players'],
                                      ), // Dynamic data (number) - usually not translated
                                      style: TextStyle(
                                        fontSize: Reusable.getDeviceWidth(
                                          context,
                                          W: 14,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getBlack(),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 5,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getTranslation(
                                        "Cost per Player",
                                      ), // 🌍 Translated
                                      style: TextStyle(
                                        fontSize: Reusable.getDeviceWidth(
                                          context,
                                          W: 14,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Reusable.getLightGrey()
                                            : Reusable.getDarkGrey(),
                                      ),
                                    ),

                                    Text(
                                      _getTranslation(
                                        gameDataMap['solo_Queue_Info']['price'],
                                      ), // Dynamic data (price) - usually not translated
                                      style: TextStyle(
                                        fontSize: Reusable.getDeviceWidth(
                                          context,
                                          W: 14,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getBlack(),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 5,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getTranslation("Skill"), // 🌍 Translated
                                      style: TextStyle(
                                        fontSize: Reusable.getDeviceWidth(
                                          context,
                                          W: 14,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Reusable.getLightGrey()
                                            : Reusable.getDarkGrey(),
                                      ),
                                    ),

                                    Text(
                                      _getTranslation(
                                        gameDataMap['solo_Queue_Info']['skill_limit'],
                                      ), // 🌍 Translated
                                      style: TextStyle(
                                        fontSize: Reusable.getDeviceWidth(
                                          context,
                                          W: 14,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getBlack(),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 15,
                                  ),
                                ),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Reusable.getDarkModeBlack()
                                                : Reusable.getWhite(),
                                            borderRadius: BorderRadius.circular(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 10,
                                              ),
                                            ),
                                            border: Border.all(
                                              color: isDark
                                                  ? Reusable.getLightGreen()
                                                  : Reusable.getGreen(),
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 5,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.call_split,
                                                  size: Reusable.getDeviceWidth(
                                                    context,
                                                    W: 25,
                                                  ),
                                                  color: isDark
                                                      ? Reusable.getLightGreen()
                                                      : Reusable.getGreen(),
                                                ),
                                                SizedBox(
                                                  width:
                                                      Reusable.getDeviceWidth(
                                                        context,
                                                        W: 5,
                                                      ),
                                                ),
                                                Text(
                                                  _getTranslation(
                                                    "Cost Shared",
                                                  ), // 🌍 Translated
                                                  style: TextStyle(
                                                    fontSize:
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 14,
                                                        ),
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getGreen(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Reusable.getDarkModeBlack()
                                                : Reusable.getWhite(),
                                            borderRadius: BorderRadius.circular(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 10,
                                              ),
                                            ),
                                            border: Border.all(
                                              color: isDark
                                                  ? Reusable.getLightGreen()
                                                  : Reusable.getGreen(),
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 5,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons
                                                      .home_repair_service_outlined,
                                                  size: Reusable.getDeviceWidth(
                                                    context,
                                                    W: 25,
                                                  ),
                                                  color: isDark
                                                      ? Reusable.getLightGreen()
                                                      : Reusable.getGreen(),
                                                ),
                                                SizedBox(
                                                  width:
                                                      Reusable.getDeviceWidth(
                                                        context,
                                                        W: 5,
                                                      ),
                                                ),
                                                Text(
                                                  _getTranslation(
                                                    "Carry Your Kit",
                                                  ), // 🌍 Translated
                                                  style: TextStyle(
                                                    fontSize:
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 14,
                                                        ),
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getGreen(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),
                        Container(
                          width: Reusable.getDeviceWidth(context, W: 388),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Reusable.getDarkModeGrey()
                                : Reusable.getWhite(),
                            borderRadius: BorderRadius.circular(
                              Reusable.getDeviceWidth(context, W: 10),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 3,
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              Reusable.getDeviceWidth(context, W: 10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Player count text (uses FutureBuilder in original code, so keeping it that way)
                                    ValueListenableBuilder<String>(
                                      valueListenable: appLanguageNotifier,
                                      builder: (context, lang, _) {
                                        return FutureBuilder<String>(
                                          // Using _getTranslation for the key
                                          future: getTranslatedText(
                                            "Players (${gameDataMap['solo_Queue_Info']['applied_players']})",
                                            lang,
                                          ),
                                          builder: (context, snapshot) {
                                            String text = "Players (5)";
                                            if (snapshot.connectionState ==
                                                ConnectionState.done) {
                                              text =
                                                  snapshot.data ??
                                                  "Players (5)";
                                            } else {
                                              // Fallback/loading state for better UX
                                              text = _getTranslation(
                                                "Players (${gameDataMap['solo_Queue_Info']['applied_players']})",
                                              );
                                            }
                                            return Text(
                                              text,
                                              style: TextStyle(
                                                fontSize:
                                                    Reusable.getDeviceWidth(
                                                      context,
                                                      W: 16,
                                                    ),
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? Reusable.getLightGreen()
                                                    : Reusable.getDarkGrey(),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    Icon(
                                      Icons.public,
                                      size: Reusable.getDeviceWidth(
                                        context,
                                        W: 25,
                                      ),
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getGreen(),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 15,
                                  ),
                                ),

                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: Reusable.getDeviceWidth(
                                            context,
                                            W: 50,
                                          ),
                                          height: Reusable.getDeviceHeight(
                                            context,
                                            H: 50,
                                          ),
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                gameDataMap['Players'][0]['profile_image'],
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                            color: Reusable.getLightGrey(),
                                            borderRadius: BorderRadius.circular(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 25,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: Reusable.getDeviceWidth(
                                            context,
                                            W: 15,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  _getTranslation(
                                                    gameDataMap['Players'][0]['player_name'],
                                                  ), // 🌍 Translated
                                                  style: TextStyle(
                                                    fontSize:
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 14,
                                                        ),
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getBlack(),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),

                                                SizedBox(
                                                  width:
                                                      Reusable.getDeviceWidth(
                                                        context,
                                                        W: 5,
                                                      ),
                                                ),
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getGreen(),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Reusable.getDeviceWidth(
                                                            context,
                                                            W: 5,
                                                          ),
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                      left:
                                                          Reusable.getDeviceWidth(
                                                            context,
                                                            W: 5,
                                                          ),
                                                      right:
                                                          Reusable.getDeviceWidth(
                                                            context,
                                                            W: 5,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      _getTranslation(
                                                        "HOST",
                                                      ), // 🌍 Translated
                                                      style: TextStyle(
                                                        fontSize:
                                                            Reusable.getDeviceWidth(
                                                              context,
                                                              W: 12,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: isDark
                                                            ? Reusable.getDarkModeBlack()
                                                            : Reusable.getWhite(),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: Reusable.getDeviceHeight(
                                                context,
                                                H: 5,
                                              ),
                                            ),
                                            SizedBox(
                                              width: Reusable.getDeviceWidth(
                                                context,
                                                W: 100,
                                              ),
                                              height: Reusable.getDeviceHeight(
                                                context,
                                                H: 25,
                                              ),
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    width:
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 100,
                                                        ),
                                                    height:
                                                        Reusable.getDeviceHeight(
                                                          context,
                                                          H: 25,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          const Color.fromRGBO(
                                                            255,
                                                            255,
                                                            255,
                                                            1,
                                                          ),
                                                      //skill level color
                                                      border: Border.all(
                                                        color: Color.fromRGBO(
                                                          gameDataMap['Players'][0]['skill_level']['skill_color']['r']
                                                              as int,
                                                          gameDataMap['Players'][0]['skill_level']['skill_color']['g']
                                                              as int,
                                                          gameDataMap['Players'][0]['skill_level']['skill_color']['b']
                                                              as int,
                                                          1,
                                                        ),
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width:
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 100,
                                                        ) *
                                                        0.7,
                                                    height:
                                                        Reusable.getDeviceHeight(
                                                          context,
                                                          H: 25,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                        gameDataMap['Players'][0]['skill_level']['skill_color']['r']
                                                            as int,
                                                        gameDataMap['Players'][0]['skill_level']['skill_color']['g']
                                                            as int,
                                                        gameDataMap['Players'][0]['skill_level']['skill_color']['b']
                                                            as int,
                                                        1,
                                                      ),
                                                      border: Border.all(
                                                        color: Color.fromRGBO(
                                                          gameDataMap['Players'][0]['skill_level']['skill_color']['r']
                                                              as int,
                                                          gameDataMap['Players'][0]['skill_level']['skill_color']['g']
                                                              as int,
                                                          gameDataMap['Players'][0]['skill_level']['skill_color']['b']
                                                              as int,
                                                          1,
                                                        ),
                                                        width: 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      _getTranslation(
                                                        gameDataMap['Players'][0]['skill_level']['skill_level'],
                                                      ), // 🌍 Translated
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Color.fromRGBO(
                                                          0,
                                                          0,
                                                          0,
                                                          1,
                                                        ),
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: Reusable.getDeviceHeight(
                                        context,
                                        H: 5,
                                      ),
                                    ),
                                    Divider(
                                      color: isDark
                                          ? Reusable.getLightGrey()
                                          : const Color.fromRGBO(
                                              81,
                                              81,
                                              81,
                                              0.3,
                                            ),
                                      thickness: 1,
                                      indent: 5,
                                      endIndent: 5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 5,
                                  ),
                                ),

                                Column(
                                  children: [
                                    gameDataMap['Players'].length >= 2
                                        ? Row(
                                            children: [
                                              Container(
                                                width: Reusable.getDeviceWidth(
                                                  context,
                                                  W: 50,
                                                ),
                                                height:
                                                    Reusable.getDeviceHeight(
                                                      context,
                                                      H: 50,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color:
                                                      Reusable.getLightGrey(),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 25,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: Reusable.getDeviceWidth(
                                                  context,
                                                  W: 15,
                                                ),
                                              ),

                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        _getTranslation(
                                                           gameDataMap['Players'][1]['player_name'],
                                                        ), // 🌍 Translated
                                                        style: TextStyle(
                                                          fontSize:
                                                              Reusable.getDeviceWidth(
                                                                context,
                                                                W: 14,
                                                              ),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: isDark
                                                              ? Reusable.getLightGreen()
                                                              : Reusable.getBlack(),
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        Reusable.getDeviceHeight(
                                                          context,
                                                          H: 5,
                                                        ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 100,
                                                        ),
                                                    height:
                                                        Reusable.getDeviceHeight(
                                                          context,
                                                          H: 25,
                                                        ),
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          width:
                                                              Reusable.getDeviceWidth(
                                                                context,
                                                                W: 100,
                                                              ),
                                                          height:
                                                              Reusable.getDeviceHeight(
                                                                context,
                                                                H: 25,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                const Color.fromRGBO(
                                                                  255,
                                                                  255,
                                                                  255,
                                                                  1,
                                                                ),
                                                            //skill level color
                                                            border: Border.all(
                                                              color:
                                                                  const Color.fromRGBO(
                                                                    100,
                                                                    181,
                                                                    246,
                                                                    1,
                                                                  ),
                                                              width: 1,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  5,
                                                                ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              Reusable.getDeviceWidth(
                                                                context,
                                                                W: 100,
                                                              ) *
                                                              0.7,
                                                          height:
                                                              Reusable.getDeviceHeight(
                                                                context,
                                                                H: 25,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                const Color.fromRGBO(
                                                                  100,
                                                                  181,
                                                                  246,
                                                                  1,
                                                                ),
                                                            border: Border.all(
                                                              color:
                                                                  const Color.fromRGBO(
                                                                    100,
                                                                    181,
                                                                    246,
                                                                    1,
                                                                  ),
                                                              width: 1,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  5,
                                                                ),
                                                          ),
                                                        ),
                                                        Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            _getTranslation(
                                                              "Pro",
                                                            ), // 🌍 Translated
                                                            style: const TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    1,
                                                                  ),
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                      height: Reusable.getDeviceHeight(
                                        context,
                                        H: 5,
                                      ),
                                    ),
                                    Divider(
                                      color: isDark
                                          ? Reusable.getLightGrey()
                                          : const Color.fromRGBO(
                                              81,
                                              81,
                                              81,
                                              0.3,
                                            ),
                                      thickness: 1,
                                      indent: 5,
                                      endIndent: 5,
                                    ),

                                    SizedBox(
                                      height: Reusable.getDeviceHeight(
                                        context,
                                        H: 5,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return PlayInfoPlayers(
                                                allPlayersList:
                                                    gameDataMap,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: Reusable.getDeviceWidth(
                                          context,
                                          W: 388,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _getTranslation(
                                                "All Players",
                                              ), // 🌍 Translated
                                              style: TextStyle(
                                                fontSize:
                                                    Reusable.getDeviceWidth(
                                                      context,
                                                      W: 14,
                                                    ),
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? Reusable.getLightGreen()
                                                    : Reusable.getBlack(),
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                              width: Reusable.getDeviceWidth(
                                                context,
                                                W: 5,
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: Reusable.getDeviceWidth(
                                                context,
                                                W: 20,
                                              ),
                                              color: Reusable.getDarkGrey(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                      height: Reusable.getDeviceHeight(
                                        context,
                                        H: 5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),

                        Container(
                          width: Reusable.getDeviceWidth(context, W: 388),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Reusable.getDarkModeGrey()
                                : Reusable.getWhite(),
                            borderRadius: BorderRadius.circular(
                              Reusable.getDeviceWidth(context, W: 10),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 3,
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(
                              Reusable.getDeviceWidth(context, W: 10),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _getTranslation(
                                        "Queries (0)",
                                      ), // 🌍 Translated
                                      style: TextStyle(
                                        fontSize: Reusable.getDeviceWidth(
                                          context,
                                          W: 16,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getBlack(),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 15,
                                  ),
                                ),

                                Column(
                                  children: [
                                    SizedBox(
                                      height: Reusable.getDeviceHeight(
                                        context,
                                        H: 5,
                                      ),
                                    ),
                                    Divider(
                                      color: isDark
                                          ? Reusable.getLightGrey()
                                          : const Color.fromRGBO(
                                              81,
                                              81,
                                              81,
                                              0.3,
                                            ),
                                      thickness: 1,
                                      indent: 5,
                                      endIndent: 5,
                                    ),

                                    SizedBox(
                                      height: Reusable.getDeviceHeight(
                                        context,
                                        H: 5,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Queries text (uses FutureBuilder in original code, so keeping it that way)
                                        ValueListenableBuilder<String>(
                                          valueListenable: appLanguageNotifier,
                                          builder: (context, lang, _) {
                                            return FutureBuilder<String>(
                                              // Using _getTranslation for the key
                                              future: getTranslatedText(
                                                "All Queries",
                                                lang,
                                              ),
                                              builder: (context, snapshot) {
                                                String text = "All Queries";
                                                if (snapshot.connectionState ==
                                                    ConnectionState.done) {
                                                  text =
                                                      snapshot.data ??
                                                      "All Queries";
                                                } else {
                                                  // Fallback/loading state for better UX
                                                  text = _getTranslation(
                                                    "All Queries",
                                                  );
                                                }
                                                return Text(
                                                  text,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getDarkGrey(),
                                                  ),
                                                  textAlign: TextAlign.center,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          width: Reusable.getDeviceWidth(
                                            context,
                                            W: 5,
                                          ),
                                        ),
                                        Icon(
                                          Icons.arrow_forward_ios,
                                          size: Reusable.getDeviceWidth(
                                            context,
                                            W: 20,
                                          ),
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getDarkGrey(),
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      height: Reusable.getDeviceHeight(
                                        context,
                                        H: 5,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 30),
                        ),
                        GestureDetector(
                          onTap: () async {
                            UserSettings userSettings = await UserSettings().loadSettings();
                            if (gameDataMap['Players'][0]['player_email'] != userSettings.email) {
                                gameDataMap['Players'].add({
                                "ishost": false,
                                "player_email": userSettings.email,
                                "player_name": userSettings.userName,
                                "profile_image": userSettings.imageURL,
                                "skill_level":{
                                  "skill_color":{
                                    "b":243,
                                    "g":100,
                                    "r":33
                                  },
                                  "skill_level":"Rookie",
                                  "skill_level_percent":20
                                }
                              }
                              
                              );log("${gameDataMap['solo_Queue_Info']['applied_players']}");
                              if(gameDataMap['solo_Queue_Info']['applied_players']  < int.parse(gameDataMap['solo_Queue_Info']['total_players'])){
                                
                                gameDataMap['solo_Queue_Info']['applied_players']+=1 ;
                              }
                            

                            final FirebaseFirestore _firestore =
                                FirebaseFirestore.instance;

                            try {
                              log("host email from map: ${gameDataMap['Players'][0]['player_email']}");
                              await _firestore
                                  .collection("Turf_User")
                                  .doc("${gameDataMap['Players'][0]['player_email']}")
                                  .collection("User_Data")
                                  .doc("Solo_Games")
                                  .collection("Solo_Games_List")
                                  .doc(gameDataMap['gameId'])
                                  .set(gameDataMap);
                            } on FirebaseFirestore catch (e) {
                              log("Error: $e");
                            }

                              setState(() {
                              
                            });

                            Navigator.of(context).pop(true);
                            }
                            
                          
                          },
                          child: Container(
                            height: Reusable.getDeviceHeight(context, H: 60),
                            width: Reusable.getDeviceWidth(context, W: 388),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                              borderRadius: BorderRadius.circular(
                                Reusable.getDeviceWidth(context, W: 30),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _getTranslation("JOIN GAME"), // 🌍 Translated
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
                          ),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 60),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_translationsCache.isEmpty)
                const Positioned.fill(child: UserLoaderScreen()),
            ],
          ),
        );
      },
    );
  }
}
