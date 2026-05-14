import 'dart:developer'; // Required for log()
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:playz_user/View/user_view/home(sport)/Bookings/Bookqr(sport).dart';
  Map<String, String> _translationsCache = {};
  String _currentLang = "en";

class BookingsSport extends StatefulWidget {
  const BookingsSport({super.key});

  @override
  State<BookingsSport> createState() => _BookingsSportState();
}

// 🔹 Dummy list of group members (image, name, role)
// Note: Keeping these outside the State class as they are global dummy data
List<Map<String, dynamic>> upcomingItems = [
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "turf_name": "Arena 51",
    "day_date": "FRI, 14-08-2025",
    "time_slot": "9:00 AM - 10:00 AM",
    "turf_address":
        "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground",
  },
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "turf_name": "Stadium 10",
    "day_date": "SAT, 15-08-2025",
    "time_slot": "7:00 PM - 8:00 PM",
    "turf_address":
        "42 RedBull Arena, Next to Stadium Bridge, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground",
  },
];

List<Map<String, dynamic>> pastItems = [
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "turf_name": "Arena 51",
    "day_date": "FRI, 14-08-2025",
    "time_slot": "9:00 AM - 10:00 AM",
    "turf_address":
        "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground",
  },
];

List<Map<String, dynamic>> cancelledItems = [
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "turf_name": "Arena 51",
    "day_date": "FRI, 14-08-2025",
    "time_slot": "9:00 AM - 10:00 AM",
    "turf_address":
        "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground",
  },
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "turf_name": "Arena 51",
    "day_date": "FRI, 14-08-2025",
    "time_slot": "9:00 AM - 10:00 AM",
    "turf_address":
        "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground",
  },
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "turf_name": "Arena 51",
    "day_date": "FRI, 14-08-2025",
    "time_slot": "9:00 AM - 10:00 AM",
    "turf_address":
        "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground",
  },
];

int selectedIndex = 0;
List<Map<String, dynamic>> currentList = [];

