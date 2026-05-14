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

class PlayInfoPlayers extends StatefulWidget {
  Map<String,dynamic> allPlayersList;

   PlayInfoPlayers({super.key, required this.allPlayersList});

  @override
  State<PlayInfoPlayers> createState() => _PlayInfoPlayersState();
}

// 🔹 Dummy list of group members (image, name, role)
List<Map<String, dynamic>> PlayInfoPlayersCardList = [
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "member_name": "Arnold Schwarzenegger",
  },
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "member_name": "Arnold Schwarzenegger",
  },
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "member_name": "Arnold Schwarzenegger",
  },
];

class _PlayInfoPlayersState extends State<PlayInfoPlayers> {

  Map<String,dynamic> appliedPlayers ={};
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Players (5)",
      "Search by Name",
      "HOST",
      "Pro", // Example skill level
      "Arnold Schwarzenegger", // Member name is static in this dummy list
      // END: Add default english text here
    };

    // Add member names from the static list to the translation keys
    for (var member in PlayInfoPlayersCardList) {
      if (member['member_name'] is String) {
        keys.add(member['member_name'] as String);
      }
    }

    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }
    _extractStrings(widget.allPlayersList, keys);
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
    appliedPlayers = widget.allPlayersList;
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
                          _getTranslation("Players (${appliedPlayers['Players'].length})"), // 🌍 Translated
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

                      // 🔹 Search bar for members
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
                            hintText: _getTranslation("Search by Name"), // 🌍 Translated
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getDarkGrey(),
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

                      // 🔹 List of Group Members
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true, // prevents infinite height
                          itemCount: appliedPlayers['Players'].length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                // 🔹 Member card container
                                Container(
                                  // height: Reusable.getDeviceHeight(context, H: 70),
                                  width:
                                      Reusable.getDeviceWidth(context, W: 388),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Reusable.getDarkModeGrey()
                                        : Reusable.getWhite(),
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
                                    padding: EdgeInsets.only(
                                      top: Reusable.getDeviceHeight(
                                        context,
                                        H: 10,
                                      ),
                                      bottom: Reusable.getDeviceHeight(
                                        context,
                                        H: 10,
                                      ),
                                      left: Reusable.getDeviceWidth(
                                        context,
                                        W: 10,
                                      ),
                                      right: Reusable.getDeviceWidth(
                                        context,
                                        W: 10,
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
                                                H: 50,
                                              ),
                                              width: Reusable.getDeviceWidth(
                                                context,
                                                W: 50,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Reusable.getDeviceWidth(
                                                    context,
                                                    W: 35,
                                                  ),
                                                ),
                                                color: Reusable.getBlack(),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  Reusable.getDeviceWidth(
                                                    context,
                                                    W: 35,
                                                  ),
                                                ),
                                                child: Image.network(
                                                  appliedPlayers['Players'][index]['profile_image'] ?? "url",
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
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          _getTranslation("${appliedPlayers['Players'][index]['player_name']}"), // 🌍 Translated
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: isDark
                                                                ? Reusable
                                                                    .getLightGreen()
                                                                : Reusable
                                                                    .getBlack(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      width: Reusable
                                                          .getDeviceWidth(
                                                        context,
                                                        W: 10,
                                                      ),
                                                    ),
                                                    (appliedPlayers['Players'][index]['ishost'])
                                                        ? Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isDark
                                                                  ? Reusable
                                                                      .getLightGreen()
                                                                  : Reusable
                                                                      .getGreen(),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                Reusable
                                                                    .getDeviceWidth(
                                                                  context,
                                                                  W: 5,
                                                                ),
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets.only(
                                                                left: Reusable
                                                                    .getDeviceWidth(
                                                                  context,
                                                                  W: 5,
                                                                ),
                                                                right: Reusable
                                                                    .getDeviceWidth(
                                                                  context,
                                                                  W: 5,
                                                                ),
                                                              ),
                                                              child: Text(
                                                                _getTranslation("HOST"), // 🌍 Translated
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      Reusable.getDeviceWidth(
                                                                    context,
                                                                    W: 10,
                                                                  ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: isDark
                                                                      ? Reusable
                                                                          .getDarkModeBlack()
                                                                      : Reusable
                                                                          .getWhite(),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : SizedBox(),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: Reusable
                                                      .getDeviceHeight(
                                                    context,
                                                    H: 5,
                                                  ),
                                                ),
                                                // Skill Level Tag
                                                SizedBox(
                                                  width: Reusable
                                                      .getDeviceWidth(
                                                    context,
                                                    W: 80,
                                                  ),
                                                  height: Reusable
                                                      .getDeviceHeight(
                                                    context,
                                                    H: 20,
                                                  ),
                                                  child: Stack(
                                                    children: [
                                                      Container(
                                                        width: Reusable
                                                            .getDeviceWidth(
                                                          context,
                                                          W: 80,
                                                        ),
                                                        height: Reusable
                                                            .getDeviceHeight(
                                                          context,
                                                          H: 20,
                                                        ),

                                                        decoration: BoxDecoration(
                                                          color: Color.fromRGBO(
                                                            255,
                                                            255,
                                                            255,
                                                            1,
                                                          ),
                                                          //skill level color
                                                          border: Border.all(
                                                            color: Color.fromRGBO(
                                                              100,
                                                              181,
                                                              246,
                                                              1,
                                                            ),
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            5,
                                                          ),
                                                        ),
                                                      ),

                                                      Container(
                                                        width: Reusable
                                                                .getDeviceWidth(
                                                              context,
                                                              W: 100,
                                                            ) *
                                                            0.7,
                                                        height: Reusable
                                                            .getDeviceHeight(
                                                          context,
                                                          H: 25,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Color.fromRGBO(
                                                            100,
                                                            181,
                                                            246,
                                                            1,
                                                          ),
                                                          border: Border.all(
                                                            color: Color.fromRGBO(
                                                              100,
                                                              181,
                                                              246,
                                                              1,
                                                            ),
                                                            width: 1,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            5,
                                                          ),
                                                        ),
                                                      ),

                                                      Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          _getTranslation("Pro"), // 🌍 Translated
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Color.fromRGBO(
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

                                        // 🔽 Dropdown icon (to change role)
                                      ],
                                    ),
                                  ),
                                ),
                                // Space between cards
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 10,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
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