import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';
import 'package:playz_user/Helper/Worker_Loader.dart';
import 'package:playz_user/View/navigationformodules.dart';
import 'package:playz_user/View/worker_view/worker_language.dart';
import 'package:playz_user/View/worker_view/worker_notification.dart';
  Map<String, String> _translationsCache = {};
  String _currentLang = "en";



// 📚 Placeholder/Mock definitions for dependencies

// Global for pages that share the local theme
final ValueNotifier<bool> isDarkWorkerThemeNotifier = ValueNotifier(false); // false = light, true = dark


// Mocking the imported screens

const List<Map<String, dynamic>> turfInfo = []; // Used for the dynamic keys getter, but empty for this screen.
// ----------------------------------------------------------------------


// --- Base Colors (Keep definitions for context) ---
const Color _kPrimaryBaseColor = Color.fromRGBO(81, 81, 81, 1);
// ... (rest of the CustomThemes definitions remain the same) ...
const Color _kHighlightBaseColor = Color.fromRGBO(237, 237, 237, 1);
const Color _kBrandButtonBaseColor = Color.fromARGB(255, 109, 77, 65);

// --- Custom Theme Definitions ---
class CustomThemes {
  // --- Light Theme Colors (Creamy and Warm) ---
  static const Color _lightPrimary = Color(0xFF9E7E6B); // Medium creamy brown (like Latte)
  static const Color _lightSecondary = Color(0xFFC89F82); // Soft, light caramel for accents
  
  // High-contrast background and surface for creaminess
  static const Color _lightBackground = Color(0xFFFAF6F2); // Very light, warm cream (Screen base)
  static const Color _lightSurface = Color(0xFFFFFFFF); // Pure white for cards/surfaces (Maximum contrast with background)
  static const Color _lightError = Color(0xFFC75555); // Muted dusty rose/red error

  // Text/Icon colors for maximum readability
  static const Color _lightOnPrimary = Colors.white; 
  static const Color _lightOnSecondary = Color(0xFF4B342A); // Dark brown text on caramel
  static const Color _lightOnBackground = Color(0xFF4B342A); // Dark brown text on cream
  static const Color _lightOnSurface = Color(0xFF4B342A); // Dark brown text on white surface

  // --- Dark Theme Colors (Rich and Warm) ---
  static const Color _darkPrimary = Color(0xFFD4AA70); // Lightened, rich toffee brown
  static const Color _darkSecondary = Color(0xFFF0E6D2); // Creamy beige accent
  
  // High-contrast dark background and surface for richness
  static const Color _darkBackground = Color(0xFF28201E); // Deep, warm espresso (Screen base)
  static const Color _darkSurface = Color(0xFF3C3330); // Slightly lighter warm dark brown for cards (Distinct elevation)
  static const Color _darkError = Color(0xFFE57373); // Muted light error red

  // Text/Icon colors for maximum readability
  static const Color _darkOnPrimary = Color(0xFF28201E); // Espresso text on toffee button
  static const Color _darkOnSecondary = Color(0xFF28201E); // Espresso text on creamy beige accent
  static const Color _darkOnBackground = Color(0xFFF0E6D2); // Creamy beige text on espresso background
  static const Color _darkOnSurface = Color(0xFFF0E6D2); // Creamy beige text on dark surface


  // ----------------------------------------------------------------------
  //                                LIGHT THEME
  // ----------------------------------------------------------------------

  static final ThemeData customLightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _lightPrimary,
      secondary: _lightSecondary,
      background: _lightBackground,
      surface: _lightSurface,
      error: _lightError,
      onPrimary: _lightOnPrimary,
      onSecondary: _lightOnSecondary,
      onBackground: _lightOnBackground,
      onSurface: _lightOnSurface,
    ),
    
    // AppBar should visually separate from the screen body
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightBackground, 
      foregroundColor: _lightOnBackground, // Dark brown icons/text
      elevation: 1, // Subtle lift
    ),
    
    // Text themes ensure dark brown on light background/surface
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _lightOnBackground),
      bodyMedium: TextStyle(color: _lightOnBackground),
      titleLarge: TextStyle(color: _lightPrimary),
    ),
    
    listTileTheme: const ListTileThemeData(
      iconColor: _lightPrimary,
      textColor: _lightOnSurface, 
    ),
    
    // Ensures buttons are clearly defined
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: _lightOnPrimary,
      ),
    ),
  );

  // ----------------------------------------------------------------------
  //                                DARK THEME
  // ----------------------------------------------------------------------

  static final ThemeData customDarkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimary,
      secondary: _darkSecondary,
      background: _darkBackground,
      surface: _darkSurface,
      error: _darkError,
      onPrimary: _darkOnPrimary, 
      onSecondary: _darkOnSecondary,
      onBackground: _darkOnBackground,
      onSurface: _darkOnSurface,
    ),
    
    // AppBar should visually separate from the screen body
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBackground, 
      foregroundColor: _darkOnBackground, // Creamy beige icons/text
      elevation: 1, // Subtle lift
    ),
    
    // Text themes ensure creamy beige on dark background/surface
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _darkOnBackground),
      bodyMedium: TextStyle(color: _darkOnBackground),
      titleLarge: TextStyle(color: _darkOnSurface),
    ),
    
    listTileTheme: const ListTileThemeData(
      iconColor: _darkPrimary,
      textColor: _darkOnSurface, 
    ),
    
    // Ensures buttons are clearly defined
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: _darkOnPrimary,
      ),
    ),
  );
}