class _BookingsSportState extends State<BookingsSport> {
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = []; // Using this for dynamic data translation

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "My Bookings",
      "Upcoming",
      "Past",
      "Cancelled",
      // END: Add default english text here
    };

    // Dynamically collect keys from the list items
    // NOTE: This assumes turfInfo will hold the data eventually.
    // To ensure the actual list data is translated, we need to manually
    // add all *potentially unique* dynamic strings here.
    // For this screen, turf names and addresses need translation.
    for (var info in upcomingItems) {
      if (info['turf_name'] is String) {
        keys.add(info['turf_name'] as String);
      }
      if (info['turf_address'] is String) {
        keys.add(info['turf_address'] as String);
      }
    }
    for (var info in pastItems) {
      if (info['turf_name'] is String) {
        keys.add(info['turf_name'] as String);
      }
      if (info['turf_address'] is String) {
        keys.add(info['turf_address'] as String);
      }
    }
    for (var info in cancelledItems) {
      if (info['turf_name'] is String) {
        keys.add(info['turf_name'] as String);
      }
      if (info['turf_address'] is String) {
        keys.add(info['turf_address'] as String);
      }
    }
    // Also include the original turfInfo list given in the prompt structure
    for (var info in this.turfInfo) {
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
List<Map<String,dynamic>> allBookings = [];
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<void> loadAllBookedSlots() async {
  UserSettings userSettings = await UserSettings().loadSettings();
  try {
    final allBookedSlots = await _firestore.collection("Turf_User").doc(userSettings.email).collection("User_Data").doc("User_Bookings").collection("All_Bookings").get();
  for (var userDoc in allBookedSlots.docs) {
        final slotID = userDoc.id;

        final turfsRef = await _firestore.collection("Turf_User").doc(userSettings.email).collection("User_Data").doc("User_Bookings").collection("All_Bookings").doc(slotID).get();
        final turfMap = turfsRef.data();

        //fetched map
  //       {
  //   "day_date":"data",
  //   "qr_text":qrCodeText,
  //   "slot_price":"data",
  //   "slot_time":"data",
  //   "turf_location":data,
  //   "turf_name":data,
  // }
        // Add fetched booking to local list and categorize
        if (turfMap != null) {
          allBookings.add(turfMap);
        }
      }

    // After fetching all bookings, categorize into upcoming/past/cancelled
    _categorizeBookings();
    if (mounted) setState(() {});
  } on FirebaseFirestore catch (e) {
    log("Error $e");
  }
}

// Helper: parse various day_date formats into a DateTime (or null)
DateTime? parseBookingDate(dynamic dayDateObj) {
  try {
    if (dayDateObj == null) return null;

    // Firestore Timestamp
    if (dayDateObj is Timestamp) return dayDateObj.toDate();

    if (dayDateObj is DateTime) return dayDateObj;

    if (dayDateObj is String) {
      // Examples: 'Tuesday | 2025-10-28 00:00:00.000' or '2025-10-28'
      if (dayDateObj.contains('|')) {
        final parts = dayDateObj.split('|');
        if (parts.length >= 2) {
          final datePart = parts[1].trim().split(' ')[0];
          return DateTime.parse(datePart);
        }
      }

      // Try parsing directly
      return DateTime.parse(dayDateObj);
    }
  } catch (e) {
    log('parseBookingDate error: $e');
    return null;
  }
  return null;
}

// Categorize allBookings into upcomingItems, pastItems, and cancelledItems
void _categorizeBookings() {
  upcomingItems.clear();
  pastItems.clear();
  cancelledItems.clear();

  final DateTime today = DateTime.now();
  final DateTime todayDate = DateTime(today.year, today.month, today.day);

  for (final Map<String, dynamic> booking in allBookings) {

    final DateTime? bookingDate = parseBookingDate(booking['day_date']);
    // If parse fails, push to past by default to avoid showing as upcoming
    final DateTime displayDate = bookingDate ?? todayDate.subtract(const Duration(days: 1));

  // Match format used in upcomingItems: uppercase short weekday, dd-MM-yyyy
  final String displayDay = DateFormat('EEE, dd-MM-yyyy').format(displayDate).toUpperCase();
    final String displayTime = booking['slot_time']?.toString() ?? booking['time_slot']?.toString() ?? '';

    final Map<String, dynamic> card = {
      'image': (booking['image'] ?? booking['turf_image'] ?? 'https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg').toString(),
      'turf_name': (booking['turf_name'] ?? booking['turfName'] ?? booking['turf_location'] ?? 'Turf').toString(),
      'day_date': displayDay,
      'time_slot': displayTime.toString(),
      'turf_address': (booking['turf_location'] ?? booking['turf_address'] ?? '').toString(),
      'raw': booking,
      'price': booking['slot_price']
    };

    // Cancellation check
    final dynamic statusObj = booking['status'];
    final String status = statusObj != null ? statusObj.toString().toLowerCase() : '';
    if (status == 'cancelled') {
      cancelledItems.add(card);
      continue;
    }

    if (bookingDate != null) {
      final DateTime bookedDateOnly = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
      if (bookedDateOnly.isAfter(todayDate) || bookedDateOnly.isAtSameMomentAs(todayDate)) {
        upcomingItems.add(card);
      } else {
        pastItems.add(card);
      }
    } else {
      // Unparseable date -> treat as past
      pastItems.add(card);
    }
  }

  // Ensure UI updates
  try {
    // Sorting: upcoming ascending, past descending
    upcomingItems.sort((a, b) {
      try {
        final DateTime ad = parseBookingDate(a['raw']?['day_date']) ?? DateTime.now();
        final DateTime bd = parseBookingDate(b['raw']?['day_date']) ?? DateTime.now();
        return ad.compareTo(bd);
      } catch (_) {
        return 0;
      }
    });
    pastItems.sort((a, b) {
      try {
        final DateTime ad = parseBookingDate(a['raw']?['day_date']) ?? DateTime.now();
        final DateTime bd = parseBookingDate(b['raw']?['day_date']) ?? DateTime.now();
        return bd.compareTo(ad);
      } catch (_) {
        return 0;
      }
    });
  } catch (_) {}
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
    // Load user bookings on init
    loadAllBookedSlots();
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";

        if (selectedIndex == 0) {
          currentList = upcomingItems;
        } else if (selectedIndex == 1) {
          currentList = pastItems;
        } else {
          currentList = cancelledItems;
        }
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
                          _getTranslation("My Bookings"), // 🌍 Translated
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

                      // 🔹 toggle
                      Container(
                        height: Reusable.getDeviceHeight(context, H: 50),
                        width: Reusable.getDeviceWidth(context, W: 388),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 30),
                          ),
                        ),
                        child: Container(
                          height: Reusable.getDeviceHeight(context, H: 50),
                          width: Reusable.getDeviceWidth(context, W: 388),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Reusable.getDarkModeGrey()
                                : Reusable.getWhite(),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(25)),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.25),
                                spreadRadius: 0,
                                blurRadius: 5,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              //toggle 3 options
                              Padding(
                                padding: EdgeInsets.only(
                                  left: Reusable.getDeviceWidth(context, W: 5),
                                ),
                                //upcoming
                                child: GestureDetector(
                                  onTap: () {
                                    selectedIndex = 0;
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 126,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: selectedIndex == 0
                                          ? LinearGradient(
                                              colors: [
                                                isDark
                                                    ? const Color.fromRGBO(
                                                        164,
                                                        255,
                                                        0,
                                                        1,
                                                      )
                                                    : const Color.fromRGBO(
                                                        35,
                                                        140,
                                                        62,
                                                        1,
                                                      ),
                                                isDark
                                                    ? const Color.fromRGBO(
                                                        46,
                                                        204,
                                                        0,
                                                        1,
                                                      )
                                                    : const Color.fromRGBO(
                                                        0,
                                                        200,
                                                        83,
                                                        1,
                                                      ),
                                              ],
                                              begin: Alignment.bottomRight,
                                              end: Alignment.topLeft,
                                            )
                                          : LinearGradient(
                                              colors: [
                                                isDark
                                                    ? Reusable.getDarkModeGrey()
                                                    : Colors.white,
                                                isDark
                                                    ? Reusable.getDarkModeGrey()
                                                    : Colors.white,
                                              ],
                                              begin: Alignment.bottomRight,
                                              end: Alignment.topLeft,
                                            ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getTranslation("Upcoming"), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: selectedIndex == 0
                                              ? isDark
                                                  ? Reusable.getDarkModeBlack()
                                                  : Reusable.getWhite()
                                              : isDark
                                                  ? Reusable.getLightGreen()
                                                  : Reusable.getDarkGrey(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(
                                    // left: Reusable.getDeviceWidth(context, W: 5)
                                    ),
                                //past
                                child: GestureDetector(
                                  onTap: () {
                                    selectedIndex = 1;
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 126,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: selectedIndex == 1
                                          ? LinearGradient(
                                              colors: [
                                                isDark
                                                    ? const Color.fromRGBO(
                                                        164,
                                                        255,
                                                        0,
                                                        1,
                                                      )
                                                    : const Color.fromRGBO(
                                                        35,
                                                        140,
                                                        62,
                                                        1,
                                                      ),
                                                isDark
                                                    ? const Color.fromRGBO(
                                                        46,
                                                        204,
                                                        0,
                                                        1,
                                                      )
                                                    : const Color.fromRGBO(
                                                        0,
                                                        200,
                                                        83,
                                                        1,
                                                      ),
                                              ],
                                              begin: Alignment.bottomRight,
                                              end: Alignment.topLeft,
                                            )
                                          : LinearGradient(
                                              colors: [
                                                isDark
                                                    ? Reusable.getDarkModeGrey()
                                                    : Colors.white,
                                                isDark
                                                    ? Reusable.getDarkModeGrey()
                                                    : Colors.white,
                                              ],
                                              begin: Alignment.bottomRight,
                                              end: Alignment.topLeft,
                                            ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getTranslation("Past"), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: selectedIndex == 1
                                              ? isDark
                                                  ? Reusable.getDarkModeBlack()
                                                  : Reusable.getWhite()
                                              : isDark
                                                  ? Reusable.getLightGreen()
                                                  : Reusable.getDarkGrey(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.only(
                                  right:
                                      Reusable.getDeviceWidth(context, W: 5),
                                ),
                                //cancelled
                                child: GestureDetector(
                                  onTap: () {
                                    selectedIndex = 2;
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 126,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: selectedIndex == 2
                                          ? LinearGradient(
                                              colors: [
                                                isDark
                                                    ? const Color.fromRGBO(
                                                        164,
                                                        255,
                                                        0,
                                                        1,
                                                      )
                                                    : const Color.fromRGBO(
                                                        35,
                                                        140,
                                                        62,
                                                        1,
                                                      ),
                                                isDark
                                                    ? const Color.fromRGBO(
                                                        46,
                                                        204,
                                                        0,
                                                        1,
                                                      )
                                                    : const Color.fromRGBO(
                                                        0,
                                                        200,
                                                        83,
                                                        1,
                                                      ),
                                              ],
                                              begin: Alignment.bottomRight,
                                              end: Alignment.topLeft,
                                            )
                                          : LinearGradient(
                                              colors: [
                                                isDark
                                                    ? Reusable.getDarkModeGrey()
                                                    : Colors.white,
                                                isDark
                                                    ? Reusable.getDarkModeGrey()
                                                    : Colors.white,
                                              ],
                                              begin: Alignment.bottomRight,
                                              end: Alignment.topLeft,
                                            ),

                                      // color: Reusable.getWhite(),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          Reusable.getDeviceWidth(
                                            context,
                                            W: 25,
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getTranslation("Cancelled"), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: selectedIndex == 2
                                              ? isDark
                                                  ? Reusable.getDarkModeBlack()
                                                  : Reusable.getWhite()
                                              : isDark
                                                  ? Reusable.getLightGreen()
                                                  : Reusable.getDarkGrey(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                          shrinkWrap:
                              true, // prevents infinite height, although Expanded handles it here
                          itemCount: currentList.length,
                          itemBuilder: (context, index) {
                            // Extract item data for translation lookup
                            final turfNameKey =
                                currentList[index]['turf_name'] as String;
                            final turfAddressKey = currentList[index]['turf_address'] as String;

                            return Column(
                              children: [
                                // 🔹 Member card container
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                             BookQRSport(rawText: currentList[index]['raw']['qr_text'], turfDetails: currentList[index],),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 115,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 388,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Reusable.getDarkModeGrey()
                                          : Reusable.getWhite(),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 3,
                                          color: Color.fromRGBO(0, 0, 0, 0.25),
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Reusable.getDeviceWidth(
                                          context,
                                          W: 15,
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
                                                height:
                                                    Reusable.getDeviceHeight(
                                                  context,
                                                  H: 85,
                                                ),
                                                width: Reusable.getDeviceWidth(
                                                  context,
                                                  W: 85,
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
                                                      W: 10,
                                                    ),
                                                  ),
                                                  child: Image.network(
                                                    currentList[index]['image'],
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
                                                  // Turf name
                                                  Text(
                                                    _getTranslation(turfNameKey), // 🌍 Translated (Dynamic data)
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: isDark
                                                          ? Reusable
                                                              .getLightGreen()
                                                          : Reusable.getBlack(),
                                                    ),
                                                  ),

                                                  SizedBox(
                                                    height:
                                                        Reusable.getDeviceHeight(
                                                      context,
                                                      H: 0,
                                                    ),
                                                  ),
                                                  // Date
                                                  Text(
                                                    currentList[index]
                                                        ['day_date'], // Dates/times usually don't need translation, but formatting might
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: isDark
                                                          ? Reusable
                                                              .getLightGrey()
                                                          : Reusable
                                                              .getDarkGrey(),
                                                    ),
                                                  ),
                                                  // Time Slot
                                                  Text(
                                                    currentList[index]
                                                        ['time_slot'], // Dates/times usually don't need translation, but formatting might
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: isDark
                                                          ? Reusable
                                                              .getLightGrey()
                                                          : Reusable
                                                              .getDarkGrey(),
                                                    ),
                                                  ),
                                                  // Address
                                                  SizedBox(
                                                    width:
                                                        Reusable.getDeviceWidth(
                                                      context,
                                                      W: 230,
                                                    ),
                                                    height:
                                                        Reusable.getDeviceHeight(
                                                      context,
                                                      H: 20,
                                                    ),
                                                    child: SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: Text(
                                                        _getTranslation(turfAddressKey), // 🌍 Translated (Dynamic data)
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Color.fromRGBO(
                                                            66,
                                                            132,
                                                            218,
                                                            1,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Space between cards
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 15,
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