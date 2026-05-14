import 'dart:developer'; // Required for log()
import 'dart:convert';
import 'package:flutter/material.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/navigation(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:qr_flutter/qr_flutter.dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class User_QR_Paid extends StatefulWidget {
  final String rawText;
  Map<String, dynamic> turfDetails = {};
  User_QR_Paid({super.key, required this.rawText, required this.turfDetails});

  @override
  State<User_QR_Paid> createState() => _User_QR_PaidState();
}

class _User_QR_PaidState extends State<User_QR_Paid> {
  Map<String,dynamic> currentTurfInfo = {};
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Scan & Play",
      "Arena 51",
      "Sunshine Sports Arena, Plot No. 27B,Opposite Seasons Mall, Near",
      "Mon, 1st Sep",
      "5:00 AM - 7:00 AM",
      "INR 2000",
      "Go To Scoreboard",
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
    // Note: log() call is provided in the prompt, keeping it.
    String? selected = await Appsharedpreferences().loadSelectedCity();
    selectedLocationNotifier.value = selected;
    log("city in home page: $selected");
    setState(() {
      selectedLocation = selected;
    });
  }
  // ===================================================================

  String _qrData = "";
  void _generateEncodedQRCode(String rawText) {
    if (rawText.isEmpty) return;
    final encoded = base64Encode(utf8.encode(rawText));
    setState(() {
      _qrData = encoded;
    });
  }

  @override
  void initState() {
    super.initState();
    currentTurfInfo = widget.turfDetails;
    if (_currentLang != appLanguageNotifier.value) {
      _translationsCache.clear();
    }
    // 🌍 Translation Logic Initialization
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadSelectedLocation();
    appLanguageNotifier.addListener(_languageChangeListener);
    // QR Code generation
    _generateEncodedQRCode(widget.rawText);
  }

  @override
  void dispose() {
    appLanguageNotifier.removeListener(
      _languageChangeListener,
    ); // 🌍 Translation Logic Disposal
    super.dispose();
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
                        const SizedBox(width: 5),
                        // 🔹 Title text
                        Text(
                          _getTranslation("Scan & Play"), // 🌍 Translated
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
                        height: Reusable.getDeviceHeight(context, H: 50),
                      ),
                      if (_qrData.isNotEmpty)
                        QrImageView(
                          data: _qrData,
                          version: QrVersions.auto,
                          size: 300,
                          foregroundColor: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getGreen(),
                          gapless: false,
                        ),
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 50),
                      ),
                      Container(
                        width: Reusable.getDeviceWidth(context, W: 350),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceHeight(context, H: 10),
                          ),
                          border: Border.all(
                            color: isDark
                                ? Reusable.getDarkModeGrey()
                                : Reusable.getLightGrey(),
                            width: 2,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(
                            Reusable.getDeviceWidth(context, W: 10),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _getTranslation("${currentTurfInfo['turfName']}"), // 🌍 Translated
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getDarkGrey(),
                                ),
                              ),
                              SizedBox(
                                height: Reusable.getDeviceHeight(
                                  context,
                                  H: 10,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    size: Reusable.getDeviceWidth(
                                      context,
                                      W: 25,
                                    ),
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                  SizedBox(
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 10,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _getTranslation(
                                        "${currentTurfInfo['location']['address']}",
                                      ), // 🌍 Translated (Assuming this is the full address key)
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: isDark
                                            ? Reusable.getLightGrey()
                                            : Reusable.getDarkGrey(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: Reusable.getDeviceHeight(
                                  context,
                                  H: 10,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month,
                                    size: Reusable.getDeviceWidth(
                                      context,
                                      W: 25,
                                    ),
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                  SizedBox(
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 10,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _getTranslation(
                                        "${currentTurfInfo['day_date']}",
                                      ), // 🌍 Translated (Date)
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: isDark
                                            ? Reusable.getLightGrey()
                                            : Reusable.getDarkGrey(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: Reusable.getDeviceHeight(
                                  context,
                                  H: 10,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: Reusable.getDeviceWidth(
                                      context,
                                      W: 25,
                                    ),
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                  SizedBox(
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 10,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _getTranslation(
                                        "${currentTurfInfo['time']}",
                                      ), // 🌍 Translated (Time)
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: isDark
                                            ? Reusable.getLightGrey()
                                            : Reusable.getDarkGrey(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: Reusable.getDeviceHeight(
                                  context,
                                  H: 10,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.currency_rupee_rounded,
                                    size: Reusable.getDeviceWidth(
                                      context,
                                      W: 25,
                                    ),
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                  SizedBox(
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 10,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _getTranslation(
                                        "${currentTurfInfo['price']}",
                                      ), // 🌍 Translated (Amount)
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
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
                        ),
                      ),
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 100),
                      ),
                      Container(
                        width: Reusable.getDeviceWidth(context, W: 388),
                        height: Reusable.getDeviceHeight(context, H: 50),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getGreen(),
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceHeight(context, H: 25),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getTranslation(
                              " Go To Scoreboard",
                            ), // 🌍 Translated
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                            ),
                          ),
                        ),
                      ),
                    ],
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
