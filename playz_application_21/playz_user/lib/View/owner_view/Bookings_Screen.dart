import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/User_Controller/User_Upload_Booking_Controller.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart'; // Assumed import
import 'package:playz_user/Helper/Owner_Loader.dart';
import 'package:playz_user/View/owner_view/DashBoard_Screen.dart';
import 'package:playz_user/View/owner_view/LanguageSelection_Screen.dart';
import 'package:playz_user/View/owner_view/MainTurfWorker_Screen.dart';
import 'package:playz_user/View/owner_view/Owner_Menu.dart';
import 'package:playz_user/View/owner_view/Turf_Screen.dart';
import 'package:playz_user/View/owner_view/owner_qr_scanner.dart';
import 'package:playz_user/View/user_view/home(sport)/homepage(sport).dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en"; 

// NOTE: Placeholder classes/functions are assumed to exist in your project:
// CustomThemes, OwnerThemeLangSettings, ownerAppLanguageNotifier,
// isDarkOwnerThemeNotifier, getTranslatedText, OwnerDrawer, etc.

class ownerBookingScreen extends StatefulWidget {
  const ownerBookingScreen({super.key});

  @override
  State<ownerBookingScreen> createState() => _ownerBookingScreenState();
}
class _ownerBookingScreenState extends State<ownerBookingScreen> {
  int selected = 1;

  List<Map> todayBooking = [
    {
      "userName": "Shriraj Deshpande",
      "timings": "10:00 AM - 11:00 AM",
      "Date": "Mon | 01-08-2025",
    },
    {
      "userName": "Aryan Mane",
      "timings": "9:00 AM - 10:00 AM",
      "Date": "Mon | 01-08-2025",
    },
  ];
  List<Map> weekBooking = [
    {
      "userName": "Vivek Kumar",
      "timings": "4:00 PM - 5:00 PM",
      "Date": "Wed | 03-08-2025",
    },
    {
      "userName": "Riya Sharma",
      "timings": "6:00 PM - 7:00 PM",
      "Date": "Fri | 05-08-2025",
    },
  ];
  List<Map> monthBooking = [
    {
      "userName": "Suresh Patel",
      "timings": "8:00 AM - 9:00 AM",
      "Date": "Mon | 15-08-2025",
    },
    {
      "userName": "Anjali Verma",
      "timings": "3:00 PM - 4:00 PM",
      "Date": "Sun | 21-08-2025",
    },
  ];
  List<Map> allBooking = [
    {
      "userName": "Nikhil Raj",
      "timings": "5:00 PM - 6:00 PM",
      "Date": "Tue | 01-09-2025",
    },
    {
      "userName": "Priya Singh",
      "timings": "7:00 PM - 8:00 PM",
      "Date": "Fri | 12-09-2025",
    },
  ];

  int bookingTabIndex = 3;
   List<Map> finalTodayBooking = [];
   List<Map> finalWeekBooking = [];
   List<Map> finalMonthBooking = [];
   List<Map> finalAllBooking = [];

  // ================= CACHE TRANSLATION LOGIC START =================

  // 1. Translation Cache Map

  // Current language to track changes
  

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Turf Owner",
      "All", "Today", "This Week", "This Month",
      "Home", "Bookings", "Turf", "Workers",
      "No Bookings", "Paid", "Pending",
      // Include any other static strings here
    };

    // 🔴 FIX: Add dynamic user names to the set of keys to be translated
    for (var booking in finalAllBooking) {
      if (booking['userName'] != null) {
        keys.add(booking['userName']);
      }
    }
_extractStrings(allBooking, keys);
    return keys.toList();
  }

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

  Future<void> loadAllTurfs() async {
    finalTodayBooking = todayBooking;
    finalWeekBooking = weekBooking;
    finalMonthBooking = monthBooking;
    finalAllBooking = allBooking;
    final allTurfList = await UserSendBookingController().fetchAllBookData();
    log("fetched list: $allTurfList");

    for (var newItem in allTurfList) {
    // {
    //   "userName": "Nikhil Raj",
    //   "timings": "5:00 PM - 6:00 PM",
    //   "Date": "Tue | 01-09-2025",
    // },
      Map<String, dynamic> turfCard = {
        "userName": newItem['user_name'],
         "timings":newItem['time'],
          "Date": newItem['day_date'],
      };

      finalAllBooking.add(turfCard);
    }

    log("List: $finalAllBooking");

    if (mounted) {
      setState(() {
        // Reload translations to include dynamic text from newly loaded games
        _loadTranslations(ownerAppLanguageNotifier.value);
      });
    }
  }

  // 3. Load Translations function
  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;

    // Check if the language is the same and the number of keys matches the cached count.
    // NOTE: This check is an optimization. If new bookings are added, the number of keys will change
    // and a reload will correctly occur.
    if (_currentLang == lang &&
        _translationsCache.keys.length == keysToLoad.length) {
      return;
    }
