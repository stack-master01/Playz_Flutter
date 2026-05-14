import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/User_Controller/User_Friend_List_Controller.dart';
import 'package:playz_user/Controller/User_Controller/User_Group_Chat_Controller.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/home(sport)/homepage(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:playz_user/View/user_view/trainer(sport)/Trainer_Chat.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class TrainerInfo extends StatefulWidget {
  Map<String, dynamic> trainerDataMap = {};

  TrainerInfo({super.key, required this.trainerDataMap});

  @override
  State<TrainerInfo> createState() => _TrainerInfoState();
}

class _TrainerInfoState extends State<TrainerInfo> {
  Map<String, dynamic> currentTrainerDataMap = {};
  String finalSelectedSport = "";
  int _currentRating = 0;
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _reportController = TextEditingController();
  bool _isSubmittingReview = false;
  bool _isSubmittingReport = false;

  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  // NOTE: turfInfo is empty here, but included for completeness of the provided logic structure.
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "25 people Interested",
      "Chris Bumstead",
      """5x Mr. Olympia Classic Physique champion, known for disciplined training, strict form, and motivating athletes to achieve peak performance.""",
      "Fitness Trainer",
      "About Chris Bumstead",
      "Renowned 5x Mr. Olympia Classic Physique champion, known for his dedication and structured training style. He guides athletes with a focus on strength, symmetry, and consistency, encouraging him to train smart, stay disciplined, and reach his full potential. His philosophy blends physical training with mental resilience, making him a complete fitness mentor.",
      "About the Sessions",
      "Monday, Tuesday, Wednesday, Thursday, Friday, Saturday",
      "Adults, Kids",
      "1-on-1 Classes, Group Classes, Online Classes",
      "Koregaon Park, Pune, Maharashtra, India",
      "Fee & Packages",
      "INR 10000/- per month",
      "CONNECT",
      "rupees", // Used in the commented-out translator example
      // END: Add default english text here
    };

    // Add dynamic keys from sportsAvailable
    for (var sport in sportsAvailable) {
      if (sport['sport'] is String) {
        keys.add(sport['sport'] as String);
      }
    }
    // Add dynamic keys from amenitiesAvailable
    for (var amenity in amenitiesAvailable) {
      if (amenity['facility'] is String) {
        keys.add(amenity['facility'] as String);
      }
    }
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    String? selected = await Appsharedpreferences().loadSelectedCity();
    selectedLocationNotifier.value = selected;
    log("city in home page: $selected");
    setState(() {
      selectedLocation = selected;
    });
  }
  // ===================================================================

  final PageController pageController = PageController();

  List<String> bookTurfList = [
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSihcmNMpJiXeA09ZUxex8OsTxdr9oXmqxH9A&s",
    "https://images.unsplash.com/photo-1503515091255-ab8063a1796d?fm=jpg&q=60&w=3000&ixlib=rb-4.1.4&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTB8fGZvb3RiYWls%20turf%7C%7C%7C",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZJivXheMQk7jaKLzSAEZJvOl8mx_Dsx1_bhNM0Q4Yrx4_buRHZWPaaVEiP9JlhJjlUvY&usqp=CAU",
  ];

  List<Map<String, dynamic>> sportsAvailable = [
    {"icon": Icons.sports_cricket_outlined, "sport": "CRICKET"},
    {"icon": Icons.sports_soccer_outlined, "sport": "FOOTBALL"},
    {"icon": Icons.sports_tennis_outlined, "sport": "TENNIS"},
  ];

  List<Map<String, dynamic>> amenitiesAvailable = [
    {"icon": Icons.local_parking_outlined, "facility": "PARKING"},
    {"icon": Icons.water_drop_outlined, "facility": "DRINKING WATER"},
    {"icon": Icons.wc_outlined, "facility": "RESTROOM"},
  ];
  Map<String, dynamic> allStudentsMap = {};
  List<dynamic> allStudentsList = [];
  Future<void> loadAllStudents() async {
    final students = await _firestore
        .collection("Turf_Trainer")
        .doc(currentTrainerDataMap['trainer_data']['email'])
        .collection("Students_List")
        .doc("All_Emails")
        .get();

    allStudentsMap = students.data() ?? {};
    allStudentsList = allStudentsMap['student_emails'];
    setState(() {});
    log("All Students: ${allStudentsList}");
  }

  String currentUserEmail = "";

  Future<void> loadCurrentEmail() async {
    UserSettings userSettings = await UserSettings().loadSettings();
    currentUserEmail = userSettings.email ?? "email";
    if (mounted) {
      setState(() {
        currentUserEmail = userSettings.email ?? "email";
        ;
      });
    }
    log("Current user: ${currentUserEmail}");
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

  // Bottom sheet to submit a report map to the trainer's Profile_Data doc
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

                        // Build report object with message, server timestamp, username and email
                        Map<String, dynamic> report = {
                          'message': msg,
                          'reported_at': FieldValue.serverTimestamp(),
                        };

                        try {
                          // mark submitting so UI shows progress
                          setStateBottom(() {
                            _isSubmittingReport = true;
                          });
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

                          // trainer email
                          final String trainerEmail = (currentTrainerDataMap['trainer_data'] ?? {})['email'] ?? currentTrainerDataMap['email'] ?? '';
                          if (trainerEmail.isEmpty) {
                            Navigator.of(context).pop();
                            return;
                          }

                          final docRef = _firestore
                              .collection('Turf_Trainer')
                              .doc(trainerEmail)
                              .collection('Trainer_Data')
                              .doc('Profile_Data');

                          // Use a transaction to append the report atomically.
                          await _firestore.runTransaction((transaction) async {
                            // Use set with merge inside transaction so doc is created if missing
                            transaction.set(
                              docRef,
                              {
                                'violation_history': FieldValue.arrayUnion([report])
                              },
                              SetOptions(merge: true),
                            );
                          });

                          setStateBottom(() {
                            _isSubmittingReport = false;
                          });

                          Navigator.of(context).pop(); // close sheet
                          _reportController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_getTranslation("Report sent successfully"))),
                          );
                        } catch (e) {
                          setStateBottom(() {
                            _isSubmittingReport = false;
                          });
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
                          color: (isDark ? Reusable.getLightGreen() : Reusable.getGreen()).withOpacity(_isSubmittingReport ? 0.8 : 1.0),
                          borderRadius: BorderRadius.circular(Reusable.getDeviceWidth(context, W: 30)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSubmittingReport) ...[
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()),
                                  strokeWidth: 2.0,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                _getTranslation("SENDING..."),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
                                ),
                              ),
                            ] else ...[
                              Text(
                                _getTranslation("SEND REPORT"),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
                                ),
                              ),
                            ]
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

  // Review + rating bottom sheet (reference-style)
  void showReviewAndRatingSheet(bool isDark) {
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
                  children: [
                    Text(
                      _getTranslation("Rate and Review"),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Reusable.getLightGreen() : Reusable.getBlack(),
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
                              _currentRating = index + 1;
                            });
                          },
                          child: Icon(
                            Icons.star,
                            size: Reusable.getDeviceWidth(context, W: 40),
                            color: index < _currentRating ? Colors.amber : Reusable.getLightGrey(),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: Reusable.getDeviceHeight(context, H: 20)),

                    // Review Text Field
                    TextField(
                      controller: _reviewController,
                      maxLines: 4,
                      style: TextStyle(
                        color: isDark ? Reusable.getWhite() : Reusable.getBlack(),
                      ),
                      cursorColor: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                      decoration: InputDecoration(
                        hintText: _getTranslation("Write your review here..."),
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
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Reusable.getDeviceWidth(context, W: 10)),
                          borderSide: BorderSide(
                            color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(Reusable.getDeviceWidth(context, W: 10)),
                          borderSide: BorderSide(
                            color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                            width: 2.0,
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

                        if (_currentRating == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_getTranslation("Please select a rating"))),
                          );
                          return;
                        }

                        // Build review map
                        Map<String, dynamic> review = {
                          'message': msg,
                          'stars': _currentRating,
                        };

                        try {
                          // mark submitting so bottom-sheet shows progress
                          setStateBottom(() {
                            _isSubmittingReview = true;
                          });
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

                          final String trainerEmail = (currentTrainerDataMap['trainer_data'] ?? {})['email'] ?? currentTrainerDataMap['email'] ?? '';
                          if (trainerEmail.isEmpty) {
                            Navigator.of(context).pop();
                            return;
                          }

                          final docRef = _firestore
                              .collection('Turf_Trainer')
                              .doc(trainerEmail)
                              .collection('Trainer_Data')
                              .doc('Profile_Data');

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
                                  final prevAvg = data['average_stars'];
                                  final prevCount = data['total_reviews'];
                                  final prevAvgD = (prevAvg is num) ? prevAvg.toDouble() : 0.0;
                                  final prevCountI = (prevCount is int) ? prevCount : (prevCount is num ? prevCount.toInt() : 0);
                                  final sum = prevAvgD * prevCountI + _currentRating.toDouble();
                                  final count = prevCountI + 1;
                                  if (count > 0) averageStars = sum / count;
                                } else {
                                  averageStars = _currentRating.toDouble();
                                }
                              }
                            }
                          } catch (e) {
                            averageStars = _currentRating.toDouble();
                          }

                          // Perform an atomic transaction to append the review, increment count and update average
                          await _firestore.runTransaction((transaction) async {
                            final snap = await transaction.get(docRef);
                            double computedAvg = averageStars; // default computed above

                            if (snap.exists) {
                              final data = snap.data();
                              if (data != null) {
                                // Prefer using total_reviews and average_stars if available
                                final prevAvg = data['average_stars'];
                                final prevCount = data['total_reviews'];
                                if (prevAvg is num && prevCount is num) {
                                  final prevAvgD = prevAvg.toDouble();
                                  final prevCountI = prevCount.toInt();
                                  computedAvg = (prevAvgD * prevCountI + _currentRating.toDouble()) / (prevCountI + 1);
                                } else if (data['reviews'] is List) {
                                  // fallback to iterating reviews list
                                  final existingReviews = data['reviews'] as List;
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
                                  sum += _currentRating.toDouble();
                                  count += 1;
                                  if (count > 0) computedAvg = sum / count;
                                } else {
                                  computedAvg = _currentRating.toDouble();
                                }
                              }
                            }

                            transaction.set(
                              docRef,
                              {
                                'reviews': FieldValue.arrayUnion([review]),
                                'total_reviews': FieldValue.increment(1),
                                'average_stars': computedAvg,
                              },
                              SetOptions(merge: true),
                            );
                          });

                          setStateBottom(() {
                            _isSubmittingReview = false;
                          });

                          Navigator.of(context).pop(); // Close sheet
                          setState(() {
                            _currentRating = 0;
                            _reviewController.clear();
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_getTranslation("Review submitted"))),
                          );
                        } catch (e) {
                          setStateBottom(() {
                            _isSubmittingReview = false;
                          });
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
                          color: (isDark ? Reusable.getLightGreen() : Reusable.getGreen()).withOpacity(_isSubmittingReview ? 0.8 : 1.0),
                          borderRadius: BorderRadius.circular(Reusable.getDeviceWidth(context, W: 30)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSubmittingReview) ...[
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()),
                                  strokeWidth: 2.0,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                _getTranslation("SUBMITTING..."),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
                                ),
                              ),
                            ] else ...[
                              Text(
                                _getTranslation("SUBMIT REVIEW"),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
                                ),
                              ),
                            ]
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
  @override
  void initState() {
    super.initState();
    _setupBanMonitoring();
    currentTrainerDataMap = widget.trainerDataMap;
    loadCurrentEmail();
    loadAllStudents();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

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
    pageController.dispose();
    _razorpay.clear();
    _reviewController.dispose();
    _reportController.dispose();
    _banSubscription?.cancel();
    super.dispose();
  }

  // Helper to extract session days string
  String _getSessionDays(Map<String, dynamic> trainerData) {
    final sessionDays = trainerData['session_days'] as Map<String, dynamic>?;
    if (sessionDays == null) return "N/A";

    final activeDays = sessionDays.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (activeDays.isEmpty) return "No regular days set";
    return activeDays.join(', ');
  }

  // Helper to extract session types string
  String _getSessionTypes(Map<String, dynamic> trainerData) {
    final sessionTypes = trainerData['session_types'] as Map<String, dynamic>?;
    if (sessionTypes == null) return "N/A";

    final activeTypes = sessionTypes.entries
        .where((entry) => entry.value == true)
        .map((entry) => entry.key)
        .toList();

    if (activeTypes.isEmpty) return "No specific session types set";
    return activeTypes.join(', ');
  }

  String chatID = "";

  String generateChatRoomId({
    required String currentUserId,
    required String otherUserId,
  }) {
    // 1. Create a list of the two IDs
    List<String> userIds = [currentUserId, otherUserId];

    // 2. Sort the list alphabetically (lexicographically)
    userIds.sort(); // This ensures the smaller ID always comes first.

    // 3. Join them with a consistent separator
    // The result will ALWAYS be "smallerId_largerId"
    return userIds.join('_');
  }

  late Razorpay _razorpay;
  bool _navigated = false; // Prevent double navigation

  void openCheckout({required double amount}) {
    var options = {
      'key': 'rzp_test_RRLNbb21SHGawp',
      'amount': amount,
      'name': 'Coaching Payment',
      'description': 'Test transaction',
      'prefill': {'contact': '9876543210', 'email': 'test@example.com'},
      'external': {
        'wallets': ['paytm', 'phonepe', 'amazonpay'],
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
    }
  }

  Future<void> setConnectionWithTrainer() async {
    UserSettings userSettings = await UserSettings().loadSettings();
    try {
      await _firestore
          .collection("Turf_Trainer")
          .doc(currentTrainerDataMap['trainer_data']['email'])
          .collection("Students_List")
          .doc("All_Emails")
          .set({
            "student_emails": FieldValue.arrayUnion([userSettings.email]),
          }, SetOptions(merge: true));
      final groupMessage = UserGroupChatController().createGroupChatObject(
        created_at: DateTime.timestamp(),
        from_id: userSettings.email!,
        from_name: userSettings.userName ?? "Anonymous",
        image_url: "image_url",
        is_image: false,
        text: "Hey, There!",
      );
      chatID = generateChatRoomId(
        currentUserId: currentTrainerDataMap['trainer_data']['email'],
        otherUserId: userSettings.email!,
      );
      UserGroupChatController().uploadGroupChat(
        groupMessage,
        groupId: "$chatID",
      );
      currentTrainerDataMap['trainer_data']['groupID'] = chatID;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return TrainerChat(groupDataMap: currentTrainerDataMap);
          },
        ),
      );

      await _firestore
          .collection("Turf_Trainer")
          .doc(currentTrainerDataMap['trainer_data']['email'])
          .collection("Students_List")
          .doc(finalSelectedSport)
          .set(
      {
        'student_list': FieldValue.arrayUnion([{
          "image_url": userSettings.imageURL,
          "student_email":userSettings.email,
          "student_name":userSettings.userName
        }]),
      },
      SetOptions(merge: true), // Ensures document fields are not overwritten
    );
    } on FirebaseFirestore catch (e) {
      log("Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment success with ID: ${response.paymentId}');
    if (!_navigated) {
      _navigated = true;
      setConnectionWithTrainer();
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment failed: ${response.message}');
    // if (!_navigated) {
    //   _navigated = true;
    //   navigatorKey.currentState?.push(
    //     MaterialPageRoute(
    //       builder: (_) => RazorSuccessPage(),
    //     ),
    //   );
    // }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('⚠️ External wallet selected: ${response.walletName}');
    // if (!_navigated) {
    //   _navigated = true;
    //   navigatorKey.currentState?.push(
    //     MaterialPageRoute(
    //       builder: (_) => RazorSuccessPage(),
    //     ),
    //   );
    // }
  }

  // Place this method inside the _CoachStudentsScreenState class or any StatefulWidget's State class.

  /// Displays a modal bottom sheet allowing the user to select a sport.
  ///
  /// The bottom sheet title is "Select a Sport".
  /// The provided list of [sports] is displayed as interactive buttons.
  ///
  /// [context] is the current BuildContext.
  /// [sports] is the list of sport names (Strings) to display.
  /// Returns the selected sport (String) or null if the sheet is dismissed.
  Future<String?> showSportSelectionSheet(
    double sessionChargesDouble,
    BuildContext context,
    List<dynamic> sports,
  ) async {
    final theme = Theme.of(context);

    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true, // Allows content to take up more space
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        final bool isDarkSheet = Theme.of(sheetContext).brightness == Brightness.dark;
        final Color sheetBg = isDarkSheet ? Reusable.getDarkModeGrey() : Reusable.getWhite();
        final Color titleColor = isDarkSheet ? Reusable.getWhite() : Reusable.getBlack();
        final Color primaryButtonBg = isDarkSheet ? Reusable.getLightGreen() : Reusable.getGreen();
        final Color primaryButtonText = isDarkSheet ? Reusable.getDarkModeBlack() : Reusable.getWhite();

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Essential for bottom sheet height
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 1. Title
                    Text(
                      "Select a Sport",
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 15),
            
                    // 2. Buttons List
                    // Use Wrap for flow layout if there are many sports
                    Wrap(
                      spacing: 10.0, // horizontal spacing
                      runSpacing: 10.0, // vertical spacing
                      children: sports.map((sport) {
                        return ElevatedButton(
                          onPressed: () {
                            // ⭐️ Key Action: Close the sheet and return the selected sport
                            Navigator.of(sheetContext).pop(sport);
            
                            openCheckout(amount: sessionChargesDouble * 100);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryButtonBg,
                            foregroundColor: primaryButtonText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            sport,
                            style: TextStyle(fontWeight: FontWeight.w600, color: primaryButtonText),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
            // SizedBox(height: 20,)
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Directly treat the value under 'trainer_data' as the trainer Map.
    final Map<String, dynamic> trainer =
        currentTrainerDataMap['trainer_data'] is Map<String, dynamic>
        ? currentTrainerDataMap['trainer_data'] as Map<String, dynamic>
        : (currentTrainerDataMap.isNotEmpty
              ? currentTrainerDataMap
              : {}); // Fallback

    // Extract needed data fields
    final String trainerName = trainer['trainer_name'] ?? 'Trainer Name N/A';
    final String trainerAbout = trainer['about'] ?? 'No description provided.';

    // Safely extract the list of images
    final List<dynamic> trainerImages = trainer['trainer_images'] is List
        ? trainer['trainer_images'] as List<dynamic>
        : [];

    final String trainerImage = trainerImages.isNotEmpty
        ? trainerImages[0] as String
        : 'https://via.placeholder.com/150'; // Placeholder image

    final String sessionDaysString = _getSessionDays(trainer);
    final String sessionTypesString = _getSessionTypes(trainer);
    final String sessionTypeRegular =
        trainer['sessions'] ?? 'Regular Sessions N/A';

    final String locationAddress = trainer['location'] != null
        ? (trainer['location']['address']?.isNotEmpty == true
              ? trainer['location']['address']
              : 'Location Address N/A')
        : 'Location N/A';

    // ✅ FIX: Safely parse session_charges as a String or a num, and convert it to num.
    num sessionCharges = 0;
    final dynamic rawCharges = trainer['session_charges'];
    if (rawCharges is num) {
      sessionCharges = rawCharges;
    } else if (rawCharges is String) {
      // Attempt to parse the string as an integer or double
      sessionCharges = num.tryParse(rawCharges) ?? 0;
    } else {
      sessionCharges = 0; // Default if null or unexpected type
    }

    final String sessionChargesString =
        "INR ${sessionCharges.toStringAsFixed(0)}/- per month"; // Using toStringAsFixed(0) to ensure no decimals if it was an int

    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          backgroundColor: isDark
              ? Reusable.getDarkModeBlack()
              : Reusable.getWhite(),
          body: Stack(
            children: [
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  //scroll this column
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Reusable.getWhite(),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(
                            Reusable.getDeviceWidth(context, W: 20),
                          ),
                          bottomRight: Radius.circular(
                            Reusable.getDeviceWidth(context, W: 20),
                          ),
                        ),
                      ),
                      height: Reusable.getDeviceHeight(
                        context,
                        H: 250,
                      ), // ✅ Give height to PageView
                      child: Stack(
                        // clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          PageView.builder(
                            controller: pageController,
                            // ✅ Use the safely extracted list
                            itemCount: trainerImages.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(
                                    Reusable.getDeviceWidth(context, W: 20),
                                  ),
                                  bottomRight: Radius.circular(
                                    Reusable.getDeviceWidth(context, W: 20),
                                  ),
                                ),
                                child: Image.network(
                                  // ✅ Use the safely extracted list
                                  trainerImages[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              );
                            },
                          ),
                          Positioned(
                            bottom: 40,
                            child: SmoothPageIndicator(
                              controller: pageController,
                              // ✅ Use the safely extracted list
                              count: trainerImages.length,
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
                          Padding(
                            padding: EdgeInsets.only(
                              left: Reusable.getDeviceWidth(context, W: 20),
                              top: Reusable.getDeviceHeight(context, H: 40),
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
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
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 3,
                                        color: Color.fromRGBO(0, 0, 0, 0.25),
                                        offset: Offset(0, 0),
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
                          allStudentsList.contains(currentUserEmail)
                              ? Padding(
                                  padding: EdgeInsets.only(
                                    right: Reusable.getDeviceWidth(
                                      context,
                                      W: 20,
                                    ),
                                    top: Reusable.getDeviceHeight(
                                      context,
                                      H: 40,
                                    ),
                                  ),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop();
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
                                          boxShadow: const [
                                            BoxShadow(
                                              blurRadius: 3,
                                              color: Color.fromRGBO(
                                                0,
                                                0,
                                                0,
                                                0.25,
                                              ),
                                              offset: Offset(0, 0),
                                            ),
                                          ],
                                          color: isDark
                                              ? Reusable.getDarkModeBlack()
                                              : Reusable.getWhite(),
                                          borderRadius: BorderRadius.circular(
                                            Reusable.getDeviceWidth(
                                              context,
                                              W: 20,
                                            ),
                                          ),
                                        ),
                                        child: GestureDetector(
                                          onTap: () async {
                                            UserSettings userSettings =
                                                await UserSettings()
                                                    .loadSettings();
                                            chatID = generateChatRoomId(
                                              currentUserId:
                                                  currentTrainerDataMap['trainer_data']['email'],
                                              otherUserId: userSettings.email!,
                                            );

                                            currentTrainerDataMap['trainer_data']['groupID'] =
                                                chatID;
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (context) {
                                                  return TrainerChat(
                                                    groupDataMap:
                                                        currentTrainerDataMap,
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                          child: Icon(
                                            Icons.chat_outlined,
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
                                )
                              : SizedBox(),
                          Positioned(
                            top: Reusable.getDeviceHeight(context, H: 220),
                            child: Column(
                              children: [
                                Container(
                                  // height: Reusable.getDeviceHeight(context, H: 366),
                                  width: Reusable.getDeviceWidth(
                                    context,
                                    W: 390,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        Reusable.getDeviceWidth(context, W: 10),
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: Reusable.getDeviceHeight(
                                          context,
                                          H: 7,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            _getTranslation(
                                              "25 people Interested",
                                            ), // 🌍 Translated
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
                                      SizedBox(
                                        height: Reusable.getDeviceHeight(
                                          context,
                                          H: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          // height: Reusable.getDeviceHeight(context, H: 366),
                          width: Reusable.getDeviceWidth(context, W: 390),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getGreen(),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(
                                Reusable.getDeviceWidth(context, W: 10),
                              ),
                              bottomRight: Radius.circular(
                                Reusable.getDeviceWidth(context, W: 10),
                              ),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: Reusable.getDeviceHeight(context, H: 7),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [],
                              ),
                              SizedBox(
                                height: Reusable.getDeviceHeight(context, H: 5),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: Reusable.getDeviceWidth(context, W: 5),
                                  right: Reusable.getDeviceWidth(context, W: 5),
                                  bottom: Reusable.getDeviceHeight(
                                    context,
                                    H: 5,
                                  ),
                                ),
                                child: Container(
                                  // height: Reusable.getDeviceHeight(
                                  // context,
                                  // H: 318,
                                  // ),
                                  width: Reusable.getDeviceWidth(
                                    context,
                                    W: 380,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        Reusable.getDeviceWidth(context, W: 5),
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: Reusable.getDeviceHeight(
                                          context,
                                          H: 15,
                                        ),
                                      ),
                                      SizedBox(
                                        height: Reusable.getDeviceHeight(
                                          context,
                                          H: 70,
                                        ),
                                        width: Reusable.getDeviceWidth(
                                          context,
                                          W: 70,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 35,
                                              ),
                                            ),
                                          ),
                                          child: Image.network(
                                            trainerImage,
                                            fit: BoxFit.cover,
                                          ),
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
                                          trainerName,
                                        ), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 16,
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
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: Reusable.getDeviceWidth(
                                            context,
                                            W: 10,
                                          ),
                                          right: Reusable.getDeviceWidth(
                                            context,
                                            W: 10,
                                          ),
                                        ),
                                        child: Text(
                                          _getTranslation(
                                            trainerAbout,
                                          ), // 🌍 Translated (Using trainer about)
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: isDark
                                                ? Reusable.getLightGrey()
                                                : Reusable.getDarkGrey(),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),

                                      SizedBox(
                                        height: Reusable.getDeviceHeight(
                                          context,
                                          H: 5,
                                        ),
                                      ),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: Reusable.getDeviceWidth(
                                              context,
                                              W: 30,
                                            ),
                                            color: Colors.amber,
                                          ),
                                          SizedBox(
                                            width: Reusable.getDeviceWidth(
                                              context,
                                              W: 5,
                                            ),
                                          ),
                                          Text(
                                            "4.5", // Rating is typically not translated
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              color: isDark
                                                  ? Reusable.getLightGreen()
                                                  : Reusable.getGreen(),
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

                                      Divider(
                                        color: isDark
                                            ? Reusable.getLightGrey()
                                            : const Color.fromRGBO(
                                                81,
                                                81,
                                                81,
                                                0.3,
                                              ),
                                        thickness: 1,
                                        indent: 20,
                                        endIndent: 20,
                                      ),

                                      Text(
                                        _getTranslation(
                                          "${currentTrainerDataMap['trainer_data']?['sports'] is List ? (currentTrainerDataMap['trainer_data']['sports'] as List).join(', ') : 'Not Specified'}",
                                        ), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w400,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getDarkGrey(),
                                        ),
                                      ),

                                      SizedBox(
                                        height: Reusable.getDeviceHeight(
                                          context,
                                          H: 5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),
                        Container(
                          // height: Reusable.getDeviceHeight(context, H: 366),
                          width: Reusable.getDeviceWidth(context, W: 390),
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 3,
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                              ),
                            ],
                            color: isDark
                                ? Reusable.getDarkModeGrey()
                                : Reusable.getWhite(),
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                Reusable.getDeviceWidth(context, W: 10),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: Reusable.getDeviceWidth(context, W: 15),
                              right: Reusable.getDeviceWidth(context, W: 15),
                              top: Reusable.getDeviceHeight(context, H: 10),
                              bottom: Reusable.getDeviceHeight(context, H: 10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTranslation(
                                    "About Chris Bumstead",
                                  ), // 🌍 Translated (using placeholder)
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
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
                                    trainerAbout,
                                  ), // 🌍 Translated (Using trainer about)
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),
                        Container(
                          // height: Reusable.getDeviceHeight(context, H: 366),
                          width: Reusable.getDeviceWidth(context, W: 390),
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 3,
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                              ),
                            ],
                            color: isDark
                                ? Reusable.getDarkModeGrey()
                                : Reusable.getWhite(),
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                Reusable.getDeviceWidth(context, W: 10),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: Reusable.getDeviceWidth(context, W: 15),
                              right: Reusable.getDeviceWidth(context, W: 15),
                              top: Reusable.getDeviceHeight(context, H: 10),
                              bottom: Reusable.getDeviceHeight(context, H: 10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTranslation(
                                    "About the Sessions",
                                  ), // 🌍 Translated
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
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
                                        W: 15,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _getTranslation(
                                          sessionDaysString,
                                        ), // ✅ Session Days
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: isDark
                                              ? Reusable.getLightGrey()
                                              : Reusable.getDarkGrey(),
                                        ),
                                        textAlign: TextAlign.left,
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
                                      Icons.supervisor_account_outlined,
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
                                        W: 15,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _getTranslation(
                                          sessionTypesString,
                                        ), // ✅ Adults, Kids, Women only
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: isDark
                                              ? Reusable.getLightGrey()
                                              : Reusable.getDarkGrey(),
                                        ),
                                        textAlign: TextAlign.left,
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
                                      Icons.co_present,
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
                                        W: 15,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _getTranslation(
                                          sessionTypeRegular,
                                        ), // ✅ Regular Session Type
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: isDark
                                              ? Reusable.getLightGrey()
                                              : Reusable.getDarkGrey(),
                                        ),
                                        textAlign: TextAlign.left,
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
                                        W: 15,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        _getTranslation(
                                          locationAddress,
                                        ), // ✅ Location
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: isDark
                                              ? Reusable.getLightGrey()
                                              : Reusable.getDarkGrey(),
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),
                        Container(
                          // height: Reusable.getDeviceHeight(context, H: 366),
                          width: Reusable.getDeviceWidth(context, W: 390),
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 3,
                                color: Color.fromRGBO(0, 0, 0, 0.3),
                              ),
                            ],
                            color: isDark
                                ? Reusable.getDarkModeGrey()
                                : Reusable.getWhite(),
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                Reusable.getDeviceWidth(context, W: 10),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: Reusable.getDeviceWidth(context, W: 15),
                              right: Reusable.getDeviceWidth(context, W: 15),
                              top: Reusable.getDeviceHeight(context, H: 10),
                              bottom: Reusable.getDeviceHeight(context, H: 10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTranslation(
                                    "Fee & Packages",
                                  ), // 🌍 Translated
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
                                  ),
                                ),

                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 15,
                                  ),
                                ),

                                Text(
                                  _getTranslation(
                                    sessionChargesString,
                                  ), // ✅ Price (Now using safely parsed num)
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 30),
                        ),
                        allStudentsList.contains(currentUserEmail)
                            ? SizedBox()
                            : GestureDetector(
                                onTap: () async {
                                  // friendData = UserFriendListController()
                                  // .createFriendObject(
                                  // email:
                                  // _searchResults[index]['email'],
                                  // image_url:
                                  // _searchResults[index]['image'],
                                  // name:
                                  // _searchResults[index]['member_name'],
                                  // );
                                  // Map<String, dynamic>
                                  // friendList = {
                                  // "friend_list": [
                                  // friendData,
                                  // ],
                                  // };

                                  // UserSettings userSettings = await UserSettings()
                                  //     .loadSettings();
                                  // final groupMessage = UserGroupChatController()
                                  //     .createGroupChatObject(
                                  //       created_at: DateTime.timestamp(),
                                  //       from_id: userSettings.email!,
                                  //       from_name:
                                  //           userSettings.userName ?? "Anonymous",
                                  //       image_url: "image_url",
                                  //       is_image: false,
                                  //       text: "Hey, There!",
                                  //     );
                                  // chatID = generateChatRoomId(
                                  //   currentUserId:
                                  //       currentTrainerDataMap['trainer_data']['email'],
                                  //   otherUserId: userSettings.email!,
                                  // );
                                  // UserGroupChatController().uploadGroupChat(
                                  //   groupMessage,
                                  //   groupId: "$chatID",
                                  // );
                                  // currentTrainerDataMap['trainer_data']['groupID'] =
                                  //     chatID;
                                  // Navigator.of(context).push(
                                  //   MaterialPageRoute(
                                  //     builder: (context) {
                                  //       return TrainerChat(
                                  //         groupDataMap: currentTrainerDataMap,
                                  //       );
                                  //     },
                                  //   ),
                                  // );
                                  // Safely extract the raw value from the map
                                  final dynamic rawCharges =
                                      trainer['session_charges'];

                                  double sessionChargesDouble = 0.0;

                                  if (rawCharges != null) {
                                    final String chargesString = rawCharges
                                        .toString();

                                    sessionChargesDouble =
                                        double.tryParse(chargesString) ?? 0.0;
                                  }

                                  // openCheckout(amount: sessionChargesDouble * 100);
                                  finalSelectedSport =
                                      (await showSportSelectionSheet(
                                        sessionChargesDouble,
                                        context,
                                        currentTrainerDataMap['trainer_data']?['sports'],
                                      ))!;
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _getTranslation(
                                          "CONNECT",
                                        ), // 🌍 Translated
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
                              SizedBox(height: 20,),
                        // Row with Report and Review buttons
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Reusable.getDeviceWidth(context, W: 10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: Reusable.getDeviceWidth(context, W: 170),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
                                    side: BorderSide(
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getGreen(),
                                    ),
                                  ),
                                  onPressed: () => showReportSheet(isDark),
                                  child: Text(_getTranslation('Report')),
                                ),
                              ),
                              SizedBox(
                                width: Reusable.getDeviceWidth(context, W: 170),
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getWhite(),
                                    backgroundColor:
                                        isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                                  ),
                                  onPressed: () => showReviewAndRatingSheet(isDark),
                                  child: Text(_getTranslation('Review')),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 60),
                        ),
                      ],
                    ),
                  ],
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
