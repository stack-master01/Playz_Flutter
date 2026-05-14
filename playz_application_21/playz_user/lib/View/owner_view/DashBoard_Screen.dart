import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playz_user/Helper/Owner_Loader.dart';
import 'package:playz_user/View/owner_view/LanguageSelection_Screen.dart';
import 'package:playz_user/View/owner_view/MainTurfWorker_Screen.dart';
import 'package:playz_user/View/owner_view/Owner_Menu.dart';
import 'package:playz_user/View/owner_view/Bookings_Screen.dart';
import 'package:playz_user/View/owner_view/Owner_Review_Screen.dart';
import 'package:playz_user/View/owner_view/Turf_Screen.dart';
import 'package:playz_user/View/owner_view/owner_qr_scanner.dart';
import 'package:playz_user/View/user_view/home(sport)/homepage(sport).dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import 'package:pie_chart/pie_chart.dart';
  Map<String, String> _translationsCache = {};
  String _currentLang = "en"; 

// NOTE: Placeholder classes/functions are assumed to exist in your project:
// CustomThemes, OwnerThemeLangSettings, ownerAppLanguageNotifier, 
// isDarkOwnerThemeNotifier, getTranslatedText, OwnerDrawer, etc.

class OwnerDashBoardScreen extends StatefulWidget {
  const OwnerDashBoardScreen({super.key});

  @override
  State<OwnerDashBoardScreen> createState() => _OwnerDashBoardScreenState();
}

class _OwnerDashBoardScreenState extends State<OwnerDashBoardScreen> {
  int selected = 0;
  int selectedMonth = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _turfName = '';

  List<String> Month = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"];
  
  // turfInfo will be populated dynamically from Firestore; start empty and
  // fall back to _turfName when rendering.
  List<Map<String, dynamic>> turfInfo = [];

  // 1. Translation Cache Map
  
  // Current language to track changes

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Turf Owner",
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Today's Income", "This Week's Income", "This Month's Income", "This Year's Income",
      "Reviews & Ratings",
      "INR 8900", "INR 53900", "INR 238900", "INR 3253900",
      "Income", "Expenditure", // Keys used in PieChart
    };

    // Add dynamic key from the fetched turf name if available
    if (_turfName.isNotEmpty) keys.add(_turfName);
    
    return keys.toList();
  }

  // 3. Load Translations function
  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;
    
    // Simple check: if the language is the same and the number of keys matches the cached count, skip.
    // NOTE: This check is basic; for production, you might want a more robust check 
    // to see if any *new* dynamic keys were added.
    if (_currentLang == lang && _translationsCache.keys.length == keysToLoad.length) {
      return; 
    }
_translationsCache.clear();
    _currentLang = lang;
    Map<String, String> newTranslations = {};
    
    // Fetch all translations
    for (String key in keysToLoad) {
      // NOTE: getTranslatedText must be an available function
      String translated = await getTranslatedText(key, lang); 
      newTranslations[key] = translated;
    }

    // Update state to trigger a re-render with cached values
    if (mounted) {
      setState(() {
        _translationsCache = newTranslations;
      });
    }
  }
