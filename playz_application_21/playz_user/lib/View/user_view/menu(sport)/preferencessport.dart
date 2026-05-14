import 'dart:developer'; // Required for log()
import 'package:flutter/material.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/menu(sport)/prefnotification.dart';
import 'package:playz_user/View/user_view/menu(sport)/prefsports.dart';
import 'package:playz_user/View/user_view/reusable.dart';
  Map<String, String> _translationsCache = {};

  String _currentLang = "en";


// Main Stateful widget for displaying preferences
class Preferences extends StatefulWidget {
  const Preferences({super.key});

  @override
  State<Preferences> createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "My Setting",
      "Preferences",
      "Sports",
      "Locations",
      "Notification",
      "Privacy",
      "Blocked Users",
      "Reset Account",
      "Delete Account",
      // END: Add default english text here
    };

    // Dynamically collect keys from the list items (if turfInfo was used)
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
  // ===================================================================

  // Define static keys
  static const String _pageTitleKey = "My Setting";
  static const String _preferencesSectionKey = "Preferences";
  static const String _sportsKey = "Sports";
  static const String _locationsKey = "Locations";
  static const String _notificationKey = "Notification";
  static const String _privacySectionKey = "Privacy";
  static const String _blockedUsersKey = "Blocked Users";
  static const String _resetAccountKey = "Reset Account";
  static const String _deleteAccountKey = "Delete Account";

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          body: Stack(
            children: [
              // Green background with top bar
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color:
                    isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
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
                          _getTranslation(_pageTitleKey), // 🌍 Translated
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
                        color: Color.fromRGBO(0, 0, 0, 0.25),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: Reusable.getDeviceWidth(context, W: 30),
                      top: Reusable.getDeviceHeight(context, H: 20),
                      right: Reusable.getDeviceWidth(context, W: 30),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Preferences Section Title
                        Text(
                          _getTranslation(
                              _preferencesSectionKey), // 🌍 Translated
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getBlack(),
                          ),
                        ),

                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),

                        // Menu Item: Sports
                        _buildMenuItem(
                          context,
                          isDark,
                          Icons.sports,
                          _sportsKey,
                          PrefSports(),
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getDarkGrey(),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 10),
                        ),
                        _buildDivider(isDark),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 10),
                        ),

                        // Menu Item: Locations
                        _buildMenuItem(
                          context,
                          isDark,
                          Icons.location_on,
                          _locationsKey,
                          PrefLocation(),
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getBlack(),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 10),
                        ),
                        _buildDivider(isDark),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 10),
                        ),

                        // Menu Item: Notification
                        _buildMenuItem(
                          context,
                          isDark,
                          Icons.notifications,
                          _notificationKey,
                          PrefNotification(),
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getDarkGrey(),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 10),
                        ),
                        _buildDivider(isDark),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 40),
                        ),

                        // Privacy Section Title
                        Text(
                          _getTranslation(_privacySectionKey), // 🌍 Translated
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getBlack(),
                          ),
                        ),

                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),

                        // Menu Item: Blocked Users
                        _buildMenuItem(
                          context,
                          isDark,
                          Icons.block,
                          _blockedUsersKey,
                          null, // No navigation for now
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getDarkGrey(),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 10),
                        ),
                        _buildDivider(isDark),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 10),
                        ),

                        // Menu Item: Reset Account
                        _buildMenuItem(
                          context,
                          isDark,
                          Icons.restart_alt_rounded,
                          _resetAccountKey,
                          null, // No navigation for now
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getDarkGrey(),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 10),
                        ),
                        _buildDivider(isDark),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 10),
                        ),

                        // Menu Item: Delete Account
                        _buildMenuItem(
                          context,
                          isDark,
                          Icons.delete_forever,
                          _deleteAccountKey,
                          null, // No navigation for now
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getDarkGrey(),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 10),
                        ),
                        _buildDivider(isDark),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 40),
                        ),
                      ],
                    ),
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

  // Helper function to build a generic menu item
  Widget _buildMenuItem(
    BuildContext context,
    bool isDark,
    IconData icon,
    String textKey,
    Widget? destination, {
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => destination,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: Reusable.getDeviceWidth(context, W: 30),
                  color:
                      isDark ? Reusable.getLightGreen() : color, // Use provided color or default
                ),
                SizedBox(
                  width: Reusable.getDeviceWidth(context, W: 15),
                ),
                Text(
                  _getTranslation(textKey), // 🌍 Translated
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Reusable.getLightGreen()
                        : Reusable.getDarkGrey(),
                  ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: Reusable.getDeviceWidth(context, W: 20),
              color: isDark
                  ? Reusable.getLightGreen()
                  : Reusable.getDarkGrey(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build a divider
  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark
          ? Reusable.getLightGrey()
          : const Color.fromRGBO(81, 81, 81, 0.3),
      thickness: 1,
    );
  }
}