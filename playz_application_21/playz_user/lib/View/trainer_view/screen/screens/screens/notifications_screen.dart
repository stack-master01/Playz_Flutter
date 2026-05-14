import 'package:flutter/material.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
import 'package:playz_user/Helper/Trainer_Loader.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/language_screen.dart';

  Map<String, String> _translationsCache = {};
  String _currentLang = "en";


const List<Map<String, dynamic>> turfInfo = []; // Used for the dynamic keys getter, but empty for this screen.
// ----------------------------------------------------------------------

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // 1. Translation Cache Map

  // Current language to track changes

  // Screen state variables
  bool sessionUpdates = true;
  bool reviewUpdates = true;
  bool studentUpdates = true;

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  @override
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // 📝 Static Translation Keys from the screen
      "Notifications",
      "Session Updates",
      "Review Updates",
      "Student Updates",
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
    _loadTranslations(trainerAppLanguageNotifier.value);
  }

  @override
  void initState() {
    super.initState();
    if (_currentLang != trainerAppLanguageNotifier.value) {
_translationsCache.clear();
}
    _loadSelectedTheme();
    _loadSelectedLang();
    // Start listening for language changes to reload translations
    trainerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    trainerAppLanguageNotifier.removeListener(_languageChangeListener);
    super.dispose();
  }

  Future<void> _loadSelectedTheme() async {
    // This screen is theme-agnostic but the logic requires it.
    String? selectedTheme = await TrainerThemeLangSettings(theme: null).loadSelectedTheme();
    // Assuming isDarkTrainerThemeNotifier is a global notifier used elsewhere
    // isDarkTrainerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await TrainerThemeLangSettings(theme: null).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    trainerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet); // Initial load of translations
  }

  // 4. Helper to retrieve cached translation
  String _getTranslation(String key) {
    // Returns the cached translation or the original key if not found
    return _translationsCache[key] ?? key;
  }

  // --- WIDGET BUILD METHODS ---

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _getTranslation("Notifications"), // ⬅️ TRANSLATED
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationTile(
                  _getTranslation("Session Updates"), // ⬅️ TRANSLATED
                  sessionUpdates,
                  (value) => setState(() => sessionUpdates = value!),
                ),
                const SizedBox(height: 20),
                _buildNotificationTile(
                  _getTranslation("Review Updates"), // ⬅️ TRANSLATED
                  reviewUpdates,
                  (value) => setState(() => reviewUpdates = value!),
                ),
                const SizedBox(height: 20),
                _buildNotificationTile(
                  _getTranslation("Student Updates"), // ⬅️ TRANSLATED
                  studentUpdates,
                  (value) => setState(() => studentUpdates = value!),
                ),
              ],
            ),
          ),
        ),if (_translationsCache.isEmpty)
                const Positioned.fill(child: TrainerLoaderScreen()),
      ],
    );
  }

  // Helper function now accepts the already translated string
  Widget _buildNotificationTile(
      String translatedTitle, bool value, Function(bool?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          translatedTitle, // Already translated
          style: const TextStyle(
            color: Colors.deepOrange,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.deepOrange,
          checkColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}