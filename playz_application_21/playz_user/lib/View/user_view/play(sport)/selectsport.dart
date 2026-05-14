import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart'; // Uncomment if needed
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart'; // Uncomment if needed
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart'; // Uncomment if needed
  Map<String, String> _translationsCache = {};
  String _currentLang = "en";


// Global notifier for selected sport and icon
final ValueNotifier<Map<String, dynamic>?> selectedSportNotifier = ValueNotifier<Map<String, dynamic>?>(null);

// =========================================================================


// Main Stateful widget for displaying sports groups
class SelectSport extends StatefulWidget {
  const SelectSport({super.key});

  @override
  State<SelectSport> createState() => _SelectSportState();
}

class _SelectSportState extends State<SelectSport> {
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Select a Sport",
      "Search by Sport",
      "Cricket",
      "Football",
      "Badminton",
      "Fitness",
      "Swimming",
      "Yoga",
      "Workout",
      "Running",
      "Cycling",
      "Combat",
      "Team Sports",
      "Box Cricket",
      "Basketball",
      "Volleyball",
      "Hockey",
      "Racquet Sports",
      "Tennis",
      "Table Tennis",
      // END: Add default english text here
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


  bool showFitness = false;
  bool showTeamSports = false;
  bool showRacquetSports = false;

  String? selectedLabel;

