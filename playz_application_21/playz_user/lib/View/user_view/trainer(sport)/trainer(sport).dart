import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/User_Controller/Display_Trainers_Controller.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/Medical_Assistant.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:playz_user/View/user_view/trainer(sport)/trainerInfo.dart';
  Map<String, String> _translationsCache = {};
  String _currentLang = "en";


class TrainerSport extends StatefulWidget {
  const TrainerSport({super.key});

  @override
  State<TrainerSport> createState() => _TrainerSportState();
}

List<Map<String, dynamic>> trainerList = [

];

class _TrainerSportState extends State<TrainerSport> {
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = []; // Not used here, but kept for logic structure

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Select location",
      "Search for Sports",
      "Available Trainers",
      "Trainer",
      "Adults", // From trainerList student_type
      "Kids", // From trainerList student_type (Assuming it might be another value)
      // END: Add default english text here
    };

    // Add dynamic keys from trainerList (trainer_name, location, student_type)
    for (var trainer in trainerList) {
      if (trainer['trainer_name'] is String) {
        keys.add(trainer['trainer_name'] as String);
      }
      if (trainer['location'] is String) {
        keys.add(trainer['location'] as String);
      }
      if (trainer['student_type'] is String) {
        keys.add(trainer['student_type'] as String);
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

  // ------------------------------------------------------------------
  String? selectedLocation;

  // Search controller and master list for filtering by trainer name
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allTrainerCards = [];

  Future<void> _loadSelectedLocation() async {
    String? selected = await Appsharedpreferences().loadSelectedCity();
    selectedLocationNotifier.value = selected;
    log("city in home page: $selected");
    setState(() {
      selectedLocation = selected;
    });
    // Call load translations after setting location, in case location name itself needs translation
    await _loadTranslations(appLanguageNotifier.value);
  }
  
  String _getTranslation(String key) => _translationsCache[key] ?? key;
  // ------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    if (_currentLang != appLanguageNotifier.value) {
_translationsCache.clear();
}
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadSelectedLocation(); // Added location loading here
    loadTrainers();
    appLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    appLanguageNotifier.removeListener(_languageChangeListener);
    _searchController.dispose();
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
  // ===================================================================

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

Future<void> loadTrainers() async {
  final trainerData = await DisplayTrainersController().fetchAlltrainer();
  log("Trainer Data: ${trainerData} ");
  //  {
  //   "image":
  //       "https://row.gymshark.com/_next/image?url=https%3A%2F%2Fimages.ctfassets.net%2Fwl6q2in9o7k3%2F4YOjnp32baAK0RNEUo1pI8%2F53e327aa51e8133f7de055951016d5ca%2FLook_One_4x5.jpg&w=3840&q=90",
  //   "icons": [Icons.fitness_center, Icons.pedal_bike],
  //   "trainer_name": "Lunsford",
  //   "location": "Kolkata, West Bengal",
  //   "student_type": "Adults",
  //   "rating": "4.5",
  // },
  // initialize master list with any seeded items already present in trainerList
  _allTrainerCards = List<Map<String, dynamic>>.from(trainerList);

  for (var i = 0; i < trainerData.length; i++) {
    final trainerMap = {
      "image": trainerData[i]['trainer_images'][0],
      // keep original icons key for fallback but prefer mapped sports icons when available
      "icons": [Icons.fitness_center, Icons.pedal_bike],
      "trainer_name": trainerData[i]['trainer_name'],
      "location": trainerData[i]['location']?['address'] ?? '',
      "student_type": "Adults",
      "rating": "4.5",
      "trainer_data": trainerData[i],
      "trainer_email": trainerData[i]['email'],
      "sports": trainerData[i]['sports'] // this is a list of string
    };

    _allTrainerCards.add(trainerMap);
  }

  // update the visible list once
  trainerList = List<Map<String, dynamic>>.from(_allTrainerCards);
  if (mounted) setState(() {});
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
                                                      ConnectionState.waiting) {
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
                                Reusable.getDeviceHeight(context, H: 15),
                          ),
                          //search for sports
                          Container(
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(
                            //     Reusable.getDeviceWidth(context, W: 30),
                            //   ),
                            // ),
                            width:
                                (MediaQuery.of(context).size.width) - 40,
                            height:
                                Reusable.getDeviceHeight(context, H: 60),
              
                            child: TextField(
                              
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              style: TextStyle(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getDarkGrey(),
                              ),
                              decoration: InputDecoration(
                                suffixIcon: Icon(
                                  Icons.search_outlined,
                                  size: 25,
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getDarkGrey(),
                                ),
                                hintText: _getTranslation('Search for Sports'), // 🌍 Translated
                                hintStyle: TextStyle(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getDarkGrey(),
                                ), // Hint text color
                                filled: true,
                                fillColor: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                                // contentPadding: EdgeInsets.symmetric(
                                // horizontal: 15,
                                // vertical: 0,
                                // ),
                                // Padding inside
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    Reusable.getDeviceWidth(context, W: 30),
                                  ), // Border radius
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(), // Border color
                                    width: 2, // Border width
                                  ),
                                ),
                                
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Reusable.getDarkModeBlack()
                                        : Reusable.getGreen(),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Reusable.getWhite()
                                        : Reusable.getDarkGrey().withOpacity(0.6),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
              
                          //filter & sort
                          
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              //white bottom sheet
              Positioned(
                top: Reusable.getDeviceHeight(context, H: 165),
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
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 10),
                      ),
                      Text(
                        _getTranslation("Available Trainers"), // 🌍 Translated
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getDarkGrey(),
                        ),
                      ),

                      //trainer cards
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: (trainerList.length / 2).ceil(),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Card 1
                                    _buildTrainerCard(
                                      context,
                                      trainerList[index * 2],
                                      isDark,
                                      index * 2,
                                    ),
                                    SizedBox(
                                      width: (MediaQuery.of(context).size.width) * 0.0467289,
                                    ),

                                    // Card 2 (if available)
                                    (((index * 2) + 1) < trainerList.length)
                                        ? _buildTrainerCard(
                                            context,
                                            trainerList[(index * 2) + 1],
                                            isDark,
                                            (index * 2) + 1,
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 10,
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

  // Helper method to build the trainer card and keep 'build' cleaner
  Widget _buildTrainerCard(BuildContext context, Map<String, dynamic> trainerData, bool isDark, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return TrainerInfo(trainerDataMap: trainerData,);
            },
          ),
        );
      },
      child: Container(
        // height: (MediaQuery.of(context).size.height) * 0.215,
        width: (MediaQuery.of(context).size.width) * 0.429906,
        decoration: BoxDecoration(
          color: isDark ? Reusable.getDarkModeGrey() : Reusable.getWhite(),
          boxShadow: const [
            BoxShadow(
              blurRadius: 3,
              color: Color.fromRGBO(0, 0, 0, 0.25),
              offset: Offset(0, 0),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: (MediaQuery.of(context).size.height) * 0.00539956,
            ),
            Stack(
              children: [
                Container(
                  height: (MediaQuery.of(context).size.height) * 0.0971922,
                  width: (MediaQuery.of(context).size.width) * 0.406542,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(trainerData['image']),
                      fit: BoxFit.cover,
                    ),
                    color: Reusable.getLightGrey(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 5,
                        right: 5,
                        top: 2,
                        bottom: 2,
                      ),
                      child: Text(
                        _getTranslation("Trainer"), // 🌍 Translated
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Reusable.getLightGreen() : Reusable.getWhite(),
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 5,
                  left: 5,
                  child: Row(
                    children: [
                      // compute icons based on trainerData['sports'] if available, else fallback to trainerData['icons']
                      Builder(builder: (context) {
                        List<IconData> iconsToShow = [];
                        if (trainerData.containsKey('sports') && trainerData['sports'] != null) {
                          iconsToShow = _getIconsForSports(trainerData['sports']);
                        }
                        if (iconsToShow.isEmpty && trainerData.containsKey('icons')) {
                          try {
                            iconsToShow = (trainerData['icons'] as List).cast<IconData>();
                          } catch (_) {
                            iconsToShow = [];
                          }
                        }

                        // Ensure at least two placeholders for layout if empty
                        final int displayCount = iconsToShow.length >= 2 ? 2 : iconsToShow.length;

                        List<Widget> iconWidgets = [];
                        for (int i = 0; i < displayCount; i++) {
                          iconWidgets.add(Container(
                            height: (MediaQuery.of(context).size.height) * 0.0215982,
                            width: (MediaQuery.of(context).size.width) * 0.0467289,
                            decoration: BoxDecoration(
                              color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              iconsToShow[i],
                              size: 15,
                              color: isDark ? Reusable.getLightGreen() : Reusable.getBlack(),
                            ),
                          ));
                          iconWidgets.add(const SizedBox(width: 5));
                        }

                        // "+X more" indicator
                        Widget moreWidget = const SizedBox();
                        if (iconsToShow.length > 2) {
                          final extraCount = iconsToShow.length - 2;
                          final rawText = "+$extraCount more";
                          moreWidget = Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(0, 0, 0, 0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 3, right: 3),
                                child: ValueListenableBuilder<String>(
                                  valueListenable: appLanguageNotifier,
                                  builder: (context, lang, _) {
                                    return FutureBuilder<String>(
                                      future: getTranslatedText(rawText, lang),
                                      builder: (context, snapshot) {
                                        String displayText = snapshot.connectionState == ConnectionState.waiting
                                            ? "..."
                                            : snapshot.hasError
                                                ? "Error"
                                                : snapshot.data ?? rawText;

                                        return Text(
                                          displayText,
                                          style: TextStyle(
                                            fontSize: 8,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Reusable.getLightGreen() : Reusable.getWhite(),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        }

                        return Row(
                          children: [
                            ...iconWidgets,
                            moreWidget,
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),

            // Trainer Name
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  _getTranslation(trainerData['trainer_name']), // 🌍 Translated
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Reusable.getLightGreen() : Reusable.getBlack(),
                  ),
                ),
              ),
            ),

            // Location
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  _getTranslation(trainerData['location']), // 🌍 Translated
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Reusable.getLightGrey() : const Color.fromRGBO(109, 109, 109, 1),
                  ),
                ),
              ),
            ),

            // Student Type
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  _getTranslation(trainerData['student_type']), // 🌍 Translated
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Reusable.getLightGrey() : const Color.fromRGBO(109, 109, 109, 1),
                  ),
                ),
              ),
            ),

            // Rating
            Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 5),
              child: Row(
                children: [
                  const Icon(
                    Icons.star,
                    size: 20,
                    color: Color.fromRGBO(255, 215, 0, 1),
                  ),
                  Text(
                    trainerData['rating'], // Rating is typically not translated
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Reusable.getLightGrey() : const Color.fromRGBO(109, 109, 109, 1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        trainerList = List<Map<String, dynamic>>.from(_allTrainerCards);
      });
      return;
    }

    final filtered = _allTrainerCards.where((trainer) {
      final name = (trainer['trainer_name'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();

    setState(() {
      trainerList = filtered;
    });
  }
}

  // Map known sport strings to Flutter IconData. Returns a list of icons for the given sports.
  List<IconData> _getIconsForSports(dynamic sportsRaw) {
    if (sportsRaw == null) return [];
    List<IconData> out = [];
    try {
      final List<dynamic> sports = (sportsRaw is List) ? sportsRaw : [sportsRaw];
      for (var s in sports) {
        if (s == null) continue;
        final key = s.toString().toLowerCase();
        if (key.contains('cricket')) {
          out.add(Icons.sports_cricket);
        } else if (key.contains('football') || key.contains('soccer')) {
          out.add(Icons.sports_soccer);
        } else if (key.contains('badminton')) {
          out.add(Icons.sports_tennis); // no badminton icon; tennis is closest
        } else if (key.contains('gym') || key.contains('fitness')) {
          out.add(Icons.fitness_center);
        } else if (key.contains('basketball')) {
          out.add(Icons.sports_basketball);
        } else if (key.contains('tennis')) {
          out.add(Icons.sports_tennis);
        } else if (key.contains('running') || key.contains('run')) {
          out.add(Icons.directions_run);
        } else {
          // fallback generic sport icon
          out.add(Icons.sports);
        }
      }
    } catch (_) {
      return [];
    }
    // Reduce duplicates while keeping order
    final seen = <IconData>{};
    return out.where((i) => seen.add(i)).toList();
  }