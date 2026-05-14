import 'package:shared_preferences/shared_preferences.dart';

class OwnerSettings {
  // --- Data Properties ---
  String? ownerId; // null by default, will be loaded from prefs
  String? ownerEmail; // null by default, will be loaded from prefs
  bool isLoggedIn = false; // false by default, will be loaded from prefs

  // --- Singleton Setup ---
  static final OwnerSettings _instance = OwnerSettings._internal();

  // Private constructor
  OwnerSettings._internal();

  // Factory constructor to return the singleton instance
  factory OwnerSettings() {
    return _instance;
  }

  // --- Update Method (similar to updateWith) ---
  /// Updates the instance's properties and returns the updated instance.
  OwnerSettings updateWith({
    String? ownerId,
    String? ownerEmail,
    // CONVERSION: Changed 'isSubscribed' to 'isLoggedIn'
    bool? isLoggedIn,
  }) {
    this.ownerId = ownerId ?? this.ownerId;
    this.ownerEmail = ownerEmail ?? this.ownerEmail;
    this.isLoggedIn = isLoggedIn ?? this.isLoggedIn; // Use the new property
    return this;
  }

  // --- Constants for SharedPreferences Keys ---
  static const _keyOwnerId = 'ownerId';
  static const _keyownerEmail = 'ownerEmail';
  // CONVERSION: Changed '_keyIsSubscribed' to '_keyIsLoggedIn'
  static const _keyIsLoggedIn = 'isLoggedIn';

  // --- Static Save Methods ---

  /// Saves the owner's ID to SharedPreferences.
  static Future<void> saveOwnerId(String ownerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyOwnerId, ownerId);
    // Also update the singleton instance
    _instance.updateWith(ownerId: ownerId);
  }

  /// Saves the store name to SharedPreferences.
  static Future<void> saveownerEmail(String ownerEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyownerEmail, ownerEmail);
    // Also update the singleton instance
    _instance.updateWith(ownerEmail: ownerEmail);
  }

  /// Saves the owner's login status to SharedPreferences.
  // CONVERSION: Changed 'saveIsSubscribed' to 'saveIsLoggedIn'
  static Future<void> saveIsLoggedIn(bool isLoggedIn) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Use the new key
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    // Also update the singleton instance
    _instance.updateWith(isLoggedIn: isLoggedIn);
  }

  // --- Instance Load Methods ---

  /// Loads the owner settings and updates the instance properties.
  /// Returns the updated OwnerSettings instance.
  Future<OwnerSettings> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load and update ownerId
    ownerId = prefs.getString(_keyOwnerId);

    // Load and update ownerEmail
    ownerEmail = prefs.getString(_keyownerEmail);

    // Load and update isLoggedIn
    // Use the new key
    isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false; // Default to false if null

    return this;
  }

  // --- Utility Method (Optional) ---

  /// Clears all owner-specific data.
  static Future<void> clearAllSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOwnerId);
    await prefs.remove(_keyownerEmail);
    // Use the new key
    await prefs.remove(_keyIsLoggedIn);

    // Also reset the singleton instance properties
    _instance.updateWith(
      ownerId: null,
      ownerEmail: null,
      isLoggedIn: false, // Use the new property
    );
  }
}




class OwnerThemeLangSettings {
  String? theme = "Light";
  String? locale = "en"; // keep it nullable for future use

  OwnerThemeLangSettings({required this.theme, this.locale});

  // copyWith allows updating theme or locale independently
  OwnerThemeLangSettings updateSetttingWith({String? theme, String? locale}) {
    return OwnerThemeLangSettings(
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