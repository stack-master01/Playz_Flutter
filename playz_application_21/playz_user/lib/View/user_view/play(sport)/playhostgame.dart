import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:playz_user/Controller/User_Controller/User_Solo_Queue_Controller.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/play(sport)/gametype.dart';
import 'package:playz_user/View/user_view/play(sport)/mappicker.dart';
import 'package:playz_user/View/user_view/play(sport)/selectsport.dart';
import 'package:playz_user/View/user_view/play(sport)/skills.dart';
import 'package:playz_user/View/user_view/reusable.dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class HostGame extends StatefulWidget {
  const HostGame({super.key});

  @override
  State<HostGame> createState() => _HostGameState();
}

class _HostGameState extends State<HostGame> {
  String? selectedSport;
  bool isPublic = true;
  final FirebaseFirestore _firebaseFirestoreObj = FirebaseFirestore.instance;

  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Host a Game",
      "Sport",
      "Cricket", // Example selected sport
      "Women's Only",
      "Area",
      "Pick location on map",
      "Date",
      "Pick a day",
      "Time",
      "Pick Exact Time",
      "Skills",
      "Give your skill",
      "Game Type",
      "Select the type of game",
      "Pay & Join",
      "Total no. of players (including you)",
      "Cost per player",
      "Game Access",
      "Public",
      "Private",
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
    _loadSelectedLocation(); // Added here for consistency, though it doesn't directly affect HostGame fields yet.
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
    log("city in host game page: $selected");
    setState(() {
      selectedLocation = selected;
      // Trigger translation load if location text changes and needs translation
      _loadTranslations(appLanguageNotifier.value);
    });
  }

  String? skill;
  String gameType = "Normal";
  bool isOn = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  LatLng? selectedLatLng;
  String? selectedAddress;

  TextEditingController noOfPlayersController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  // Helper for date formatting
  String get _formattedDate => selectedDate == null
      ? _getTranslation("Pick a day")
      : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}";

  // Helper for time formatting
  String get _formattedTime => selectedTime == null
      ? _getTranslation("Pick Exact Time")
      : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // 🔙 Back button
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(false),
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
                              _getTranslation("Host a Game"), // 🌍 Translated
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

                        IconButton(
                          onPressed: () async {
                            UserSettings userSettings = await UserSettings()
                                .loadSettings();
                            log("${userSettings.email}");
                            Map<String, dynamic>
                            soloQueueObj = HostGameController().createSoloQueueObject(
                              hostName: userSettings.userName ?? "Anonymous",
                              hostProfileUrl: userSettings.imageURL ?? "https://t3.ftcdn.net/jpg/07/24/59/76/360_F_724597608_pmo5BsVumFcFyHJKlASG2Y2KpkkfiYUU.jpg",
                              hostEmail:
                                  userSettings.email ?? "unknown@user.com",
                              hostSkillLevel: "Elite",
                              hostLevelColor: {"r": 33, "g": 150, "b": 243},
                              hostLevelPercent: 70,
                              sport: selectedSport ?? "Cricket",
                              gameType: gameType ?? "Friendly",
                              gameAccess: isPublic ? "Public" : "Private",
                              skillLimit: skill ?? "Elite",
                              price: priceController.text,
                              totalPlayers: noOfPlayersController.text,
                              selectedLatLng: selectedLatLng,
                              selectedAddress: selectedAddress,
                              date:
                                  "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                              time:
                                  "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}", isHost: true, playerEmail: userSettings.email ?? "user@gmail.com",
                            );

                            await HostGameController().uploadSoloGame(
                              soloQueueObj,
                            );
                            Navigator.of(context).pop(true);
                          },
                          icon: Icon(
                            Icons.done,
                            size: Reusable.getDeviceWidth(context, W: 30),
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

                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),

                        // 🔹 Sport Selection
                        GestureDetector(
                          onTap: () async {
                            selectedSport = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return SelectSport();
                                },
                              ),
                            );
                            setState(() {
                              
                            });
                          },
                          child: Container(
                            height: Reusable.getDeviceHeight(context, H: 70),
                            width: Reusable.getDeviceWidth(context, W: 388),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeGrey()
                                  : Reusable.getWhite(),
                              border: Border.all(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(
                                Reusable.getDeviceWidth(context, W: 35),
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
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.sports,
                                        size: Reusable.getDeviceWidth(
                                          context,
                                          W: 40,
                                        ),
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getDarkGrey(),
                                      ),
                                      SizedBox(
                                        width: Reusable.getDeviceWidth(
                                          context,
                                          W: 20,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _getTranslation(
                                              "Sport",
                                            ), // 🌍 Translated
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? Reusable.getLightGrey()
                                                  : Reusable.getBlack(),
                                            ),
                                          ),
                                          Text(
                                            _getTranslation(
                                              selectedSport ?? "Cricket",
                                            ), // 🌍 Translated
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Reusable.getLightGreen()
                                                  : Reusable.getDarkGrey(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),

                        // 🔹 Women's Only tag
                        Padding(
                          padding: EdgeInsets.only(
                            left: Reusable.getDeviceWidth(context, W: 20),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Reusable.getDeviceWidth(context, W: 10),
                                ),
                                border: Border.all(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getDarkGrey(),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(
                                  Reusable.getDeviceWidth(context, W: 5),
                                ),
                                child: Text(
                                  _getTranslation(
                                    "Women's Only",
                                  ), // 🌍 Translated
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 10),
                        ),

                        // 🔹 Area/Location Picker
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MapPickerPage(
                                  onLocationPicked:
                                      (LatLng pos, String address) {
                                        setState(() {
                                          selectedLatLng = pos;
                                          selectedAddress = address;
                                        });
                                      },
                                ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                            ),
                            child: Column(
                              children: [
                                Divider(
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Color.fromRGBO(81, 81, 81, 0.3),
                                  thickness: 1,
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: Reusable.getDeviceWidth(
                                              context,
                                              W: 30,
                                            ),
                                            color: isDark
                                                ? Reusable.getLightGreen()
                                                : Reusable.getDarkGrey(),
                                          ),
                                          SizedBox(
                                            width: Reusable.getDeviceWidth(
                                              context,
                                              W: 20,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _getTranslation(
                                                  "Area",
                                                ), // 🌍 Translated
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Reusable.getLightGrey()
                                                      : Reusable.getBlack(),
                                                ),
                                              ),
                                              Container(
                                                width: Reusable.getDeviceWidth(
                                                  context,
                                                  W: 250,
                                                ),
                                                child: Text(
                                                  selectedAddress ??
                                                      _getTranslation(
                                                        "Pick location on map",
                                                      ), // 🌍 Translated
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getDarkGrey(),
                                                  ),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
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
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 🔹 Date Picker
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Reusable.getGreen(),
                                      onPrimary: Colors.white,
                                      onSurface: Reusable.getDarkGrey(),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                              context: context,
                              initialDate: selectedDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                            ),
                            child: Column(
                              children: [
                                Divider(
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Color.fromRGBO(81, 81, 81, 0.3),
                                  thickness: 1,
                                  indent: 20,
                                  endIndent: 20,
                                ),

                                Padding(
                                  padding: EdgeInsets.only(
                                    left: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                    right: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_month,
                                            size: Reusable.getDeviceWidth(
                                              context,
                                              W: 30,
                                            ),
                                            color: isDark
                                                ? Reusable.getLightGreen()
                                                : Reusable.getDarkGrey(),
                                          ),
                                          SizedBox(
                                            width: Reusable.getDeviceWidth(
                                              context,
                                              W: 20,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _getTranslation(
                                                  "Date",
                                                ), // 🌍 Translated
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Reusable.getLightGrey()
                                                      : Reusable.getBlack(),
                                                ),
                                              ),
                                              Text(
                                                _formattedDate, // Uses translated helper
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: isDark
                                                      ? Reusable.getLightGreen()
                                                      : Reusable.getDarkGrey(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
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
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 🔹 Time Picker
                        GestureDetector(
                          onTap: () async {
                            TimeOfDay now = TimeOfDay.now();
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: selectedTime ?? now,
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: Reusable.getGreen(),
                                      onPrimary: Colors.white,
                                      onSurface: Reusable.getDarkGrey(),
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: Reusable.getGreen(),
                                      ),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );

                            if (picked != null) {
                              setState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                            ),
                            child: Column(
                              children: [
                                Divider(
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Color.fromRGBO(81, 81, 81, 0.3),
                                  thickness: 1,
                                  indent: 20,
                                  endIndent: 20,
                                ),

                                Padding(
                                  padding: EdgeInsets.only(
                                    left: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                    right: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            size: Reusable.getDeviceWidth(
                                              context,
                                              W: 30,
                                            ),
                                            color: isDark
                                                ? Reusable.getLightGreen()
                                                : Reusable.getDarkGrey(),
                                          ),
                                          SizedBox(
                                            width: Reusable.getDeviceWidth(
                                              context,
                                              W: 20,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _getTranslation(
                                                  "Time",
                                                ), // 🌍 Translated
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Reusable.getLightGrey()
                                                      : Reusable.getBlack(),
                                                ),
                                              ),
                                              Text(
                                                _formattedTime, // Uses translated helper
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: isDark
                                                      ? Reusable.getLightGreen()
                                                      : Reusable.getDarkGrey(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
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
                                ),

                                Divider(
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Color.fromRGBO(81, 81, 81, 0.3),
                                  thickness: 1,
                                  indent: 20,
                                  endIndent: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 🔹 Skills
                        GestureDetector(
                          onTap: () async {
                            skill = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return SkillLevel();
                                },
                              ),
                            );
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                    right: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star_border_outlined,
                                            size: Reusable.getDeviceWidth(
                                              context,
                                              W: 30,
                                            ),
                                            color: isDark
                                                ? Reusable.getLightGreen()
                                                : Reusable.getDarkGrey(),
                                          ),
                                          SizedBox(
                                            width: Reusable.getDeviceWidth(
                                              context,
                                              W: 20,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _getTranslation(
                                                  "Skills",
                                                ), // 🌍 Translated
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Reusable.getLightGrey()
                                                      : Reusable.getBlack(),
                                                ),
                                              ),
                                              Text(
                                                skill == null
                                                    ? _getTranslation(
                                                        "Give your skill",
                                                      )
                                                    : _getTranslation(
                                                        skill!,
                                                      ), // 🌍 Translated
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: isDark
                                                      ? Reusable.getLightGreen()
                                                      : Reusable.getDarkGrey(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
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
                                ),

                                Divider(
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Color.fromRGBO(81, 81, 81, 0.3),
                                  thickness: 1,
                                  indent: 20,
                                  endIndent: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 🔹 Game Type
                        GestureDetector(
                          onTap: () async {
                            gameType = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) {
                                  return GameType();
                                },
                              ),
                            );
                            setState(() {});
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                    right: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.category_outlined,
                                            size: Reusable.getDeviceWidth(
                                              context,
                                              W: 30,
                                            ),
                                            color: isDark
                                                ? Reusable.getLightGreen()
                                                : Reusable.getDarkGrey(),
                                          ),
                                          SizedBox(
                                            width: Reusable.getDeviceWidth(
                                              context,
                                              W: 20,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _getTranslation(
                                                  "Game Type",
                                                ), // 🌍 Translated
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Reusable.getLightGrey()
                                                      : Reusable.getBlack(),
                                                ),
                                              ),
                                              Text(
                                                gameType == null
                                                    ? _getTranslation(
                                                        "Select the type of game",
                                                      )
                                                    : _getTranslation(
                                                        gameType!,
                                                      ), // 🌍 Translated
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: isDark
                                                      ? Reusable.getLightGreen()
                                                      : Reusable.getDarkGrey(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
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
                                ),

                                Divider(
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Color.fromRGBO(81, 81, 81, 0.3),
                                  thickness: 1,
                                  indent: 20,
                                  endIndent: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 🔹 Pay & Join Toggle and Inputs
                        SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: (MediaQuery.of(
                                context,
                              ).viewInsets.bottom),
                            ),
                            child: Container(
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: Reusable.getDeviceWidth(
                                        context,
                                        W: 30,
                                      ),
                                      right: Reusable.getDeviceWidth(
                                        context,
                                        W: 30,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.payments_outlined,
                                              size: Reusable.getDeviceWidth(
                                                context,
                                                W: 30,
                                              ),
                                              color: isDark
                                                  ? Reusable.getLightGreen()
                                                  : Reusable.getDarkGrey(),
                                            ),
                                            SizedBox(
                                              width: Reusable.getDeviceWidth(
                                                context,
                                                W: 20,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _getTranslation(
                                                    "Pay & Join",
                                                  ), // 🌍 Translated
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getDarkGrey(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Switch(
                                          activeTrackColor: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getGreen(),
                                          activeColor: isDark
                                              ? Reusable.getDarkModeBlack()
                                              : Reusable.getDarkGrey(),
                                          inactiveThumbColor:
                                              Reusable.getDarkGrey(),
                                          inactiveTrackColor:
                                              Reusable.getLightGrey(),
                                          value: isOn,
                                          onChanged: (bool value) {
                                            setState(() {
                                              isOn =
                                                  value; // update toggle state
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  isOn
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              height: Reusable.getDeviceHeight(
                                                context,
                                                H: 10,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: Reusable.getDeviceWidth(
                                                  context,
                                                  W: 20,
                                                ),
                                                right: Reusable.getDeviceWidth(
                                                  context,
                                                  W: 20,
                                                ),
                                              ),
                                              child: TextField(
                                                controller:
                                                    noOfPlayersController,
                                                cursorColor:
                                                    Reusable.getGreen(),
                                                decoration: InputDecoration(
                                                  hintText: _getTranslation(
                                                    "Total no. of players (including you)",
                                                  ), // 🌍 Translated
                                                  hintStyle: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          Reusable.getLightGrey(),
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Reusable.getDeviceWidth(
                                                            context,
                                                            W: 30,
                                                          ),
                                                        ),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          Reusable.getGreen(),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Reusable.getDeviceWidth(
                                                            context,
                                                            W: 30,
                                                          ),
                                                        ),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                          color: Colors.orange,
                                                          width: 2,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                              color:
                                                                  Colors.purple,
                                                              width: 2,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: Reusable.getDeviceHeight(
                                                context,
                                                H: 10,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                left: Reusable.getDeviceWidth(
                                                  context,
                                                  W: 20,
                                                ),
                                                right: Reusable.getDeviceWidth(
                                                  context,
                                                  W: 20,
                                                ),
                                              ),
                                              child: TextField(
                                                controller: priceController,
                                                cursorColor:
                                                    Reusable.getGreen(),
                                                decoration: InputDecoration(
                                                  hintText: _getTranslation(
                                                    "Cost per player",
                                                  ), // 🌍 Translated
                                                  hintStyle: const TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          Reusable.getLightGrey(),
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Reusable.getDeviceWidth(
                                                            context,
                                                            W: 30,
                                                          ),
                                                        ),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      color:
                                                          Reusable.getGreen(),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          Reusable.getDeviceWidth(
                                                            context,
                                                            W: 30,
                                                          ),
                                                        ),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                          color: Colors.orange,
                                                          width: 2,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  focusedErrorBorder:
                                                      OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                              color:
                                                                  Colors.purple,
                                                              width: 2,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: Reusable.getDeviceHeight(
                                                context,
                                                H: 10,
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox(),
                                  Divider(
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Color.fromRGBO(81, 81, 81, 0.3),
                                    thickness: 1,
                                    indent: 20,
                                    endIndent: 20,
                                  ),

                                  // 🔹 Game Access Section
                                  GestureDetector(
                                    onTap: () {
                                      // // Note: Current onTap navigates to SkillLevel, which seems incorrect for Game Access.
                                      // // You might want to update this to a dedicated GameAccess screen/modal.
                                      // Navigator.of(context).push(
                                      //   MaterialPageRoute(
                                      //     builder: (context) {
                                      //       return SkillLevel();
                                      //     },
                                      //   ),
                                      // );
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Reusable.getDarkModeBlack()
                                            : Reusable.getWhite(),
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                              left: Reusable.getDeviceWidth(
                                                context,
                                                W: 30,
                                              ),
                                              right: Reusable.getDeviceWidth(
                                                context,
                                                W: 30,
                                              ),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .room_preferences_outlined,
                                                          size:
                                                              Reusable.getDeviceWidth(
                                                                context,
                                                                W: 30,
                                                              ),
                                                          color: isDark
                                                              ? Reusable.getLightGreen()
                                                              : Reusable.getDarkGrey(),
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              Reusable.getDeviceWidth(
                                                                context,
                                                                W: 20,
                                                              ),
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              _getTranslation(
                                                                "Game Access",
                                                              ), // 🌍 Translated
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: isDark
                                                                    ? Reusable.getLightGreen()
                                                                    : Reusable.getDarkGrey(),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height:
                                                      Reusable.getDeviceHeight(
                                                        context,
                                                        H: 20,
                                                      ),
                                                ),

                                                // Public/Private buttons
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        isPublic = true;
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: isPublic
                                                              ? isDark
                                                                    ? Reusable.getLightGreen()
                                                                    : Reusable.getGreen()
                                                              : Reusable.getDarkGrey(),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Reusable.getDeviceWidth(
                                                                  context,
                                                                  W: 10,
                                                                ),
                                                              ),
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsets.only(
                                                            left:
                                                                Reusable.getDeviceWidth(
                                                                  context,
                                                                  W: 20,
                                                                ),
                                                            right:
                                                                Reusable.getDeviceWidth(
                                                                  context,
                                                                  W: 20,
                                                                ),
                                                            top:
                                                                Reusable.getDeviceHeight(
                                                                  context,
                                                                  H: 10,
                                                                ),
                                                            bottom:
                                                                Reusable.getDeviceHeight(
                                                                  context,
                                                                  H: 10,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .language_rounded,
                                                                size:
                                                                    Reusable.getDeviceWidth(
                                                                      context,
                                                                      W: 30,
                                                                    ),
                                                                color: isDark
                                                                    ? Reusable.getDarkModeBlack()
                                                                    : Reusable.getWhite(),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    Reusable.getDeviceWidth(
                                                                      context,
                                                                      W: 10,
                                                                    ),
                                                              ),
                                                              Text(
                                                                _getTranslation(
                                                                  "Public",
                                                                ), // 🌍 Translated
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
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
                                                    SizedBox(
                                                      width:
                                                          Reusable.getDeviceWidth(
                                                            context,
                                                            W: 40,
                                                          ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        isPublic = false;
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: isPublic
                                                              ? Reusable.getDarkGrey()
                                                              : Colors
                                                                    .redAccent,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Reusable.getDeviceWidth(
                                                                  context,
                                                                  W: 10,
                                                                ),
                                                              ),
                                                        ),
                                                        child: Padding(
                                                          padding: EdgeInsets.only(
                                                            left:
                                                                Reusable.getDeviceWidth(
                                                                  context,
                                                                  W: 20,
                                                                ),
                                                            right:
                                                                Reusable.getDeviceWidth(
                                                                  context,
                                                                  W: 20,
                                                                ),
                                                            top:
                                                                Reusable.getDeviceHeight(
                                                                  context,
                                                                  H: 10,
                                                                ),
                                                            bottom:
                                                                Reusable.getDeviceHeight(
                                                                  context,
                                                                  H: 10,
                                                                ),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .lock_outline_rounded,
                                                                size:
                                                                    Reusable.getDeviceWidth(
                                                                      context,
                                                                      W: 30,
                                                                    ),
                                                                color:
                                                                    Reusable.getWhite(),
                                                              ),
                                                              SizedBox(
                                                                width:
                                                                    Reusable.getDeviceWidth(
                                                                      context,
                                                                      W: 10,
                                                                    ),
                                                              ),
                                                              Text(
                                                                _getTranslation(
                                                                  "Private",
                                                                ), // 🌍 Translated
                                                                style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color:
                                                                      Reusable.getWhite(),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: Reusable.getDeviceHeight(
                                              context,
                                              H: 10,
                                            ),
                                          ),
                                          Divider(
                                            color: isDark
                                                ? Reusable.getLightGrey()
                                                : Color.fromRGBO(
                                                    81,
                                                    81,
                                                    81,
                                                    0.3,
                                                  ),
                                            thickness: 1,
                                            indent: 20,
                                            endIndent: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
