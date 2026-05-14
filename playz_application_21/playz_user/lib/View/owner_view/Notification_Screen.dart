import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Needed for Intl.
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Helper/Owner_Loader.dart';
import 'package:playz_user/View/owner_view/LanguageSelection_Screen.dart';
import 'package:playz_user/View/owner_view/Owner_Menu.dart';

  Map<String, String> _translationsCache = {};


// Renamed class to follow PascalCase convention
class ownerNotificationScreen extends StatefulWidget {
  const ownerNotificationScreen({super.key});

  @override
  // Renamed state creation
  State<ownerNotificationScreen> createState() => _ownerNotificationScreenState();
}

// Renamed state class to follow convention
class _ownerNotificationScreenState extends State<ownerNotificationScreen> {
  // --- START OF CACHED TRANSLATION LOGIC ---
  // 1. Translation Cache Map

  // Current language to track changes
  String _currentLang = "en";

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  List<String> get _allTranslationKeys {
    Set<String> keys = {
     
      // Keys specific to this screen
      "Notifications",
      "Booking Updates",
      "Review Updates",
      "Worker Updates",
    };

    // Add dynamic keys from the turfInfo list (Assuming turfInfo is globally available)
    // NOTE: Using a placeholder for turfInfo as it's not defined in the snippet
    const List<Map<String, String>> turfInfo = [
      {'turfName': 'Turf A'},
      {'turfName': 'Turf B'}
    ];
    for (var info in turfInfo) {
      if (info['turfName'] != null) {
        keys.add(info['turfName']!);
      }
    }

    return keys.toList();
  }

  // 3. Load Translations function
  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;

    // Simple check: if the language is the same and the number of keys matches the cached count, skip.
    if (_currentLang == lang && _translationsCache.keys.length == keysToLoad.length) {
      return;
    }
_translationsCache.clear();
    _currentLang = lang;
    Map<String, String> newTranslations = {};

    // Fetch all translations
    for (String key in keysToLoad) {
      // NOTE: getTranslatedText must be an available function
      String translated = await getTranslatedText(key, lang);
      newTranslations[key] = translated;
    }

    // Update state to trigger a re-render with cached values
    if (mounted) {
      setState(() {
        _translationsCache = newTranslations;
      });
    }
  }

  // Future for loading theme and language
  Future<void> _loadSelectedTheme() async {
    // NOTE: OwnerThemeLangSettings and isDarkOwnerThemeNotifier are assumed to be accessible.
    String? selectedTheme = await OwnerThemeLangSettings(theme: null).loadSelectedTheme();
    isDarkOwnerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    // NOTE: OwnerThemeLangSettings and ownerAppLanguageNotifier are assumed to be accessible.
    String? selectedLang = await OwnerThemeLangSettings(theme: null).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    ownerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet); // Initial load of translations
  }

  // Listener function to call _loadTranslations when the language notifier changes
  void _languageChangeListener() {
    // NOTE: ownerAppLanguageNotifier is assumed to be accessible.
    _loadTranslations(ownerAppLanguageNotifier.value);
  }

  // 4. Helper to retrieve cached translation
  String _getTranslation(String key) {
    // Returns the cached translation or the original key if not found
    return _translationsCache[key] ?? key;
  }
  // --- END OF CACHED TRANSLATION LOGIC ---


  bool bookingUpdates = true;
  bool reviewUpdates = true;
  bool workerUpdates = true;

  @override
  void initState() {
    super.initState();
    if (_currentLang != ownerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    // Translation logic initialization
    _loadSelectedTheme();
    _loadSelectedLang();
    // Start listening for language changes to reload translations
    ownerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    // Stop listening for language changes
    ownerAppLanguageNotifier.removeListener(_languageChangeListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while translations are fetching
     
    
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkOwnerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme
            : CustomThemes.customLightTheme;
        final primaryColor = theme.colorScheme.primary;
        final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

        return Theme(
          data: theme,
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: Text(_getTranslation('Notifications')), // Use translation
                  backgroundColor: primaryColor,
                ),
                body: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTranslation('Notifications'), // Use translation
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 20),
                      CheckboxListTile(
                        title: Text(
                          _getTranslation('Booking Updates'), // Use translation
                          style: TextStyle(color: textColor),
                        ),
                        activeColor: primaryColor,
                        value: bookingUpdates,
                        onChanged: (bool? value) {
                          setState(() {
                            bookingUpdates = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text(
                          _getTranslation('Review Updates'), // Use translation
                          style: TextStyle(color: textColor),
                        ),
                        activeColor: primaryColor,
                        value: reviewUpdates,
                        onChanged: (bool? value) {
                          setState(() {
                            reviewUpdates = value ?? false;
                          });
                        },
                      ),
                      CheckboxListTile(
                        title: Text(
                          _getTranslation('Worker Updates'), // Use translation
                          style: TextStyle(color: textColor),
                        ),
                        activeColor: primaryColor,
                        value: workerUpdates,
                        onChanged: (bool? value) {
                          setState(() {
                            workerUpdates = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),if (_translationsCache.isEmpty)
                const Positioned.fill(child: OwnerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }
}