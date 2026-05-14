import 'dart:developer';
import 'package:flutter/material.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/play(sport)/gametype.dart';
import 'package:playz_user/View/user_view/play(sport)/selectsport.dart';
import 'package:playz_user/View/user_view/play(sport)/skills.dart';
import 'package:playz_user/View/user_view/reusable.dart';
  Map<String, String> _translationsCache = {};
  String _currentLang = "en";


class FilterPlaySport extends StatefulWidget {
  const FilterPlaySport({super.key});

  @override
  State<FilterPlaySport> createState() => _FilterPlaySportState();
}

class _FilterPlaySportState extends State<FilterPlaySport> {
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Filter",
      "Reset",
      "Sport",
      "Select Sport",
      "Women's Only",
      "Date",
      "Pick a day",
      "Time",
      "Pick Exact Time",
      "Skills",
      "Give your skill",
      "Game Type",
      "Select the type of game",
      "Pay & Join",
      // END: Add default english text here
      
      // Dynamic keys from notifiers/data:
      selectedSportNotifier.value?['sport'] ?? "Select Sport",
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
    // Also load translations after selected sport is loaded if needed,
    // but the listener will handle lang change.
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
    });
  }

  bool isOn = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

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
                color:
                    isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
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
                            const SizedBox(width: 5),
                            // 🔹 Title text
                            Text(
                              _getTranslation("Filter"), // 🌍 Translated
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
                        Row(
                          children: [
                            Icon(
                              Icons.replay_outlined,
                              size: Reusable.getDeviceWidth(context, W: 25),
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                            ),
                            // SizedBox(width: 5),
                            // 🔹 Reset text
                            Text(
                              _getTranslation("Reset"), // 🌍 Translated
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                              ),
                            ),

                            SizedBox(
                              width: Reusable.getDeviceWidth(context, W: 20),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      // 🔹 Select Sport Item
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SelectSport();
                                  },
                                ),
                              )
                              .then((_) {
                            // Refresh UI after returning from SelectSport
                            setState(() {
                              _loadTranslations(appLanguageNotifier.value);
                            });
                          });
                        },
                        child: Container(
                          height:
                              Reusable.getDeviceHeight(context, H: 70),
                          width:
                              Reusable.getDeviceWidth(context, W: 388),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    ValueListenableBuilder<
                                        Map<String, dynamic>?>(
                                      valueListenable: selectedSportNotifier,
                                      builder: (context, selected, _) {
                                        return Icon(
                                          selected?['icon'] ?? Icons.sports,
                                          size: Reusable.getDeviceWidth(
                                            context,
                                            W: 40,
                                          ),
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getDarkGrey(),
                                        );
                                      },
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
                                          _getTranslation("Sport"), // 🌍 Translated
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Reusable.getLightGrey()
                                                : Reusable.getBlack(),
                                          ),
                                        ),
                                        ValueListenableBuilder<
                                            Map<String, dynamic>?>(
                                          valueListenable:
                                              selectedSportNotifier,
                                          builder: (context, selected, _) {
                                            String sportKey = selected?['sport'] ?? "Select Sport";
                                            return Text(
                                              _getTranslation(sportKey), // 🌍 Translated sport name/placeholder
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? Reusable.getLightGreen()
                                                    : Reusable.getDarkGrey(),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: Reusable.getDeviceWidth(context, W: 30),
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

                      // 🔹 Women's Only Label
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
                                _getTranslation("Women's Only"), // 🌍 Translated
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

                      // 🔹 Date Picker
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
                                  // NOTE: Date picker theme text needs to be translated via context builder if required,
                                  // but the main text is translated below.
                                ),
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
                                    : const Color.fromRGBO(81, 81, 81, 0.3),
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: Reusable.getDeviceWidth(context, W: 30),
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
                                              _getTranslation("Date"), // 🌍 Translated
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? Reusable.getLightGrey()
                                                    : Reusable.getDarkGrey(),
                                              ),
                                            ),
                                            Text(
                                              selectedDate == null
                                                  ? _getTranslation("Pick a day") // 🌍 Translated
                                                  : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
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
                                  // NOTE: Time picker theme text needs to be translated via context builder if required,
                                  // but the main text is translated below.
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
                                    : const Color.fromRGBO(81, 81, 81, 0.3),
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: Reusable.getDeviceWidth(context, W: 30),
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
                                              _getTranslation("Time"), // 🌍 Translated
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
                                                  ? _getTranslation("Pick Exact Time") // 🌍 Translated
                                                  : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
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
                                    : const Color.fromRGBO(81, 81, 81, 0.3),
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
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return SkillLevel();
                              },
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
                              Padding(
                                padding: EdgeInsets.only(
                                  left: Reusable.getDeviceWidth(context, W: 30),
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
                                              _getTranslation("Skills"), // 🌍 Translated
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? Reusable.getLightGrey()
                                                    : Reusable.getDarkGrey(),
                                              ),
                                            ),
                                            Text(
                                              _getTranslation("Give your skill"), // 🌍 Translated
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
                                    : const Color.fromRGBO(81, 81, 81, 0.3),
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
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return GameType();
                              },
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
                              Padding(
                                padding: EdgeInsets.only(
                                  left: Reusable.getDeviceWidth(context, W: 30),
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
                                              _getTranslation("Game Type"), // 🌍 Translated
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: isDark
                                                    ? Reusable.getLightGrey()
                                                    : Reusable.getDarkGrey(),
                                              ),
                                            ),
                                            Text(
                                              _getTranslation("Select the type of game"), // 🌍 Translated
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
                                    : const Color.fromRGBO(81, 81, 81, 0.3),
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 🔹 Pay & Join Toggle
                      Container(
                        decoration: BoxDecoration(
                            color: isDark
                                ? Reusable.getDarkModeBlack()
                                : Reusable.getWhite()),
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: Reusable.getDeviceWidth(context, W: 30),
                                right: Reusable.getDeviceWidth(context, W: 30),
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
                                            _getTranslation("Pay & Join"), // 🌍 Translated
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
                                        : Reusable.getWhite(),
                                    inactiveThumbColor: Reusable.getDarkGrey(),
                                    inactiveTrackColor: Reusable.getLightGrey(),
                                    value: isOn,
                                    onChanged: (bool value) {
                                      setState(() {
                                        isOn = value; // update toggle state
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Divider(
                              color: isDark
                                  ? Reusable.getLightGrey()
                                  : const Color.fromRGBO(81, 81, 81, 0.3),
                              thickness: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                          ],
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