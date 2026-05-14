import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/navigationformodules.dart';
import 'package:playz_user/View/user_view/AI_Chat.dart';
import 'package:playz_user/View/user_view/home(sport)/Bookings/Bookings(sport).dart';
import 'package:playz_user/View/user_view/home(sport)/Groups/groups(sports).dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/home(sport)/homepage(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preferencessport.dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/menu(sport)/profile.dart';
import 'package:playz_user/View/user_view/navigation(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:translator/translator.dart';
  Map<String, String> _translationsCache = {};

  String _currentLang = "en";






// Global Notifiers/Settings Placeholders
ValueNotifier<ThemeSettings> appSettingsNotifier = ValueNotifier(
  ThemeSettings(theme: "Light"), // initial theme
);

ValueNotifier<String> appLanguageNotifier = ValueNotifier(
  "en",
); // default English




final translator = GoogleTranslator();

Future<String> getTranslatedText(String text, String langCode) async {
  if (langCode == "en") return text; // no need to translate
  try {
    var translation = await translator.translate(text, to: langCode);
    return translation.text;
  } catch (e) {
    // Fallback if translation fails
    log("Translation failed for '$text': $e");
    return text;
  }
}

// =========================================================================

class MenuSport extends StatefulWidget {
  const MenuSport({super.key});

  @override
  State<MenuSport> createState() => _MenuSportState();
}

class _MenuSportState extends State<MenuSport> {
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "View your full profile",
      "My Bookings",
      "View and manage your reservations",
      "Squad",
      "Your sports buddies",
      "Z Coins",
      "Earn, save, and spend",
      "Preferences",
      "Personalize your experience",
      "App Language",
      "Switch to your preferred language",
      "App Theme",
      "Customize your visual experience",
      "Help & Support",
      "We’re here to assist you",
      "Logout",
      "Log out from the app",
      "Select Language",
      
