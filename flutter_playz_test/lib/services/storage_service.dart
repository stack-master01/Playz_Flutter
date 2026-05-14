import 'package:shared_preferences/shared_preferences.dart';

/// Keys used across the app for SharedPreferences.
class _Keys {
  static const email    = 'user_email';
  static const phone    = 'user_phone';
  static const password = 'user_password';
  static const name     = 'user_name';
  static const userOtp  = 'user_otp';
}

/// Singleton service wrapping SharedPreferences.
/// Call [StorageService.init()] once at app startup.
class StorageService {
  StorageService._();
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Getters ──────────────────────────────────────────────────────
  static String get email    => _prefs.getString(_Keys.email)    ?? '';
  static String get phone    => _prefs.getString(_Keys.phone)    ?? '';
  static String get password => _prefs.getString(_Keys.password) ?? '';
  static String get name     => _prefs.getString(_Keys.name)     ?? '';
  static String get userOtp  => _prefs.getString(_Keys.userOtp)  ?? '';
  static bool   get isLoggedIn => email.isNotEmpty || phone.isNotEmpty;

  // ── Setters ──────────────────────────────────────────────────────
  static Future<void> setEmail(String v)    => _prefs.setString(_Keys.email,    v);
  static Future<void> setPhone(String v)    => _prefs.setString(_Keys.phone,    v);
  static Future<void> setPassword(String v) => _prefs.setString(_Keys.password, v);
  static Future<void> setName(String v)     => _prefs.setString(_Keys.name,     v);
  static Future<void> setUserOtp(String v)  => _prefs.setString(_Keys.userOtp,  v);

  /// Save all user fields at once (on login / register).
  static Future<void> saveUser({
    required String email,
    required String phone,
    required String password,
    String name = '',
    String userOtp = '',
  }) async {
    await Future.wait([
      setEmail(email),
      setPhone(phone),
      setPassword(password),
      setName(name),
      setUserOtp(userOtp),
    ]);
  }

  /// Wipe all stored user data (on logout).
  static Future<void> clearUser() async {
    await Future.wait([
      _prefs.remove(_Keys.email),
      _prefs.remove(_Keys.phone),
      _prefs.remove(_Keys.password),
      _prefs.remove(_Keys.name),
      _prefs.remove(_Keys.userOtp),
    ]);
  }
}
