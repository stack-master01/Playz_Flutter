import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/AI_Chat.dart';
import 'package:playz_user/View/user_view/Banned_Screen.dart';
import 'package:playz_user/View/user_view/Medical_Assistant.dart';
import 'package:playz_user/View/user_view/book(sports)/book(sport).dart';
import 'package:playz_user/View/user_view/home(sport)/Bookings/Bookings(sport).dart';
import 'package:playz_user/View/user_view/home(sport)/Friends/Friends(sport).dart';
import 'package:playz_user/View/user_view/home(sport)/Groups/groups(sports).dart';
import 'package:playz_user/View/user_view/home(sport)/scoreboard/scoreboard.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';

Future<StreamSubscription<DocumentSnapshot>> startBanMonitoring({
  required BuildContext context,
  required FirebaseFirestore firestoreInstance,
}) async {
  // 1. Load user settings to get the document ID (email)
  UserSettings userSettings = await UserSettings().loadSettings();

  // 2. Return the stream subscription
  return firestoreInstance
      .collection("Turf_User")
      .doc(userSettings.email)
      .snapshots() // Continuous stream
      .listen(
        (userDoc) {
          final userMap = userDoc.data();
          final bool isBanned = userMap?['isBanned'] as bool? ?? false;

          log("Reused Ban Monitor Stream: isBanned = $isBanned");

          // 3. Navigation Logic (only runs if the user is not banned)
          if (isBanned) {
            if (ModalRoute.of(context)?.settings.name != '/banned') {
              // Push and replace to BannedScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const BannedScreen(),
                  settings: const RouteSettings(name: '/banned'),
                ),
              );
            }
          }
        },
        onError: (error) {
          log("Error watching reusable ban status stream: $error");
        },
      );
}

