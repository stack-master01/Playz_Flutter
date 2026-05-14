import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/View/navigationformodules.dart';
import 'package:playz_user/View/owner_view/LanguageSelection_Screen.dart';
import 'package:playz_user/View/owner_view/Notification_Screen.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/language_screen.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/notifications_screen.dart';

// Global for pages that share the local theme
final ValueNotifier<bool> isDarkTrainerThemeNotifier = ValueNotifier(
  false,
); // false = light, true = dark

// --- Base Colors ---
Color _kDeepOrangePrimary = Colors.deepOrange;
// Deep Orange Accent is typically a lighter shade for buttons/highlights.
Color _kDeepOrangeAccent = Colors.deepOrangeAccent;
// A dark shade of the color for background in dark mode
Color _kDeepOrangeDarkBackground = Color(
  0xFF212121,
); // Dark Grey/Blackish for contrast
Color _kDeepOrangeDarkSurface = Color(0xFF424242);

// --- Custom Theme Definitions ---
class CustomThemes {
  // Deep Orange shades for light theme with improved shading and contrast
  static const Color _deepOrangePrimaryLight = Color(
    0xFFBF360C,
  ); // Dark deep orange
  static const Color _deepOrangeSecondaryLight = Color(
    0xFFFF7043,
  ); // Accent orange
  static const Color _deepOrangeBackgroundLight = Color(
    0xFFFAF3EB,
  ); // Warm off-white background
  static const Color _deepOrangeSurfaceLight = Color(
    0xFFFFEDE2,
  ); // Soft surface shade
  static const Color _deepOrangeOnPrimaryLight = Colors.white;
  static const Color _deepOrangeOnSecondaryLight = Colors.white;
  static const Color _deepOrangeTextLight = Color(
    0xFF4E342E,
  ); // Dark brownish text

  // Dark mode colors with deep orange and charcoal theme
  static const Color _charcoalBackgroundDark = Color(0xFF121212);
  static const Color _charcoalSurfaceDark = Color(0xFF1E1E1E);
  static const Color _deepOrangePrimaryDark = Color(
    0xFFFF5722,
  ); // Deep orange bright
  static const Color _deepOrangeSecondaryDark = Color(
    0xFFFF7043,
  ); // Lighter deep orange accent
  static const Color _deepOrangeOnPrimaryDark = Color(
    0xFFE0E0E0,
  ); // Light gray text on primary
  static const Color _deepOrangeTextDark = Color(
    0xFFE0E0E0,
  ); // Light gray text for readability

  // ---------------- Improved Light Theme ----------------
  static final ThemeData customLightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _deepOrangePrimaryLight,
      secondary: _deepOrangeSecondaryLight,
      background: _deepOrangeBackgroundLight,
      surface: _deepOrangeSurfaceLight,
      onPrimary: _deepOrangeOnPrimaryLight,
      onSecondary: _deepOrangeOnSecondaryLight,
      onBackground: _deepOrangeTextLight,
      onSurface: _deepOrangePrimaryLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _deepOrangeBackgroundLight,
      foregroundColor: _deepOrangePrimaryLight,
      elevation: 0,
    ),
    scaffoldBackgroundColor: _deepOrangeBackgroundLight,
    cardColor: _deepOrangeSurfaceLight,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _deepOrangeTextLight),
      bodyMedium: TextStyle(color: _deepOrangeTextLight),
      titleLarge: TextStyle(color: _deepOrangePrimaryLight),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: _deepOrangePrimaryLight,
      textColor: _deepOrangePrimaryLight,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _deepOrangeSecondaryLight,
      foregroundColor: Colors.white,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: _deepOrangePrimaryLight,
      textTheme: ButtonTextTheme.primary,
    ),
  );

  // ---------------- Dark Theme ----------------
  static final ThemeData customDarkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: _deepOrangePrimaryDark,
      secondary: _deepOrangeSecondaryDark,
      background: _charcoalBackgroundDark,
      surface: _charcoalSurfaceDark,
      onPrimary: _deepOrangeOnPrimaryDark,
      onSecondary: _deepOrangeOnPrimaryDark,
      onBackground: _deepOrangeTextDark,
      onSurface: _deepOrangeOnPrimaryDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _charcoalBackgroundDark,
      foregroundColor: _deepOrangeOnPrimaryDark,
      elevation: 0,
    ),
    scaffoldBackgroundColor: _charcoalBackgroundDark,
    cardColor: _charcoalSurfaceDark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: _deepOrangeTextDark),
      bodyMedium: TextStyle(color: _deepOrangeTextDark),
      titleLarge: TextStyle(color: _deepOrangeOnPrimaryDark),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: _deepOrangeTextDark,
      textColor: _deepOrangeTextDark,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _deepOrangeSecondaryDark,
      foregroundColor: Colors.white,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: _deepOrangePrimaryDark,
      textTheme: ButtonTextTheme.primary,
    ),
  );
}

