
import 'package:shared_preferences/shared_preferences.dart';

class WorkerSettings {
  // --- Data Properties ---
  String? workerId; // null by default, will be loaded from prefs
  bool isLoggedIn = false; // false by default, will be loaded from prefs
  String? email; // null by default, will be loaded from prefs

  // --- Singleton Setup ---
  static final WorkerSettings _instance = WorkerSettings._internal();

  // Private constructor
  WorkerSettings._internal();

  // Factory constructor to return the singleton instance
  factory WorkerSettings() {
    return _instance;
  }

  // --- Update Method (similar to updateSetttingWith) ---
  /// Updates the instance's properties and returns the updated instance.
  WorkerSettings updateWith({
    String? workerId,
    bool? isLoggedIn,
    String? email,
  }) {
    this.workerId = workerId ?? this.workerId;
    this.isLoggedIn = isLoggedIn ?? this.isLoggedIn;
    this.email = email ?? this.email;
    return this;
  }

  // --- Constants for SharedPreferences Keys ---
  static const _keyworkerId = 'workerId';
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyEmail = 'email';

  // --- Static Save Methods ---

  /// Saves the worker's ID to SharedPreferences.
  static Future<void> saveworkerId(String workerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyworkerId, workerId);
    // Also update the singleton instance
    _instance.updateWith(workerId: workerId);
  }

  /// Saves the worker's login status to SharedPreferences.
  static Future<void> saveIsLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    // Also update the singleton instance
    _instance.updateWith(isLoggedIn: isLoggedIn);
  }

  /// Saves the worker's email to SharedPreferences.
  static Future<void> saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    // Also update the singleton instance
    _instance.updateWith(email: email);
  }

  // --- Instance Load Methods ---

  /// Loads the worker settings and updates the instance properties.
  /// Returns the updated WorkerSettings instance.
  Future<WorkerSettings> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load and update workerId
    workerId = prefs.getString(_keyworkerId);

    // Load and update isLoggedIn
    isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false; // Default to false if null

    // Load and update email
    email = prefs.getString(_keyEmail);

    return this;
  }

  // --- Utility Method (Optional) ---

  /// Clears all worker-specific data.
  static Future<void> clearAllSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyworkerId);
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyEmail);

    // Also reset the singleton instance properties
    _instance.updateWith(
      workerId: null,
      isLoggedIn: false,
      email: null,
    );
  }
}


class WorkerThemeLangSettings {
  String? theme = "Light";
  String? locale = "en"; // keep it nullable for future use

  WorkerThemeLangSettings({required this.theme, this.locale});

  // copyWith allows updating theme or locale independently
  WorkerThemeLangSettings updateSetttingWith({String? theme, String? locale}) {
    return WorkerThemeLangSettings(
      theme: theme ?? this.theme,
      locale: locale ?? this.locale,
    );
  }

  static Future<void> saveSelectedTheme(String? theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', theme!);
  }

  static Future<void> saveSelectedLocale(String? locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (locale != null) await prefs.setString('locale', locale);
  }

  Future<String?> loadSelectedTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    theme = prefs.getString('theme');

    if (theme != null) {
      return theme;
    }
    return null;
  }

  Future<String?> loadSelectedLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    locale = prefs.getString('locale');
    return locale;
  }
}