// _translationsCache.clear();
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

  // 4. Helper to retrieve cached translation
  String _getTranslation(String key) {
    // Returns the cached translation or the original key if not found
    return _translationsCache[key] ?? key;
  }

  // Listener function to call _loadTranslations when the language notifier changes
  void _languageChangeListener() {
    _loadTranslations(ownerAppLanguageNotifier.value);
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await OwnerThemeLangSettings(
      theme: null,
    ).loadSelectedTheme();
    isDarkOwnerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await OwnerThemeLangSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    ownerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet); // Initial load of translations
  }

  // ================= CACHE TRANSLATION LOGIC END =================
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
    ownerAppLanguageNotifier.addListener(_languageChangeListener);
    
loadAllTurfs();
    // Cache translation setup
    _loadSelectedTheme();
    _loadSelectedLang();
    // ownerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    ownerAppLanguageNotifier.removeListener(_languageChangeListener);
    _banSubscription?.cancel();
    super.dispose();
  }

  // Helper function uses cached translation
  Widget _buildTabButton(String titleKey, int index, Color primaryColor) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: bookingTabIndex == index
            ? primaryColor
            : Colors.grey[200],
        foregroundColor: bookingTabIndex == index ? Colors.white : primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        setState(() {
          bookingTabIndex = index;
        });
      },
      // Use cached translation
      child: Text(_getTranslation(titleKey)),
    );
  }

  // Helper function uses cached translation
  Widget _buildBookingList(Color primaryColor) {
    List<Map> bookingList;
    switch (bookingTabIndex) {
      case 0:
        bookingList = finalTodayBooking;
        break;
      case 1:
        bookingList = finalWeekBooking;
        break;
      case 2:
        bookingList = finalMonthBooking;
        break;
      case 3:
        bookingList = finalAllBooking;
        break;
      default:
        bookingList = finalTodayBooking;
    }

    if (bookingList.isEmpty) {
      // Use cached translation
      return Center(child: Text(_getTranslation("No Bookings")));
    }

    return ListView.builder(
      itemCount: bookingList.length,
      itemBuilder: (context, index) {
        final booking = bookingList[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            title: Text(
              booking['timings'] ?? "",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryColor,
              ),
            ),
            subtitle: Text(
              // 🔴 FIX: Apply _getTranslation to the user name
              _getTranslation(booking['userName'] ?? ""),
              style: const TextStyle(fontSize: 15),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  booking['Date'] ?? "",
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? Colors.green[400]
                        : Colors.orange[400],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    // Use cached translation for "Paid" or "Pending"
                    _getTranslation(index % 2 == 0 ? "Paid" : "Pending"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator if translations haven't loaded yet

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
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 25,
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  // Use cached translation (fast)
                  title: Text(
                    _getTranslation("Turf Owner"),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: primaryColor,
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const BookingQRScannerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.qr_code_scanner_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.message_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ],
                ),
                drawer: OwnerDrawer(),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // Use cached translation for tab buttons
                          _buildTabButton("All", 3, primaryColor),
                          _buildTabButton("Today", 0, primaryColor),
                          _buildTabButton("This Week", 1, primaryColor),
                          _buildTabButton("This Month", 2, primaryColor),
                        ],
                      ),
                    ),
                    Expanded(child: _buildBookingList(primaryColor)),
                  ],
                ),
                bottomNavigationBar: StylishBottomBar(
                  backgroundColor: primaryColor,
                  items: [
                    BottomBarItem(
                      icon: const Icon(Icons.home, color: Colors.white),
                      // Use cached translation
                      title: Text(
                        _getTranslation('Home'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: primaryColor,
                      selectedIcon: const Icon(
                        Icons.read_more,
                        color: Colors.white,
                      ),
                    ),
                    BottomBarItem(
                      icon: const Icon(
                        Icons.calendar_month_sharp,
                        color: Colors.white,
                      ),
                      // Use cached translation
                      title: Text(
                        _getTranslation('Bookings'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: primaryColor,
                    ),
                    BottomBarItem(
                      icon: const Icon(
                        Icons.sports_basketball,
                        color: Colors.white,
                      ),
                      // Use cached translation
                      title: Text(
                        _getTranslation('Turf'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: primaryColor,
                    ),
                    BottomBarItem(
                      icon: const Icon(
                        Icons.people_rounded,
                        color: Colors.white,
                      ),
                      // Use cached translation
                      title: Text(
                        _getTranslation('Workers'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: primaryColor,
                    ),
                  ],
                  option: DotBarOptions(
                    dotStyle: DotStyle.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.white, Colors.white],
                    ),
                  ),
                  hasNotch: true,
                  currentIndex: selected,
                  onTap: (index) {
                    setState(() => selected = index);
                    switch (index) {
                      case 0:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const OwnerDashBoardScreen(),
                          ),
                        );
                        break;
                      case 2:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) =>
                                const ownerAfterRegistrationTurfScreen(),
                          ),
                        );
                        break;
                      case 3:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const ownerTurfWorkerScreen(),
                          ),
                        );
                        break;
                    }
                  },
                ),
              ),
              if (_translationsCache.isEmpty)
                const Positioned.fill(child: OwnerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }
}