// --- Logout Dialog ---
void showLogoutDialog(BuildContext context) {
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
              "Confirm Logout",
              style: TextStyle(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to log out of your account?",
          style: TextStyle(color: colorScheme.primary, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              "CANCEL",
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              OwnerSettings.clearAllSettings();
              Navigator.of(dialogContext).pop(true);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) {
                  return DummyNavigatorScreen();
                }),
                (Route<dynamic> route) => false,
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logging out...')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              "LOGOUT",
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
class TrainerDrawer extends StatefulWidget {
  const TrainerDrawer({super.key});

  @override
  State<TrainerDrawer> createState() => _TrainerDrawerState();
}

class _TrainerDrawerState extends State<TrainerDrawer> {
  bool _isDarkMode = isDarkTrainerThemeNotifier.value;

  @override
  Widget build(BuildContext context) {
    final currentTheme = _isDarkMode
        ? CustomThemes.customDarkTheme
        : CustomThemes.customLightTheme;
    final colorScheme = currentTheme.colorScheme;

    return Theme(
      data: currentTheme,
      child: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(30),
          children: [
            const SizedBox(height: 10),

            Text(
              "MENU",
              style: currentTheme.textTheme.titleLarge?.copyWith(
                color: colorScheme.primary,
                fontSize: 32,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),

            Text("App Preferences", style: currentTheme.textTheme.titleLarge),
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
                  _isDarkMode ? "Dark Mode" : "Light Mode",
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                trailing: Switch(
                  value: _isDarkMode,
                  activeColor: colorScheme.secondary,
                  onChanged: (val) async {
                    setState(() {
                      _isDarkMode = val;
                    });
                    val
                        ? isDarkTrainerThemeNotifier.value = true
                        : isDarkTrainerThemeNotifier.value = false;
                    log("${isDarkTrainerThemeNotifier.value}");
                    OwnerThemeLangSettings.saveSelectedTheme(
                      val ? "Dark" : "Light",
                    );
                    log(
                      "${await OwnerThemeLangSettings(theme: null).loadSelectedTheme()}",
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val
                              ? 'Dark Mode Toggled ON'
                              : 'Light Mode Toggled OFF',
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
              title: "Notifications",
              colorScheme: colorScheme,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => NotificationsScreen()),
                );
              },
            ),

            const Divider(height: 1),

            // --- Language ---
            _buildDrawerTile(
              context,
              icon: Icons.language,
              title: "App Language",
              colorScheme: colorScheme,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TrainerLanguageScreen()),
                );
              },
              isBottom: true,
            ),

            const SizedBox(height: 20),

            Text("Support", style: currentTheme.textTheme.titleLarge),
            const SizedBox(height: 5),

            _buildDrawerTile(
              context,
              icon: Icons.support_agent,
              title: "Contact Us",
              colorScheme: colorScheme,
              onTap: () {},
              isTop: true,
            ),
            const Divider(height: 1),
            _buildDrawerTile(
              context,
              icon: Icons.help_outline_rounded,
              title: "FAQs",
              colorScheme: colorScheme,
              onTap: () {},
              isBottom: true,
            ),

            const SizedBox(height: 20),

            Text(
              "Account & Security",
              style: currentTheme.textTheme.titleLarge,
            ),
            const SizedBox(height: 5),

            _buildDrawerTile(
              context,
              icon: Icons.lock_outline,
              title: "Set Password",
              colorScheme: colorScheme,
              onTap: () {},
              isTop: true,
            ),
            const Divider(height: 1),
            _buildDrawerTile(
              context,
              icon: Icons.delete_outline_sharp,
              title: "Delete Account",
              colorScheme: colorScheme,
              onTap: () {},
              isBottom: true,
            ),

            const SizedBox(height: 20),

            Text(
              "Legal & Information",
              style: currentTheme.textTheme.titleLarge,
            ),
            const SizedBox(height: 5),

            _buildDrawerTile(
              context,
              icon: Icons.policy_outlined,
              title: "Privacy Policy",
              colorScheme: colorScheme,
              onTap: () {},
              isTop: true,
            ),
            const Divider(height: 1),
            _buildDrawerTile(
              context,
              icon: Icons.info_outline,
              title: "About App",
              colorScheme: colorScheme,
              onTap: () {},
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("LOGOUT", style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Icon(Icons.logout_sharp),
                ],
              ),
            ),
          ],
        ),
      ),
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
      topLeft: Radius.circular(15),
      topRight: Radius.circular(15),
    );
  } else if (isBottom && !isTop) {
    borderRadius = const BorderRadius.only(
      bottomLeft: Radius.circular(15),
      bottomRight: Radius.circular(15),
    );
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
      trailing: Icon(
        Icons.arrow_forward_ios_outlined,
        color: colorScheme.primary,
      ),
      onTap: onTap,
    ),
  );
}
