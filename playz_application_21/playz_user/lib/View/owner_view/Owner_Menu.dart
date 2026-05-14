import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Helper/Owner_Loader.dart';
import 'package:playz_user/View/About_Us.dart';
import 'package:playz_user/View/navigationformodules.dart';
import 'package:playz_user/View/owner_view/ForgotPassword_Screen.dart';
import 'package:playz_user/View/owner_view/LanguageSelection_Screen.dart';
import 'package:playz_user/View/owner_view/Login_Screen.dart';
import 'package:playz_user/View/owner_view/Notification_Screen.dart';
  Map<String, String> _translationsCache = {};
  String _currentLang = "en";

// ----------------------------------------------------------------------
// --- PLACEHOLDER DEPENDENCIES (MOCK IMPLEMENTATIONS FOR TRANSLATION) ---
// ----------------------------------------------------------------------

// Global for language state
// final ValueNotifier<String> ownerAppLanguageNotifier = ValueNotifier<String>('en');

// Mock list for dynamic keys (turfInfo)
const List<Map<String, dynamic>> turfInfo = [
  {'turfName': 'Main Turf'},
  {'turfName': 'Small Ground'}
];



// ----------------------------------------------------------------------

// Global for pages that share the local theme
final ValueNotifier<bool> isDarkOwnerThemeNotifier = ValueNotifier(false); // false = light, true = dark


class CustomThemes {
  // Primary color constraint: Color.fromRGBO(13, 71, 161, 1) = 0xFF0D47A1
  static const Color _kPrimaryBaseColor = Color(0xFF0D47A1); // Deep Blue (Primary)
  
  // Base blue palette for consistency and contrast
  static const Color _kPrimaryLightColor = Color(0xFF4B77C2); // Lighter Blue (e.g., highlights)
  static const Color _kPrimaryDarkColor = Color(0xFF002071); // Dark Navy (e.g., strong accents)

  // Secondary color for accents/interactive elements
  static const Color _kSecondaryBaseColor = Color(0xFFC29B4B); // Gold/Amber for contrast and flair
  static const Color _kSecondaryLightColor = Color(0xFFD4B16A);
  static const Color _kSecondaryDarkColor = Color(0xFF9E7729);

  // Light Theme Surfaces/Backgrounds (ensuring background != surface)
  static const Color _lightBackground = Color(0xFFFAFAFA); // Off-White, main screen base
  static const Color _lightSurface = Color(0xFFE3E9F5); // Very light, cool gray/blue (Card/Widget background)
  static const Color _lightOnColor = Color(0xFF000A2C); // Very dark navy for text/icons on light surfaces
  static const Color _lightError = Color(0xFFB00020);

  // Dark Theme Surfaces/Backgrounds (ensuring background != surface)
  static const Color _darkBackground = Color(0xFF07101E); // Deepest Navy/Almost Black (Screen base)
  static const Color _darkSurface = Color(0xFF132036); // Slightly lighter dark navy (Card/Widget background)
  static const Color _darkOnColor = Color(0xFFEFEFEF); // Near-White for text/icons on dark surfaces
  static const Color _darkError = Color(0xFFCF6679);


