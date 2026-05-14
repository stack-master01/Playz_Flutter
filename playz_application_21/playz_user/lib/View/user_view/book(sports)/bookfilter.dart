import 'dart:developer'; // For log()

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Note: These imports are left as is, assuming they exist in your project structure
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/play(sport)/mappicker.dart';
import 'package:playz_user/View/user_view/play(sport)/selectsport.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:intl/intl.dart'; // Needed for DateFormat
  Map<String, String> _translationsCache = {};
  String _currentLang = "en";


class BookFilterSport extends StatefulWidget {
  const BookFilterSport({super.key});

  @override
  State<BookFilterSport> createState() => _BookFilterSportState();
}

class _BookFilterSportState extends State<BookFilterSport> {
  // Local state for the screen
  bool isOn = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  LatLng? selectedLatLng;
  String? selectedAddress;
  String? selectedLocation; // From the provided logic

  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN)
  // ===================================================================


  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here
      "Filter",
      "Sport",
      "Cricket",
      "Women's Only",
      "Area",
      "Pick location on map",
      "Date",
      "Pick a day",
      "Time",
      "Pick Exact Time",
      // END: Add default english text here
    };
    return keys.toList();
  }

  void _languageChangeListener() {
    _loadTranslations(appLanguageNotifier.value);
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

  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;
    if (_currentLang == lang && _translationsCache.keys.length == keysToLoad.length) {
      return;
    }

    _currentLang = lang;
    Map<String, String> newTranslations = {};

    for (String key in keysToLoad) {
      String translated = await getTranslatedText(
        key,
        lang,
      ); // getTranslatedText should be available in the project
      newTranslations[key] = translated;
    }

    if (mounted) {
      setState(() {
        _translationsCache = newTranslations;
      });
    }
  }
String? selectedSport;
  String _getTranslation(String key) => _translationsCache[key] ?? key;
  // ------------------------------------------------------------------

  Future<void> _loadSelectedLocation() async {
    String? selected = await Appsharedpreferences().loadSelectedCity();
    selectedLocationNotifier.value = selected;
    log("city in home page: $selected");
    setState(() {
      selectedLocation = selected;
    });
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

  // ===================================================================
  // WIDGET BUILD METHOD WITH TRANSLATION APPLIED
  // ===================================================================

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
                              _getTranslation("Filter"), // ✨ TRANSLATED
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
                        // ✅ Finalize filter (tick) - returns selected sport to caller
                        IconButton(
                          onPressed: () {
                            // prefer explicit selectedSport (from Navigator result), fallback to notifier
                            final sel = selectedSport ?? selectedSportNotifier.value?['sport'];
                            Navigator.of(context).pop(sel);
                          },
                          icon: Icon(
                            Icons.check,
                            size: Reusable.getDeviceWidth(context, W: 25),
                            color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
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

                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),

                        // 🔹 Sport selector
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
                                            _getTranslation("Sport"), // ✨ TRANSLATED
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? Reusable.getLightGreen()
                                                  : Reusable.getBlack(),
                                            ),
                                          ),
                                          Text(
                                            _getTranslation(selectedSport ?? "Cricket"), // ✨ TRANSLATED
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Reusable.getLightGrey()
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
                                  _getTranslation("Women's Only"), // ✨ TRANSLATED
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? Reusable.getLightGrey()
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

                        // 🔹 Area selector
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
                                      ? Reusable.getTextGrey()
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
                                                _getTranslation("Area"), // ✨ TRANSLATED
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Reusable.getLightGrey()
                                                      : Reusable.getDarkGrey(),
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
                                                          "Pick location on map"), // ✨ TRANSLATED
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: isDark
                                                        ? Reusable
                                                            .getLightGreen()
                                                        : Reusable
                                                            .getDarkGrey(),
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

                        // 🔹 Date selector
                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              builder: (context, child) {
                                return Theme(
                                  child: child!,
                                  data: Theme.of(context).copyWith(
                                    colorScheme: ColorScheme.light(
                                      primary: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable
                                              .getGreen(), // ✅ your custom green
                                      onPrimary: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable
                                              .getWhite(), // text/icon color on green
                                      onSurface: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                      surface: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                    ),
                                  ), // text color on surface
                                );
                              },
                              context: context,
                              initialDate: selectedDate ??
                                  DateTime.now(), // default today or previously selected
                              firstDate:
                                  DateTime(2000), // earliest allowed date
                              lastDate: DateTime(2100), // latest allowed date
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
                                      ? Reusable.getTextGrey()
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
                                                _getTranslation("Date"), // ✨ TRANSLATED
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Reusable.getLightGrey()
                                                      : Reusable.getDarkGrey(),
                                                ),
                                              ),
                                              Text(
                                                selectedDate != null
                                                    ? DateFormat('dd MMM yyyy')
                                                        .format(selectedDate!)
                                                    : _getTranslation(
                                                        "Pick a day"), // ✨ TRANSLATED
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: isDark
                                                      ? Reusable
                                                          .getLightGreen()
                                                      : Reusable
                                                          .getDarkGrey(),
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

                        // 🔹 Time selector
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
                                      primary: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getGreen(),
                                      onPrimary: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                      onSurface: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                      surface: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                    ),
                                    textButtonTheme: TextButtonThemeData(
                                      style: TextButton.styleFrom(
                                        foregroundColor: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                    ),
                                    textTheme: TextTheme(
                                      titleLarge: TextStyle(
                                        // 🔹 "SELECT TIME" header
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getDarkGrey(),
                                        fontWeight: FontWeight.bold,
                                      ),
                                      bodyLarge: TextStyle(
                                        // 🔹 fallback for text inside picker
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getDarkGrey(),
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
                                      ? Reusable.getTextGrey()
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
                                                _getTranslation("Time"), // ✨ TRANSLATED
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Reusable.getLightGrey()
                                                      : Reusable.getDarkGrey(),
                                                ),
                                              ),
                                              Text(
                                                selectedTime == null
                                                    ? _getTranslation(
                                                        "Pick Exact Time") // ✨ TRANSLATED
                                                    : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: isDark
                                                      ? Reusable
                                                          .getLightGreen()
                                                      : Reusable
                                                          .getDarkGrey(),
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
                                      ? Reusable.getTextGrey()
                                      : Color.fromRGBO(81, 81, 81, 0.3),
                                  thickness: 1,
                                  indent: 20,
                                  endIndent: 20,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 🔹 List of Group Members
                      ],
                    ),
                  ),
                ),
              ),
              // if (_translationsCache.isEmpty)
              // const Positioned.fill(
              //   child: UserLoaderScreen(),
              // ),
            ],
          ),
        );
      },
    );
  }
}