      "Select Theme",
      "Light Mode",
      "Dark Mode",
      "Are you sure you want to logout?\nYou will need to login again to access your account.",
      "Cancel",
      "Logged out successfully",
      // END: Add default english text here
    };

    // Dynamically collect keys from the list items (turfInfo not used here, but kept as per logic)
    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }

    // Add static/dynamic user data keys if they need translation
    keys.add("Shriraj Deshpande"); // Example User Name

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
  String selectedColorTheme = appSettingsNotifier.value.theme ?? "Light";
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
    selectedColorTheme = selectedTheme ?? "Light";
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

  void _showLogoutDialog(BuildContext context, bool isDark) {
    const String titleKey = 'Logout';
    const String contentKey =
        'Are you sure you want to logout?\nYou will need to login again to access your account.';
    const String cancelKey = 'Cancel';
    const String logoutKey = 'Logout';
    const String snackBarKey = 'Logged out successfully';

    showDialog(
      context: context,
      barrierDismissible: false, // prevents closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              isDark ? Reusable.getDarkModeGrey() : Reusable.getWhite(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            _getTranslation(titleKey), // 🌍 Translated
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color:
                  isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
            ),
          ),
          content: Text(
            _getTranslation(contentKey), // 🌍 Translated
            style: TextStyle(
              fontSize: 16,
              color: isDark ? Reusable.getTextGrey() : Reusable.getBlack(),
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
              },
              child: Text(
                _getTranslation(cancelKey), // 🌍 Translated
                style: TextStyle(
                  color: isDark ? Reusable.getLightGrey() : Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                ThemeSettings.saveSelectedLocale("en");
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => DummyNavigatorScreen(),
                  ),
                  (Route<dynamic> route) =>
                      false, // Removes all previous routes
                );
                await UserSettings.clearAllSettings();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(_getTranslation(
                          snackBarKey))), // 🌍 Translated
                );
              },
              child: Text(
                _getTranslation(logoutKey), // 🌍 Translated
                style: TextStyle(
                  fontSize: 16,
                  color: isDark
                      ? Reusable.getDarkModeBlack()
                      : Reusable.getWhite(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String selectedLanguage = "English";

  // simple local z-coins counter (replace with real source as needed)
  int _zCoins = 1000;

  Future<void> _showZCoinsSheet(BuildContext context, bool isDark) async {
    // In a real app you'd fetch the user's balance from your backend here.
    // For now we use the local `_zCoins` value.
    showModalBottomSheet(
      backgroundColor: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Reusable.getDeviceWidth(context, W: 30)),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _getTranslation(_zCoinsTitleKey),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Reusable.getLightGreen() : Reusable.getBlack(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getTranslation(_zCoinsSubtitleKey),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Reusable.getLightGrey() : Reusable.getDarkGrey(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                decoration: BoxDecoration(
                  color: isDark ? Reusable.getDarkModeGrey() : const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_zCoins',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Reusable.getLightGreen() : Reusable.getBlack(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Z',
                      style: TextStyle(
                        fontSize: 20,
                        color: isDark ? Reusable.getLightGrey() : Reusable.getDarkGrey(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  _getTranslation('Close'),
                  style: TextStyle(color: isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite()),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  // Note: initState is already defined above with translation logic.
  // The two functions below are kept here for continuity.

  // @override
  // void initState() {
  //   super.initState();
  //   _loadSelectedColorTheme();
  // }

  Future<void> _loadSelectedColorTheme() async {
    String? selected = await ThemeSettings(theme: null).loadSelectedTheme();
    appSettingsNotifier.value.theme = selected;
    log("color theme in home page: $selected");
    setState(() {});
  }

  Widget buildLanguageRadio(
    String title,
    String code,
    String currentLang,
    bool isDark,
  ) {
    return RadioListTile<String>(
      title: Text(
        _getTranslation(title), // 🌍 Translated
        style: TextStyle(
          color:
              isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
        ),
      ),
      value: code,
      groupValue: currentLang,
      activeColor:
          isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
      onChanged: (value) async {
        // Clear this page's translation cache immediately so the loader activates
        // while new translations are fetched via the language change listener.
        setState(() {
          _translationsCache.clear();
        });

        appLanguageNotifier.value = value!;
        Navigator.of(context).pop(); // close bottom sheet
        await ThemeSettings.saveSelectedLocale(value);
        log(
          "sharedlang: ${await ThemeSettings(locale: null, theme: null).loadSelectedLocale()}",
        );

        // trigger a rebuild; actual translations will be loaded by _languageChangeListener
        setState(() {
          appLanguageNotifier.value = value;
          log("language: ${appLanguageNotifier.value}");
        });
      },
    );
  }

  void showAppLanguages(bool isDark) {
    const String titleKey = "Select Language";
    showModalBottomSheet(
      backgroundColor:
          isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Reusable.getDeviceWidth(context, W: 30)),
        ),
      ),
      builder: (context) {
        return ValueListenableBuilder<String>(
          valueListenable: appLanguageNotifier,
          builder: (context, lang, _) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      _getTranslation(titleKey), // 🌍 Translated
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getDarkGrey(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Languages (Translation for title is handled in buildLanguageRadio)
                    buildLanguageRadio("English", "en", lang, isDark),
                    buildLanguageRadio("Hindi | हिन्दी", "hi", lang, isDark),
                    buildLanguageRadio("Marathi | मराठी", "mr", lang, isDark),
                    buildLanguageRadio("Tamil | தமிழ்", "ta", lang, isDark),
                    buildLanguageRadio("Telugu | తెలుగు", "te", lang, isDark),
                    buildLanguageRadio("Kannada | ಕನ್ನಡ", "kn", lang, isDark),
                    buildLanguageRadio(
                      "Malayalam | മലയാളം",
                      "ml",
                      lang,
                      isDark,
                    ),
                    buildLanguageRadio("Bengali | বাংলা", "bn", lang, isDark),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void showAppColorThemes(bool isDark) {
    const String titleKey = "Select Theme";
    const String lightModeKey = "Light Mode";
    const String darkModeKey = "Dark Mode";

    showModalBottomSheet(
      backgroundColor:
          isDark ? Reusable.getDarkModeBlack() : Reusable.getWhite(),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      _getTranslation(titleKey), // 🌍 Translated
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getBlack(),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 🔹 Radio Button: Light Mode
                    RadioListTile<String>(
                      title: Text(
                        _getTranslation(lightModeKey), // 🌍 Translated
                        style: TextStyle(
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getDarkGrey(),
                        ),
                      ),
                      value: "Light",
                      activeColor: isDark
                          ? Reusable.getLightGreen()
                          : Reusable.getGreen(),
                      groupValue: selectedColorTheme,
                      onChanged: (value) async {
                        // save Light
                        await ThemeSettings.saveSelectedTheme("Light");
                        log(
                          "${await ThemeSettings(theme: null).loadSelectedTheme()}",
                        );

                        // update state
                        setStateBottom(() {
                          selectedColorTheme = value!;
                        });

                        setState(() {
                          appSettingsNotifier.value = ThemeSettings(
                            theme: "Light",
                          );
                          log("notifier: ${appSettingsNotifier.value.theme}");
                        });

                        // close AFTER updating
                        Navigator.of(context).pop();
                      },
                    ),

                    // 🔹 Radio Button: Dark Mode
                    RadioListTile<String>(
                      title: Text(
                        _getTranslation(darkModeKey), // 🌍 Translated
                        style: TextStyle(
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getDarkGrey(),
                        ),
                      ),
                      value: "Dark",
                      activeColor: isDark
                          ? Reusable.getLightGreen()
                          : Reusable.getGreen(),
                      groupValue: selectedColorTheme,
                      onChanged: (value) async {
                        // save Dark
                        await ThemeSettings.saveSelectedTheme("Dark");
                        log(
                          "${await ThemeSettings(theme: null).loadSelectedTheme()}",
                        );

                        setStateBottom(() {
                          selectedColorTheme = value!;
                        });

                        setState(() {
                          appSettingsNotifier.value = ThemeSettings(
                            theme: "Dark",
                          );
                          log("notifier: ${appSettingsNotifier.value.theme}");
                        });

                        Navigator.of(context).pop();
                      },
                    ),

                     SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Define static keys for menu items
  static const String _userNameKey = "Profile";
  static const String _viewProfileKey = "View your full profile";
  static const String _bookingsTitleKey = "My Bookings";
  static const String _bookingsSubtitleKey = "View and manage your reservations";
  static const String _squadTitleKey = "Squad";
  static const String _squadSubtitleKey = "Your sports buddies";
  static const String _zCoinsTitleKey = "Z Coins";
  static const String _zCoinsSubtitleKey = "Earn, save, and spend";
  static const String _preferencesTitleKey = "Preferences";
  static const String _preferencesSubtitleKey = "Personalize your experience";
  static const String _languageTitleKey = "App Language";
  static const String _languageSubtitleKey = "Switch to your preferred language";
  static const String _themeTitleKey = "App Theme";
  static const String _themeSubtitleKey = "Customize your visual experience";
  static const String _helpTitleKey = "Help & Support";
  static const String _helpSubtitleKey = "We’re here to assist you";
  static const String _logoutTitleKey = "Logout";
  static const String _logoutSubtitleKey = "Log out from the app";

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
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return UserProfile();
                                      },
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: (MediaQuery.of(
                                                    context)
                                                .size
                                                .height) *
                                            0.0539956,
                                        width: (MediaQuery.of(
                                                    context)
                                                .size
                                                .height) *
                                            0.0539956,
                                        child: Icon(
                                          Icons.account_circle,
                                          size: (MediaQuery.of(
                                                      context)
                                                  .size
                                                  .height) *
                                              0.0539956,
                                          color: isDark
                                              ? Reusable.getDarkModeBlack()
                                              : Reusable.getWhite(),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getTranslation(
                                                _userNameKey), // 🌍 Translated (Dynamic data key)
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? Reusable
                                                      .getDarkModeBlack()
                                                  : Reusable.getWhite(),
                                            ),
                                          ),
                                          Text(
                                            _getTranslation(
                                                _viewProfileKey), // 🌍 Translated
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              color: isDark
                                                  ? Reusable
                                                      .getDarkModeBlack()
                                                  : Reusable.getWhite(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
                top: (MediaQuery.of(context).size.height) * 0.1187904,
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      //space
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 10),
                      ),
                      // My Bookings
                      _buildMenuItem(
                        context,
                        isDark,
                        Icons.book_outlined,
                        _bookingsTitleKey,
                        _bookingsSubtitleKey,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return BookingsSport();
                              },
                            ),
                          );
                        },
                      ),
                      _buildDivider(isDark),

                      // Squad
                      _buildMenuItem(
                        context,
                        isDark,
                        Icons.groups_3_outlined,
                        _squadTitleKey,
                        _squadSubtitleKey,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return GroupsSports();
                              },
                            ),
                          );
                        },
                      ),
                      _buildDivider(isDark),

                      // Z Coins
                      _buildMenuItem(
                        context,
                        isDark,
                        Icons.payments_outlined,
                        _zCoinsTitleKey,
                        _zCoinsSubtitleKey,
                        () {
                          // show bottom sheet with user's Z Coins
                          _showZCoinsSheet(context, isDark);
                        },
                      ),
                      _buildDivider(isDark),

                      // Preferences
                      _buildMenuItem(
                        context,
                        isDark,
                        Icons.category_outlined,
                        _preferencesTitleKey,
                        _preferencesSubtitleKey,
                        () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return Preferences();
                              },
                            ),
                          );
                        },
                      ),
                      _buildDivider(isDark),

                      // App Language
                      _buildMenuItem(
                        context,
                        isDark,
                        Icons.language_outlined,
                        _languageTitleKey,
                        _languageSubtitleKey,
                        () {
                          showAppLanguages(isDark);
                        },
                      ),
                      _buildDivider(isDark),

                      // App Theme
                      _buildMenuItem(
                        context,
                        isDark,
                        Icons.contrast_outlined,
                        _themeTitleKey,
                        _themeSubtitleKey,
                        () {
                          showAppColorThemes(isDark);
                        },
                      ),
                      _buildDivider(isDark),

                      // Help & Support
                      _buildMenuItem(
                        context,
                        isDark,
                        Icons.help_outline,
                        _helpTitleKey,
                        _helpSubtitleKey,
                        () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return ChatScreen();
          }));
                        },
                      ),
                      _buildDivider(isDark),

                      // Logout
                      _buildMenuItem(
                        context,
                        isDark,
                        Icons.logout_outlined,
                        _logoutTitleKey,
                        _logoutSubtitleKey,
                        () {
                          _showLogoutDialog(context, isDark);
                        },
                      ),
                      Divider(
                        color: Colors.transparent,
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                      ),
                      // SizedBox(height: 80),
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

  // Helper function to build menu items
  Widget _buildMenuItem(
    BuildContext context,
    bool isDark,
    IconData icon,
    String titleKey,
    String subtitleKey,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 40, right: 40),
      child: GestureDetector(
        onTap: onTap,
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
                    size: 30,
                    color:
                        isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTranslation(titleKey), // 🌍 Translated
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getBlack(),
                        ),
                      ),
                      SizedBox(
                        width: Reusable.getDeviceWidth(
                          context,
                          W: 260,
                        ),
                        child: Text(
                          _getTranslation(subtitleKey), // 🌍 Translated
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? Reusable.getLightGrey()
                                : Reusable.getDarkGrey(),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 20,
                color:
                    isDark ? Reusable.getLightGreen() : Reusable.getDarkGrey(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build dividers
  Widget _buildDivider(bool isDark) {
    return Divider(
      color: isDark
          ? Reusable.getTextGrey()
          : const Color.fromRGBO(81, 81, 81, 0.3),
      thickness: 1,
      indent: 20,
      endIndent: 20,
    );
  }
}