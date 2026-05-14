import 'dart:developer';

import 'package:flutter/material.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';
  Map<String, String> _translationsCache = {};
  String _currentLang = "en";



class SkillLevel extends StatefulWidget {
  const SkillLevel({super.key});

  @override
  State<SkillLevel> createState() => _SkillLevelState();
}

class _SkillLevelState extends State<SkillLevel> {
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Skill Level",
      "Rookie",
      "Contender",
      "Champion", // This is repeated in the UI, but added once here
      "GOAT",
      "Clear",
      "Done",
      // END: Add default english text here
    };

    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }
    return keys.toList();
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
      // Also load translations if location name might need it
      _loadTranslations(appLanguageNotifier.value);
    });
  }
  // ===================================================================

  bool isOn = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isRookieSelected = false;
  bool isContenderSelected = false;
  bool isEliteSelected = false;
  bool isChampionSelected = false;
  bool isGOATSelected = false;

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
                    padding:
                        const EdgeInsets.only(top: 40, left: 10, right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // 🔙 Back button


                           


                            IconButton(
                              onPressed: () => Navigator.of(context).pop("${isRookieSelected ? "-Rookie " : ""}" "${isContenderSelected ? "-Contender " : "" }" "${isEliteSelected ? "-Elite " : "" }" "${isChampionSelected ? "-Champion " : "" }" "${isGOATSelected ? "-GOAT" : "" }"),
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                size: Reusable.getDeviceWidth(context, W: 25),
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                              ),
                            ),
                            const SizedBox(width: 5),
                            // 🔹 Title text
                            Text(
                              _getTranslation("Skill Level"), // 🌍 Translated
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
                      ],
                    ),
                  ),
                ),
              ),

              // 🔹 White rounded bottom sheet (Main content area)
              Positioned(
                top: (MediaQuery.of(context).size.height) *
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

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 20),
                          ),

                          // 🔹 Rookie toggle
                          Container(
                            height: Reusable.getDeviceHeight(context, H: 60),
                            width: Reusable.getDeviceWidth(context, W: 388),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                              border: Border.all(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                Reusable.getDeviceWidth(context, W: 30),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: Reusable.getDeviceWidth(context, W: 20),
                                right: Reusable.getDeviceWidth(context, W: 20),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _getTranslation("Rookie"), // 🌍 Translated
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                  ),

                                  // ✅ Custom green checkbox
                                  StatefulBuilder(
                                    builder: (context, setStateCheck) {
                                      return Checkbox(
                                        value: isRookieSelected,
                                        activeColor: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                        checkColor: isDark
                                            ? Reusable.getDarkModeBlack()
                                            : Reusable.getWhite(), // tick color
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isRookieSelected = value ?? false;
                                          });
                                          setStateCheck(() {}); // update local UI
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 20),
                          ),

                          // 🔹 Contender toggle
                          Container(
                            height: Reusable.getDeviceHeight(context, H: 60),
                            width: Reusable.getDeviceWidth(context, W: 388),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                              border: Border.all(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                Reusable.getDeviceWidth(context, W: 30),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: Reusable.getDeviceWidth(context, W: 20),
                                right: Reusable.getDeviceWidth(context, W: 20),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _getTranslation("Contender"), // 🌍 Translated
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                  ),

                                  // ✅ Custom green checkbox
                                  StatefulBuilder(
                                    builder: (context, setStateCheck) {
                                      return Checkbox(
                                        value: isContenderSelected,
                                        activeColor: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                        checkColor: isDark
                                            ? Reusable.getDarkModeBlack()
                                            : Reusable.getWhite(),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isContenderSelected = value ?? false;
                                          });
                                          setStateCheck(() {}); // update local UI
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 20),
                          ),

                          // 🔹 Elite toggle (Note: Variable name is isEliteSelected, but text is Champion)
                          Container(
                            height: Reusable.getDeviceHeight(context, H: 60),
                            width: Reusable.getDeviceWidth(context, W: 388),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                              border: Border.all(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                Reusable.getDeviceWidth(context, W: 30),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: Reusable.getDeviceWidth(context, W: 20),
                                right: Reusable.getDeviceWidth(context, W: 20),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _getTranslation("Elite"), // 🌍 Translated
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                  ),

                                  // ✅ Custom green checkbox
                                  StatefulBuilder(
                                    builder: (context, setStateCheck) {
                                      return Checkbox(
                                        value: isEliteSelected,
                                        activeColor: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                        checkColor: isDark
                                            ? Reusable.getDarkModeBlack()
                                            : Reusable.getWhite(),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isEliteSelected = value ?? false;
                                          });
                                          setStateCheck(() {}); // update local UI
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 20),
                          ),

                          // 🔹 Champion toggle (Note: Variable name is isChampionSelected, but text is Champion - this is likely a duplicate or error in original code)
                          Container(
                            height: Reusable.getDeviceHeight(context, H: 60),
                            width: Reusable.getDeviceWidth(context, W: 388),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                              border: Border.all(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                Reusable.getDeviceWidth(context, W: 30),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: Reusable.getDeviceWidth(context, W: 20),
                                right: Reusable.getDeviceWidth(context, W: 20),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _getTranslation("Champion"), // 🌍 Translated (Duplicate)
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                  ),

                                  // ✅ Custom green checkbox
                                  StatefulBuilder(
                                    builder: (context, setStateCheck) {
                                      return Checkbox(
                                        value: isChampionSelected,
                                        activeColor: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                        checkColor: isDark
                                            ? Reusable.getDarkModeBlack()
                                            : Reusable.getWhite(),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isChampionSelected = value ?? false;
                                          });
                                          setStateCheck(() {}); // update local UI
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 20),
                          ),

                          // 🔹 GOAT toggle
                          Container(
                            height: Reusable.getDeviceHeight(context, H: 60),
                            width: Reusable.getDeviceWidth(context, W: 388),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                              border: Border.all(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                Reusable.getDeviceWidth(context, W: 30),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                left: Reusable.getDeviceWidth(context, W: 20),
                                right: Reusable.getDeviceWidth(context, W: 20),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _getTranslation("GOAT"), // 🌍 Translated
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                  ),

                                  // ✅ Custom green checkbox
                                  StatefulBuilder(
                                    builder: (context, setStateCheck) {
                                      return Checkbox(
                                        value: isGOATSelected,
                                        activeColor: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                        checkColor: isDark
                                            ? Reusable.getDarkModeBlack()
                                            : Reusable.getWhite(),
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isGOATSelected = value ?? false;
                                          });
                                          setStateCheck(() {}); // update local UI
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: Reusable.getDeviceWidth(context, W: 20),
                              right: Reusable.getDeviceWidth(context, W: 20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 🔹 Clear Button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isRookieSelected = false;
                                      isContenderSelected = false;
                                      isEliteSelected = false;
                                      isChampionSelected = false;
                                      isGOATSelected = false;
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(
                                          context,
                                          W: 10,
                                        ),
                                      ),
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getGreen(),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: Reusable.getDeviceWidth(
                                          context,
                                          W: 60,
                                        ),
                                        right: Reusable.getDeviceWidth(
                                          context,
                                          W: 60,
                                        ),
                                        top: Reusable.getDeviceHeight(
                                          context,
                                          H: 15,
                                        ),
                                        bottom: Reusable.getDeviceHeight(
                                          context,
                                          H: 15,
                                        ),
                                      ),
                                      child: Text(
                                        _getTranslation("Clear"), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Reusable.getDarkModeBlack()
                                              : Reusable.getWhite(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // 🔹 Done Button
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      
                                    });
                                    Navigator.of(context).pop("${isRookieSelected ? "-Rookie " : ""}" "${isContenderSelected ? "-Contender " : "" }" "${isEliteSelected ? "-Elite " : "" }" "${isChampionSelected ? "-Champion " : "" }" "${isGOATSelected ? "-GOAT" : "" }");
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(
                                          context,
                                          W: 10,
                                        ),
                                      ),
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getGreen(),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        left: Reusable.getDeviceWidth(
                                          context,
                                          W: 60,
                                        ),
                                        right: Reusable.getDeviceWidth(
                                          context,
                                          W: 60,
                                        ),
                                        top: Reusable.getDeviceHeight(
                                          context,
                                          H: 15,
                                        ),
                                        bottom: Reusable.getDeviceHeight(
                                          context,
                                          H: 15,
                                        ),
                                      ),
                                      child: Text(
                                        _getTranslation("Done"), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Reusable.getDarkModeBlack()
                                              : Reusable.getWhite(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),if (_translationsCache.isEmpty)
              const Positioned.fill(
                child: UserLoaderScreen(),
              ),
            ],
          ),
        );
      },
    );
  }
}