// --- Logout Dialog (Updated to use _getTranslation) ---
void showLogoutDialog(BuildContext context, String Function(String) getTranslation) {
  final colorScheme = Theme.of(context).colorScheme;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: colorScheme.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: colorScheme.primary),
            const SizedBox(width: 10),
            Text(
              getTranslation("Confirm Logout"), // ⬅️ TRANSLATED
              style: TextStyle(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          getTranslation("Are you sure you want to log out of your account?"), // ⬅️ TRANSLATED
          style: TextStyle(color: colorScheme.primary, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              getTranslation("CANCEL"), // ⬅️ TRANSLATED
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              WorkerSettings.clearAllSettings();
              Navigator.of(dialogContext).pop(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(getTranslation('Logging out...'))), // ⬅️ TRANSLATED
              );
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
                return DummyNavigatorScreen();
              },), (Route<dynamic> route) => false);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              getTranslation("LOGOUT"), // ⬅️ TRANSLATED
              style: TextStyle(
                color: colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

// --- Drawer Widget ---
class WorkerDrawer extends StatefulWidget {
  const WorkerDrawer({super.key});

  @override
  State<WorkerDrawer> createState() => _WorkerDrawerState();
}

class _WorkerDrawerState extends State<WorkerDrawer> {
  // 1. Translation Cache Map

  // Current language to track changes

  // Local state for theme toggle
  bool _isDarkMode = isDarkWorkerThemeNotifier.value;

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  @override
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // Static Text Keys
      "MENU",
      "App Preferences",
      "Dark Mode",
      "Light Mode",
      "Dark Mode Toggled ON",
      "Light Mode Toggled OFF",
      "Notifications",
      "App Language",
      "Support",
      "Contact Us",
      "FAQs",
      "Account & Security",
      "Set Password",
      "Delete Account",
      "Legal & Information",
      "Privacy Policy",
      "About App",
      "LOGOUT",
      // Dialog Keys
      "Confirm Logout",
      "Are you sure you want to log out of your account?",
      "CANCEL",
      'Logging out...',
    };

    // Add dynamic keys from the turfInfo list (if applicable to this screen)
    for (var info in turfInfo) {
      // Safely access 'turfName', as it might be used for venue translation
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
    String? selectedTheme = await WorkerThemeLangSettings(theme: null).loadSelectedTheme();
    isDarkWorkerThemeNotifier.value = selectedTheme == "Dark";
    // Also update the local state to match the global notifier
    _isDarkMode = isDarkWorkerThemeNotifier.value;
  }

  Future<void> _loadSelectedLang() async {
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


  // --- WIDGET BUILD ---
  @override
  Widget build(BuildContext context) {
       
    // Re-read theme setting as it might be updated from outside or init
    _isDarkMode = isDarkWorkerThemeNotifier.value;
    final currentTheme =
        _isDarkMode ? CustomThemes.customDarkTheme : CustomThemes.customLightTheme;
    final colorScheme = currentTheme.colorScheme;

    return Stack(
      children: [
        Theme(
          data: currentTheme,
          child: Drawer(
            child: ListView(
              padding: const EdgeInsets.all(30),
              children: [
                const SizedBox(height: 10),
        
                Text(
                  _getTranslation("MENU"), // ⬅️ TRANSLATED
                  style: currentTheme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 10),
        
                Text(
                  _getTranslation("App Preferences"), // ⬅️ TRANSLATED
                  style: currentTheme.textTheme.titleLarge,
                ),
                const SizedBox(height: 5),
        
                // --- THEME TOGGLE ---
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      _isDarkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      color: colorScheme.primary,
                    ),
                    title: Text(
                      _getTranslation(_isDarkMode ? "Dark Mode" : "Light Mode"), // ⬅️ TRANSLATED
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    trailing: Switch(
                      value: _isDarkMode,
                      activeColor: colorScheme.secondary,
                      onChanged: (val) async {
                        setState(() {
                          _isDarkMode = val;
                        });
                        val?isDarkWorkerThemeNotifier.value = true:isDarkWorkerThemeNotifier.value=false;
                        log("${isDarkWorkerThemeNotifier.value}");
                        WorkerThemeLangSettings.saveSelectedTheme(val?"Dark":"Light");
                        log("${await WorkerThemeLangSettings(theme: null).loadSelectedTheme()}");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _getTranslation(val
                                  ? 'Dark Mode Toggled ON'
                                  : 'Light Mode Toggled OFF'), // ⬅️ TRANSLATED
                            ),
                            duration: const Duration(milliseconds: 700),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        
                const Divider(height: 1),
        
                // --- Notifications ---
                _buildDrawerTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: _getTranslation("Notifications"), // ⬅️ TRANSLATED
                  colorScheme: colorScheme,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => workernotification()),
                    );
                  },
                ),
        
                const Divider(height: 1),
        
                // --- Language ---
                _buildDrawerTile(
                  context,
                  icon: Icons.language,
                  title: _getTranslation("App Language"), // ⬅️ TRANSLATED
                  colorScheme: colorScheme,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => WorkerLanguage()),
                    );
                  },
                  isBottom: true,
                ),
        
                const SizedBox(height: 20),
        
                Text(_getTranslation("Support"), style: currentTheme.textTheme.titleLarge), // ⬅️ TRANSLATED
                const SizedBox(height: 5),
        
                _buildDrawerTile(
                  context,
                  icon: Icons.support_agent,
                  title: _getTranslation("Contact Us"), // ⬅️ TRANSLATED
                  colorScheme: colorScheme,
                  onTap: () {},
                  isTop: true,
                ),
                const Divider(height: 1),
                _buildDrawerTile(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: _getTranslation("FAQs"), // ⬅️ TRANSLATED
                  colorScheme: colorScheme,
                  onTap: () {},
                  isBottom: true,
                ),
        
                const SizedBox(height: 20),
        
                Text(_getTranslation("Account & Security"), // ⬅️ TRANSLATED
                    style: currentTheme.textTheme.titleLarge),
                const SizedBox(height: 5),
        
                _buildDrawerTile(
                  context,
                  icon: Icons.lock_outline,
                  title: _getTranslation("Set Password"), // ⬅️ TRANSLATED
                  colorScheme: colorScheme,
                  onTap: () {},
                  isTop: true,
                ),
                const Divider(height: 1),
                _buildDrawerTile(
                  context,
                  icon: Icons.delete_outline_sharp,
                  title: _getTranslation("Delete Account"), // ⬅️ TRANSLATED
                  colorScheme: colorScheme,
                  onTap: () {},
                  isBottom: true,
                ),
        
                const SizedBox(height: 20),
        
                Text(_getTranslation("Legal & Information"), // ⬅️ TRANSLATED
                    style: currentTheme.textTheme.titleLarge),
                const SizedBox(height: 5),
        
                _buildDrawerTile(
                  context,
                  icon: Icons.policy_outlined,
                  title: _getTranslation("Privacy Policy"), // ⬅️ TRANSLATED
                  colorScheme: colorScheme,
                  onTap: () {},
                  isTop: true,
                ),
                const Divider(height: 1),
                _buildDrawerTile(
                  context,
                  icon: Icons.info_outline,
                  title: _getTranslation("About App"), // ⬅️ TRANSLATED
                  colorScheme: colorScheme,
                  onTap: () {},
                  isBottom: true,
                ),
        
                const SizedBox(height: 30),
        
                // --- LOGOUT BUTTON ---
                ElevatedButton(
                  onPressed: () => showLogoutDialog(context, _getTranslation), // ⬅️ Passed _getTranslation
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(260, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_getTranslation("LOGOUT"), style: const TextStyle(fontSize: 20)), // ⬅️ TRANSLATED
                      const SizedBox(width: 10),
                      const Icon(Icons.logout_sharp),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),if (_translationsCache.isEmpty)
                const Positioned.fill(child: WorkerLoaderScreen()),
      ],
    );
  }
}

// --- Helper for Drawer Tiles (Title is now a required translated string) ---
Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title, // This is expected to be a translated string
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    bool isTop = false,
    bool isBottom = false,
}) {
  BorderRadius? borderRadius;
  if (isTop && !isBottom) {
    borderRadius = const BorderRadius.only(
        topLeft: Radius.circular(15), topRight: Radius.circular(15));
  } else if (isBottom && !isTop) {
    borderRadius = const BorderRadius.only(
        bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15));
  } else if (isTop && isBottom) {
    borderRadius = BorderRadius.circular(15);
  } else {
    borderRadius = BorderRadius.zero;
  }

  return Container(
    decoration: BoxDecoration(
      color: colorScheme.surface,
      borderRadius: borderRadius,
    ),
    child: ListTile(
      leading: Icon(icon, color: colorScheme.primary),
      title: Text(title, style: TextStyle(color: colorScheme.onSurface)),
      trailing:
          Icon(Icons.arrow_forward_ios_outlined, color: colorScheme.primary),
      onTap: onTap,
    ),
  );
}