import 'package:flutter/material.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';
import 'package:playz_user/Helper/Worker_Loader.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/trainer_menu.dart';
import 'package:playz_user/View/worker_view/worker_language.dart';

  Map<String, String> _translationsCache = {};
const List<Map<String, dynamic>> turfInfo = []; // Used for dynamic keys in the provided snippet
  String _currentLang = "en";

class workernotification extends StatefulWidget {
  const workernotification({super.key});

  @override
  State createState() => workernotificationstate();
}

class workernotificationstate extends State<workernotification> {
  // 1. Translation Cache Map
  // Current language to track changes

  bool isworker = false;
  bool isattendence = false;
  bool isReview = false;

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // Screen-specific static texts
      "Notification",
      "Work Updates",
      "Review Updates",
      "Attendance Updates",
    };

    // Add dynamic keys from the turfInfo list (if applicable to this screen)
    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }

    return keys.toList();
  }

  // 3. Load Translations function
  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;

    // Basic check: if the language is the same and the number of keys matches the cached count, skip.
    if (_currentLang == lang && _translationsCache.keys.length == keysToLoad.length) {
      return;
    }

    _currentLang = lang;
    Map<String, String> newTranslations = {};

    // Fetch all translations
    for (String key in keysToLoad) {
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

  // Listener function to call _loadTranslations when the language notifier changes
  void _languageChangeListener() {
    _loadTranslations(workerAppLanguageNotifier.value);
  }

  @override
  void initState() {
    super.initState();
    if (_currentLang != workerAppLanguageNotifier.value) {
_translationsCache.clear();
}
    _loadSelectedTheme();
    _loadSelectedLang();
    // Start listening for language changes to reload translations
    workerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    workerAppLanguageNotifier.removeListener(_languageChangeListener);
    super.dispose();
  }

  Future<void> _loadSelectedTheme() async {
    // Note: Assuming you need this for theme/localization setup
    String? selectedTheme = await WorkerThemeLangSettings(theme: null).loadSelectedTheme();
    isDarkTrainerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    // Note: Assuming you need this for theme/localization setup
    String? selectedLang = await WorkerThemeLangSettings(theme: null).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    workerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet); // Initial load of translations
  }

  // 4. Helper to retrieve cached translation
  String _getTranslation(String key) {
    // Returns the cached translation or the original key if not found
    return _translationsCache[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    
    
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(
              _getTranslation("Notification"), // ⬅️ TRANSLATED
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black, // Adjust for theme if necessary
              ),
            ),
          ),
          body: Column(
            children: [
              _buildNotificationRow(
                context,
                "Work Updates", // Key
                isworker,
                (value) => isworker = value,
                const SizedBox(width: 170),
              ),
              _buildNotificationRow(
                context,
                "Review Updates", // Key
                isReview,
                (value) => isReview = value,
                const SizedBox(width: 152),
              ),
              _buildNotificationRow(
                context,
                "Attendance Updates", // Key
                isattendence,
                (value) => isattendence = value,
                const SizedBox(width: 112),
              ),
            ],
          ),
        ),if (_translationsCache.isEmpty)
                const Positioned.fill(child: WorkerLoaderScreen()),
      ],
    );
  }

  Widget _buildNotificationRow(
    BuildContext context,
    String translationKey,
    bool currentValue,
    Function(bool) onChanged,
    Widget spacer,
  ) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Text(
          _getTranslation(translationKey), // ⬅️ TRANSLATED
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black, // Adjust for theme if necessary
          ),
        ),
        // Note: Using SizedBox for spacing is fragile for varying translation lengths.
        // Consider using Spacer() or padding/alignment instead for better layout adaptivity.
        spacer, 
        Checkbox(
          value: currentValue,
          activeColor: Colors.green,
          onChanged: (bool? value) {
            setState(() {
              onChanged(value ?? false);
            });
          },
        ),
      ],
    );
  }
}