Future<StreamSubscription<DocumentSnapshot>> startOwnerBanMonitoring({
  required BuildContext context,
  required FirebaseFirestore firestoreInstance,
}) async {
  // 1. Load user settings to get the document ID (email)
  OwnerSettings ownerSettings = await OwnerSettings().loadSettings();

  // 2. Return the stream subscription
  return firestoreInstance
      .collection("Turf_Owner")
      .doc(ownerSettings.ownerEmail)
      .snapshots() // Continuous stream
      .listen(
        (userDoc) {
          final userMap = userDoc.data();
          final bool isBanned = userMap?['isBanned'] as bool? ?? false;

          log("Reused Ban Monitor Stream: isBanned = $isBanned");

          // 3. Navigation Logic (only runs if the user is not banned)
          if (isBanned) {
            if (ModalRoute.of(context)?.settings.name != '/banned') {
              // Push and replace to BannedScreen
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const BannedScreen(),
                  settings: const RouteSettings(name: '/banned'),
                ),
              );
            }
          }
        },
        onError: (error) {
          log("Error watching reusable ban status stream: $error");
        },
      );
}

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class HomePage extends StatefulWidget {
  HomePage({super.key});
  final FirebaseFirestore firestoreInstance = FirebaseFirestore.instance;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // ------------------------------------------------------------------
  // 🔹 Translation Cache Logic (Exactly as provided)
  // ------------------------------------------------------------------

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Select location",
      "Sports Mode",
      "Gaming Mode",
      "Groups",
      "Find, Connect, and Game On with Your Crew",
      "Bookings",
      "Lock Your Slot",
      "Friends",
      "Build Your Squad",
      "Scoreboard",
      "Track scores, climb ranks, win more",
      "Cricket",
      "Football",
      "Badminton",
      "Table\nTennis",
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

  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // bool isBanned = false;
  // Future<void> checkBanned() async {
  //   UserSettings userSettings = await UserSettings().loadSettings();

  //   final userDoc = await _firestore.collection("Turf_User").doc(userSettings.email).get();
  //   final userMap = userDoc.data();
  //   isBanned = userMap?['isBanned'];
  //   log("banned status: ${userMap?['isBanned']}");
  //   if (isBanned) {
  //     Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){
  //       return BannedScreen();
  //     }));
  //   }
  // }

  // Future<void> _startBanMonitoring() async {
  //     // We use Future.microtask to delay execution slightly until the build phase
  //     // is complete and the context is fully ready.
  //     Future.microtask(() async {
  //       try {
  //         // Load user settings to get the document ID (email)
  //         UserSettings userSettings = await UserSettings().loadSettings();

  //         // 🔑 The key change: Use snapshots() instead of get()
  //         _banSubscription = widget.firestoreInstance
  //             .collection("Turf_User")
  //             .doc(userSettings.email)
  //             .snapshots()
  //             .listen((userDoc) {

  //           final userMap = userDoc.data();
  //           // Safely retrieve 'isBanned' field, defaulting to false
  //           final bool isBanned = userMap?['isBanned'] as bool? ?? false;

  //           log("Real-time ban status: $isBanned");

  //           // 3. Navigation logic (inside the listener)
  //           if (isBanned) {
  //             // Check if we are already on the BannedScreen to prevent a loop
  //             if (ModalRoute.of(context)?.settings.name != '/banned') {
  //               // Push replacement to immediately show the BannedScreen
  //               Navigator.of(context).pushReplacement(MaterialPageRoute(
  //                 builder: (context) => const BannedScreen(),
  //                 settings: const RouteSettings(name: '/banned'), // Identifier
  //               ));
  //             }
  //           }
  //         }, onError: (error) {
  //           log("Error watching ban status stream: $error");
  //         });
  //       } catch (e) {
  //         log("Failed to start ban monitoring stream: $e");
  //       }
  //     });
  //   }
  StreamSubscription<DocumentSnapshot>? _banSubscription;
  // Auto-scroll controller & timer for advertList
  final ScrollController _adScrollController = ScrollController();
  Timer? _adAutoScrollTimer;
  int _currentAdIndex = 0;
  late final AnimationController _shimmerController;

  Future<void> _setupBanMonitoring() async {
    // You can call this method at any time you need to (re)start the monitor
    _banSubscription?.cancel(); // Cancel any existing one before starting anew
    _banSubscription = await startBanMonitoring(
      context: context,
      firestoreInstance: FirebaseFirestore.instance, // Use your actual instance
    );
  }

  void _startAutoScrollAds() {
    // Cancel any existing timer
    _adAutoScrollTimer?.cancel();

    if (advertList.isEmpty) return;

    // Periodically advance to the next ad
    _adAutoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;

      // Calculate item width used in the horizontal list (container width + spacing)
      final width = MediaQuery.of(context).size.width;
      final double itemWidth = (width * 0.700934) + 20; // matches layout spacing

      _currentAdIndex++;
      if (_currentAdIndex >= advertList.length) {
        _currentAdIndex = 0;
      }

      final double target = _currentAdIndex * itemWidth;
      if (_adScrollController.hasClients) {
        try {
          await _adScrollController.animateTo(
            target,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } catch (_) {
          // ignore animation errors if controller became unavailable
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // checkBanned();
    loadAllAds();
    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    _setupBanMonitoring();
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
    _adAutoScrollTimer?.cancel();
    _shimmerController.dispose();
    try {
      _adScrollController.dispose();
    } catch (_) {}
    log("BanStatusWatcher disposed: Stream successfully cancelled.");
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

  List<Map<String, String>> sportsList = [
    {"sport": "Cricket", "image": "assets/Images/cricket001.jpg"},
    {"sport": "Football", "image": "assets/Images/football.jpg"},
    {"sport": "Badminton", "image": "assets/Images/badminton.jpg"},
    {"sport": "Tennis", "image": "assets/Images/tennis.jpg"},
    {"sport": "Table Tennis", "image": "assets/Images/table_tennis.jpg"},
  ];

  List<Map<String, dynamic>> advertList = [
];
  // whether adverts have finished loading at least once
  bool _adsLoaded = false;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
Future<void> loadAllAds() async {
  // mark as loading
  if (mounted) setState(() { _adsLoaded = false; });

  // stop any existing auto-scroll and clear previous ads to avoid duplicates
  _adAutoScrollTimer?.cancel();
  advertList.clear();

  final adsDoc = await _firestore.collection("Admin").doc("Ads_Data").get();
  final allAds = adsDoc.data();
  for (var element in allAds?['ads_list'] ?? []) {
    final adMap = {"adImage": element['image_url']};
    log("Ad URL: $adMap");
    advertList.add(adMap);
  }

  // start auto scrolling now that ads are present
  _startAutoScrollAds();

  if (mounted) setState(() {
    _adsLoaded = true;
  });
}

Future<void> _refreshAds() async {
  // show loader while refreshing
  if (mounted) setState(() { _adsLoaded = false; });

  // cancel existing timer and clear list
  _adAutoScrollTimer?.cancel();
  advertList.clear();

  try {
    await loadAllAds();
  } catch (e) {
    log('Error refreshing ads: $e');
  } finally {
    if (mounted) setState(() { _adsLoaded = true; });
  }
}

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
    // if (_translationsCache.isEmpty) {
    //   return const Scaffold(
    //     body: Center(child: UserLoaderScreen()),
    //   );
    // }
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier,
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";

        return Scaffold(
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
                left: 20,
                right: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🔹 Translated Location Label
                  ValueListenableBuilder<String?>(
                    valueListenable: selectedLocationNotifier,
                    builder: (context, value, _) {
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PrefLocation(),
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
                              valueListenable: appLanguageNotifier,
                              builder: (context, lang, _) {
                                return FutureBuilder<String>(
                                  future: getTranslatedText(
                                    value ?? "Select location",
                                    lang,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        "...",
                                        style: TextStyle(
                                          color: isDark
                                              ? Reusable.getDarkModeGrey()
                                              : Reusable.getWhite(),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text(
                                        "Error",
                                        style: TextStyle(
                                          color: isDark
                                              ? Reusable.getDarkModeGrey()
                                              : Reusable.getWhite(),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w500,
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
                                          fontWeight: FontWeight.w500,
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
                  
                  // Notification + Chat
                  Row(
                    children: [
                      // Icon(
                      //   Icons.notifications_none_outlined,
                      //   color: isDark
                      //       ? Reusable.getDarkModeBlack()
                      //       : Reusable.getWhite(),
                      //   size: 30,
                      // ),
                      const SizedBox(width: 25),
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
          ),
                    ),
                  
                    // White bottom sheet
                    Positioned(
          top: Reusable.getDeviceHeight(context, H: 90),
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Reusable.getDarkModeBlack()
                  : Reusable.getWhite(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(50),
                topRight: Radius.circular(50),
              ),
              boxShadow: [
                const BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.25),
                  blurRadius: 10,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 20),
                  
                      // 🔹 Translated "Sports Mode" / "Gaming Mode"
                      Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Align(
                          alignment: Alignment.center,
                          child: Stack(
                            children: [
                              Container(
                                height: 50,
                                width:
                                    MediaQuery.of(context).size.width -
                                    40,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Reusable.getDarkModeGrey()
                                      : Reusable.getWhite(),
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(
                                        0,
                                        0,
                                        0,
                                        0.25,
                                      ),
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(5),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 40,
                                          width:
                                              ((MediaQuery.of(
                                                            context,
                                                          ).size.width -
                                                          40) /
                                                      2 -
                                                  5) *
                                              2,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
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
                                              begin:
                                                  Alignment.bottomRight,
                                              end: Alignment.topLeft,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(25),
                                          ),
                                          child: Center(
                                            child: Text(
                                              _getTranslation(
                                                "Game On with PlayZ",
                                              ),
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight:
                                                    FontWeight.w600,
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
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  
                      const SizedBox(height: 30),
                  
                      // 🔹 Groups
                      _buildOptionCard(
                        context,
                        icon: Icons.groups_3_outlined,
                        title: _getTranslation("Groups"),
                        subtitle: _getTranslation(
                          "Find, Connect, and Game On with Your Crew",
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GroupsSports(),
                          ),
                        ),
                        isDark: isDark,
                      ),
                  
                      const SizedBox(height: 20),
                  
                      // 🔹 Bookings + Friends
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _buildOptionCard(
                              context,
                              icon: Icons.book_outlined,
                              title: _getTranslation("Bookings"),
                              subtitle: _getTranslation("Lock Your Slot"),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const BookingsSport(),
                                ),
                              ),
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildOptionCard(
                              context,
                              icon: Icons.group_outlined,
                              title: _getTranslation("Friends"),
                              subtitle: _getTranslation(
                                "Build Your Squad",
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const FriendsSport(),
                                ),
                              ),
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                  
                      const SizedBox(height: 20),
                  
                      // 🔹 Scoreboard
                      _buildOptionCard(
                        context,
                        icon: Icons.scoreboard_outlined,
                        title: _getTranslation("Scoreboard"),
                        subtitle: _getTranslation(
                          "Track scores, climb ranks, win more",
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Scoreboard(),
                          ),
                        ),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                  
                SizedBox(height: 15),
                SizedBox(
                  height:
                                    (MediaQuery.of(context).size.height) *
                                    0.164708,
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: sportsList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                            return BookSport(filterBy: sportsList[index]['sport'],);
                          }));
                        },
                        child: Container(
                          child: Row(
                            children: [
                              SizedBox(width: 20),
                              Container(
                                height:
                                    (MediaQuery.of(context).size.height) *
                                    0.144708,
                                width:
                                    (MediaQuery.of(context).size.width) *
                                    0.21028,
                                // color: Colors.white,
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.all(Radius.circular(10)),
                                  child: Image.asset(
                                    "${sportsList[index]['image']}",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              sportsList.length - 1 == index ? SizedBox(width: 20,) : SizedBox(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                  
                SizedBox(height: 20),
                SizedBox(
                  height:
                                  (MediaQuery.of(context).size.height) *
                                  0.181987,
                  child: ListView.builder(
                    controller: _adScrollController,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    scrollDirection: Axis.horizontal,
                    itemCount: (_adsLoaded && advertList.isNotEmpty) ? advertList.length : 3,
                    itemBuilder: (context, index) {
                      // Show shimmer placeholders while adverts are loading
                      if (!_adsLoaded || advertList.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: _buildShimmerAd(context),
                        );
                      }

                      return Container(
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            Container(
                              height: (MediaQuery.of(context).size.height) * 0.161987,
                              width: (MediaQuery.of(context).size.width) * 0.700934,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(10),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Grey placeholder while image loads
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                    Image.network(
                                      "${advertList[index]['adImage']}",
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const SizedBox.shrink();
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey[600],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            advertList.length - 1 == index ? const SizedBox(width: 20) : const SizedBox(),
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
                  
                    if (_translationsCache.isEmpty && advertList.isEmpty)
          const Positioned.fill(child: UserLoaderScreen()),
            ],
          ),
        );
      },
    );
  }

  // Simple shimmer placeholder for advert tiles (no external package)
  Widget _buildShimmerAd(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.700934;
    final height = MediaQuery.of(context).size.height * 0.161987;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade300,
      ),
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return ShaderMask(
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment(-1 - 0.3 + _shimmerController.value * 2, 0),
                end: Alignment(1 + 0.3 + _shimmerController.value * 2, 0),
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade100,
                  Colors.grey.shade300,
                ],
                stops: const [0.1, 0.5, 0.9],
              ).createShader(rect);
            },
            blendMode: BlendMode.srcATop,
            child: Container(
              width: width,
              height: height,
              color: Colors.grey.shade300,
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? Reusable.getDarkModeGrey() : Reusable.getWhite(),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.25), blurRadius: 3),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Container(
              height: 50,
              width: 44,
              decoration: BoxDecoration(
                color: isDark
                    ? Reusable.getDarkModeBlack()
                    : Reusable.getLightGrey(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
              ),
              child: Icon(
                icon,
                color: isDark
                    ? Reusable.getLightGreen()
                    : Reusable.getDarkGrey(),
                size: 30,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(

                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Reusable.getLightGreen()
                          : Reusable.getBlack(),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Reusable.getLightGrey()
                          : Reusable.getDarkGrey(),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