  // ---------------- Light Theme ----------------
  static final ThemeData customLightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: _kPrimaryBaseColor,
      primaryContainer: _kPrimaryLightColor,
      secondary: _kSecondaryBaseColor,
      secondaryContainer: _kSecondaryLightColor,
      background: _lightBackground,
      surface: _lightSurface,
      error: _lightError,
      onPrimary: Colors.white, // White text on dark primary
      onSecondary: _lightOnColor, // Dark text on amber/gold secondary
      onBackground: _lightOnColor, // Dark text on off-white background
      onSurface: _kPrimaryDarkColor, // Dark navy text on light surface
    ),
    
    // AppBar provides contrast or separation from body
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightBackground,
      foregroundColor: _kPrimaryBaseColor, // Blue icons/text
      elevation: 1, // Slight lift for separation
    ),
    
    // Text themes rely on OnColors for high contrast
    textTheme: TextTheme(
      bodyLarge: const TextStyle(color: _lightOnColor),
      bodyMedium: TextStyle(color: _lightOnColor.withOpacity(0.8)),
      titleLarge: const TextStyle(color: _kPrimaryDarkColor, fontWeight: FontWeight.w700),
      headlineSmall: const TextStyle(color: _kPrimaryBaseColor),
      labelLarge: const TextStyle(color: _kSecondaryBaseColor),
    ),
    
    listTileTheme: const ListTileThemeData(
      iconColor: _kPrimaryBaseColor,
      textColor: _lightOnColor,
    ),
    
    cardColor: _lightSurface, // Use dedicated surface color
    scaffoldBackgroundColor: _lightBackground,
    // Use ColorScheme secondary for highlights for a non-blue contrast
    highlightColor: _kSecondaryBaseColor.withOpacity(0.15),
    splashColor: _kSecondaryBaseColor.withOpacity(0.25),
  );

  // ---------------- Dark Theme ----------------
  static final ThemeData customDarkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _kPrimaryBaseColor,
      primaryContainer: _kPrimaryLightColor,
      secondary: _kSecondaryBaseColor,
      secondaryContainer: _kSecondaryLightColor,
      background: _darkBackground,
      surface: _darkSurface,
      error: _darkError,
      onPrimary: Colors.white,
      onSecondary: _darkOnColor, // Light text on amber/gold secondary
      onBackground: _darkOnColor, // Light text on very dark background
      onSurface: _darkOnColor, // Light text on dark surface
    ),
    
    // AppBar provides contrast or separation from body
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBackground,
      foregroundColor: _darkOnColor, // Light icons/text
      elevation: 1, // Slight lift for separation
    ),
    
    // Text themes rely on OnColors for high contrast
    textTheme: TextTheme(
      bodyLarge: const TextStyle(color: _darkOnColor),
      bodyMedium: TextStyle(color: _darkOnColor.withOpacity(0.8)),
      titleLarge: const TextStyle(color: _darkOnColor, fontWeight: FontWeight.w700),
      headlineSmall: const TextStyle(color: _kPrimaryLightColor),
      labelLarge: const TextStyle(color: _kSecondaryBaseColor),
    ),
    
    listTileTheme: const ListTileThemeData(
      iconColor: _kPrimaryLightColor,
      textColor: _darkOnColor,
    ),
    
    cardColor: _darkSurface, // Use dedicated surface color
    scaffoldBackgroundColor: _darkBackground,
    // Use ColorScheme secondary for highlights for a non-blue contrast
    highlightColor: _kSecondaryBaseColor.withOpacity(0.15),
    splashColor: _kSecondaryBaseColor.withOpacity(0.25),
  );
}





