import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:playz_user/Controller/User_Controller/Display_Turfs_Controller.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/Medical_Assistant.dart';
import 'package:playz_user/View/user_view/book(sports)/bookfilter.dart';
import 'package:playz_user/View/user_view/book(sports)/bookturfinfo.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/home(sport)/homepage(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class BookSport extends StatefulWidget {
  String? filterBy;
   BookSport({super.key,this.filterBy});

  @override
  State<BookSport> createState() => _BookSportState();
}

class _BookSportState extends State<BookSport> {
    String? currentFilterBy;
  int selectedMode = 0;

  //list for play sports events
 List<Map<String, dynamic>> bookTurfList=[];
  // master copy used for search filtering
  List<Map<String, dynamic>> _allBookTurfCards = [];
  // currently applied sport filter (from BookFilterSport)
  String? _appliedSportFilter;
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> allTurfList = [
    // {
    //   "images": [
    //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSihcmNMpJiXeA09ZUxex8OsTxdr9oXmqxH9A&s",
    //     "https://images.unsplash.com/photo-1503515091255-ab8063a1796d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGZvb3RiYWxsJTIwdHVyZnxlbnwwfHwwfHx8MA%3D%3D",
    //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZJivXheMQk7jaKLzSAEZJvOl8mx_Dsx1_bhNM0Q4Yrx4_buRHZWPaaVEiP9JlhJjlUvY&usqp=CAU",
    //   ],
    //   "turf_name": "Arena 50",
    //   "location": "Pune",
    //   "distance": "(~3.3 kms)",
    //   "starting_price": "500",
    //   "turf_rating": "3.5",
    //   "turf_reviews": "13",
    // },
    // {
    //   "images": [
    //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSihcmNMpJiXeA09ZUxex8OsTxdr9oXmqxH9A&s",
    //     "https://images.unsplash.com/photo-1503515091255-ab8063a1796d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGZvb3RiYWxsJTIwdHVyZnxlbnwwfHwwfHx8MA%3D%3D",
    //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZJivXheMQk7jaKLzSAEZJvOl8mx_Dsx1_bhNM0Q4Yrx4_buRHZWPaaVEiP9JlhJjlUvY&usqp=CAU",
    //   ],
    //   "turf_name": "Arena 51",
    //   "location": "Pune",
    //   "distance": "(~3.6 kms)",
    //   "starting_price": "800",
    //   "turf_rating": "4.5",
    //   "turf_reviews": "103",
    // },
    // {
    //   "images": [
    //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSihcmNMpJiXeA09ZUxex8OsTxdr9oXmqxH9A&s",
    //     "https://images.unsplash.com/photo-1503515091255-ab8063a1796d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGZvb3RiYWxsJTIwdHVyZnxlbnwwfHwwfHx8MA%3D%3D",
    //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZJivXheMQk7jaKLzSAEZJvOl8mx_Dsx1_bhNM0Q4Yrx4_buRHZWPaaVEiP9JlhJjlUvY&usqp=CAU",
    //   ],
    //   "turf_name": "Arena 51",
    //   "location": "Pune",
    //   "distance": "(~3.6 kms)",
    //   "starting_price": "800",
    //   "turf_rating": "4.5",
    //   "turf_reviews": "103",
    // },
    // {
    //   "images": [
    //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSihcmNMpJiXeA09ZUxex8OsTxdr9oXmqxH9A&s",
    //     "https://images.unsplash.com/photo-1503515091255-ab8063a1796d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGZvb3RiYWxsJTIwdHVyZnxlbnwwfHwwfHx8MA%3D%3D",
    //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZJivXheMQk7jaKLzSAEZJvOl8mx_Dsx1_bhNM0Q4Yrx4_buRHZWPaaVEiP9JlhJjlUvY&usqp=CAU",
    //   ],
    //   "turf_name": "Arena 55",
    //   "location": "Pune",
    //   "distance": "(~3.6 kms)",
    //   "starting_price": "800",
    //   "turf_rating": "4.5",
    //   "turf_reviews": "103",
    // },
  ];

