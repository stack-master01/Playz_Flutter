import 'dart:async';
import 'dart:developer'; // Required for log()

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/book(sports)/turfBill.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/home(sport)/homepage(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class SelectSportAndTime extends StatefulWidget {
  Map<String, dynamic> turfInfoMap = {};
  SelectSportAndTime({super.key, required this.turfInfoMap});

  @override
  State<SelectSportAndTime> createState() => _SelectSportAndTimeState();
}

class _SelectSportAndTimeState extends State<SelectSportAndTime> {
  Map<String, dynamic> currentTurfInfoMap = {};
  List<Map<String, dynamic>> _bookedSlots = []; // NEW: To hold the booked slots

  bool isOn = false;
  String selectedSport = "";
  String selectedGround = "";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  double totalPrice = 0.0;

  Map<String, dynamic> selectedBookingDetails = {
    'selectedSport': null,
    'selectedGround': null,
    'selectedDate': null, // DateTime object
    'dayOfWeek': null, // String: e.g., 'Monday'
    'startTime': null, // String: e.g., '6:00 AM'
    'endTime': null, // String: e.g., '7:00 AM'
    'totalPrice': 0.0, // double
    'turfInfo': null, // Map of the current turf info
  };

  List<Map<String, dynamic>> sportsAvailableKeys = [
    {"icon": Icons.sports_cricket_outlined, "sport": "CRICKET"},
    {"icon": Icons.sports_soccer_outlined, "sport": "FOOTBALL"},
    {"icon": Icons.sports_tennis_outlined, "sport": "TENNIS"},
  ];
  int selectedIndex = 0;
  String startTime = "";
  String endTime = "";
  List<Map<String, dynamic>> timeSlotList = [];
  List<String> groundsAvailable = ["5x5", "7x7", "11x11"];


  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Select Sport and Time",
      "Select a Sport",
      "CRICKET",
      "FOOTBALL",
      "TENNIS",
      "Select Ground Type",
      ...groundsAvailable,
      "Select Date",
      "Pick a day",
      "Date: ",
      "Select Time Slot",
      "Start",
      "End",
      "00:00 AM",
      "Total Price : INR 2000",
      "NEXT",
      "Start Time",
      "End Time",
      "Please select a date first", // Added for translation
      "Please select a sport, ground, date, and a valid time slot to proceed.", // Added for translation
      "Selected time range includes a booked or unavailable slot. Please choose another time.", // Added for translation
    };

    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }

    for (var sport in sportsAvailableKeys) {
      keys.add(sport['sport']);
    }
    _extractStrings(currentTurfInfoMap, keys);
    return keys.toList();
  }

  void _extractStrings(dynamic data, Set<String> keys) {
    if (data is String) {

      if (data.isNotEmpty) {
        keys.add(data);
      }
    } else if (data is Map) {
      data.values.forEach((value) => _extractStrings(value, keys));
    } else if (data is List) {
      data.forEach((item) => _extractStrings(item, keys));
    }
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
Future<void> _setupBanMonitoring() async {
    // You can call this method at any time you need to (re)start the monitor
    _banSubscription?.cancel(); // Cancel any existing one before starting anew
    _banSubscription = await startBanMonitoring(
      context: context, 
      firestoreInstance: FirebaseFirestore.instance, // Use your actual instance
    );
  }
  @override
  void initState() {
    super.initState();
    _setupBanMonitoring();
    currentTurfInfoMap = widget.turfInfoMap;
    // Extract booked slots from turfInfoMap (assuming a key like 'booked_slots')
    // If the data structure is different, you'd adjust this line.
    if (currentTurfInfoMap['booked_slots'] is List) {
      _bookedSlots = (currentTurfInfoMap['booked_slots'] as List)
          .cast<Map<String, dynamic>>();
    }
    
    selectedBookingDetails['turfInfo'] = currentTurfInfoMap;
    timeSlotList = extractTimeSlotsFromMap(currentTurfInfoMap);
    log("time slots: $timeSlotList");
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

  String? selectedLocation;

  Future<void> _loadSelectedLocation() async {
    String? selected = await Appsharedpreferences().loadSelectedCity();
    selectedLocationNotifier.value = selected;
    log("city in home page: $selected");
    setState(() {
      selectedLocation = selected;
    });
  }

  /// Checks the status of a specific time slot on a given day against fixed off-times AND booked slots.
  /// Checks the status of a specific time slot on a given day against fixed off-times AND booked slots.
  Map<String, dynamic> getSlotStatus(String dayName, DateTime selectedDate, String timeSlotStart) {
    // 1. Prepare time and date formats for comparison
    final DateFormat timeFormat = DateFormat('h:mm a');
    final DateTime currentStart = timeFormat.parse(timeSlotStart);
  final DateTime nextHour = currentStart.add(const Duration(hours: 1));
    final String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    
    // Log the slot being checked
    // log('Checking slot: $dayName, $dateStr, $targetTimeRange for sport: $selectedSport'); 

    // 2. We will NOT consider fixed 'isOff' flags — bookings should be determined
    // only from the dynamic `booked_slots` list. Always treat fixed schedule as available.
    bool isOff = false;
    
  // We intentionally do not treat any slot as 'fixed off' here; booked slots
  // are determined only from the dynamic `booked_slots` list.
    
    // 3. Check against the dynamic booked slots
    bool isBooked = false;
    if (selectedSport.isNotEmpty && _bookedSlots.isNotEmpty) {
      try {
        // Build target interval anchored to the selected date
        final DateTime targetStartDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          currentStart.hour,
          currentStart.minute,
        );
        final DateTime targetEndDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          nextHour.hour,
          nextHour.minute,
        );

        isBooked = _bookedSlots.any((slot) {
          final dynamic dayDateObj = slot['day_date'];
          final String? slotTimeRange = slot['time'] as String? ?? slot['timeRange'] as String?;
          final String? slotSport = (slot['sport'] as String?)?.toString();

          if (slotTimeRange == null || slotSport == null) return false;
          if (slotSport.trim() != selectedSport.trim()) return false;

          // Normalize the date part to compare with selected date
          try {
            String slotDateStr = '';

            if (dayDateObj == null) {
              return false;
            } else if (dayDateObj is String) {
              if (dayDateObj.contains(' | ')) {
                final parts = dayDateObj.split(' | ');
                if (parts.length >= 2) {
                  slotDateStr = parts[1].split(' ')[0];
                }
              } else {
                slotDateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(dayDateObj));
              }
            } else if (dayDateObj is DateTime) {
              slotDateStr = DateFormat('yyyy-MM-dd').format(dayDateObj);
            } else {
              try {
                final dynamic maybeDate = dayDateObj.toDate();
                if (maybeDate is DateTime) {
                  slotDateStr = DateFormat('yyyy-MM-dd').format(maybeDate);
                }
              } catch (_) {
                return false;
              }
            }

            if (slotDateStr.isEmpty) return false;
            if (slotDateStr != dateStr) return false; // different date -> not relevant

            // Parse slot time range (e.g., '6:00 AM - 8:00 AM') and build DateTimes anchored to selected date
            final parts = slotTimeRange.split('-').map((s) => s.trim()).toList();
            if (parts.length != 2) return false;

            final DateTime bookedStartParsed = timeFormat.parse(parts[0]);
            final DateTime bookedEndParsed = timeFormat.parse(parts[1]);

            final DateTime bookedStart = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                bookedStartParsed.hour,
                bookedStartParsed.minute);
            // If end time equals start time (unlikely) treat as one-hour slot; otherwise use given end
            final DateTime bookedEnd = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                bookedEndParsed.hour,
                bookedEndParsed.minute);

            // Interval overlap check: bookedStart < targetEnd && bookedEnd > targetStart
            if (bookedStart.isBefore(targetEndDateTime) && bookedEnd.isAfter(targetStartDateTime)) {
              return true; // overlapping booked interval
            }
          } catch (e) {
            log('Error parsing booked slot date/time: $e');
            return false;
          }

          return false;
        });
      } catch (e) {
        log('Error checking booked slots: $e');
        isBooked = false;
      }
    }
    
    // 4. Determine final status
    final bool isAvailable = !isBooked && !isOff;

    return {
      'isAvailable': isAvailable,
      'isBooked': isBooked,
      'isOff': isOff,
    };
  }

  void _calculateTotalPrice() {
    if (selectedDate == null ||
        startTime.isEmpty ||
        endTime.isEmpty ||
        selectedGround.isEmpty ||
        selectedSport.isEmpty 
        ) {
      setState(() {
        totalPrice = 0.0;
        selectedBookingDetails['totalPrice'] = 0.0;
      });
      return;
    }

    double calculatedPrice = 0.0;
    bool hasUnavailableSlot = false; // Flag to check for booked or off slots

    final String dayName = DateFormat('EEEE').format(selectedDate!);
    selectedBookingDetails['dayOfWeek'] = dayName;

    final Map<String, dynamic>? slots =
        currentTurfInfoMap['time_slots']?['slots'] as Map<String, dynamic>?;

    final List<dynamic>? daySlots = slots?[dayName];

    if (daySlots == null) {
      hasUnavailableSlot = true;
    }

    final DateFormat timeFormat = DateFormat('h:mm a');
    try {
      DateTime currentStart = timeFormat.parse(startTime);
      final DateTime selectedEnd = timeFormat.parse(endTime);
      
      // Safety check: ensure start is before end
      if (!currentStart.isBefore(selectedEnd)) {
         hasUnavailableSlot = true;
      }

      while (currentStart.isBefore(selectedEnd) && !hasUnavailableSlot) {
        final String currentSlotStart = timeFormat.format(currentStart);
        final DateTime nextHour = currentStart.add(const Duration(hours: 1));
        final String nextSlotEnd = timeFormat.format(nextHour);

        // Check the dynamic status (booked/off) for the current 1-hour segment
        final status = getSlotStatus(dayName, selectedDate!, currentSlotStart);
        
        // **CRITICAL CHECK**
        if (!status['isAvailable']) {
          hasUnavailableSlot = true; // Mark as unavailable and break loop
          break;
        }

        final String targetTimeRange = '$currentSlotStart - $nextSlotEnd';

        final Map<String, dynamic>? matchingSlot = daySlots!.firstWhere(
          (slot) =>
              slot is Map<String, dynamic> &&
              slot['timeRange'] == targetTimeRange,
          orElse: () => null,
        );

        if (matchingSlot != null) {
          final num? price = matchingSlot['price'] as num?;
          if (price != null) {
            calculatedPrice += price.toDouble();
          } else {
            hasUnavailableSlot = true;
          }
        } else {
          hasUnavailableSlot = true;
        }

        currentStart = nextHour;

        if (currentStart.hour == selectedEnd.hour &&
            currentStart.minute == selectedEnd.minute) {
          break;
        }
      }
    } catch (e) {
      log('Error during price calculation loop: $e');
      hasUnavailableSlot = true;
    }

    // Final price assignment
    if (hasUnavailableSlot) {
      calculatedPrice = 0.0;
      if (startTime.isNotEmpty && endTime.isNotEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(_getTranslation("Selected time range includes a booked or unavailable slot. Please choose another time.")),
                  duration: Duration(seconds: 3),
              ),
          );
      }
    }

    setState(() {
      totalPrice = calculatedPrice;
      selectedBookingDetails['totalPrice'] = calculatedPrice;
    });
  }


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
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
                        Text(
                          _getTranslation(
                            "Select Sport and Time",
                          ), // ✨ TRANSLATED
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

              Positioned(
                top: (MediaQuery.of(context).size.height) * 0.097192,
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
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Spacing
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 30),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            left: Reusable.getDeviceWidth(context, W: 20),
                          ),
                          child: Text(
                            _getTranslation("Select a Sport"), // ✨ TRANSLATED
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getDarkGrey(),
                            ),
                          ),
                        ),

                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: (currentTurfInfoMap['sports'].length / 2)
                              .ceil(),
                          itemBuilder: (context, index) {
                            final sportKey1 =
                                currentTurfInfoMap['sports'][(index * 2)];
                            final sportKey2 =
                                ((index * 2) + 1) <
                                        currentTurfInfoMap['sports'].length
                                    ? currentTurfInfoMap['sports'][(index * 2) + 1]
                                    : null;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          selectedSport = sportKey1;
                                          selectedBookingDetails['selectedSport'] = sportKey1; // ⭐️ NEW: Update map
                                          // Recalculate price in case sport affects booking status
                                          _calculateTotalPrice(); 
                                          setState(() {});
                                        },
                                        child: Container(
                                          height: Reusable.getDeviceHeight(
                                            context,
                                            H: 40,
                                          ),
                                          decoration: BoxDecoration(
                                            color: (sportKey1 == selectedSport)
                                                ? isDark
                                                    ? Reusable.getLightGreen()
                                                    : Reusable.getGreen()
                                                : isDark
                                                    ? Reusable.getDarkModeBlack()
                                                    : Reusable.getWhite(),
                                            borderRadius: BorderRadius.circular(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 10,
                                              ),
                                            ),
                                            border: Border.all(
                                              color: (sportKey1 == selectedSport)
                                                  ? isDark
                                                      ? Reusable.getLightGreen()
                                                      : Reusable.getGreen()
                                                  : isDark
                                                      ? Reusable.getTextGrey()
                                                      : Reusable.getDarkGrey(),
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
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
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  _getTranslation(
                                                    sportKey1,
                                                  ), // ✨ TRANSLATED
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: (sportKey1 ==
                                                            selectedSport)
                                                        ? isDark
                                                            ? Reusable.getDarkModeBlack()
                                                            : Reusable.getWhite()
                                                        : isDark
                                                            ? Reusable.getTextGrey()
                                                            : Reusable.getDarkGrey(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        width: Reusable.getDeviceWidth(
                                          context,
                                          W: 10,
                                        ),
                                      ),

                                      if (sportKey2 != null)
                                        GestureDetector(
                                          onTap: () {
                                            selectedSport = sportKey2;
                                            selectedBookingDetails['selectedSport'] = sportKey2; // ⭐️ NEW: Update map
                                            _calculateTotalPrice(); 
                                            setState(() {});
                                          },
                                          child: Container(
                                            height: Reusable.getDeviceHeight(
                                              context,
                                              H: 40,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (sportKey2 == selectedSport)
                                                      ? isDark
                                                          ? Reusable.getLightGreen()
                                                          : Reusable.getGreen()
                                                      : isDark
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
                                                color: (sportKey2 == selectedSport)
                                                    ? isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getGreen()
                                                    : isDark
                                                        ? Reusable.getTextGrey()
                                                        : Reusable.getDarkGrey(),
                                                width: 1,
                                              ),
                                            ),
                                            child: Padding(
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
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _getTranslation(
                                                      sportKey2,
                                                    ), // ✨ TRANSLATED
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: (sportKey2 ==
                                                              selectedSport)
                                                          ? isDark
                                                              ? Reusable.getDarkModeBlack()
                                                              : Reusable.getWhite()
                                                          : isDark
                                                              ? Reusable.getTextGrey()
                                                              : Reusable.getDarkGrey(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox(),
                                    ],
                                  ),
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
                          height: Reusable.getDeviceHeight(context, H: 30),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            left: Reusable.getDeviceWidth(context, W: 20),
                          ),
                          child: Text(
                            _getTranslation(
                              "Select Ground Type",
                            ), // ✨ TRANSLATED
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getDarkGrey(),
                            ),
                          ),
                        ),

                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: (groundsAvailable.length / 3).ceil(),
                          itemBuilder: (context, index) {
                            final groundKey1 = groundsAvailable[(index * 3)];
                            final groundKey2 =
                                ((index * 3) + 1) < groundsAvailable.length
                                    ? groundsAvailable[(index * 3) + 1]
                                    : null;
                            final groundKey3 =
                                ((index * 3) + 2) < groundsAvailable.length
                                    ? groundsAvailable[(index * 3) + 2]
                                    : null;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          selectedGround = groundKey1;
                                          selectedBookingDetails['selectedGround'] = groundKey1; // ⭐️ NEW: Update map
                                          _calculateTotalPrice();
                                          setState(() {});
                                        },
                                        child: Container(
                                          height: Reusable.getDeviceHeight(
                                            context,
                                            H: 40,
                                          ),
                                          decoration: BoxDecoration(
                                            color:
                                                (groundKey1 == selectedGround)
                                                    ? isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getGreen()
                                                    : isDark
                                                        ? Reusable.getDarkModeBlack()
                                                        : Reusable.getWhite(),
                                            borderRadius: BorderRadius.circular(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 10,
                                              ),
                                            ),
                                            border: Border.all(
                                              color:
                                                  (groundKey1 == selectedGround)
                                                      ? isDark
                                                          ? Reusable.getLightGreen()
                                                          : Reusable.getGreen()
                                                      : isDark
                                                          ? Reusable.getTextGrey()
                                                          : Reusable.getDarkGrey(),
                                              width: 1,
                                            ),
                                          ),
                                          child: Padding(
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
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  _getTranslation(
                                                    groundKey1,
                                                  ), // ✨ TRANSLATED
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: (groundKey1 ==
                                                            selectedGround)
                                                        ? isDark
                                                            ? Reusable.getDarkModeBlack()
                                                            : Reusable.getWhite()
                                                        : isDark
                                                            ? Reusable.getTextGrey()
                                                            : Reusable.getDarkGrey(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                        width: Reusable.getDeviceWidth(
                                          context,
                                          W: 20,
                                        ),
                                      ),

                                      if (groundKey2 != null)
                                        GestureDetector(
                                          onTap: () {
                                            selectedGround = groundKey2;
                                            selectedBookingDetails['selectedGround'] = groundKey2; // ⭐️ NEW: Update map
                                            _calculateTotalPrice();
                                            setState(() {});
                                          },
                                          child: Container(
                                            height: Reusable.getDeviceHeight(
                                              context,
                                              H: 40,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (groundKey2 == selectedGround)
                                                      ? isDark
                                                          ? Reusable.getLightGreen()
                                                          : Reusable.getGreen()
                                                      : isDark
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
                                                color: (groundKey2 ==
                                                        selectedGround)
                                                    ? isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getGreen()
                                                    : isDark
                                                        ? Reusable.getTextGrey()
                                                        : Reusable.getDarkGrey(),
                                                width: 1,
                                              ),
                                            ),
                                            child: Padding(
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
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _getTranslation(
                                                      groundKey2,
                                                    ), // ✨ TRANSLATED
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: (groundKey2 ==
                                                              selectedGround)
                                                          ? isDark
                                                              ? Reusable.getDarkModeBlack()
                                                              : Reusable.getWhite()
                                                          : isDark
                                                              ? Reusable.getTextGrey()
                                                              : Reusable.getDarkGrey(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        SizedBox(),

                                      SizedBox(
                                        width: Reusable.getDeviceWidth(
                                          context,
                                          W: 20,
                                        ),
                                      ),

                                      if (groundKey3 != null)
                                        GestureDetector(
                                          onTap: () {
                                            selectedGround = groundKey3;
                                            selectedBookingDetails['selectedGround'] = groundKey3; // ⭐️ NEW: Update map
                                            _calculateTotalPrice();
                                            setState(() {});
                                          },
                                          child: Container(
                                            height: Reusable.getDeviceHeight(
                                              context,
                                              H: 40,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  (groundKey3 == selectedGround)
                                                      ? isDark
                                                          ? Reusable.getLightGreen()
                                                          : Reusable.getGreen()
                                                      : isDark
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
                                                color: (groundKey3 ==
                                                        selectedGround)
                                                    ? isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getGreen()
                                                    : isDark
                                                        ? Reusable.getTextGrey()
                                                        : Reusable.getDarkGrey(),
                                                width: 1,
                                              ),
                                            ),
                                            child: Padding(
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
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    _getTranslation(
                                                      groundKey3,
                                                    ), // ✨ TRANSLATED
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: (groundKey3 ==
                                                              selectedGround)
                                                          ? isDark
                                                              ? Reusable.getDarkModeBlack()
                                                              : Reusable.getWhite()
                                                          : isDark
                                                              ? Reusable.getTextGrey()
                                                              : Reusable.getDarkGrey(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        const SizedBox(),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 30),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            left: Reusable.getDeviceWidth(context, W: 20),
                          ),
                          child: Text(
                            _getTranslation("Select Date"), // ✨ TRANSLATED
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getDarkGrey(),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 5),
                        ),

                        GestureDetector(
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              builder: (context, child) {
                                return Theme(
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
                                  child: child!,
                                );
                              },
                              context: context,
                              initialDate: selectedDate ??
                                  DateTime
                                      .now(), // default today or previously selected
                              firstDate: DateTime(
                                2000,
                              ), // earliest allowed date
                              lastDate: DateTime(2100), // latest allowed date
                            );

                            if (picked != null) {
                              // Reset time slots when date changes
                              startTime = ""; 
                              endTime = "";
                              selectedBookingDetails['startTime'] = null;
                              selectedBookingDetails['endTime'] = null;
                              
                              setState(() {
                                selectedDate = picked;
                                // store a clean date string (yyyy-MM-dd) instead of the full DateTime with zeros
                                selectedBookingDetails['selectedDate'] = DateFormat('yyyy-MM-dd').format(picked); // ⭐️ NEW: Update map as string
                                _calculateTotalPrice(); // Recalculate price on date change
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
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _getTranslation(
                                                  "Date: ",
                                                ), // ✨ TRANSLATED
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: isDark
                                                      ? Reusable.getTextGrey()
                                                      : Reusable.getDarkGrey(),
                                                ),
                                              ),
                                              Text(
                                                selectedDate == null
                                                    ? _getTranslation(
                                                        "Pick a day",
                                                      ) // ✨ TRANSLATED
                                                    : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                                                style: TextStyle(
                                                  fontSize: 16,
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 30),
                        ),

                        Padding(
                          padding: EdgeInsets.only(
                            left: Reusable.getDeviceWidth(context, W: 20),
                          ),
                          child: Text(
                            _getTranslation("Select Time Slot"), // ✨ TRANSLATED
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getDarkGrey(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 10),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (selectedSport.isEmpty || selectedDate == null) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text("Please select a sport and date first."),
                                            duration: Duration(seconds: 2),
                                        ),
                                    );
                                    return;
                                }
                                showTimeSlots(isDark);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                  borderRadius: BorderRadius.circular(
                                    Reusable.getDeviceWidth(context, W: 10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: Reusable.getDeviceHeight(
                                          context,
                                          H: 5,
                                        ),
                                        bottom: Reusable.getDeviceHeight(
                                          context,
                                          H: 5,
                                        ),
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
                                          Text(
                                            _getTranslation(
                                              "Start",
                                            ), // ✨ TRANSLATED
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? Reusable.getDarkModeBlack()
                                                  : Reusable.getWhite(),
                                            ),
                                          ),
                                          SizedBox(
                                            height: Reusable.getDeviceHeight(
                                              context,
                                              H: 5,
                                            ),
                                          ),
                                          Text(
                                            (startTime == "")
                                                ? _getTranslation(
                                                    "00:00 AM",
                                                  ) // ✨ TRANSLATED
                                                : startTime,
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
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              width: Reusable.getDeviceWidth(context, W: 20),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (startTime.isEmpty) {
                                     ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text("Please select a start time first."),
                                            duration: Duration(seconds: 2),
                                        ),
                                    );
                                    return;
                                }
                                showFilteredTimeSlots(isDark);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                  borderRadius: BorderRadius.circular(
                                    Reusable.getDeviceWidth(context, W: 10),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: Reusable.getDeviceHeight(
                                          context,
                                          H: 5,
                                        ),
                                        bottom: Reusable.getDeviceHeight(
                                          context,
                                          H: 5,
                                        ),
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
                                          Text(
                                            _getTranslation(
                                              "End",
                                            ), // ✨ TRANSLATED
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? Reusable.getDarkModeBlack()
                                                  : Reusable.getWhite(),
                                            ),
                                          ),
                                          SizedBox(
                                            height: Reusable.getDeviceHeight(
                                              context,
                                              H: 5,
                                            ),
                                          ),
                                          Text(
                                            (endTime == "")
                                                ? _getTranslation(
                                                    "00:00 AM",
                                                  ) // ✨ TRANSLATED
                                                : endTime,
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
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 120),
                        ),

                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Total Price : INR ${totalPrice.toStringAsFixed(0)}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                            ),
                          ),
                        ),

                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),
                        GestureDetector(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              onTap: () {
                                if (selectedBookingDetails['selectedSport'] == null ||
                                    selectedBookingDetails['selectedGround'] == null ||
                                    selectedBookingDetails['selectedDate'] == null ||
                                    selectedBookingDetails['startTime'] == null ||
                                    selectedBookingDetails['endTime'] == null ||
                                    selectedBookingDetails['totalPrice'] == 0.0) {
                                  log("Booking incomplete. Please select all options and a valid time range.");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(_getTranslation("Please select a sport, ground, date, and a valid time slot to proceed.")),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return TurfBill(
                                        bookingDetails: selectedBookingDetails, currentTurfInfo: currentTurfInfoMap,
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
                                width:
                                    Reusable.getDeviceWidth(context, W: 388),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                  borderRadius: BorderRadius.circular(
                                    Reusable.getDeviceWidth(context, W: 30),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _getTranslation("NEXT"), // ✨ TRANSLATED
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

  List<Map<String, dynamic>> extractTimeSlotsFromMap(
      Map<String, dynamic> data,
      ) {
    final Map<String, dynamic>? slots =
        data['time_slots']?['slots'] as Map<String, dynamic>?;

    if (slots == null || slots.isEmpty) {
      return [];
    }

    final Set<String> uniqueStartTimes = {};
    final RegExp timeRegex = RegExp(r'(\d{1,2}:\d{2} [AP]M) -');

    // Iterate over the values (the lists of time slots for each day)
    for (final daySlots in slots.values) {
      if (daySlots is List) {
        for (final slot in daySlots) {
          if (slot is Map<String, dynamic> && slot.containsKey('timeRange')) {
            String timeRange = slot['timeRange'] as String;
            final match = timeRegex.firstMatch(timeRange);
            if (match != null) {
              // Add the captured start time to the set (for uniqueness)
              uniqueStartTimes.add(match.group(1)!.trim());
            }
          }
        }
      }
    }

    final List<String> sortedTimes = uniqueStartTimes.toList();
    final DateFormat timeFormat = DateFormat('h:mm a');

    sortedTimes.sort((a, b) {
      final DateTime timeA = timeFormat.parse(a);
      final DateTime timeB = timeFormat.parse(b);
      return timeA.compareTo(timeB);
    });

    // We no longer add default status flags here, they are checked dynamically
    return sortedTimes.map((time) {
      return {
        "time": time,
      };
    }).toList();
  }

  void showTimeSlots(bool isDark) {
    final String? dayName = selectedDate == null
        ? null
        : DateFormat('EEEE').format(selectedDate!);

    if (dayName == null) return; // Should be handled by the check before calling

    showModalBottomSheet(
      isScrollControlled: false, // for keyboard resize
      isDismissible: true, // disable tap outside to close
      enableDrag: true,
      backgroundColor: isDark
          ? Reusable.getDarkModeBlack()
          : Reusable.getWhite(),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Reusable.getDeviceWidth(context, W: 30)),
        ),
      ),
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(
              left: Reusable.getDeviceWidth(context, W: 20),
              right: Reusable.getDeviceWidth(context, W: 20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: Reusable.getDeviceHeight(context, H: 30)),
                Text(
                  _getTranslation("Start Time"), // ✨ TRANSLATED
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Reusable.getLightGreen()
                        : Reusable.getBlack(),
                  ),
                ),
                SizedBox(height: Reusable.getDeviceHeight(context, H: 10)),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6, // Number of columns
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0, // Width/height ratio of each item
                  ),
                  itemCount: timeSlotList.length,
                  itemBuilder: (context, index) {
                    final String timeSlot = timeSlotList[index]['time'];
                    
                    // GET DYNAMIC STATUS — we only care if it's booked (ignore fixed 'off')
                    final status = getSlotStatus(dayName, selectedDate!, timeSlot);
                    final bool isBooked = status['isBooked'] as bool;
                    
                    // Only booked slots should be disabled (we no longer consider fixed-off)
                    final bool isDisabled = isBooked;

                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () {
                        selectedIndex = index + 1;
                        startTime = timeSlot;
                        selectedBookingDetails['startTime'] = startTime; // ⭐️ NEW: Update map
                        selectedBookingDetails['endTime'] = null; // Reset end time on new start time selection
                        endTime = "";
                        Navigator.of(context).pop();
                        // Call filtered slot picker immediately after selecting start time
                        showFilteredTimeSlots(isDark);
                        _calculateTotalPrice(); // Call for status update
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          // Only booked slots are shown in red
                          color: isBooked
                              ? const Color.fromRGBO(255, 0, 0, 1) // Booked: Red
                              : (timeSlot == startTime)
                                  ? (isDark ? Reusable.getGreen() : Reusable.getLightGreen())
                                  : (isDark ? Reusable.getLightGreen() : Reusable.getGreen()),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            timeSlot,
                            style: TextStyle(
                // Text color: booked items show white text
                color: isBooked
                  ? Reusable.getWhite()
                  : (timeSlot == startTime)
                    ? Reusable.getWhite()
                    : (isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: Reusable.getDeviceHeight(context, H: 60)),
              ],
            ),
          ),
        );
      },
    );
  }

  void showFilteredTimeSlots(bool isDark) {
    if (startTime.isEmpty || selectedDate == null) return;
    
    final List filteredSlots = timeSlotList.sublist(selectedIndex);
    final String dayName = DateFormat('EEEE').format(selectedDate!);

    showModalBottomSheet(
      isScrollControlled: false, // for keyboard resize
      isDismissible: true, // disable tap outside to close
      enableDrag: true,
      backgroundColor: isDark
          ? Reusable.getDarkModeBlack()
          : Reusable.getWhite(),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Reusable.getDeviceWidth(context, W: 30)),
        ),
      ),
      builder: (context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: EdgeInsets.only(
              left: Reusable.getDeviceWidth(context, W: 20),
              right: Reusable.getDeviceWidth(context, W: 20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: Reusable.getDeviceHeight(context, H: 30)),
                Text(
                  _getTranslation("End Time"), // ✨ TRANSLATED
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Reusable.getLightGreen()
                        : Reusable.getBlack(),
                  ),
                ),
                SizedBox(height: Reusable.getDeviceHeight(context, H: 10)),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6, // Number of columns
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0, // Width/height ratio of each item
                  ),
                  itemCount: filteredSlots.length,
                  itemBuilder: (context, index) {
                    final String timeSlot = filteredSlots[index]['time'];
                    
                    // GET DYNAMIC STATUS for the end time slot — only booked matters
                    final status = getSlotStatus(dayName, selectedDate!, timeSlot);
                    final bool isBooked = status['isBooked'] as bool;
                    
                    // Only booked slots are disabled now
                    final bool isDisabled = isBooked;

                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () {
                        endTime = timeSlot;
                        selectedBookingDetails['endTime'] = endTime; // ⭐️ NEW: Update map
                        Navigator.of(context).pop();
                        _calculateTotalPrice(); // This will check the entire range validity.
                        setState(() {});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          // Booked slots appear red; others follow selected/available colors
                          color: isBooked
                              ? const Color.fromRGBO(255, 0, 0, 1)
                              : (timeSlot == endTime)
                                  ? (isDark ? Reusable.getGreen() : Reusable.getLightGreen())
                                  : (isDark ? Reusable.getLightGreen() : Reusable.getGreen()),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            timeSlot,
                            style: TextStyle(
                // Text color: booked items show white text
                color: isBooked
                  ? Reusable.getWhite()
                  : (timeSlot == endTime)
                    ? Reusable.getWhite()
                    : (isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: Reusable.getDeviceHeight(context, H: 60)),
              ],
            ),
          ),
        );
      },
    );
  }
}