StreamSubscription<DocumentSnapshot>? _banSubscription;
Future<void> _setupBanMonitoring() async {
// You can call this method at any time you need to (re)start the monitor
_banSubscription?.cancel(); // Cancel any existing one before starting anew
_banSubscription = await startOwnerBanMonitoring(
context: context,
firestoreInstance: FirebaseFirestore.instance, // Use your actual instance
);
}
  @override
  void initState() {
    super.initState();
    _setupBanMonitoring();

    if (_currentLang != ownerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadOwnerTurfName();
    // Start listening for language changes to reload translations
    ownerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  Future<void> _loadOwnerTurfName() async {
    try {
      final ownerSettings = await OwnerSettings().loadSettings();
      final ownerEmail = ownerSettings.ownerEmail;
      if (ownerEmail != null && ownerEmail.isNotEmpty) {
        // Try to fetch turfs under this owner. Prefer first turf's turfName.
        final turfsSnap = await _firestore
            .collection('Turf_Owner')
            .doc(ownerEmail)
            .collection('Turfs')
            .get();
        if (turfsSnap.docs.isNotEmpty) {
          final first = turfsSnap.docs.first.data();
          final fetchedName = first['turfName'] ?? first['name'] ?? '';
          if (fetchedName is String && fetchedName.isNotEmpty) {
            setState(() {
              _turfName = fetchedName;
            });
          }
        } else {
          // As a fallback, try to read the owner doc's display name
          final ownerDoc = await _firestore.collection('Turf_Owner').doc(ownerEmail).get();
          if (ownerDoc.exists) {
            final data = ownerDoc.data();
            final name = data?['userName'] ?? data?['ownerName'] ?? '';
            if (name is String && name.isNotEmpty) {
              setState(() {
                _turfName = name;
              });
            }
          }
        }
      }
    } catch (e) {
      // ignore errors, keep default turfName
    }
  }

  // Listener function to call _loadTranslations when the language notifier changes
  void _languageChangeListener() {
    _loadTranslations(ownerAppLanguageNotifier.value);
  }

  @override
  void dispose() {
    ownerAppLanguageNotifier.removeListener(_languageChangeListener);
    _banSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await OwnerThemeLangSettings(theme: null).loadSelectedTheme();
    isDarkOwnerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await OwnerThemeLangSettings(theme: null).loadSelectedLocale(); 
    String langToSet = selectedLang ?? "en";
    ownerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet); // Initial load of translations
  }
  
  // 4. Helper to retrieve cached translation
  String _getTranslation(String key) {
    // Returns the cached translation or the original key if not found
    return _translationsCache[key] ?? key; 
  }

  @override
  Widget build(BuildContext context) {
  final Map<String, dynamic> currentInfo = (turfInfo.isNotEmpty && selectedMonth < turfInfo.length)
    ? turfInfo[selectedMonth]
    : {
      'turfName': _turfName.isNotEmpty ? _turfName : 'Your Turf',
      'totalIncome': 0,
      'expenditure': 0,
      };
    
    // Use dummy values for the donut chart only (keep UI stable while real data loads)
    final pieData = <String, double>{
      _getTranslation("Income"): 8900.0,
      _getTranslation("Expenditure"): 5900.0,
    };

    // Check if translations are loaded. If not, show a loading indicator.
    

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkOwnerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme 
            : CustomThemes.customLightTheme; 

        final primaryColor = theme.colorScheme.primary;

        return Theme(
          data: theme,
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white, size: 25),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  // Show Turf name on top and role beneath it for context
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getTranslation(_turfName.isNotEmpty ? _turfName : currentInfo['turfName']),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getTranslation("Turf Owner"),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  centerTitle: true,
                  backgroundColor: primaryColor,
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                          return BookingQRScannerScreen();
                        }));
                      },
                      icon: const Icon(Icons.qr_code_scanner_outlined, color: Colors.white, size: 25),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.message_outlined, color: Colors.white, size: 25),
                    ),
                  ],
                ),
                drawer: OwnerDrawer(),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Use cached text for dynamic turfName (fast)
                      Text(
                        _getTranslation(currentInfo['turfName']), 
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 23,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(Month.length, (index) {
                          final isSelected = selectedMonth == index;
                          return GestureDetector(
                            onTap: () => setState(() => selectedMonth = index),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryColor : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                _getTranslation(Month[index]), // Use cached text (fast)
                                style: TextStyle(
                                  color: isSelected ? Colors.white : primaryColor,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _statCard("Today's Income", "INR 8900", primaryColor),
                            _statCard("This Week's Income", "INR 53900", primaryColor),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _statCard("This Month's Income", "INR 238900", primaryColor, highlight: true),
                            _statCard("This Year's Income", "INR 3253900", primaryColor),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
                          ],
                        ),
                        height: 280,
                        child: PieChart(
                          dataMap: pieData,
                          animationDuration: const Duration(milliseconds: 800),
                          chartType: ChartType.ring,
                          colorList: const [Colors.green, Colors.red],
                          chartRadius: 120,
                          legendOptions: const LegendOptions(
                            showLegends: true,
                            legendShape: BoxShape.rectangle,
                            legendPosition: LegendPosition.bottom,
                            legendTextStyle: TextStyle(fontSize: 15),
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValuesOutside: true,
                            showChartValuesInPercentage: true,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(13, 71, 161, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            onPressed: () async {
                              // load owner email from shared prefs
                              final ownerSettings = await OwnerSettings().loadSettings();
                              final ownerEmail = ownerSettings.ownerEmail;
                              List<Map<String, dynamic>> reviewsList = [];
                              double avgStars = 0.0;
                              int totalReviews = 0;

                              if (ownerEmail != null && ownerEmail.isNotEmpty) {
                                try {
                                  final turfsSnap = await FirebaseFirestore.instance
                                      .collection('Turf_Owner')
                                      .doc(ownerEmail)
                                      .collection('Turfs')
                                      .get();
                                  if (turfsSnap.docs.isNotEmpty) {
                                    // pick first turf (or aggregate as needed)
                                    final turfDoc = turfsSnap.docs.first;
                                    final data = turfDoc.data();
                                    final r = data['reviews'];
                                    if (r is List) {
                                      for (var item in r) {
                                        if (item is Map) reviewsList.add(Map<String, dynamic>.from(item));
                                      }
                                    }
                                    final av = data['average_stars'];
                                    if (av is num) avgStars = av.toDouble();
                                    else if (av is String) avgStars = double.tryParse(av) ?? 0.0;
                                    final tr = data['total_reviews'];
                                    if (tr is int) totalReviews = tr;
                                    else if (tr is num) totalReviews = tr.toInt();
                                    else if (tr is String) totalReviews = int.tryParse(tr) ?? 0;
                                  }
                                } catch (e) {
                                  // ignore errors and navigate with empty defaults
                                }
                              }
                              log("reviews: ${reviewsList}");
                              log("stars: ${avgStars}");
                              log("reviews: ${totalReviews}");

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return owner_Review_Screen(
                                      reviews: reviewsList,
                                      averageStars: avgStars,
                                      totalReviews: totalReviews,
                                    );
                                  },
                                ),
                              );
                            },
                            child: Text(
                            _getTranslation("Reviews & Ratings"), // Use cached text (fast)
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        ),
                    ],
                  ),
                ),
                bottomNavigationBar: StylishBottomBar(
                  backgroundColor: primaryColor,
                  items: [
                    BottomBarItem(
                      icon: const Icon(Icons.home, color: Colors.white),
                      title: const Text('Home', style: TextStyle(color: Colors.white)),
                      backgroundColor: primaryColor,
                      selectedIcon: const Icon(Icons.read_more, color: Colors.white),
                    ),
                    BottomBarItem(
                      icon: const Icon(Icons.calendar_month_sharp, color: Colors.white),
                      title: const Text('Bookings', style: TextStyle(color: Colors.white)),
                      backgroundColor: primaryColor,
                    ),
                    BottomBarItem(
                      icon: const Icon(Icons.sports_basketball, color: Colors.white),
                      title: const Text('Turf', style: TextStyle(color: Colors.white)),
                      backgroundColor: primaryColor,
                    ),
                    BottomBarItem(
                      icon: const Icon(Icons.people_rounded, color: Colors.white),
                      title: const Text('Workers', style: TextStyle(color: Colors.white)),
                      backgroundColor: primaryColor,
                    ),
                  ],
                  option: DotBarOptions(
                    dotStyle: DotStyle.circle,
                    gradient: const LinearGradient(colors: [Colors.white, Colors.white]),
                  ),
                  hasNotch: true,
                  currentIndex: selected,
                  onTap: (index) {
                    setState(() => selected = index);
                    switch (index) {
                      case 0: break;
                      case 1: Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ownerBookingScreen())); break;
                      case 2: Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ownerAfterRegistrationTurfScreen())); break;
                      case 3: Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ownerTurfWorkerScreen())); break;
                    }
                  },
                ),
              ),if (_translationsCache.isEmpty)
                const Positioned.fill(child: OwnerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String title, String value, Color primaryColor, {bool highlight = false}) {
    return Expanded(
      child: Card(
        color: highlight ? primaryColor : Colors.white,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Column(
            children: [
              Text(
                _getTranslation(title), // Use cached text (fast)
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: highlight ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _getTranslation(value), // Use cached text (fast)
                style: TextStyle(
                  color: highlight ? Colors.white : primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}