import 'dart:async';
import 'dart:developer'; // For log()

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/book(sports)/selectsportandtime.dart';
// Note: These imports are left as is, assuming they exist in your project structure
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/home(sport)/homepage(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

Map<String, String> _translationsCache = {};

String _currentLang = "en";

// =========================================================================

class BookTurfInfo extends StatefulWidget {
  Map<String, dynamic> turfInfoMap = {};
  BookTurfInfo({super.key, required this.turfInfoMap});

  @override
  State<BookTurfInfo> createState() => _BookTurfInfoState();
}

class _BookTurfInfoState extends State<BookTurfInfo> {

double _latitude = 0;
double _longitude = 0;
    void _openDirections() async {
    if (_latitude != null && _longitude != null) {
      final url =
          "https://www.google.com/maps/dir/?api=1&destination=${_latitude},${_longitude}&travelmode=driving";
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  Map<String, dynamic> currentTurfInfoMap = {};

  final PageController pageController = PageController();
  final TextEditingController _reportController = TextEditingController();

  // The lists now use static English keys. These lists will be transformed
  // into lists of translated strings within the build method.
  List<Map<String, dynamic>> sportsAvailableKeys = [
    {"icon": Icons.sports_cricket_outlined, "sport": "CRICKET"},
    {"icon": Icons.sports_soccer_outlined, "sport": "FOOTBALL"},
    {"icon": Icons.sports_tennis_outlined, "sport": "TENNIS"},
  ];

  List<Map<String, dynamic>> amenitiesAvailableKeys = [
    {"icon": Icons.local_parking_outlined, "facility": "PARKING"},
    {"icon": Icons.water_drop_outlined, "facility": "DRINKING WATER"},
    {"icon": Icons.wc_outlined, "facility": "RESTROOM"},
  ];

  List<String> bookTurfList = [
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSihcmNMpJiXeA09ZUxex8OsTxdr9oXmqxH9A&s",
    "https://images.unsplash.com/photo-1503515091255-ab8063a1796d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGZvb3RiYWxsJTIwdHVyZnxlbnwwfHwwfHx8MA%3D%3D",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZJivXheMQk7jaKLzSAEZJvOl8mx_Dsx1_bhNM0Q4Yrx4_buRHZWPaaVEiP9JlhJjlUvY&usqp=CAU",
  ];

  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN)
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  String? selectedLocation; // From the provided logic

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Arena 51",
      "6:00 AM - 11:30 PM",
      "4.5 (256)",
      "RATE VENUE",
      "Total Games - 425",
      "1 UPCOMING",
      "Sports Available",
      "Amenities",
      "Create Game",
      "About Venue",
      "Only turf shoes (no studs).\nPlay within booked time slot.\nNo smoking, alcohol, or outside food.\nRespect players & avoid rough play.\nKeep the turf clean.",
      "BOOK",
      // Text from sportsAvailableKeys and amenitiesAvailableKeys
      ...sportsAvailableKeys.map((e) => e['sport'] as String),
      ...amenitiesAvailableKeys.map((e) => e['facility'] as String),
      // Venue Address (Should ideally be dynamic, but treating as a static key for translation)
      "Sunshine Sports Arena, Plot No. 27B,Opposite Seasons Mall, Near Magarpatta Flyover,Behind Phoenix Marketcity Service Road,Hadapsar Kharadi Bypass Extension,Survey No. 112/3, Lane No. 5, Magarpatta City, Pune 411028, Maharashtra, India",
      // END: Add default english text here
    };

    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }
    _extractStrings(currentTurfInfoMap, keys);
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
StreamSubscription<DocumentSnapshot>? _banSubscription;
  @override
  void initState() {
    super.initState();
    _setupBanMonitoring();
    currentTurfInfoMap = widget.turfInfoMap;
    _latitude = currentTurfInfoMap['location']['latitude'];
    _longitude = currentTurfInfoMap['location']['longitude'];
    if (_currentLang != appLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadSelectedLocation();
    appLanguageNotifier.addListener(_languageChangeListener);
  }
Future<void> _setupBanMonitoring() async {
    // You can call this method at any time you need to (re)start the monitor
    _banSubscription?.cancel(); // Cancel any existing one before starting anew
    _banSubscription = await startBanMonitoring(
      context: context, 
      firestoreInstance: FirebaseFirestore.instance, // Use your actual instance
    );
  }
  @override
  void dispose() {
    pageController.dispose();
    _reportController.dispose();
    appLanguageNotifier.removeListener(_languageChangeListener);
    _banSubscription?.cancel();
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

  Future<void> _loadSelectedLocation() async {
    String? selected = await Appsharedpreferences().loadSelectedCity();
    selectedLocationNotifier.value = selected;
    log("city in home page: $selected");
    setState(() {
      selectedLocation = selected;
    });
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

  // derive display values for average rating and total reviews
  final dynamic _rawAvg = currentTurfInfoMap['average_stars'];
  double _displayAvg = 0.0;
  if (_rawAvg is num) _displayAvg = _rawAvg.toDouble();
  else if (_rawAvg is String) _displayAvg = double.tryParse(_rawAvg) ?? 0.0;

  final dynamic _rawTotal = currentTurfInfoMap['total_reviews'];
  int _displayTotal = 0;
  if (_rawTotal is int) _displayTotal = _rawTotal;
  else if (_rawTotal is num) _displayTotal = _rawTotal.toInt();
  else if (_rawTotal is String) _displayTotal = int.tryParse(_rawTotal) ?? 0;

  return Scaffold(
          body: Stack(
            children: [
              Container(
                color: isDark
                    ? Reusable.getDarkModeBlack()
                    : Reusable.getWhite(),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: Column(
                    //scroll this column
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Reusable.getDarkModeBlack()
                              : Reusable.getWhite(),
                        ),
                        height: Reusable.getDeviceHeight(
                          context,
                          H: 250,
                        ), // ✅ Give height to PageView
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            PageView.builder(
                              controller: pageController,
                              itemCount:
                                  currentTurfInfoMap['turfImages'].length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  child: Image.network(
                                    currentTurfInfoMap['turfImages'][index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                );
                              },
                            ),
                            Positioned(
                              bottom: 10,
                               child: SmoothPageIndicator(
                                controller: pageController,
                                count: currentTurfInfoMap['turfImages'].length,
                                effect: WormEffect(
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  activeDotColor: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                  dotColor: isDark
                                      ? Reusable.getDarkModeBlack()
                                      : Reusable.getWhite(),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: Reusable.getDeviceWidth(context, W: 20),
                                    top: Reusable.getDeviceHeight(context, H: 40),
                                  ),
                                  child: Align(
                                    alignment: Alignment.topLeft,
                                    child: GestureDetector(
                                      onTap: () {Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        width: Reusable.getDeviceWidth(
                                          context,
                                          W: 40,
                                        ),
                                        height: Reusable.getDeviceHeight(
                                          context,
                                          H: 40,
                                        ),
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              blurRadius: 3,
                                              color: isDark
                                                  ? const Color.fromRGBO(
                                                      164,
                                                      255,
                                                      0,
                                                      0.25,
                                                    )
                                                  : const Color.fromRGBO(
                                                      0,
                                                      0,
                                                      0,
                                                      0.25,
                                                    ),
                                              offset: const Offset(0, 0),
                                            ),
                                          ],
                                          color: isDark
                                              ? Reusable.getDarkModeBlack()
                                              : Reusable.getWhite(),
                                          borderRadius: BorderRadius.circular(
                                            Reusable.getDeviceWidth(context, W: 20),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_back_ios_rounded,
                                          size: Reusable.getDeviceWidth(
                                            context,
                                            W: 25,
                                          ),
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getDarkGrey(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Padding(
                              padding: EdgeInsets.only(
                                right: Reusable.getDeviceWidth(context, W: 20),
                                top: Reusable.getDeviceHeight(context, H: 40),
                              ),
                              child: Align(
                                alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        showReportSheet(isDark);
                                      },
                                  child: Container(
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 40,
                                    ),
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 3,
                                          color: isDark
                                              ? const Color.fromRGBO(
                                                  164,
                                                  255,
                                                  0,
                                                  0.25,
                                                )
                                              : const Color.fromRGBO(
                                                  0,
                                                  0,
                                                  0,
                                                  0.25,
                                                ),
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(context, W: 20),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.report_gmailerrorred,
                                      size: Reusable.getDeviceWidth(
                                        context,
                                        W: 30,
                                      ),
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                              ],
                            ),
                            Positioned(
                              right: Reusable.getDeviceWidth(context, W: 20),
                              bottom: -Reusable.getDeviceHeight(context, H: 20),
                              child: Row(
                                children: [
                                  Container(
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 40,
                                    ),
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(context, W: 20),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 3,
                                          color: isDark
                                              ? const Color.fromRGBO(
                                                  164,
                                                  255,
                                                  0,
                                                  0.25,
                                                )
                                              : const Color.fromRGBO(
                                                  0,
                                                  0,
                                                  0,
                                                  0.25,
                                                ),
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.favorite_border_rounded,
                                      size: Reusable.getDeviceWidth(
                                        context,
                                        W: 25,
                                      ),
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 20,
                                    ),
                                  ),
                                  Container(
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 40,
                                    ),
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 3,
                                          color: isDark
                                              ? const Color.fromRGBO(
                                                  164,
                                                  255,
                                                  0,
                                                  0.25,
                                                )
                                              : const Color.fromRGBO(
                                                  0,
                                                  0,
                                                  0,
                                                  0.25,
                                                ),
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(context, W: 20),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.share_outlined,
                                      size: Reusable.getDeviceWidth(
                                        context,
                                        W: 25,
                                      ),
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 35),
                      ),
                      Container(
                        color: isDark
                            ? Reusable.getDarkModeBlack()
                            : Reusable.getWhite(),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: Reusable.getDeviceWidth(context, W: 20),
                            right: Reusable.getDeviceWidth(context, W: 20),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTranslation(
                                    currentTurfInfoMap['turfName'],
                                  ), // ✨ TRANSLATED
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getBlack(),
                                  ),
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 15,
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
                                          ? Reusable.getLightGreen()
                                          : Reusable.getBlack(),
                                    ),
                                    SizedBox(
                                      width: Reusable.getDeviceWidth(
                                        context,
                                        W: 10,
                                      ),
                                    ),
                                    Text(
                                      _getTranslation(
                                        "6:00 AM - 11:30 PM",
                                      ), // ✨ TRANSLATED
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: isDark
                                            ? Reusable.getLightGrey()
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
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: Reusable.getDeviceWidth(
                                        context,
                                        W: 30,
                                      ),
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getBlack(),
                                    ),
                                    SizedBox(
                                      width: Reusable.getDeviceWidth(
                                        context,
                                        W: 10,
                                      ),
                                    ),
                                    SizedBox(
                                      width: Reusable.getDeviceWidth(
                                        context,
                                        W: 340,
                                      ),
                                      child: Text(
                                        _getTranslation(
                                          currentTurfInfoMap['location']['address'],
                                        ), // ✨ TRANSLATED
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: isDark
                                              ? Reusable.getLightGrey()
                                              : Reusable.getBlack(),
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(context, H: 15),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () {
                                      _openDirections();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Reusable.getDeviceWidth(context, W: 12),
                                        vertical: Reusable.getDeviceHeight(context, H: 8),
                                      ),
                                      decoration: BoxDecoration(
                                        color: isDark ? Reusable.getDarkModeGrey() : Reusable.getLightGrey(),
                                        borderRadius: BorderRadius.circular(
                                          Reusable.getDeviceWidth(context, W: 8),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.map,
                                            size: Reusable.getDeviceWidth(context, W: 20),
                                            color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                                          ),
                                          SizedBox(width: Reusable.getDeviceWidth(context, W: 8)),
                                          Text(
                                            _getTranslation("Open in Maps"),
                                            style: TextStyle(
                                              color: isDark ? Reusable.getLightGreen() : Reusable.getBlack(),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 30,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.star,
                                              size: 20,
                                              color: Color.fromRGBO(
                                                230,
                                                184,
                                                0,
                                                1,
                                              ),
                                            ),
                                            SizedBox(
                                              width: Reusable.getDeviceWidth(
                                                context,
                                                W: 5,
                                              ),
                                            ),
                                            Text(
                                              '${_displayAvg > 0 ? _displayAvg.toStringAsFixed(1) : _getTranslation("N/A")} (${_displayTotal.toString()})',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
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
                                        GestureDetector(
                                          onTap: () {
                                            showReviewAndRatingSheet(isDark);
                                          },
                                          child: Container(
                                            width: Reusable.getDeviceWidth(
                                              context,
                                              W: 180,
                                            ),
                                            height: Reusable.getDeviceHeight(
                                              context,
                                              H: 40,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Reusable.getDarkModeBlack()
                                                  : Reusable.getWhite(),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    Reusable.getDeviceWidth(
                                                      context,
                                                      W: 10,
                                                    ),
                                                  ),
                                              border: Border.all(
                                                color: isDark
                                                    ? Reusable.getLightGreen()
                                                    : Reusable.getBlack(),
                                                width: 1,
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                _getTranslation(
                                                  "RATE VENUE",
                                                ), // ✨ TRANSLATED
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: isDark
                                                      ? Reusable.getLightGreen()
                                                      : Reusable.getBlack(),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: Reusable.getDeviceWidth(
                                        context,
                                        W: 20,
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              _getTranslation(
                                                "Total Games - 425",
                                              ), // ✨ TRANSLATED
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
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
                                        Container(
                                          width: Reusable.getDeviceWidth(
                                            context,
                                            W: 180,
                                          ),
                                          height: Reusable.getDeviceHeight(
                                            context,
                                            H: 40,
                                          ),
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
                                                  : Reusable.getBlack(),
                                              width: 1,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getTranslation(
                                                "1 UPCOMING",
                                              ), // ✨ TRANSLATED
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: isDark
                                                    ? Reusable.getLightGreen()
                                                    : Reusable.getBlack(),
                                              ),
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
                                    H: 30,
                                  ),
                                ),
                                Text(
                                  _getTranslation(
                                    "Sports Available",
                                  ), // ✨ TRANSLATED
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getBlack(),
                                  ),
                                ),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount:
                                      (currentTurfInfoMap['sports'].length / 2)
                                          .ceil(),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: Reusable.getDeviceHeight(
                                            context,
                                            H: 10,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: Reusable.getDeviceHeight(
                                                context,
                                                H: 40,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? Reusable.getDarkModeBlack()
                                                    : Reusable.getWhite(),
                                                borderRadius:
                                                    BorderRadius.circular(
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
                                                padding: EdgeInsets.only(
                                                  left: Reusable.getDeviceWidth(
                                                    context,
                                                    W: 20,
                                                  ),
                                                  right:
                                                      Reusable.getDeviceWidth(
                                                        context,
                                                        W: 20,
                                                      ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Icon(
                                                    //   sportsAvailableKeys[(index *
                                                    //       2)]['icon'],
                                                    //   size:
                                                    //       Reusable.getDeviceWidth(
                                                    //         context,
                                                    //         W: 25,
                                                    //       ),
                                                    //   color: isDark
                                                    //       ? Reusable.getLightGreen()
                                                    //       : Reusable.getGreen(),
                                                    // ),
                                                    // SizedBox(
                                                    //   width:
                                                    //       Reusable.getDeviceWidth(
                                                    //         context,
                                                    //         W: 10,
                                                    //       ),
                                                    // ),
                                                    Text(
                                                      _getTranslation(
                                                        currentTurfInfoMap['sports'][(index *
                                                            2)],
                                                      ), // ✨ TRANSLATED
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: isDark
                                                            ? Reusable.getLightGreen()
                                                            : Reusable.getGreen(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: Reusable.getDeviceWidth(
                                                context,
                                                W: 10,
                                              ),
                                            ),
                                            (((index * 2) + 1) <
                                                    currentTurfInfoMap['sports']
                                                        .length)
                                                ? Container(
                                                    height:
                                                        Reusable.getDeviceHeight(
                                                          context,
                                                          H: 40,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? Reusable.getDarkModeBlack()
                                                          : Reusable.getWhite(),
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          // Icon(
                                                          //   sportsAvailableKeys[(index *
                                                          //           2) +
                                                          //       1]['icon'],
                                                          //   size:
                                                          //       Reusable.getDeviceWidth(
                                                          //         context,
                                                          //         W: 25,
                                                          //       ),
                                                          //   color: isDark
                                                          //       ? Reusable.getLightGreen()
                                                          //       : Reusable.getGreen(),
                                                          // ),
                                                          // SizedBox(
                                                          //   width:
                                                          //       Reusable.getDeviceWidth(
                                                          //         context,
                                                          //         W: 10,
                                                          //       ),
                                                          // ),
                                                          Text(
                                                            _getTranslation(
                                                              currentTurfInfoMap['sports'][(index *
                                                                      2) +
                                                                  1],
                                                            ), // ✨ TRANSLATED
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: isDark
                                                                  ? Reusable.getLightGreen()
                                                                  : Reusable.getGreen(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                        SizedBox(
                                          height: Reusable.getDeviceHeight(
                                            context,
                                            H: 0,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 30,
                                  ),
                                ),
                                Text(
                                  _getTranslation("Amenities"), // ✨ TRANSLATED
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getBlack(),
                                  ),
                                ),
                                ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount:
                                      (currentTurfInfoMap['amenities'].length /
                                              2)
                                          .ceil(),
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        SizedBox(
                                          height: Reusable.getDeviceHeight(
                                            context,
                                            H: 10,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: Reusable.getDeviceHeight(
                                                context,
                                                H: 40,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isDark
                                                    ? Reusable.getDarkModeBlack()
                                                    : Reusable.getWhite(),
                                                borderRadius:
                                                    BorderRadius.circular(
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
                                                padding: EdgeInsets.only(
                                                  left: Reusable.getDeviceWidth(
                                                    context,
                                                    W: 20,
                                                  ),
                                                  right:
                                                      Reusable.getDeviceWidth(
                                                        context,
                                                        W: 20,
                                                      ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Icon(
                                                    //   amenitiesAvailableKeys[(index *
                                                    //       2)]['icon'],
                                                    //   size:
                                                    //       Reusable.getDeviceWidth(
                                                    //         context,
                                                    //         W: 25,
                                                    //       ),
                                                    //   color: isDark
                                                    //       ? Reusable.getLightGreen()
                                                    //       : Reusable.getGreen(),
                                                    // ),
                                                    SizedBox(
                                                      width:
                                                          Reusable.getDeviceWidth(
                                                            context,
                                                            W: 10,
                                                          ),
                                                    ),
                                                    Text(
                                                      _getTranslation(
                                                        currentTurfInfoMap['amenities'][(index *
                                                            2)],
                                                      ), // ✨ TRANSLATED
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: isDark
                                                            ? Reusable.getLightGreen()
                                                            : Reusable.getGreen(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: Reusable.getDeviceWidth(
                                                context,
                                                W: 10,
                                              ),
                                            ),
                                            (((index * 2) + 1) <
                                                    currentTurfInfoMap['amenities']
                                                        .length)
                                                ? Container(
                                                    height:
                                                        Reusable.getDeviceHeight(
                                                          context,
                                                          H: 40,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isDark
                                                          ? Reusable.getDarkModeBlack()
                                                          : Reusable.getWhite(),
                                                      borderRadius:
                                                          BorderRadius.circular(
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
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          // Icon(
                                                          //   amenitiesAvailableKeys[(index *
                                                          //           2) +
                                                          //       1]['icon'],
                                                          //   size:
                                                          //       Reusable.getDeviceWidth(
                                                          //         context,
                                                          //         W: 25,
                                                          //       ),
                                                          //   color: isDark
                                                          //       ? Reusable.getLightGreen()
                                                          //       : Reusable.getGreen(),
                                                          // ),
                                                          SizedBox(
                                                            width:
                                                                Reusable.getDeviceWidth(
                                                                  context,
                                                                  W: 10,
                                                                ),
                                                          ),
                                                          Text(
                                                            _getTranslation(
                                                              currentTurfInfoMap['amenities'][(index *
                                                                      2) +
                                                                  1],
                                                            ), // ✨ TRANSLATED
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: isDark
                                                                  ? Reusable.getLightGreen()
                                                                  : Reusable.getGreen(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                        SizedBox(
                                          height: Reusable.getDeviceHeight(
                                            context,
                                            H: 0,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 30,
                                  ),
                                ),
                                Container(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 60,
                                  ),
                                  width: Reusable.getDeviceWidth(
                                    context,
                                    W: 388,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Reusable.getDarkModeGrey()
                                        : Reusable.getLightGrey(),
                                    borderRadius: BorderRadius.circular(
                                      Reusable.getDeviceWidth(context, W: 30),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
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
                                          W: 5,
                                        ),
                                      ),
                                      Text(
                                        _getTranslation(
                                          "Create Game",
                                        ), // ✨ TRANSLATED
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getDarkGrey(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 30,
                                  ),
                                ),
                                Text(
                                  _getTranslation(
                                    "About Venue",
                                  ), // ✨ TRANSLATED
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getBlack(),
                                  ),
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 10,
                                  ),
                                ),
                                Text(
                                  _getTranslation(
                                    '''Only turf shoes (no studs).\nPlay within booked time slot.\nNo smoking, alcohol, or outside food.\nRespect players & avoid rough play.\nKeep the turf clean.''',
                                  ), // ✨ TRANSLATED
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 10,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final FirebaseFirestore _firestore =
                                        FirebaseFirestore.instance;

                                    // turfTimeSlots was unused; removed.
                                    List<Map<String,dynamic>> bookedSlots = [];

                                    try {
                                      // Step 1: Get all user documents under "Turf_User"
                                      final userSnapshot = await _firestore
                                          .collection('Turf_Owner')
                                          .doc(currentTurfInfoMap['userEmail'])
                                          .collection('Turfs')
                                          .doc(currentTurfInfoMap['turfName'])
                                          .collection('TimeSlots')
                                          .get();

                                      final slotMap = userSnapshot.docs;
                                      currentTurfInfoMap['time_slots'] =
                                          slotMap[0].data();

                                      final bookingSnapshot = await _firestore
                                          .collection('Turf_Owner')
                                          .doc(currentTurfInfoMap['userEmail'])
                                          .collection('Turfs')
                                          .doc(currentTurfInfoMap['turfName'])
                                          .collection('Booking')
                                          .get();

                                      final bookMap = bookingSnapshot.docs;
                                      for (var element in bookMap) {
                                       bookedSlots.add(element.data()); 
                                      }
                                      currentTurfInfoMap['booked_slots'] = bookedSlots;
                                      log(
                                        "✅  Turfs time slots Fetched: $currentTurfInfoMap",
                                      );
                                    } catch (e) {
                                      log("❌ Error fetching turfs: $e");
                                    }

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return SelectSportAndTime(
                                            turfInfoMap: currentTurfInfoMap,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 60,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 388,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getGreen(),
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(context, W: 30),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _getTranslation(
                                            "BOOK",
                                          ), // ✨ TRANSLATED
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
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 60,
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
              if (_translationsCache.isEmpty)
                const Positioned.fill(child: UserLoaderScreen()),
            ],
          ),
        );
      },
    );
  }

  int _currentRating = 0; // State variable for the selected rating
  final TextEditingController _reviewController =
      TextEditingController(); // Controller for the text field
  void showReviewAndRatingSheet(bool isDark) {
    // Changed function name
    showModalBottomSheet(
      backgroundColor: isDark
          ? Reusable.getDarkModeBlack()
          : Reusable.getWhite(),
      context: context,
      isScrollControlled:
          true, // Allows the sheet to take full height for keyboard
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Reusable.getDeviceWidth(context, W: 30)),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                // Adjust padding to accommodate the keyboard
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              ),
              child: SingleChildScrollView(
                // Use SingleChildScrollView to prevent overflow when keyboard appears
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Essential for bottom sheet height
                  children: [
                    Text(
                      _getTranslation("Rate and Review"), // Changed title
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getBlack(),
                      ),
                    ),
                    SizedBox(height: Reusable.getDeviceHeight(context, H: 20)),

                    // Star Rating Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () {
                            setStateBottom(() {
                              _currentRating = index + 1; // 1-indexed rating
                            });
                          },
                          child: Icon(
                            Icons.star,
                            size: Reusable.getDeviceWidth(
                              context,
                              W: 40,
                            ), // Large stars
                            color: index < _currentRating
                                ? Colors
                                      .amber // Yellow for selected stars
                                : Reusable.getLightGrey(), // Light grey for unselected
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: Reusable.getDeviceHeight(context, H: 20)),

                    // Review Text Field
                    TextField(
                      controller: _reviewController,
                      maxLines: 4, // 4 lines wide
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getWhite()
                            : Reusable.getBlack(),
                      ),
                      cursorColor: isDark
                          ? Reusable.getLightGreen()
                          : Reusable.getGreen(),
                      decoration: InputDecoration(
                        hintText: _getTranslation("Write your review here..."),
                        hintStyle: TextStyle(
                          color: isDark
                              ? Reusable.getLightGrey()
                              : Reusable.getDarkGrey(),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? Reusable.getDarkModeGrey()
                            : Reusable.getWhite(), // Similar to your container background for dark mode
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 10),
                          ),
                          borderSide: BorderSide(
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getGreen(),
                            width: 1.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 10),
                          ),
                          borderSide: BorderSide(
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getGreen(),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 10),
                          ),
                          borderSide: BorderSide(
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getGreen(),
                            width: 2.0, // Slightly thicker border when focused
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Reusable.getDeviceHeight(context, H: 20)),

                    // Submit Button
                    GestureDetector(
                      onTap: () async {
                        final msg = _reviewController.text.trim();
                        if (msg.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_getTranslation("Please write a review"))),
                          );
                          return;
                        }

                        // Build review map
                        Map<String, dynamic> review = {
                          'message': msg,
                          'stars': _currentRating,
                        };

                        try {
                          // load user info for profile and name (if available)
                          final userSettings = await UserSettings().loadSettings();
                          final senderProfile = userSettings.imageURL;
                          final senderName = userSettings.userName;
                          if (senderProfile != null && senderProfile.isNotEmpty) {
                            review['sender_profile'] = senderProfile;
                          }
                          if (senderName != null && senderName.isNotEmpty) {
                            review['senders_name'] = senderName;
                          }

                          final FirebaseFirestore _firestore = FirebaseFirestore.instance;
                          final docRef = _firestore
                              .collection('Turf_Owner')
                              .doc(currentTurfInfoMap['userEmail'])
                              .collection('Turfs')
                              .doc(currentTurfInfoMap['turfName']);

                          // Compute new average_stars by reading existing reviews (if any)
                          double averageStars = _currentRating.toDouble();
                          try {
                            final snapshot = await docRef.get();
                            if (snapshot.exists) {
                              final data = snapshot.data();
                              if (data != null) {
                                final existingReviews = data['reviews'];
                                if (existingReviews is List && existingReviews.isNotEmpty) {
                                  double sum = 0.0;
                                  int count = 0;
                                  for (var r in existingReviews) {
                                    if (r is Map && r['stars'] != null) {
                                      final s = r['stars'];
                                      if (s is int) sum += s.toDouble();
                                      else if (s is double) sum += s;
                                      count++;
                                    }
                                  }
                                  // include the new review's stars
                                  sum += _currentRating.toDouble();
                                  count += 1;
                                  if (count > 0) averageStars = sum / count;
                                } else if (data['average_stars'] != null && data['total_reviews'] != null) {
                                  // Fallback: use stored average and count if reviews list absent
                                  final prevAvg = data['average_stars'];
                                  final prevCount = data['total_reviews'];
                                  final prevAvgD = (prevAvg is num) ? prevAvg.toDouble() : 0.0;
                                  final prevCountI = (prevCount is int) ? prevCount : (prevCount is num ? prevCount.toInt() : 0);
                                  final sum = prevAvgD * prevCountI + _currentRating.toDouble();
                                  final count = prevCountI + 1;
                                  if (count > 0) averageStars = sum / count;
                                } else {
                                  // No prior reviews: average is the current rating
                                  averageStars = _currentRating.toDouble();
                                }
                              }
                            }
                          } catch (e) {
                            // If reading fails for any reason, fall back to the current rating
                            averageStars = _currentRating.toDouble();
                          }

                          await docRef.set(
                            {
                              'reviews': FieldValue.arrayUnion([review]),
                              'total_reviews': FieldValue.increment(1),
                              'average_stars': averageStars,
                            },
                            SetOptions(merge: true),
                          );

                          Navigator.of(context).pop(); // Close sheet
                          setState(() {
                            _currentRating = 0;
                            _reviewController.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_getTranslation("Review submitted"))),
                          );
                        } catch (e) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_getTranslation("Failed to submit review"))),
                          );
                        }
                      },
                      child: Container(
                        height: Reusable.getDeviceHeight(context, H: 60),
                        width: Reusable.getDeviceWidth(context, W: 388),
                        decoration: BoxDecoration(
                          color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                          borderRadius: BorderRadius.circular(Reusable.getDeviceWidth(context, W: 30)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getTranslation("SUBMIT REVIEW"),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showReportSheet(bool isDark) {
    showModalBottomSheet(
      backgroundColor: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Reusable.getDeviceWidth(context, W: 30)),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateBottom) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTranslation("Report Issue"),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Reusable.getLightGreen() : Reusable.getBlack(),
                      ),
                    ),
                    SizedBox(height: Reusable.getDeviceHeight(context, H: 12)),
                    TextField(
                      controller: _reportController,
                      maxLines: 6,
                      style: TextStyle(
                        color: isDark ? Reusable.getWhite() : Reusable.getBlack(),
                      ),
                      cursorColor: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                      decoration: InputDecoration(
                        hintText: _getTranslation("Describe the issue in detail..."),
                        hintStyle: TextStyle(
                          color: isDark ? Reusable.getLightGrey() : Reusable.getDarkGrey(),
                        ),
                        filled: true,
                        fillColor: isDark ? Reusable.getDarkModeGrey() : Reusable.getWhite(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Reusable.getDeviceWidth(context, W: 10)),
                          borderSide: BorderSide(
                            color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Reusable.getDeviceHeight(context, H: 16)),
                    GestureDetector(
                      onTap: () async {
                        final msg = _reportController.text.trim();
                        if (msg.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_getTranslation("Please enter a description"))),
                          );
                          return;
                        }

                        // Build report object with message, timestamp, username and email
                        Map<String, dynamic> report = {
                          'message': msg,
                          'reported_at': Timestamp.now(),
                        };

                        try {
                          // Load current user's info (if available)
                          final userSettings = await UserSettings().loadSettings();
                          final reporterEmail = userSettings.email;
                          final reporterName = userSettings.userName;
                          if (reporterEmail != null && reporterEmail.isNotEmpty) {
                            report['reporter_email'] = reporterEmail;
                          }
                          if (reporterName != null && reporterName.isNotEmpty) {
                            report['reporter_name'] = reporterName;
                          }

                          final FirebaseFirestore _firestore = FirebaseFirestore.instance;

                          final docRef = _firestore
                              .collection('Turf_Owner')
                              .doc(currentTurfInfoMap['userEmail'])
                              .collection('Turfs')
                              .doc(currentTurfInfoMap['turfName']);

                          await docRef.set(
                            {
                              'violation_history': FieldValue.arrayUnion([report])
                            },
                            SetOptions(merge: true),
                          );

                          Navigator.of(context).pop(); // close sheet
                          _reportController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_getTranslation("Report sent successfully"))),
                          );
                        } catch (e) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_getTranslation("Failed to send report"))),
                          );
                        }
                      },
                      child: Container(
                        height: Reusable.getDeviceHeight(context, H: 60),
                        width: Reusable.getDeviceWidth(context, W: 388),
                        decoration: BoxDecoration(
                          color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                          borderRadius: BorderRadius.circular(Reusable.getDeviceWidth(context, W: 30)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getTranslation("SEND REPORT"),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Reusable.getDeviceHeight(context, H: 10)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