  // Helper for sport selection UI
  Widget sportTile({
    required String label,
    required IconData? icon,
    String? svgAsset,
    required bool isSelected,
    required VoidCallback onTap,
    bool isDark = false,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        setState(() {
          selectedLabel = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: Reusable.getDeviceWidth(context, W: 115),
        height: Reusable.getDeviceHeight(context, H: 75),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? Reusable.getLightGreen().withOpacity(0.15) : Reusable.getGreen().withOpacity(0.15))
              : (isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (isDark ? Reusable.getLightGreen() : Reusable.getGreen())
                : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [const BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                size: 30,
                color: isSelected
                    ? (isDark ? Reusable.getLightGreen() : Reusable.getGreen())
                    : (isDark ? Reusable.getLightGreen() : Reusable.getBlack()),
              ),
            if (svgAsset != null)
              SvgPicture.asset(
                svgAsset,
                width: 25,
                height: 25,
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? (isDark ? Reusable.getLightGreen() : Reusable.getGreen())
                      : (isDark ? Reusable.getLightGreen() : Reusable.getBlack()),
                  BlendMode.srcIn,
                ),
              ),
            const SizedBox(height: 5),
            Text(
              _getTranslation(label), // 🌍 Translated
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? (isDark ? Reusable.getLightGreen() : Reusable.getGreen())
                    : (isDark ? Reusable.getLightGreen() : Reusable.getBlack()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier,
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          body: Stack(
            children: [
              // Green background with top bar
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
                        // Back button
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
                        // Page title
                        Text(
                          _getTranslation("Select a Sport"), // 🌍 Translated
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

              // White rounded container at bottom (acts like bottom sheet)
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
                        color: Color.fromRGBO(0, 0, 0, 0.18),
                        blurRadius: 12,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 18),
                      // Search bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Reusable.getDarkModeBlack()
                                : Reusable.getWhite(),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            style: TextStyle(
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getDarkGrey(),
                            ),
                            cursorColor: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getGreen(),
                            decoration: InputDecoration(
                              hintText: _getTranslation("Search by Sport"), // 🌍 Translated
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getDarkGrey(),
                              ),
                              filled: true,
                              fillColor: Colors.transparent,
                              suffixIcon: Icon(
                                Icons.search,
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                size: 26,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Quick sport selection row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            sportTile(
                              label: "Cricket",
                              icon: Icons.sports_cricket_outlined,
                              isSelected: selectedSportNotifier.value?['sport'] == "Cricket",
                              onTap: () {
                                selectedSportNotifier.value = {
                                  "sport": "Cricket",
                                  "icon": Icons.sports_cricket_outlined,
                                };

                                Navigator.of(context).pop("Cricket");
                              },
                              isDark: isDark,
                            ),
                            sportTile(
                              label: "Football",
                              icon: Icons.sports_soccer_rounded,
                              isSelected: selectedSportNotifier.value?['sport'] == "Football",
                              onTap: () {
                                setState(() {
                                  selectedSportNotifier.value = {
                                    "sport": "Football",
                                    "icon": Icons.sports_soccer_rounded,
                                  };
                                });
                                Navigator.of(context).pop("Football");
                              },
                              isDark: isDark,
                            ),
                            sportTile(
                              label: "Badminton",
                              icon: Icons.sports_tennis_rounded,
                              isSelected: selectedSportNotifier.value?['sport'] == "Badminton",
                              onTap: () {
                                selectedSportNotifier.value = {
                                  "sport": "Badminton",
                                  "icon": Icons.sports_tennis_rounded,
                                };

                                Navigator.of(context).pop("Badminton");
                              },
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Fitness Section
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    showFitness = !showFitness;
                                    setState(() {});
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        showFitness
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 28,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _getTranslation("Fitness"), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getBlack(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Divider(
                                color: isDark
                                    ? Reusable.getLightGrey()
                                    : const Color.fromRGBO(81, 81, 81, 0.18),
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                              const SizedBox(height: 8),
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 200),
                                crossFadeState: showFitness
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                firstChild: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        sportTile(
                                          label: "Swimming",
                                          icon: Icons.pool,
                                          isSelected: selectedSportNotifier.value?['sport'] == "Swimming",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Swimming",
                                                "icon": Icons.pool,
                                              };
                                            });
                                            Navigator.of(context).pop("Swimming");
                                          },
                                          isDark: isDark,
                                        ),
                                        sportTile(
                                          label: "Yoga",
                                          icon: Icons.self_improvement,
                                          isSelected: selectedSportNotifier.value?['sport'] == "Yoga",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Yoga",
                                                "icon": Icons.self_improvement,
                                              };
                                            });
                                            Navigator.of(context).pop("Yoga");
                                          },
                                          isDark: isDark,
                                        ),
                                        sportTile(
                                          label: "Workout",
                                          icon: Icons.sports_gymnastics_rounded,
                                          isSelected: selectedSportNotifier.value?['sport'] == "Workout",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Workout",
                                                "icon": Icons.sports_gymnastics_rounded,
                                              };
                                            });
                                            Navigator.of(context).pop("Workout");
                                          },
                                          isDark: isDark,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        sportTile(
                                          label: "Running",
                                          icon: Icons.directions_run_rounded,
                                          isSelected: selectedSportNotifier.value?['sport'] == "Running",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Running",
                                                "icon": Icons.directions_run_rounded,
                                              };
                                            });
                                            Navigator.of(context).pop("Running");
                                          },
                                          isDark: isDark,
                                        ),
                                        sportTile(
                                          label: "Cycling",
                                          icon: Icons.pedal_bike_rounded,
                                          isSelected: selectedSportNotifier.value?['sport'] == "Cycling",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Cycling",
                                                "icon": Icons.pedal_bike_rounded,
                                              };
                                            });
                                            Navigator.of(context).pop("Cycling");
                                          },
                                          isDark: isDark,
                                        ),
                                        sportTile(
                                          label: "Combat",
                                          icon: Icons.sports_martial_arts_rounded,
                                          isSelected: selectedSportNotifier.value?['sport'] == "Combat",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Combat",
                                                "icon": Icons.sports_martial_arts_rounded,
                                              };
                                            });
                                            Navigator.of(context).pop("Combat");
                                          },
                                          isDark: isDark,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                                secondChild: const SizedBox.shrink(),
                              ),

                              // Team Sports Section
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    showTeamSports = !showTeamSports;
                                    setState(() {});
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        showTeamSports
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 28,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _getTranslation("Team Sports"), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getBlack(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Divider(
                                color: isDark
                                    ? Reusable.getLightGrey()
                                    : const Color.fromRGBO(81, 81, 81, 0.18),
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                              const SizedBox(height: 8),
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 200),
                                crossFadeState: showTeamSports
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                firstChild: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        sportTile(
                                          label: "Cricket",
                                          icon: Icons.sports_cricket_outlined,
                                          isSelected: selectedSportNotifier.value?['sport'] == "Cricket",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Cricket",
                                                "icon": Icons.sports_cricket_outlined,
                                              };
                                            });
                                            Navigator.of(context).pop("Cricket");
                                          },
                                          isDark: isDark,
                                        ),
                                        sportTile(
                                          label: "Football",
                                          icon: Icons.sports_soccer_rounded,
                                          isSelected: selectedSportNotifier.value?['sport'] == "Football",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Football",
                                                "icon": Icons.sports_soccer_rounded,
                                              };
                                            });
                                            Navigator.of(context).pop("Football");
                                          },
                                          isDark: isDark,
                                        ),
                                        sportTile(
                                          label: "Box Cricket",
                                          icon: Icons.sports_cricket_outlined,
                                          isSelected: selectedSportNotifier.value?['sport'] == "Box Cricket",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Box Cricket",
                                                "icon": Icons.sports_cricket_outlined,
                                              };
                                            });
                                            Navigator.of(context).pop("Box Cricket");
                                          },
                                          isDark: isDark,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        sportTile(
                                          label: "Basketball",
                                          icon: Icons.sports_basketball_outlined,
                                          isSelected: selectedSportNotifier.value?['sport'] == "Basketball",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Basketball",
                                                "icon": Icons.sports_basketball_outlined,
                                              };
                                            });
                                            Navigator.of(context).pop("Basketball");
                                          },
                                          isDark: isDark,
                                        ),
                                        sportTile(
                                          label: "Volleyball",
                                          icon: Icons.sports_volleyball_outlined,
                                          isSelected: selectedSportNotifier.value?['sport'] == "Volleyball",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Volleyball",
                                                "icon": Icons.sports_volleyball_outlined,
                                              };
                                            });
                                            Navigator.of(context).pop("Volleyball");
                                          },
                                          isDark: isDark,
                                        ),
                                        sportTile(
                                          label: "Hockey",
                                          icon: Icons.sports_hockey_outlined,
                                          isSelected: selectedSportNotifier.value?['sport'] == "Hockey",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Hockey",
                                                "icon": Icons.sports_hockey_outlined,
                                              };
                                            });
                                            Navigator.of(context).pop("Hockey");
                                          },
                                          isDark: isDark,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                                secondChild: const SizedBox.shrink(),
                              ),

                              // Racquet Sports Section
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: GestureDetector(
                                  onTap: () {
                                    showRacquetSports = !showRacquetSports;
                                    setState(() {});
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        showRacquetSports
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 28,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _getTranslation("Racquet Sports"), // 🌍 Translated
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? Reusable.getLightGreen()
                                              : Reusable.getBlack(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Divider(
                                color: isDark
                                    ? Reusable.getLightGrey()
                                    : const Color.fromRGBO(81, 81, 81, 0.18),
                                thickness: 1,
                                indent: 20,
                                endIndent: 20,
                              ),
                              const SizedBox(height: 8),
                              AnimatedCrossFade(
                                duration: const Duration(milliseconds: 200),
                                crossFadeState: showRacquetSports
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                firstChild: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        sportTile(
                                          label: "Tennis",
                                          icon: null,
                                          svgAsset: 'assets/SVG/tennis-2-svgrepo-com.svg',
                                          isSelected: selectedSportNotifier.value?['sport'] == "Tennis",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Tennis",
                                                "svg": 'assets/SVG/tennis-2-svgrepo-com.svg',
                                              };
                                            });
                                            Navigator.of(context).pop("Tennis");
                                          },
                                          isDark: isDark,
                                        ),
                                        sportTile(
                                          label: "Badminton",
                                          icon: null,
                                          svgAsset: 'assets/SVG/badminton-svgrepo-com.svg',
                                          isSelected: selectedSportNotifier.value?['sport'] == "Badminton",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Badminton",
                                                "svg": 'assets/SVG/badminton-svgrepo-com.svg',
                                              };
                                            });
                                            Navigator.of(context).pop("Badminton");
                                          },
                                          isDark: isDark,
                                        ),
                                        sportTile(
                                          label: "Table Tennis",
                                          icon: null,
                                          svgAsset: 'assets/SVG/table-tennis-4-svgrepo-com.svg',
                                          isSelected: selectedSportNotifier.value?['sport'] == "Table Tennis",
                                          onTap: () {
                                            setState(() {
                                              selectedSportNotifier.value = {
                                                "sport": "Table Tennis",
                                                "svg": 'assets/SVG/table-tennis-4-svgrepo-com.svg',
                                              };
                                            });
                                            Navigator.of(context).pop("Table Tennis");
                                          },
                                          isDark: isDark,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                                secondChild: const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
if (_translationsCache.isEmpty)
              const Positioned.fill(
                child: UserLoaderScreen(),
              ),
              // (TODO: Bottom navigation can be added here if needed)
            ],
          ),
        );
      },
    );
  }
}