import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:playz_user/Controller/User_Controller/Turf_Solo_Queue_Games_Controller.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/Medical_Assistant.dart';
import 'package:playz_user/View/user_view/home(sport)/homepage(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/play(sport)/filterinplay(sport).dart';
import 'package:playz_user/View/user_view/play(sport)/playgameinfo.dart';
import 'package:playz_user/View/user_view/play(sport)/playhostgame.dart';
import 'package:playz_user/View/user_view/reusable.dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class PlayPageSport extends StatefulWidget {
  const PlayPageSport({super.key});

  @override
  State<PlayPageSport> createState() => _PlayPageSportState();
}

class _PlayPageSportState extends State<PlayPageSport> {
  String _selectedView = "All Games";
  bool isJoined = false;
  bool isUpdated = false;
  // String selectOption = "All Games";
  String? currentUserEmail;
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys =
        {
              // START: Add default english text here (STATIC TEXT)
              "Select location",
              "Game Diary",
              "All Games",
              "My Sports",
              "More Sports",
              "Cricket",
              "Football",
              "Badminton",
              "Basketball",
              "Tennis",
              "Host Game",
              "Filter",
              "Sort",
              "Available Games",
              "Onboard",
              "Pro",
              "Casual",
              "Price",
              "Time",
              "Distance",
              // END: Add default english text here

              // Dynamic keys from lists:
              for (var item in sportsList) item['sport'] as String,

              // 💡 FIX APPLIED HERE 💡
              for (var item in playSportList)
                (item['solo_Queue_Info'] as Map<String, dynamic>?)?['sport']
                    as String?,
              for (var item in playSportList)
                (item['solo_Queue_Info'] as Map<String, dynamic>?)?['game_type']
                    as String?,
              for (var item in playSportList)
                (item['solo_Queue_Info'] as Map<String, dynamic>?)?['host_name']
                    as String?,
              for (var item in playSportList)
                (item['solo_Queue_Info']
                        as Map<String, dynamic>?)?['host_skill_level']
                    as String?, // Adjusted for safe access
              for (var item in playSportList)
                (item['solo_Queue_Info'] as Map<String, dynamic>?)?['address']
                    as String?,
            }
            // This line is essential: it removes any null values resulting from the safe access chains.
            .whereType<String>()
            .toSet();

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
    if (_currentLang != appLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadSelectedLocation();
    _loadCurrentEmail();
    appLanguageNotifier.addListener(_languageChangeListener);
    loadSoloGames();
    dayDateList = generateNext30Days();
    currentSport = sportsList[0]['sport']; // safely initialize here
    dateSelected =
        "${dayDateList[0]['day']} ${dayDateList[0]['date']} ${dayDateList[0]['month']}";
    setState(() {
      currentGamesList = playSportList;
    });
  }

  List<Map<String, String>> generateNext30Days() {
    final now = DateTime.now(); // today's date
    final DateFormat monthFormat = DateFormat('MMM'); // e.g. Oct
    final DateFormat dayFormat = DateFormat('EEE'); // e.g. Sun

    List<Map<String, String>> dayDateList = [];

    for (int i = 0; i < 30; i++) {
      final date = now.add(Duration(days: i)); // increment by 1 each loop

      dayDateList.add({
        "month": monthFormat.format(date),
        "date": date.day.toString(),
        "day": dayFormat.format(date),
      });
    }

    return dayDateList;
  }

  Future<void> _loadCurrentEmail() async {
    UserSettings userSettings = await UserSettings().loadSettings();
    currentUserEmail = userSettings.email;
    log("Load current user email: $currentUserEmail");
  }

