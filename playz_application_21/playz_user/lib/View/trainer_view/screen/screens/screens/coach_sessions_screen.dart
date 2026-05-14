import 'package:flutter/material.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
import 'package:playz_user/Helper/Trainer_Loader.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/language_screen.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/trainer_menu.dart';

  Map<String, String> _translationsCache = {};
  String _currentLang = "en";


const List<Map<String, dynamic>> turfInfo = []; // Assuming this list is empty/irrelevant for this screen, but needed for the logic.
// ----------------------------------------------------------------------


class CoachSessionsScreen extends StatefulWidget {
  const CoachSessionsScreen({super.key});

  @override
  State<CoachSessionsScreen> createState() => _CoachSessionsScreenState();
}

class _CoachSessionsScreenState extends State<CoachSessionsScreen> {
  // 1. Translation Cache Map

  // Current language to track changes

  // Translation key for the currently selected sport
  String selectedSport = "Cricket";

  // Session data (will not be translated, only the values used as keys in the list view)
  final List<Map<String, String>> sessions = [
    {
      "coach": "Aaryan Sharma",
      "time": "5:00 PM - 7:00 PM",
      "date": "20-08-2025",
      "venue": "Sunshine Sports Arena, Plot No..."
    },
    {
      "coach": "Shriraj Sharma",
      "time": "5:00 PM - 7:00 PM",
      "date": "20-08-2025",
      "venue": "Sunshine Sports Arena, Plot No..."
    },
    {
      "coach": "Rushkesh Sharma",
      "time": "5:00 PM - 7:00 PM",
      "date": "20-08-2025",
      "venue": "Sunshine Sports Arena, Plot No..."
    },
    {
      "coach": "Manish Sharma",
      "time": "5:00 PM - 7:00 PM",
      "date": "20-08-2025",
      "venue": "Sunshine Sports Arena, Plot No..."
    },
  ];

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  @override
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // 📝 Static Translation Keys from the screen
      "Sessions",
      "Cricket",
      "Football",
      // Add all potentially dynamic/data-driven strings that need translation
      for (var s in sessions) ...[
        s['coach']!,
        s['time']!,
        s['date']!,
        s['venue']!,
      ],
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
    String? selectedTheme = await TrainerThemeLangSettings(theme: null).loadSelectedTheme();
    isDarkTrainerThemeNotifier.value = selectedTheme == "Dark";
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
       
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkTrainerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme
            : CustomThemes.customLightTheme;

        return Theme(
          data: theme,
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: theme.colorScheme.background,
                drawer: const TrainerDrawer(),
                // 🔶 App Bar
                appBar: AppBar(
                  backgroundColor: theme.colorScheme.primary,
                  elevation: 0,
                  title: Text(
                    _getTranslation("Sessions"), // ⬅️ TRANSLATED
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  actions: [
                    Icon(Icons.notifications_none,
                        color: theme.colorScheme.onPrimary),
                    const SizedBox(width: 15),
                    Icon(Icons.chat_bubble_outline,
                        color: theme.colorScheme.onPrimary),
                    const SizedBox(width: 15),
                  ],
                ),
              
                // 🔶 Body
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tabs: Cricket / Football
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          _buildSportButton("Cricket", theme), // ⬅️ Uses translated key
                          const SizedBox(width: 8),
                          _buildSportButton("Football", theme), // ⬅️ Uses translated key
                        ],
                      ),
                    ),
              
                    // Session Cards
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) {
                          final s = sessions[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.shadowColor.withOpacity(0.1),
                                  blurRadius: 3,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Left side icon
                                Icon(Icons.sports_cricket,
                                    color: theme.colorScheme.primary, size: 28),
                                const SizedBox(width: 12),
              
                                // Divider line
                                Container(
                                  width: 1,
                                  height: 80,
                                  color: theme.dividerColor,
                                ),
                                const SizedBox(width: 12),
              
                                // Session Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Use translated text for data/placeholders
                                      _buildSessionDetail(
                                          Icons.person, _getTranslation(s["coach"]!), theme), // ⬅️ TRANSLATED
                                      const SizedBox(height: 4),
                                      _buildSessionDetail(
                                          Icons.access_time, _getTranslation(s["time"]!), theme), // ⬅️ TRANSLATED
                                      const SizedBox(height: 4),
                                      _buildSessionDetail(
                                          Icons.calendar_today, _getTranslation(s["date"]!), theme), // ⬅️ TRANSLATED
                                      const SizedBox(height: 4),
                                      _buildSessionDetail(
                                          Icons.location_on, _getTranslation(s["venue"]!), theme), // ⬅️ TRANSLATED
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),if (_translationsCache.isEmpty)
                const Positioned.fill(child: TrainerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }

  // 🔸 Helper for sport toggle buttons
  Widget _buildSportButton(String sportKey, ThemeData theme) {
    final bool isSelected = selectedSport == sportKey;
    return GestureDetector(
      onTap: () => setState(() => selectedSport = sportKey),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getTranslation(sportKey), // ⬅️ TRANSLATED
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // 🔸 Helper for each detail line
  Widget _buildSessionDetail(IconData icon, String translatedText, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            translatedText, // Already translated string is passed
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}