// --- Logout Dialog ---
void showLogoutDialog(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  // Temporary state for the dialog to access the translation helper
  // NOTE: In a real app, you would pass the translation map down or use a global provider.
  final state = context.findAncestorStateOfType<_OwnerDrawerState>();
  String Function(String) getT = (key) => state?._getTranslation(key) ?? key;


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
              getT("Confirm Logout"), // Translated
              style: TextStyle(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          getT("Are you sure you want to log out of your account?"), // Translated
          style: TextStyle(color: colorScheme.primary, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              getT("CANCEL"), // Translated
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await OwnerSettings.clearAllSettings();
              OwnerThemeLangSettings.saveSelectedLocale("en");
              Navigator.of(dialogContext).pop(true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(getT('Logging out...'))), // Translated
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
              getT("LOGOUT"), // Translated
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
class OwnerDrawer extends StatefulWidget {
  const OwnerDrawer({super.key});

  @override
  State<OwnerDrawer> createState() => _OwnerDrawerState();
}

class _OwnerDrawerState extends State<OwnerDrawer> {
  // 1. Translation Cache Map
  // Current language to track changes

  bool _isDarkMode = isDarkOwnerThemeNotifier.value;

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // Original Keys
      "Turf Owner",
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Today's Income", "This Week's Income", "This Month's Income", "This Year's Income",
      "Reviews & Ratings",
      "INR 8900", "INR 53900", "INR 238900", "INR 3253900",
      "Income", "Expenditure",

      // Keys specific to OwnerDrawer UI
      "MENU", "App Preferences", "Dark Mode", "Light Mode", "Notifications",
      "App Language", "Support", "Contact Us", "FAQs", "Account & Security",
      "Set Password", "Delete Account", "Legal & Information", "Privacy Policy",
      "About App", "LOGOUT", "Confirm Logout", "Are you sure you want to log out of your account?",
      "CANCEL", "Logging out...", "Dark Mode Toggled ON", "Light Mode Toggled OFF",
    };

    // Add dynamic keys from the turfInfo list
    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName']);
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
    _loadTranslations(ownerAppLanguageNotifier.value);
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await OwnerThemeLangSettings(theme: null).loadSelectedTheme();
    isDarkOwnerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await OwnerThemeLangSettings(theme: null).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    ownerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet); // Initial load of translations
  }

  // 4. Helper to retrieve cached translation
  String _getTranslation(String key) {
    // Returns the cached translation or the original key if not found
    return _translationsCache[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    if (_currentLang != ownerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    // Start of translation logic integration
    _loadSelectedTheme();
    _loadSelectedLang();
    ownerAppLanguageNotifier.addListener(_languageChangeListener);
    // End of translation logic integration
  }

  @override
  void dispose() {
    ownerAppLanguageNotifier.removeListener(_languageChangeListener);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
     

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
                  _getTranslation("MENU"), // Translated
                  style: currentTheme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontSize: 32,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 10),
        
                Text(
                  _getTranslation("App Preferences"), // Translated
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
                      _getTranslation(_isDarkMode ? "Dark Mode" : "Light Mode"), // Translated
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    trailing: Switch(
                      value: _isDarkMode,
                      activeColor: colorScheme.secondary,
                      onChanged: (val) async {
                        setState(() {
                          _isDarkMode = val;
                        });
                        val?isDarkOwnerThemeNotifier.value = true:isDarkOwnerThemeNotifier.value=false;
                        log("${isDarkOwnerThemeNotifier.value}");
                        OwnerThemeLangSettings.saveSelectedTheme(val?"Dark":"Light");
                        log("${await OwnerThemeLangSettings(theme: null).loadSelectedTheme()}");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _getTranslation(val
                                  ? 'Dark Mode Toggled ON'
                                  : 'Light Mode Toggled OFF'), // Translated
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
                  title: _getTranslation("Notifications"), // Translated
                  colorScheme: colorScheme,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ownerNotificationScreen()),
                    );
                  },
                ),
        
                const Divider(height: 1),
        
                // --- Language ---
                _buildDrawerTile(
                  context,
                  icon: Icons.language,
                  title: _getTranslation("App Language"), // Translated
                  colorScheme: colorScheme,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ownerLanguageScreen()),
                    );
                  },
                  isBottom: true,
                ),
        
                const SizedBox(height: 20),
        
                Text(_getTranslation("Support"), style: currentTheme.textTheme.titleLarge), // Translated
                const SizedBox(height: 5),
        
                _buildDrawerTile(
                  context,
                  icon: Icons.support_agent,
                  title: _getTranslation("Contact Us"), // Translated
                  colorScheme: colorScheme,
                  onTap: () {},
                  isTop: true,
                ),
                const Divider(height: 1),
                _buildDrawerTile(
                  context,
                  icon: Icons.help_outline_rounded,
                  title: _getTranslation("FAQs"), // Translated
                  colorScheme: colorScheme,
                  onTap: () {},
                  isBottom: true,
                ),
        
                const SizedBox(height: 20),
        
                Text(_getTranslation("Account & Security"), // Translated
                    style: currentTheme.textTheme.titleLarge),
                const SizedBox(height: 5),
        
                _buildDrawerTile(
                  context,
                  icon: Icons.lock_outline,
                  title: _getTranslation("Set Password"), // Translated
                  colorScheme: colorScheme,
                  onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                   ownerForgotPasswordScreen(),
                  ));
                  },
                  isTop: true,
                ),
                const Divider(height: 1),
                _buildDrawerTile(
                  context,
                  icon: Icons.delete_outline_sharp,
                  title: _getTranslation("Delete Account"), // Translated
                  colorScheme: colorScheme,
                  onTap: () {},
                  isBottom: true,
                ),
        
                const SizedBox(height: 20),
        
                Text(_getTranslation("Legal & Information"), // Translated
                    style: currentTheme.textTheme.titleLarge),
                const SizedBox(height: 5),
        
                _buildDrawerTile(
                  context,
                  icon: Icons.policy_outlined,
                  title: _getTranslation("Privacy Policy"), // Translated
                  colorScheme: colorScheme,
                  onTap: () {},
                  isTop: true,
                ),
                const Divider(height: 1),
                _buildDrawerTile(
                  context,
                  icon: Icons.info_outline,
                  title: _getTranslation("About App"), // Translated
                  colorScheme: colorScheme,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context){
                      return TurfAboutPage();
                    }));
                  },
                  isBottom: true,
                ),
        
                const SizedBox(height: 30),
        
                // --- LOGOUT BUTTON ---
                ElevatedButton(
                  onPressed: () => showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(260, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_getTranslation("LOGOUT"), style: const TextStyle(fontSize: 20)), // Translated
                      const SizedBox(width: 10),
                      const Icon(Icons.logout_sharp),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),  if (_translationsCache.isEmpty)
                const Positioned.fill(child: OwnerLoaderScreen()),

      ],
    );
  }
}

// --- Helper for Drawer Tiles ---
Widget _buildDrawerTile(
    BuildContext context, {
    required IconData icon,
    required String title,
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