  // In _PlayPageSportState
  Future<void> loadSoloGames() async {
    final fetchedGames = await TurfSoloGamesController().fetchAllSoloGames();

    // Define the date formats needed for parsing and formatting
    final DateFormat inputFormat = DateFormat(
      'dd-MM-yyyy',
    ); // Format of fetched date (e.g., 19-10-2025)
    final DateFormat dayFormat = DateFormat('EEE'); // e.g., Sat
    final DateFormat monthFormat = DateFormat('MMM'); // e.g., Oct

    for (var newItem in fetchedGames) {
      bool alreadyExists = playSportList.any(
        (oldItem) => oldItem['gameId'] == newItem['gameId'],
      );

      for (int i = 0; i < newItem['Players'].length; i++) {
        log("Emails from map: ${newItem['Players'][i]['player_email']}");
        if (newItem['Players'][i]['player_email'] == currentUserEmail) {
          myGamesSportList.add(newItem);
        }
      }
      if (!alreadyExists) {
        final soloInfo = newItem['solo_Queue_Info'] as Map<String, dynamic>?;

        if (soloInfo != null) {
          // --- 1. Date Transformation ---
          // Get the date string from soloInfo (if it exists)
          String? gameDateString = soloInfo['date'];

          if (gameDateString != null) {
            try {
              // Parse the fetched date string (e.g., "19-10-2025")
              final DateTime parsedDate = inputFormat.parse(gameDateString);

              // Reformat the date to match the UI's selected date format (e.g., "Sat 19 Oct")
              soloInfo['date'] =
                  "${dayFormat.format(parsedDate)} ${parsedDate.day.toString()} ${monthFormat.format(parsedDate)}";
            } catch (e) {
              // If date parsing fails, use the current selected date (Today) as a fallback.
              soloInfo['date'] = dateSelected;
              log("Date parsing failed for game: $e");
            }
          } else {
            // If no date field exists in the data, assume it's for today (the currently selected date)
            soloInfo['date'] = dateSelected;
          }

          // --- 2. Color Object Handling ---
          // The host_level_color can be a String ('Colors.red', 'red') or a Map ({r: 33, g: 150, b: 243}).
          // We must normalize it to a single Color object for the UI.

          dynamic colorData = soloInfo['host_level_color'];
          Color hostLevelColorObject;

          // Add the derived color object to the map for easy UI access

          playSportList.add(newItem);
        }
      }
    }

    log("List: $playSportList");

    if (mounted) {
      // By default, sort the loaded games by price (ascending) so the UI
      // shows cheaper games first unless the user changes the sort option.
      playSportList.sort((a, b) {
        final priceA = int.tryParse(a['solo_Queue_Info']?['price']?.toString() ?? '0') ?? 0;
        final priceB = int.tryParse(b['solo_Queue_Info']?['price']?.toString() ?? '0') ?? 0;
        return priceA.compareTo(priceB);
      });

      setState(() {
        // Set the current list to the sorted list and reload translations
        currentGamesList = playSportList;
        _loadTranslations(appLanguageNotifier.value);
      });
    }
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
      // Trigger translation load if location text changes and needs translation
      _loadTranslations(appLanguageNotifier.value);
    });
  }

  Future<void> _loadSelectedColorTheme() async {
    String? selected = await ThemeSettings(theme: null).loadSelectedTheme();
    // Assuming appSettingsNotifier.value is ThemeSettings and theme is writable/updatable via notifier.value
    // Since appSettingsNotifier is a ValueNotifier<ThemeSettings>, we should update the whole value:
    appSettingsNotifier.value = ThemeSettings(theme: selected);
    log("color theme in home page: ${selected!}");
    setState(() {});
  }

  //list for sports
  List<Map<String, dynamic>> sportsList = [
    {"icon": Icons.sports_cricket_outlined, "sport": "Cricket"},
    {"icon": Icons.sports_football_outlined, "sport": "Football"},
    {"icon": Icons.sports_tennis_rounded, "sport": "Badminton"},
    {"icon": Icons.sports_basketball_outlined, "sport": "Basketball"},
    {"icon": Icons.sports_tennis_outlined, "sport": "Tennis"},
  ];

  //list for days & date
  List<Map<String, String>> dayDateList = [];
  List<Map<String, dynamic>> myGamesSportList = [];
  List<Map<String, dynamic>> currentGamesList = [];
  //list for play sports events
  List<Map<String, dynamic>> playSportList = [
    // {
    //   "sport": "Cricket",
    //   "game_type": "Casual",
    //   "imageurl":
    //       "https://storyblok-cdn.photoroom.com/f/191576/1176x882/f95162c213/profile_picture_hero_before.webp",
    //   "onboard_players": "5/22",
    //   "host_name": "Virat Kholi",
    //   "date": "Wed 6 Aug",
    //   "time": "9:00 AM",
    //   "address":
    //       "Shop No. 6, Regent Plaza Mall, Baner - Pashan Link Rd, Baner, Pune, Maharashtra 411045, India",
    //   "sport_icon": Icons.sports_cricket_outlined,
    //   "player_level": "Pro",
    //   "level_color": const Color.fromRGBO(100, 181, 246, 1.0),
    //   "price": "200",
    //   "level_percent": 0.80,
    // },
    // {
    //   "sport": "Cricket",
    //   "game_type": "Casual",
    //   "imageurl":
    //       "https://storyblok-cdn.photoroom.com/f/191576/1176x882/f95162c213/profile_picture_hero_before.webp",
    //   "onboard_players": "5/22",
    //   "host_name": "Virat Kholi",
    //   "date": "Mon 4 Aug",
    //   "time": "9:00 AM",
    //   "address":
    //       "Shop No. 6, Regent Plaza Mall, Baner - Pashan Link Rd, Baner, Pune, Maharashtra 411045, India",
    //   "sport_icon": Icons.sports_cricket_outlined,
    //   "player_level": "Pro",
    //   "level_color": const Color.fromRGBO(100, 181, 246, 1.0),
    //   "price": "200",
    //   "level_percent": 0.80,
    // },
    // {
    //   "sport": "Cricket",
    //   "game_type": "Casual",
    //   "imageurl":
    //       "https://storyblok-cdn.photoroom.com/f/191576/1176x882/f95162c213/profile_picture_hero_before.webp",
    //   "onboard_players": "5/22",
    //   "host_name": "Virat Kholi",
    //   "date": "Mon 4 Aug",
    //   "time": "9:00 AM",
    //   "address":
    //       "Shop No. 6, Regent Plaza Mall, Baner - Pashan Link Rd, Baner, Pune, Maharashtra 411045, India",
    //   "sport_icon": Icons.sports_cricket_outlined,
    //   "player_level": "Pro",
    //   "level_color": const Color.fromRGBO(100, 181, 246, 1.0),
    //   "price": "200",
    //   "level_percent": 0.80,
    // },
    // {
    //   "sport": "Cricket",
    //   "game_type": "Casual",
    //   "imageurl":
    //       "https://storyblok-cdn.photoroom.com/f/191576/1176x882/f95162c213/profile_picture_hero_before.webp",
    //   "onboard_players": "5/22",
    //   "host_name": "Virat Kholi",
    //   "date": "Tue 5 Aug",
    //   "time": "9:00 AM",
    //   "address":
    //       "Shop No. 6, Regent Plaza Mall, Baner - Pashan Link Rd, Baner, Pune, Maharashtra 411045, India",
    //   "sport_icon": Icons.sports_cricket_outlined,
    //   "player_level": "Pro",
    //   "level_color": const Color.fromRGBO(100, 181, 246, 1.0),
    //   "price": "200",
    //   "level_percent": 0.80,
    // },
    // {
    //   "sport": "Football",
    //   "game_type": "Casual",
    //   "imageurl":
    //       "https://storyblok-cdn.photoroom.com/f/191576/1176x882/f95162c213/profile_picture_hero_before.webp",
    //   "onboard_players": "5/22",
    //   "host_name": "Virat Kholi",
    //   "date": "Wed 6 Aug",
    //   "time": "9:00 AM",
    //   "address":
    //       "Shop No. 6, Regent Plaza Mall, Baner - Pashan Link Rd, Baner, Pune, Maharashtra 411045, India",
    //   "sport_icon": Icons.sports_soccer,
    //   "player_level": "Pro",
    //   "level_color": const Color.fromRGBO(100, 181, 246, 1.0),
    //   "price": "200",
    //   "level_percent": 0.80,
    // },
    // {
    //   "sport": "Badminton",
    //   "game_type": "Casual",
    //   "imageurl":
    //       "https://storyblok-cdn.photoroom.com/f/191576/1176x882/f95162c213/profile_picture_hero_before.webp",
    //   "onboard_players": "5/22",
    //   "host_name": "Virat Kholi",
    //   "date": "Wed 6 Aug",
    //   "time": "9:00 AM",
    //   "address":
    //       "Shop No. 6, Regent Plaza Mall, Baner - Pashan Link Rd, Baner, Pune, Maharashtra 411045, India",
    //   "sport_icon": Icons.sports_tennis,
    //   "player_level": "Pro",
    //   "level_color": const Color.fromRGBO(100, 181, 246, 1.0),
    //   "price": "200",
    //   "level_percent": 0.80,
    // },
  ];
  String currentSport = "";
  String dateSelected = "";

  var selectedOption = "Price";

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        //height and width for sports list
        double height = (MediaQuery.of(context).size.height) * 0.0431965;
        return Scaffold(
          body: Stack(
            children: [
              Column(
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
                                        // Re-load translations if location changes (though not required by prompt, defensive practice)
                                        _loadTranslations(
                                          appLanguageNotifier.value,
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          // const SizedBox(width: 5),
                                          ValueListenableBuilder<String?>(
                                            valueListenable:
                                                selectedLocationNotifier,
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
                                                      Icons
                                                          .my_location_outlined,
                                                      color: isDark
                                                          ? Reusable.getDarkModeGrey()
                                                          : Reusable.getWhite(),
                                                      size: 30,
                                                    ),
                                                    const SizedBox(width: 5),
                                                    ValueListenableBuilder<
                                                      String
                                                    >(
                                                      valueListenable:
                                                          appLanguageNotifier,
                                                      builder: (context, lang, _) {
                                                        return FutureBuilder<
                                                          String
                                                        >(
                                                          future: getTranslatedText(
                                                            value ??
                                                                "Select location",
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
                                                                  color:
                                                                      isDark
                                                                      ? Reusable.getDarkModeGrey()
                                                                      : Reusable.getWhite(),
                                                                  fontSize:
                                                                      20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              );
                                                            } else if (snapshot
                                                                .hasError) {
                                                              return Text(
                                                                "Error",
                                                                style: TextStyle(
                                                                  color:
                                                                      isDark
                                                                      ? Reusable.getDarkModeGrey()
                                                                      : Reusable.getWhite(),
                                                                  fontSize:
                                                                      20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              );
                                                            } else {
                                                              return Text(
                                                                snapshot.data ??
                                                                    "",
                                                                style: TextStyle(
                                                                  color:
                                                                      isDark
                                                                      ? Reusable.getDarkModeGrey()
                                                                      : Reusable.getWhite(),
                                                                  fontSize:
                                                                      20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
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
                                    //       ? Reusable.getDarkModeGrey()
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
                          //space
                          SizedBox(
                            height:
                                (MediaQuery.of(context).size.height) *
                                0.0215982,
                          ),
                          //date & sports container
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height:
                                (MediaQuery.of(context).size.height) *
                                0.117710,
                            color: isDark
                                ? Reusable.getDarkModeBlack()
                                : Reusable.getWhite(),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                //sports and types
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: () {
                                        _selectedView = "Game Diary";
                                        setState(() {
                                          currentGamesList =
                                              myGamesSportList;
                                        });
                                      },
                                      child: Text(
                                        _getTranslation(
                                          "Game Diary",
                                        ), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? _selectedView ==
                                                        "Game Diary"
                                                    ? Reusable.getLightGreen()
                                                    : Reusable.getLightGrey()
                                              : _selectedView ==
                                                    "Game Diary"
                                              ? Reusable.getGreen()
                                              : Reusable.getDarkGrey(),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    GestureDetector(
                                      onTap: () {
                                        _selectedView = "All Games";
                                        setState(() {
                                          currentGamesList = playSportList;
                                        });
                                      },
                                      child: Text(
                                        _getTranslation(
                                          "All Games",
                                        ), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? _selectedView ==
                                                        "All Games"
                                                    ? Reusable.getLightGreen()
                                                    : Reusable.getLightGrey()
                                              : _selectedView ==
                                                    "All Games"
                                              ? Reusable.getGreen()
                                              : Reusable.getDarkGrey(),
                                        ),
                                      ),
                                    ),
                                    
                                  ],
                                ),
              
                                Divider(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : const Color.fromRGBO(81, 81, 81, 0.3),
                                  thickness: 1,
                                  indent: 20,
                                  endIndent: 20,
                                ),
              
                                //sports list
                                const SizedBox(width: 20),
                                SizedBox(
                                  height:
                                      (MediaQuery.of(context).size.height) *
                                      0.0531965,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: sportsList.length,
                                      itemBuilder: (context, index) {
                                        String sportName =
                                            sportsList[index]['sport']
                                                as String;
                                        return Row(
                                          children: [
                                            const SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () {
                                                currentSport = sportName;
                                                setState(() {
                                                  _loadTranslations(
                                                    appLanguageNotifier.value,
                                                  ); // Re-load to catch dynamic keys like currentSport if needed
                                                });
                                              },
                                              child: Container(
                                                height: height,
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? Reusable.getDarkModeGrey()
                                                      : Reusable.getWhite(),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        10,
                                                      ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color:
                                                          sportName ==
                                                              currentSport
                                                          ? const Color.fromRGBO(
                                                              0,
                                                              200,
                                                              83,
                                                              0.5,
                                                            )
                                                          : const Color.fromRGBO(
                                                              0,
                                                              0,
                                                              0,
                                                              0.25,
                                                            ),
                                                      spreadRadius: 0,
                                                      blurRadius: 3,
                                                      offset: const Offset(
                                                        0,
                                                        0,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    const SizedBox(width: 5),
                                                    Icon(
                                                      sportsList[index]['icon'],
                                                      size: 30,
                                                      color:
                                                          sportName ==
                                                              currentSport
                                                          ? isDark
                                                                ? Reusable.getLightGreen()
                                                                : Reusable.getGreen()
                                                          : isDark
                                                          ? Reusable.getLightGrey()
                                                          : Reusable.getDarkGrey(),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      _getTranslation(
                                                        sportName,
                                                      ), // 🌍 Translated sport name
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color:
                                                            sportName ==
                                                                currentSport
                                                            ? isDark
                                                                  ? Reusable.getLightGreen()
                                                                  : Reusable.getGreen()
                                                            : isDark
                                                            ? Reusable.getLightGrey()
                                                            : Reusable.getDarkGrey(),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 10),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
              
                          SizedBox(
                            height:
                                (MediaQuery.of(context).size.height) *
                                0.0269978,
                          ),
              
                          //date & days list
                          SizedBox(
                            height:
                                (MediaQuery.of(context).size.height) *
                                0.086393,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: dayDateList.length,
                                itemBuilder: (context, index) {
                                  String dateKey =
                                      "${dayDateList[index]['day']} ${dayDateList[index]['date']} ${dayDateList[index]['month']}";
                                  bool isSelected = dateKey == dateSelected;
                                  return Row(
                                    children: [
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          dateSelected = dateKey;
                                          setState(() {});
                                        },
                                        child: Container(
                                          height:
                                              (MediaQuery.of(
                                                context,
                                              ).size.height) *
                                              0.086393,
                                          width:
                                              (MediaQuery.of(
                                                context,
                                              ).size.width) *
                                              0.140186,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Reusable.getDarkModeGrey()
                                                : Reusable.getWhite(),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Text(
                                                // Month is usually not translated in this format, but we translate the day abbreviation
                                                dayDateList[index]['month']!,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? isDark
                                                            ? Reusable.getLightGreen()
                                                            : Reusable.getGreen()
                                                      : isDark
                                                      ? Reusable.getTextGrey()
                                                      : Reusable.getDarkGrey(),
                                                ),
                                              ),
                                              Text(
                                                dayDateList[index]['date']!,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? isDark
                                                            ? Reusable.getLightGreen()
                                                            : Reusable.getGreen()
                                                      : isDark
                                                      ? Reusable.getTextGrey()
                                                      : Reusable.getDarkGrey(),
                                                ),
                                              ),
                                              Text(
                                                // Day abbreviation
                                                _getTranslation(
                                                  dayDateList[index]['day']!,
                                                ), // 🌍 Translated day
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? isDark
                                                            ? Reusable.getLightGreen()
                                                            : Reusable.getGreen()
                                                      : isDark
                                                      ? Reusable.getTextGrey()
                                                      : Reusable.getDarkGrey(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
              
                          const SizedBox(height: 20),
              
                          //filter & sort
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    isUpdated = await Navigator.of(context)
                                        .push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return HostGame();
                                            },
                                          ),
                                        );
                                    try {
                                      if (isUpdated) {
                                        loadSoloGames();
                                        setState(() {});
                                      }
                                    } finally {
                                      isUpdated = false;
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      SizedBox(width: 5,),
                                      Text(
                                        _getTranslation(
                                          "Host Game",
                                        ), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Reusable.getDarkModeBlack()
                                              : Reusable.getWhite(),
                                        ),
                                      ),
                                      Icon(
                                        Icons.add,
                                        size: 19,
                                        color: isDark
                                            ? Reusable.getDarkModeBlack()
                                            : Reusable.getWhite(),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    // GestureDetector(
                                    //   onTap: () {
                                    //     Navigator.of(context).push(
                                    //       MaterialPageRoute(
                                    //         builder: (context) {
                                    //           return FilterPlaySport();
                                    //         },
                                    //       ),
                                    //     );
                                    //   },
                                    //   child: Row(
                                    //     children: [
                                    //       Icon(
                                    //         Icons.filter_list,
                                    //         size: 19,
                                    //         color: isDark
                                    //             ? Reusable.getDarkModeBlack()
                                    //             : Reusable.getWhite(),
                                    //       ),
                                    //       Text(
                                    //         _getTranslation(
                                    //           "Filter",
                                    //         ), // 🌍 Translated
                                    //         style: TextStyle(
                                    //           fontSize: 16,
                                    //           fontWeight: FontWeight.w700,
                                    //           color: isDark
                                    //               ? Reusable.getDarkModeBlack()
                                    //               : Reusable.getWhite(),
                                    //         ),
                                    //       ),
                                    //       const SizedBox(width: 25),
                                    //     ],
                                    //   ),
                                    // ),
                                    GestureDetector(
                                      onTap: () {
                                        showSortOptions();
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
                                            _getTranslation(
                                              "Sort",
                                            ), // 🌍 Translated
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: isDark
                                                  ? Reusable.getDarkModeBlack()
                                                  : Reusable.getWhite(),
                                            ),
                                          ),
                                          const SizedBox(width: 30),
                                        ],
                                      ),
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
                ],
              ),
              //white bottom sheet
              Positioned(
                top: (MediaQuery.of(context).size.height) * 0.386609,
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
                  //Available games
                  child: Column(
                    children: [
                      //space
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 10),
                      ),
                      Text(
                        _getTranslation("Available Games"), // 🌍 Translated
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
                          itemCount: currentGamesList.length,
                          itemBuilder: (context, index) {
                            // Filter logic: show only games matching currentSport and dateSelected
                            return ((currentGamesList[index]['solo_Queue_Info']['sport'] ==
                                        currentSport) &&
                                    (currentGamesList[index]['solo_Queue_Info']['date'] ==
                                        dateSelected))
                                ? Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () async {
                                          isJoined = await Navigator.of(context)
                                              .push(
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return PlayGameInfo(
                                                      currentPlayGameInfo:
                                                          currentGamesList[index],
                                                    );
                                                  },
                                                ),
                                              );
                                          try {
                                            if (isJoined) {
                                              loadSoloGames();
                                              setState(() {});
                                            }
                                          } finally {
                                            isJoined = false;
                                          }
                                        },
                                        child: Container(
                                          width:
                                              (MediaQuery.of(
                                                context,
                                              ).size.width) *
                                              0.906542,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? Reusable.getDarkModeGrey()
                                                : Reusable.getWhite(),
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
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  left: Reusable.getDeviceWidth(
                                                    context,
                                                    W: 5,
                                                  ),
                                                  right:
                                                      Reusable.getDeviceWidth(
                                                        context,
                                                        W: 10,
                                                      ),
                                                  top: Reusable.getDeviceHeight(
                                                    context,
                                                    H: 5,
                                                  ),
                                                  bottom:
                                                      Reusable.getDeviceHeight(
                                                        context,
                                                        H: 10,
                                                      ),
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 10,
                                                            top: 5,
                                                          ),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.topLeft,
                                                        //game type
                                                        child: Text(
                                                          _getTranslation(
                                                            currentGamesList[index]['solo_Queue_Info']['game_type'],
                                                          ), // 🌍 Translated
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: isDark
                                                                ? Reusable.getLightGreen()
                                                                : Reusable.getDarkGrey(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          Reusable.getDeviceHeight(
                                                            context,
                                                            H: 5,
                                                          ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                left: 10,
                                                              ),
                                                          child: CircleAvatar(
                                                            radius: 15,
                                                            //host image
                                                            backgroundImage:
                                                                NetworkImage(
                                                                  currentGamesList[index]['solo_Queue_Info']['host_profile_url'],
                                                                ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 15,
                                                        ),
                                                        //no. of players
                                                        Text(
                                                          "${currentGamesList[index]['solo_Queue_Info']['applied_players']}/${currentGamesList[index]['solo_Queue_Info']['total_players']} ${_getTranslation("Onboard")}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: isDark
                                                                ? Reusable.getLightGreen()
                                                                : Reusable.getBlack(),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          Reusable.getDeviceHeight(
                                                            context,
                                                            H: 5,
                                                          ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 10,
                                                          ),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        //host name
                                                        child: Text(
                                                          _getTranslation(
                                                            currentGamesList[index]['solo_Queue_Info']['host_name'],
                                                          ), // 🌍 Translated
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
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
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 10,
                                                          ),
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        //date & time
                                                        child: Text(
                                                          // Assuming date and time format are not translated, only the content
                                                          "${currentGamesList[index]['solo_Queue_Info']['date']}, ${currentGamesList[index]['solo_Queue_Info']['time']}",
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: isDark
                                                                ? Reusable.getLightGreen()
                                                                : Reusable.getBlack(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          Reusable.getDeviceHeight(
                                                            context,
                                                            H: 5,
                                                          ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 10,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .location_on_outlined,
                                                            size: 20,
                                                            color:
                                                                Reusable.getTextGrey(),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              currentGamesList[index]['solo_Queue_Info']['address'],
                                                              style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color: isDark
                                                                    ? Reusable.getLightGrey()
                                                                    : const Color.fromRGBO(
                                                                        109,
                                                                        109,
                                                                        109,
                                                                        1,
                                                                      ),
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          Reusable.getDeviceHeight(
                                                            context,
                                                            H: 10,
                                                          ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            left: 10,
                                                          ),
                                                      child: Row(
                                                        children: [
                                                          //sport icon
                                                          // Icon(
                                                          //   playSportList[index]['sport_icon'],
                                                          //   size: 20,
                                                          //   color: const Color.fromRGBO(
                                                          //       109,
                                                          //       109,
                                                          //       109,
                                                          //       1),
                                                          // ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Stack(
                                                            children: [
                                                              Container(
                                                                width:
                                                                    (MediaQuery.of(
                                                                      context,
                                                                    ).size.width) *
                                                                    0.21028,
                                                                height:
                                                                    (MediaQuery.of(
                                                                      context,
                                                                    ).size.height) *
                                                                    0.0215982,
                                                                decoration: BoxDecoration(
                                                                  color:
                                                                      const Color.fromRGBO(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        1,
                                                                      ),
                                                                  //skill level color
                                                                  border: Border.all(
                                                                    color: Colors
                                                                        .blue,
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        5,
                                                                      ),
                                                                ),
                                                              ),
                                                              Container(
                                                                width:
                                                                    (MediaQuery.of(
                                                                      context,
                                                                    ).size.width) *
                                                                    0.21028 *
                                                                    0.7,
                                                                height:
                                                                    (MediaQuery.of(
                                                                      context,
                                                                    ).size.height) *
                                                                    0.0215982,
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .blue,
                                                                  border: Border.all(
                                                                    color:
                                                                        const Color.fromRGBO(
                                                                          100,
                                                                          181,
                                                                          246,
                                                                          1,
                                                                        ),
                                                                    width: 1,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        5,
                                                                      ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets.only(
                                                                      left: 20,
                                                                    ),
                                                                child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  //player level
                                                                  child: Text(
                                                                    _getTranslation(
                                                                      currentGamesList[index]['solo_Queue_Info']['host_skill_level'],
                                                                    ), // 🌍 Translated
                                                                    style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      color:
                                                                          Color.fromRGBO(
                                                                            0,
                                                                            0,
                                                                            0,
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
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Padding(
                                              //   padding: const EdgeInsets.only(
                                              //     top: 10,
                                              //     right: 10,
                                              //   ),
                                              //   child: Align(
                                              //     alignment: Alignment.topRight,
                                              //     child: Icon(
                                              //       Icons.bookmark_outline,
                                              //       size: 25,
                                              //       color: isDark
                                              //           ? Reusable.getLightGreen()
                                              //           : Reusable.getGreen(),
                                              //     ),
                                              //   ),
                                              // ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 10,
                                                  right: 10,
                                                ),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Text(
                                                    "₹${currentGamesList[index]['solo_Queue_Info']['price']}",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isDark
                                                          ? Reusable.getLightGreen()
                                                          : Reusable.getGreen(),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                    ],
                                  )
                                : const SizedBox();
                          },
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

  // Inside _PlayPageSportState
  // Inside _PlayPageSportState

  void showSortOptions() {
    showModalBottomSheet(
      backgroundColor: Reusable.getWhite(),
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
                    _getTranslation("Sort By"), // 🌍 Translated
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 🔹 Radio Button: Price
                  RadioListTile<String>(
                    title: Text(_getTranslation("Price")), // 🌍 Translated
                    value: "Price",
                    activeColor: Reusable.getGreen(),
                    groupValue: selectedOption,
                    onChanged: (value) async {
                      setStateBottom(() {
                        selectedOption = value!;
                      });
                      await _sortGamesList(); // <-- Apply Sort
                      setState(() {}); // Update parent state (PlayPageSport)
                      Navigator.of(context).pop(); // Close sheet
                    },
                  ),

                  // 🔹 Radio Button: Time
                  RadioListTile<String>(
                    title: Text(_getTranslation("Time")), // 🌍 Translated
                    value: "Time",
                    activeColor: Reusable.getGreen(),
                    groupValue: selectedOption,
                    onChanged: (value) async {
                      setStateBottom(() {
                        selectedOption = value!;
                      });
                      await _sortGamesList(); // <-- Apply Sort
                      setState(() {}); // Update parent state
                      Navigator.of(context).pop();
                    },
                  ),

                  // 🔹 Radio Button: Distance
                  RadioListTile<String>(
                    title: Text(_getTranslation("Distance")), // 🌍 Translated
                    value: "Distance",
                    activeColor: Reusable.getGreen(),
                    groupValue: selectedOption,
                    onChanged: (value) async {
                      setStateBottom(() {
                        selectedOption = value!;
                      });
                      await _sortGamesList(); // <-- Apply Sort
                      setState(() {}); // Update parent state
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // --- DISTANCE CALCULATION UTILITIES ---
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0); // Use dart:math's pi
  }

  // double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  //   const double R = 6371; // Radius of the Earth in kilometers

  //   final dLat = _degreesToRadians(lat2 - lat1);
  //   final dLon = _degreesToRadians(lon2 - lon1);

  //   final a = (sin(dLat / 2) * sin(dLat / 2)) +
  //       cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

  //   final c = 2 * atan2(sqrt(a), sqrt(1 - a));

  //   return R * c; // Distance in kilometers
  // }
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // pi/180
    final a =
        0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  // Update the return type to non-nullable Map<String, double>
  Future<Map<String, double>> _getCurrentUserLocation() async {
    // 1. Get location from Appsharedpreferences (which might be null)
    LatLng? currentLocation = await Appsharedpreferences().loadSelectedLatLng();

    if (currentLocation == null) {
      log(
        "Warning: Current user location not found in preferences. Using fallback location.",
      );
      // Fallback to a central Pune location if user location is null
      return {'latitude': 18.5204, 'longitude': 73.8567};
    }
    log(
      "latitude: ${currentLocation.latitude}, longitude: ${currentLocation.longitude}",
    );
    // 2. Return the non-nullable map
    return {
      'latitude': currentLocation.latitude,
      'longitude': currentLocation.longitude,
    };
  }

  // --- DISTANCE SORT HELPER ---
  // --- DISTANCE SORT HELPER ---
  void _sortByDistance(
    List<Map<String, dynamic>> listToSort,
    Map<String, double> myLocation,
  ) {
    // These are guaranteed to be doubles now due to the fix in _getCurrentUserLocation
    final myLat = myLocation['latitude'] ?? 0.0;
    final myLon = myLocation['longitude'] ?? 0.0;

    listToSort.sort((a, b) {
      // ... location extraction logic (already correct) ...
      final infoA = a['solo_Queue_Info'];
      final infoB = b['solo_Queue_Info'];

      // --- Game A Location Extraction ---
      final locationA = infoA['location_latlan'];

      final latA = locationA['latitude'] is num
          ? (locationA['latitude'] as num).toDouble()
          : myLat; // Defaults to user location if data is bad

      final lonA = locationA['longitude'] is num
          ? (locationA['longitude'] as num).toDouble()
          : myLon;

      // --- Game B Location Extraction ---
      final locationB = infoB['location_latlan'];

      final latB = locationB['latitude'] is num
          ? (locationB['latitude'] as num).toDouble()
          : myLat;

      final lonB = locationB['longitude'] is num
          ? (locationB['longitude'] as num).toDouble()
          : myLon;

      // Calculate distances
      final distA = _calculateDistance(myLat, myLon, latA, lonA);
      final distB = _calculateDistance(myLat, myLon, latB, lonB);

      // Sort by shortest distance first
      return distA.compareTo(distB);
    });
  }

  // --- MAIN SORTING FUNCTION ---
  Future<void> _sortGamesList() async {
    // Await the location map once
    Map<String, double> locMap = await _getCurrentUserLocation();

    setState(() {
      switch (selectedOption) {
        case "Price":
          // ... Price logic (works fine) ...
          playSportList.sort((a, b) {
            final priceA =
                int.tryParse(
                  a['solo_Queue_Info']['price']?.toString() ?? '0',
                ) ??
                0;
            final priceB =
                int.tryParse(
                  b['solo_Queue_Info']['price']?.toString() ?? '0',
                ) ??
                0;
            return priceA.compareTo(priceB);
          });
          break;

        case "Time":
          // ... Time logic (works fine) ...
          playSportList.sort((a, b) {
            final timeStrA =
                a['solo_Queue_Info']['time']?.toString() ?? '11:59 PM';
            final timeStrB =
                b['solo_Queue_Info']['time']?.toString() ?? '11:59 PM';

            try {
              final timeFormat = DateFormat('h:mm a');
              final timeA = timeFormat.parse(timeStrA);
              final timeB = timeFormat.parse(timeStrB);
              return timeA.compareTo(timeB);
            } catch (e) {
              log("Error parsing time for sorting: $e");
              return timeStrA.compareTo(timeStrB);
            }
          });
          break;

        case "Distance":
          // Pass the guaranteed non-null location map
          _sortByDistance(playSportList, locMap);
          break;

        default:
          break;
      }
    });
  }
}