  // ------------------------------------------------------------------
  // 🔹 Translation Cache Logic (Exactly as provided)
  // ------------------------------------------------------------------

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Sports Mode",
      "Gaming Mode",
      "Filter",
      "Sort",
      "Favorites",
      "Select location",
      "Available Games",
      "Pune",
      "Price Starting From ",
    };

    for (var info in turfInfo) {
      if (info['turf_name'] is String) {
        keys.add(info['turf_name'] as String);
        keys.add(info['location'] as String);
        keys.add(info['distance'] as String);
      }
    }
    _extractStrings(bookTurfList, keys);
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

  Future<void> loadAllTurfs() async {
    allTurfList = await DisplayTurfController().fetchAllTurfs();
    log("fetched list: $allTurfList");

    for (var newItem in allTurfList) {
      // {
      //   "images": [
      //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSihcmNMpJiXeA09ZUxex8OsTxdr9oXmqxH9A&s",
      //     "https://images.unsplash.com/photo-1503515091255-ab8063a1796d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGZvb3RiYWxsJTIwdHVyZnxlbnwwfHwwfHx8MA%3D%3D",
      //     "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZJivXheMQk7jaKLzSAEZJvOl8mx_Dsx1_bhNM0Q4Yrx4_buRHZWPaaVEiP9JlhJjlUvY&usqp=CAU",
      //   ],
      //   "turf_name": "Arena 55",
      //   "location": "Pune",
      //   "distance": "(~3.6 kms)",
      //   "starting_price": "800",
      //   "turf_rating": "4.5",
      //   "turf_reviews": "103",
      // },
      // compute distance if user location and turf lat/lng available
      LatLng? userLatLng = await Appsharedpreferences().loadSelectedLatLng();
      String distanceStr = "(~N/A)";
      try {
        final dynamic loc = newItem['location'];
        if (loc != null && (loc['latitude'] != null && loc['longitude'] != null) && userLatLng != null) {
          final double turfLat = (loc['latitude'] is String) ? double.parse(loc['latitude']) : (loc['latitude'] as num).toDouble();
          final double turfLng = (loc['longitude'] is String) ? double.parse(loc['longitude']) : (loc['longitude'] as num).toDouble();
          final double distKm = _distanceInKm(userLatLng.latitude, userLatLng.longitude, turfLat, turfLng);
          distanceStr = "(~${distKm.toStringAsFixed(1)} kms)";
        }
      } catch (e) {
        log('Error computing distance: $e');
      }

        // fetch time_slots and bookings for this turf from Firestore
        try {
          // make a mutable copy of the turf info map
          Map<String, dynamic> currentTurfInfoMap = Map<String, dynamic>.from(newItem);

          final userEmail = currentTurfInfoMap['userEmail']?.toString() ?? '';
          final turfName = currentTurfInfoMap['turfName']?.toString() ?? '';

          if (userEmail.isNotEmpty && turfName.isNotEmpty) {
            final userSnapshot = await _firestore
                .collection('Turf_Owner')
                .doc(userEmail)
                .collection('Turfs')
                .doc(turfName)
                .collection('TimeSlots')
                .get();

            final slotMap = userSnapshot.docs;
            if (slotMap.isNotEmpty) {
              currentTurfInfoMap['time_slots'] = slotMap[0].data();
            }

            final bookingSnapshot = await _firestore
                .collection('Turf_Owner')
                .doc(userEmail)
                .collection('Turfs')
                .doc(turfName)
                .collection('Booking')
                .get();

            final bookMap = bookingSnapshot.docs;
            List<Map<String, dynamic>> bookedSlots = [];
            for (var element in bookMap) {
              bookedSlots.add(Map<String, dynamic>.from(element.data() as Map));
            }
            currentTurfInfoMap['booked_slots'] = bookedSlots;

            // replace loop variable so subsequent code uses fetched data
            newItem = currentTurfInfoMap;

            log("✅ Turfs time slots Fetched: $currentTurfInfoMap");
          }
        } catch (e) {
          log("❌ Error fetching turfs: $e");
        }


      // compute lowest price from time_slots -> slots -> day -> list of slot maps
      String startingPriceStr = "N/A";
      try {
        final timeSlots = newItem['time_slots'];
        num? minPrice;
        if (timeSlots != null && timeSlots is Map && timeSlots['slots'] is Map) {
          final slotsMap = timeSlots['slots'] as Map;
          for (var entry in slotsMap.entries) {
            final dayList = entry.value;
            if (dayList is List) {
              for (var slot in dayList) {
                if (slot is Map && slot.containsKey('price')) {
                  final dynamic p = slot['price'];
                  num? priceNum;
                  if (p is num) {
                    priceNum = p;
                  } else if (p is String) {
                    // strip non-numeric (like currency symbols) then parse
                    final cleaned = p.replaceAll(RegExp(r"[^0-9.]"), "");
                    priceNum = num.tryParse(cleaned);
                  }
                  if (priceNum != null) {
                    if (minPrice == null || priceNum < minPrice) minPrice = priceNum;
                  }
                }
              }
            }
          }
        }
        if (minPrice != null) startingPriceStr = minPrice.toString();
      } catch (e) {
        log('Error computing starting price: $e');
      }

      // extract average_stars and total_reviews (if present) for display
      double avgStars = 0.0;
      int totalReviews = 0;
      try {
        final av = newItem['average_stars'];
        if (av is num) {
          avgStars = av.toDouble();
        } else if (av is String) {
          avgStars = double.tryParse(av) ?? 0.0;
        }
        final tr = newItem['total_reviews'];
        if (tr is int) {
          totalReviews = tr;
        } else if (tr is num) {
          totalReviews = tr.toInt();
        } else if (tr is String) {
          totalReviews = int.tryParse(tr) ?? 0;
        }
      } catch (e) {
        // ignore and keep defaults
      }

      Map<String, dynamic> turfCard = {
        "images": newItem['turfImages'],
        "turf_name": newItem['turfName'],
        "location": newItem['location']?['address'] ?? "Turf Adderss",
        "distance": distanceStr,
        "starting_price": startingPriceStr,
        // keep legacy display keys but prefer actual values when available
        "turf_rating": (avgStars > 0) ? avgStars.toStringAsFixed(1) : "N/A",
        "turf_reviews": totalReviews > 0 ? totalReviews.toString() : "0",
        "average_stars": avgStars,
        "total_reviews": totalReviews,
        "turf_info": newItem,
        "turf_sports": newItem['sports']
      };

      // add to master list and display list (initially unfiltered)
      _allBookTurfCards.add(turfCard);
      bookTurfList.add(turfCard);
    }

    log("List: $bookTurfList");
    // If an external filter was provided via `widget.filterBy`, apply it
    if (currentFilterBy != null) {
      final selectedSportRaw = currentFilterBy!;
      final selectedSport = selectedSportRaw.toLowerCase();
      final filtered = _allBookTurfCards.where((card) {
        final ts = card['turf_sports'];
        if (ts == null) return false;
        if (ts is String) return ts.toLowerCase().contains(selectedSport);
        if (ts is List) return ts.any((e) => e.toString().toLowerCase().contains(selectedSport));
        if (ts is Map) return ts.values.any((e) => e.toString().toLowerCase().contains(selectedSport));
        return false;
      }).toList();

      if (mounted) {
        setState(() {
          bookTurfList = filtered;
          _appliedSportFilter = selectedSportRaw;
          selectedMode = 0; // match behaviour from filter button
          // Reload translations to include dynamic text from newly loaded games
          _loadTranslations(appLanguageNotifier.value);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          // Reload translations to include dynamic text from newly loaded games
          _loadTranslations(appLanguageNotifier.value);
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        bookTurfList = List<Map<String, dynamic>>.from(_allBookTurfCards);
      });
      return;
    }

    final filtered = _allBookTurfCards.where((card) {
      final name = (card['turf_name'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();

    setState(() {
      bookTurfList = filtered;
    });
  }

  // Haversine formula to compute distance between two lat/lng points
  double _distanceInKm(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth's radius in km
    double toRad(double deg) => deg * (3.141592653589793 / 180.0);
    final double dLat = toRad(lat2 - lat1);
    final double dLon = toRad(lon2 - lon1);
    final double a = (sin(dLat / 2) * sin(dLat / 2)) + cos(toRad(lat1)) * cos(toRad(lat2)) * (sin(dLon / 2) * sin(dLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
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
    currentFilterBy = widget.filterBy;
    _setupBanMonitoring();
    if (_currentLang != appLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadSelectedLocation();
    loadAllTurfs();
    appLanguageNotifier.addListener(_languageChangeListener);
    // turfInfo.addAll(bookTurfList);
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
        //height and width for sports list
        return Scaffold(
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: isDark
                          ? Reusable.getLightGreen()
                          : Reusable.getGreen(),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 40,
                                left: 20,
                                right: 20,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  //location
                                  ValueListenableBuilder<String?>(
                                    valueListenable: selectedLocationNotifier,
                                    builder: (context, value, _) {
                                      return GestureDetector(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const PrefLocation(),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.my_location_outlined,
                                              color: isDark
                                                  ? Reusable.getDarkModeGrey()
                                                  : Reusable.getWhite(),
                                              size: 30,
                                            ),
                                            const SizedBox(width: 5),
                                            ValueListenableBuilder<String>(
                                              valueListenable:
                                                  appLanguageNotifier,
                                              builder: (context, lang, _) {
                                                return FutureBuilder<String>(
                                                  future: getTranslatedText(
                                                    value ?? "Select location",
                                                    lang,
                                                  ),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return Text(
                                                        "...",
                                                        style: TextStyle(
                                                          color: isDark
                                                              ? Reusable.getDarkModeGrey()
                                                              : Reusable.getWhite(),
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      );
                                                    } else if (snapshot
                                                        .hasError) {
                                                      return Text(
                                                        "Error",
                                                        style: TextStyle(
                                                          color: isDark
                                                              ? Reusable.getDarkModeGrey()
                                                              : Reusable.getWhite(),
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      );
                                                    } else {
                                                      return Text(
                                                        snapshot.data ?? "",
                                                        style: TextStyle(
                                                          color: isDark
                                                              ? Reusable.getDarkModeGrey()
                                                              : Reusable.getWhite(),
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      );
                                                    }
                                                  },
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),

                                  //notification and chat
                                  Row(
                                    children: [
                                      // Icon(
                                      //   Icons.notifications_none_outlined,
                                      //   color: isDark
                                      //       ? Reusable.getDarkModeBlack()
                                      //       : Reusable.getWhite(),
                                      //   size: 30,
                                      // ),
                                      SizedBox(width: 25),
                                      GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return MedicalAssistantScreen();
                                    },
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.health_and_safety_outlined,
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                                size: 30,
                              ),
                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            //space
                            // SizedBox(
                            //   height: Reusable.getDeviceHeight(context, H: 20),
                            // ),

                            // Padding(
                            //   padding: const EdgeInsets.only(left: 20),
                            //   child: Align(
                            //     alignment: Alignment.center,
                            //     child: Stack(
                            //       children: [
                            //         Container(
                            //           height: 50,
                            //           width:
                            //               (MediaQuery.of(context).size.width) -
                            //               40,
                            //           decoration: BoxDecoration(
                            //             color: isDark
                            //                 ? Reusable.getDarkModeGrey()
                            //                 : Reusable.getWhite(),
                            //             borderRadius: BorderRadius.all(
                            //               Radius.circular(25),
                            //             ),
                            //             boxShadow: [
                            //               BoxShadow(
                            //                 color: Color.fromRGBO(
                            //                   0,
                            //                   0,
                            //                   0,
                            //                   0.25,
                            //                 ),
                            //                 spreadRadius: 0,
                            //                 blurRadius: 5,
                            //                 offset: Offset(0, 0),
                            //               ),
                            //             ],
                            //           ),
                            //         ),
                            //         //2 toggle options
                            //         Row(
                            //           children: [
                            //             Padding(
                            //               padding: const EdgeInsets.only(
                            //                 left: 5,
                            //                 top: 5,
                            //                 bottom: 5,
                            //               ),
                            //               //sports mode
                            //               child: GestureDetector(
                            //                 onTap: () {
                            //                   selectedMode = 0;
                            //                   setState(() {});
                            //                 },
                            //                 child: Stack(
                            //                   children: [
                            //                     Container(
                            //                       height: 40,
                            //                       width:
                            //                           (((MediaQuery.of(
                            //                                     context,
                            //                                   ).size.width) -
                            //                                   40) /
                            //                               2) -
                            //                           5,
                            //                       decoration: BoxDecoration(
                            //                         gradient: LinearGradient(
                            //                           colors: [
                            //                             selectedMode == 0
                            //                                 ? isDark
                            //                                       ? Color.fromRGBO(
                            //                                           164,
                            //                                           255,
                            //                                           0,
                            //                                           1,
                            //                                         )
                            //                                       : Color.fromRGBO(
                            //                                           35,
                            //                                           140,
                            //                                           62,
                            //                                           1,
                            //                                         )
                            //                                 : Colors
                            //                                       .transparent,
                            //                             selectedMode == 0
                            //                                 ? isDark
                            //                                       ? Color.fromRGBO(
                            //                                           46,
                            //                                           204,
                            //                                           0,
                            //                                           1,
                            //                                         )
                            //                                       : Color.fromRGBO(
                            //                                           0,
                            //                                           200,
                            //                                           83,
                            //                                           1,
                            //                                         )
                            //                                 : Colors
                            //                                       .transparent,
                            //                           ],
                            //                           begin:
                            //                               Alignment.bottomRight,
                            //                           end: Alignment.topLeft,
                            //                         ),
                            //                         borderRadius:
                            //                             BorderRadius.all(
                            //                               Radius.circular(25),
                            //                             ),
                            //                       ),
                            //                     ),
                            //                     Container(
                            //                       height: 40,
                            //                       width:
                            //                           (((MediaQuery.of(
                            //                                     context,
                            //                                   ).size.width) -
                            //                                   40) /
                            //                               2) -
                            //                           5,
                            //                       child: Align(
                            //                         alignment: Alignment.center,
                            //                         child: Text(
                            //                           _getTranslation(
                            //                             "Sports Mode",
                            //                           ),
                            //                           style: TextStyle(
                            //                             fontSize: 16,
                            //                             fontWeight:
                            //                                 FontWeight.w600,
                            //                             color: selectedMode == 0
                            //                                 ? isDark
                            //                                       ? Reusable.getDarkModeBlack()
                            //                                       : Reusable.getWhite()
                            //                                 : isDark
                            //                                 ? Reusable.getLightGreen()
                            //                                 : Reusable.getGreen(),
                            //                           ),
                            //                         ),
                            //                       ),
                            //                     ),
                            //                   ],
                            //                 ),
                            //               ),
                            //             ),

                            //             // Padding(
                            //             //   padding: const EdgeInsets.only(
                            //             //     right: 5,
                            //             //     top: 5,
                            //             //     bottom: 5,
                            //             //   ),
                            //             //   //gaming mode
                            //             //   child: GestureDetector(
                            //             //     onTap: () {
                            //             //       selectedMode = 1;
                            //             //       setState(() {});
                            //             //     },
                            //             //     child: Stack(
                            //             //       children: [
                            //             //         Container(
                            //             //           height: 40,
                            //             //           width:
                            //             //               (((MediaQuery.of(
                            //             //                         context,
                            //             //                       ).size.width) -
                            //             //                       40) /
                            //             //                   2) -
                            //             //               5,
                            //             //           decoration: BoxDecoration(
                            //             //             gradient: LinearGradient(
                            //             //               colors: [
                            //             //                 selectedMode == 1
                            //             //                     ? Color.fromRGBO(
                            //             //                         0,
                            //             //                         80,
                            //             //                         172,
                            //             //                         1,
                            //             //                       )
                            //             //                     : Colors
                            //             //                           .transparent,
                            //             //                 selectedMode == 1
                            //             //                     ? Color.fromRGBO(
                            //             //                         0,
                            //             //                         183,
                            //             //                         255,
                            //             //                         1,
                            //             //                       )
                            //             //                     : Colors
                            //             //                           .transparent,
                            //             //               ],
                            //             //               begin:
                            //             //                   Alignment.bottomRight,
                            //             //               end: Alignment.topLeft,
                            //             //             ),
                            //             //             borderRadius:
                            //             //                 BorderRadius.all(
                            //             //                   Radius.circular(25),
                            //             //                 ),
                            //             //           ),
                            //             //         ),
                            //             //         Container(
                            //             //           height: 40,
                            //             //           width:
                            //             //               (((MediaQuery.of(
                            //             //                         context,
                            //             //                       ).size.width) -
                            //             //                       40) /
                            //             //                   2) -
                            //             //               5,
                            //             //           child: Align(
                            //             //             alignment: Alignment.center,
                            //             //             child: Text(
                            //             //               _getTranslation(
                            //             //                 "Gaming Mode",
                            //             //               ),
                            //             //               style: TextStyle(
                            //             //                 fontSize: 16,
                            //             //                 fontWeight:
                            //             //                     FontWeight.w600,
                            //             //                 color: selectedMode == 1
                            //             //                     ? Reusable.getWhite()
                            //             //                     : Reusable.getLightBlue(),
                            //             //               ),
                            //             //             ),
                            //             //           ),
                            //             //         ),
                            //             //       ],
                            //             //     ),
                            //             //   ),
                            //             // ),
                            //           ],
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            SizedBox(
                              height: Reusable.getDeviceHeight(context, H: 20),
                            ),
                            //search for sports
                            Container(
                              width: (MediaQuery.of(context).size.width) - 40,
                              height: Reusable.getDeviceHeight(context, H: 60),

                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                style: TextStyle(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getDarkGrey(),
                                ),
                                cursorColor: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                decoration: InputDecoration(
                                  hintText: "Search by Name",
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getTextGrey(),
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
                                    size: Reusable.getDeviceWidth(
                                      context,
                                      W: 30,
                                    ),
                                  ),

                                  // Borders
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
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
                                        ? Reusable.getWhite()
                                        : Reusable.getDarkGrey().withOpacity(0.6),
                                      width: 2,
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

                            //filter & sort
                            SizedBox(
                              height:
                                  (MediaQuery.of(context).size.height) *
                                  0.0215982,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return BookFilterSport();
                                          },
                                        ),
                                      );
                              
                                      if (result != null) {
                                        final selectedSportRaw = result.toString();
                                        final selectedSport = selectedSportRaw.toLowerCase();
                                        final filtered = _allBookTurfCards.where((card) {
                                          final ts = card['turf_sports'];
                                          if (ts == null) return false;
                                          if (ts is String) return ts.toLowerCase().contains(selectedSport);
                                          if (ts is List) return ts.any((e) => e.toString().toLowerCase().contains(selectedSport));
                                          if (ts is Map) return ts.values.any((e) => e.toString().toLowerCase().contains(selectedSport));
                                          return false;
                                        }).toList();
                              
                                        setState(() {
                                          // apply filter list
                                          bookTurfList = filtered;
                                          // remember applied sport for UI
                                          _appliedSportFilter = selectedSportRaw;
                                          // switch to Sports Mode (assumption: sport selection implies sports mode)
                                          selectedMode = 0;
                                        });
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.filter_list,
                                          size: 19,
                                          color: isDark
                                              ? Reusable.getDarkModeBlack()
                                              : Reusable.getWhite(),
                                        ),
                                        Text(
                                          _getTranslation("Filter"),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? Reusable.getDarkModeBlack()
                                                : Reusable.getWhite(),
                                          ),
                                        ),
                                        if (_appliedSportFilter != null) ...[
                                          SizedBox(width: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isDark ? Reusable.getDarkModeGrey() : Colors.white24,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                                                width: 1,
                                              ),
                                            ),
                                            child: Text(
                                              _appliedSportFilter!,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? Reusable.getLightGreen() : Reusable.getBlack(),
                                              ),
                                            ),
                                          ),
                                        ],
                                        SizedBox(width: 25),
                                      ],
                                    ),
                                  ),
                              
                                  GestureDetector(
                                    onTap: () {
                                      showSortOptions(isDark);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.sort,
                                          size: 19,
                                          color: isDark
                                              ? Reusable.getDarkModeBlack()
                                              : Reusable.getWhite(),
                                        ),
                                        Text(
                                          _getTranslation("Sort"),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? Reusable.getDarkModeBlack()
                                                : Reusable.getWhite(),
                                          ),
                                        ),
                                        SizedBox(width: 25),
                                      ],
                                    ),
                                  ),
                              
                                  // Row(
                                  //   children: [
                                  //     Icon(
                                  //       Icons.favorite_border_outlined,
                                  //       size: 19,
                                  //       color: isDark
                                  //           ? Reusable.getDarkModeBlack()
                                  //           : Reusable.getWhite(),
                                  //     ),
                                  //     Text(
                                  //       _getTranslation("Favorites"),
                                  //       style: TextStyle(
                                  //         fontSize: 16,
                                  //         fontWeight: FontWeight.w700,
                                  //         color: isDark
                                  //             ? Reusable.getDarkModeBlack()
                                  //             : Reusable.getWhite(),
                                  //       ),
                                  //     ),
                                  //     SizedBox(width: 25),
                                  //   ],
                                  // ),
                              
                                  // Row(
                                  //   children: [
                                  //     Icon(
                                  //       Icons.discount_outlined,
                                  //       size: 19,
                                  //       color: isDark
                                  //           ? Reusable.getDarkModeBlack()
                                  //           : Reusable.getWhite(),
                                  //     ),
                              
                                  //     SizedBox(width: 25),
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //white bottom sheet
              Positioned(
                top: Reusable.getDeviceHeight(context, H: 220),
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
                  //Available games
                  child: Column(
                    children: [
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 10),
                      ),
                      Text(
                        _getTranslation("Available Turfs"),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getDarkGrey(),
                        ),
                      ),

                      //game cards
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: bookTurfList.length,
                          itemBuilder: (context, listIndex) {
                            final pageController = PageController();
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  // SizedBox(height: 10),
                                  SizedBox(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 10,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return BookTurfInfo(turfInfoMap: bookTurfList[listIndex]['turf_info'],);
                                          },
                                        ),
                                      );
                                    },
                                    child: Container(
                                      
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Reusable.getDarkModeGrey()
                                            : Reusable.getWhite(),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 3,
                                            color: Color.fromRGBO(0, 0, 0, 0.25),
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height:
                                                (MediaQuery.of(
                                                  context,
                                                ).size.height) *
                                                0.01079913,
                                          ),
                                          Container(
                                            height:
                                                (MediaQuery.of(
                                                  context,
                                                ).size.height) *
                                                0.140388,
                                            width:
                                                (MediaQuery.of(
                                                  context,
                                                ).size.width) *
                                                0.859813,
                                            decoration: BoxDecoration(
                                              // color: Colors.black,
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                            child: Stack(
                                              alignment: Alignment.bottomCenter,
                                              children: [
                                                PageView.builder(
                                                  controller: pageController,
                                                  itemCount:
                                                      bookTurfList[listIndex]['images']
                                                          .length,
                                                  itemBuilder: (context, index) {
                                                    // Return the widget for the current page
                                                    return Container(
                                                      decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                            bookTurfList[listIndex]['images'][index],
                                                          ),
                                                          fit: BoxFit.cover,
                                                        ),
                              
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ), // Example color
                                                    );
                                                  },
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(
                                                    bottom: 5,
                                                  ),
                                                  child: SmoothPageIndicator(
                                                    controller: pageController,
                                                    count:
                                                        bookTurfList[listIndex]['images']
                                                            .length,
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
                                              ],
                                            ),
                                          ),
                              
                                          SizedBox(
                                            height:
                                                (MediaQuery.of(
                                                  context,
                                                ).size.height) *
                                                0.01079913,
                                          ),
                              
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                // SizedBox(
                                                //   width:
                                                //       (MediaQuery.of(
                                                //         context,
                                                //       ).size.height) *
                                                //       0.01079913,
                                                // ),
                                                Text(
                                                  _getTranslation(
                                                    bookTurfList[listIndex]['turf_name'],
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getBlack(),
                                                  ),
                                                ),
                              
                                                Row(
                                                  children: [
                                                    Text(
                                                      _getTranslation(
                                                        "${bookTurfList[listIndex]['turf_rating']}",
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isDark
                                                            ? Reusable.getLightGreen()
                                                            : Reusable.getGreen(),
                                                      ),
                                                    ),
                              
                                                    Text(
                                                      _getTranslation(
                                                        "(${bookTurfList[listIndex]['turf_reviews']})",
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: isDark
                                                            ? Reusable.getLightGreen()
                                                            : Reusable.getGreen(),
                                                      ),
                                                    ),
                              
                                                    SizedBox(
                                                      width:
                                                          (MediaQuery.of(
                                                            context,
                                                          ).size.height) *
                                                          0.01079913,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                              
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "${_getTranslation(bookTurfList[listIndex]['location']) + _getTranslation(bookTurfList[listIndex]['distance'])}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Reusable.getLightGrey()
                                                      : const Color.fromRGBO(
                                                          109,
                                                          109,
                                                          109,
                                                          1,
                                                        ),
                                                ),
                                              ),
                                            ),
                                          ),
                              
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                            ),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                _getTranslation(
                                                      "Price Starting From ",
                                                    ) +
                                                    "   ₹" +
                                                    _getTranslation(
                                                      bookTurfList[listIndex]['starting_price'],
                                                    ),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark
                                                      ? Reusable.getLightGreen()
                                                      : Reusable.getBlack(),
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                        ],
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
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_translationsCache.isEmpty || bookTurfList.isEmpty)
                const Positioned.fill(child: UserLoaderScreen()),
            ],
          ),
        );
      },
    );
  }

  var selectedOption = "Price";
  void _sortByPrice() {
    setState(() {
      bookTurfList.sort((a, b) {
        final na = _parsePrice(a['starting_price']);
        final nb = _parsePrice(b['starting_price']);
        return na.compareTo(nb);
      });
    });
  }

  void _sortByDistance() {
    setState(() {
      bookTurfList.sort((a, b) {
        final da = _parseDistance(a['distance']);
        final db = _parseDistance(b['distance']);
        return da.compareTo(db);
      });
    });
  }

  num _parsePrice(dynamic p) {
    if (p == null) return double.infinity;
    if (p is num) return p;
    final s = p.toString();
    final cleaned = s.replaceAll(RegExp(r"[^0-9.]"), "");
    final v = num.tryParse(cleaned);
    return v ?? double.infinity;
  }

  num _parseDistance(dynamic d) {
    if (d == null) return double.infinity;
    final s = d.toString();
    final m = RegExp(r'([0-9]+(?:\.[0-9]+)?)').firstMatch(s);
    if (m != null) return num.parse(m.group(1)!);
    return double.infinity;
  }

  void showSortOptions(bool isDark) {
    // Default role

    showModalBottomSheet(
      backgroundColor: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Reusable.getDeviceWidth(context, W: 30)),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          // Allows updating UI inside bottom sheet
          builder: (context, setStateBottom) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    _getTranslation("Sort By"),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Reusable.getLightGreen() : Reusable.getBlack(),
                    ),
                  ),

                  SizedBox(height: 10),

                  // 🔹 Radio Button: Price
                  RadioListTile<String>(
                    title: Text(
                      _getTranslation("Price"),
                      style: TextStyle(
                        color: isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
                      ),
                    ),
                    value: "Price",
                    activeColor: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setStateBottom(() {
                        selectedOption = value!;
                      });
                      _sortByPrice();
                      Navigator.of(context).pop(); // update parent state
                    },
                  ),

                  // 🔹 Radio Button: Distance
                  RadioListTile<String>(
                    title: Text(
                      _getTranslation("Distance"),
                      style: TextStyle(
                        color: isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
                      ),
                    ),
                    value: "Distance",
                    activeColor: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setStateBottom(() {
                        selectedOption = value!;
                      });
                      _sortByDistance();
                      Navigator.of(context).pop();
                    },
                  ),

                  SizedBox(height: 16),

                  // Submit button
                ],
              ),
            );
          },
        );
      },
    );
  }
}
