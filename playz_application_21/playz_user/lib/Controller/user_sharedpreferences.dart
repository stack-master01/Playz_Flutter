import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter/material.dart';

class Appsharedpreferences {
  String? selectedCity;
  double? selectedLat;
  double? selectedLng;
  static Future<void> saveSelectedCity(String? city, LatLng? latLng) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCity', city!);
    await prefs.setDouble('selectedLat', latLng!.latitude);
    await prefs.setDouble('selectedLng', latLng.longitude);
  }

  Future<String?> loadSelectedCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedCity = prefs.getString('selectedCity');
    selectedLat = prefs.getDouble('selectedLat');
    selectedLng = prefs.getDouble('selectedLng');

    if (selectedCity != null && selectedLat != null && selectedLng != null) {
      return selectedCity;
    }
    return null;
  }

  Future<LatLng?> loadSelectedLatLng() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    selectedLat = prefs.getDouble('selectedLat');
    selectedLng = prefs.getDouble('selectedLng');

    if (selectedLat != null && selectedLng != null) {
      return LatLng(selectedLat!, selectedLng!);
    }
    return null;
  }
}

class ThemeSettings {
  String? theme = "Light";
  String? locale = "en"; // keep it nullable for future use

  ThemeSettings({required this.theme, this.locale});

  // copyWith allows updating theme or locale independently
  ThemeSettings updateSetttingWith({String? theme, String? locale}) {
    return ThemeSettings(
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

class UserSettings {
  // --- Data Properties ---
  String? userId; // null by default, will be loaded from prefs
  bool isLoggedIn = false; // false by default, will be loaded from prefs
  String? email; // null by default, will be loaded from prefs
  String? userName = 'username';
  String? userBio = 'Enter something about you!';
  String? imageURL =
      'https://t3.ftcdn.net/jpg/07/24/59/76/360_F_724597608_pmo5BsVumFcFyHJKlASG2Y2KpkkfiYUU.jpg';

  // --- Singleton Setup ---
  static final UserSettings _instance = UserSettings._internal();

  // Private constructor
  UserSettings._internal();

  // Factory constructor to return the singleton instance
  factory UserSettings() {
    return _instance;
  }

  // --- Update Method (similar to updateSetttingWith) ---
  /// Updates the instance's properties and returns the updated instance.
  UserSettings updateWith({
    String? userId,
    bool? isLoggedIn,
    String? email,
    String? userName,
    String? userBio,
    String? imageURL,
  }) {
    this.userId = userId ?? this.userId;
    this.isLoggedIn = isLoggedIn ?? this.isLoggedIn;
    this.email = email ?? this.email;
    this.userName = userName ?? this.userName;
    this.userBio = userBio ?? this.userBio;
    this.imageURL = imageURL ?? this.imageURL;
    return this;
  }

  // --- Constants for SharedPreferences Keys ---
  static const _keyUserId = 'userId';
  static const _keyIsLoggedIn = 'isLoggedIn';
  static const _keyEmail = 'email';
  static const _keyuserName = 'username';
  static const _keyuserBio = 'Enter something about you!';
  static const _keyimageURL =
      'https://t3.ftcdn.net/jpg/07/24/59/76/360_F_724597608_pmo5BsVumFcFyHJKlASG2Y2KpkkfiYUU.jpg';

  // --- Static Save Methods ---

  /// Saves the user's ID to SharedPreferences.
  static Future<void> saveUserId(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    // Also update the singleton instance
    _instance.updateWith(userId: userId);
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

  static Future<void> saveUserName(String userName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyuserName, userName);
    // Also update the singleton instance
    _instance.updateWith(userName: userName);
  }

  static Future<void> saveUserBio(String userBio) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyuserBio, userBio);
    // Also update the singleton instance
    _instance.updateWith(userBio: userBio);
  }

  static Future<void> saveUserProfileImageURL(String imageURL) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyimageURL, imageURL);
    // Also update the singleton instance
    _instance.updateWith(imageURL: imageURL);
  }

  // --- Instance Load Methods ---

  /// Loads the user settings and updates the instance properties.
  /// Returns the updated UserSettings instance.
  Future<UserSettings> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Load and update userId
    userId = prefs.getString(_keyUserId);

    // Load and update isLoggedIn
    isLoggedIn =
        prefs.getBool(_keyIsLoggedIn) ?? false; // Default to false if null

    // Load and update email
    email = prefs.getString(_keyEmail);

    userName = prefs.getString(_keyuserName);

    userBio = prefs.getString(_keyuserBio);

    imageURL = prefs.getString(_keyimageURL);
    return this;
  }

  // --- Utility Method (Optional) ---

  /// Clears all user-specific data.
  static Future<void> clearAllSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyimageURL);
    await prefs.remove(_keyuserBio);
    await prefs.remove(_keyuserName);

    // Also reset the singleton instance properties
    _instance.updateWith(userId: null, isLoggedIn: false, email: null);
  }
}
