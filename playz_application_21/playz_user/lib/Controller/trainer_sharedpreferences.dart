import 'package:shared_preferences/shared_preferences.dart';

class TrainerSettings {
  // --- Data Properties ---
  String? trainerId; // null by default, will be loaded from prefs
  bool isLoggedIn = false; // false by default, will be loaded from prefs
  String? trainerEmail; // null by default, will be loaded from prefs
  String? trainerName;

  // --- Singleton Setup ---
  static final TrainerSettings _instance = TrainerSettings._internal();

  // Private constructor
  TrainerSettings._internal();

  // Factory constructor to return the singleton instance
  factory TrainerSettings() {
    return _instance;
  }

  // --- Update Method (similar to updateSetttingWith) ---
  /// Updates the instance's properties and returns the updated instance.
  TrainerSettings updateWith({
    String? userId,
    bool? isLoggedIn,
    String? email,
    String? trainerName,
  }) {
    this.trainerId = userId ?? this.trainerId;
    this.isLoggedIn = isLoggedIn ?? this.isLoggedIn;
    this.trainerEmail = email ?? this.trainerEmail;
    this.trainerName = trainerName ?? this.trainerName;
    return this;
  }

  // --- Constants for SharedPreferences Keys ---
  static const _keyUserId = 'userId';
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyEmail = 'email';
  static const _keyTrainerName = 'Trainer';

  // --- Static Save Methods ---

  /// Saves the user's ID to SharedPreferences.
  static Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    // Also update the singleton instance
    _instance.updateWith(userId: userId);
  }

 static Future<void> saveTrainerName(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTrainerName, userId);
    // Also update the singleton instance
    _instance.updateWith(trainerName: userId);
  }
  /// Saves the user's login status to SharedPreferences.
  static Future<void> saveIsLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    // Also update the singleton instance
    _instance.updateWith(isLoggedIn: isLoggedIn);
  }

  /// Saves the user's email to SharedPreferences.
  static Future<void> saveEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    // Also update the singleton instance
    _instance.updateWith(email: email);
  }

  // --- Instance Load Methods ---

  /// Loads the user settings and updates the instance properties.
  /// Returns the updated UserSettings instance.
  Future<TrainerSettings> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load and update userId
    trainerId = prefs.getString(_keyUserId);

    // Load and update isLoggedIn
    isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false; // Default to false if null

    // Load and update email
    trainerEmail = prefs.getString(_keyEmail);

    trainerName = prefs.getString(_keyTrainerName);

    return this;
  }

  // --- Utility Method (Optional) ---

  /// Clears all user-specific data.
  static Future<void> clearAllSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyEmail);

    // Also reset the singleton instance properties
    _instance.updateWith(
      userId: null,
      isLoggedIn: false,
      email: null,
    );
  }
}



class TrainerThemeLangSettings {
  String? theme = "Light";
  String? locale = "en"; // keep it nullable for future use

  TrainerThemeLangSettings({required this.theme, this.locale});

  // copyWith allows updating theme or locale independently
  TrainerThemeLangSettings updateSetttingWith({String? theme, String? locale}) {
    return TrainerThemeLangSettings(
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