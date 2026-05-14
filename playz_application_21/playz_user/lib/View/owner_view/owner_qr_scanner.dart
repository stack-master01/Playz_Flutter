import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:playz_user/Controller/User_Controller/User_Upload_Booking_Controller.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Helper/Owner_Loader.dart';
import 'package:playz_user/View/owner_view/Book_Verification_Success.dart';
import 'package:playz_user/View/owner_view/LanguageSelection_Screen.dart';
import 'package:playz_user/View/owner_view/Owner_Menu.dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

// Example: You must already have these imported somewhere globally
// import 'package:playz_user/Utils/OwnerThemeLangSettings.dart';
// import 'package:playz_user/Utils/get_translated_text.dart'; // function getTranslatedText(key, lang)

class BookingQRScannerScreen extends StatefulWidget {
  const BookingQRScannerScreen({super.key});

  @override
  State<BookingQRScannerScreen> createState() => _BookingQRScannerScreenState();
}

class _BookingQRScannerScreenState extends State<BookingQRScannerScreen> {
  // ------------------- 🟩 TRANSLATION CACHE LOGIC -------------------

  List<String> get _allTranslationKeys {
    // Static text used in this screen only
    return [
      "Validate Booking QR",
      "Scan the User's Booking QR Code to Check-In:",
      "Booking Data Decoded:",
      "Ready to validate booking...",
      "Attempting to validate ID:",
      "VALIDATE BOOKING",
    ];
  }

  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;

    if (_currentLang == lang &&
        _translationsCache.keys.length == keysToLoad.length) {
      return;
    }
    _translationsCache.clear();
    _currentLang = lang;
    Map<String, String> newTranslations = {};

    for (String key in keysToLoad) {
      // Assume you have getTranslatedText(key, lang) defined globally
      String translated = await getTranslatedText(key, lang);
      newTranslations[key] = translated;
    }

    if (mounted) {
      setState(() {
        _translationsCache = newTranslations;
      });
    }
  }

  void _extractStrings(dynamic data, Set<String> keys) {
    if (data is String) {
      // Add the string if it's not empty and potentially not a URL/ID
      // For translation purposes, you might want to filter out IDs, URLs, etc.
      // For simplicity here, we add all strings.
      if (data.isNotEmpty) {
        keys.add(data);
      }
    } else if (data is Map) {
      data.values.forEach((value) => _extractStrings(value, keys));
    } else if (data is List) {
      data.forEach((item) => _extractStrings(item, keys));
    }
    // Ignore other types like int, double, bool, null, etc.
  }

  List<String> allQRCodes = [];
  Future<void> loadAllTurfs() async {
    final allTurfList = await UserSendBookingController().fetchAllBookData();
    log("fetched list: $allTurfList");

    for (var newItem in allTurfList) {
      //    List<Map> allBooking = [
      // {
      //   "userName": "Nikhil Raj",
      //   "timings": "5:00 PM - 6:00 PM",
      //   "Date": "Tue | 01-09-2025",
      // },
      String qrCode = newItem['qr_code_text'];

      allQRCodes.add(qrCode);
    }

    log("List: $allQRCodes");

    if (mounted) {
      setState(() {
        // Reload translations to include dynamic text from newly loaded games
        _loadTranslations(ownerAppLanguageNotifier.value);
      });
    }
  }

  void _languageChangeListener() {
    _loadTranslations(ownerAppLanguageNotifier.value);
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await OwnerThemeLangSettings(
      theme: null,
    ).loadSelectedTheme();
    isDarkOwnerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await OwnerThemeLangSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    ownerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet);
  }

  String _getTranslation(String key) {
    return _translationsCache[key] ?? key;
  }

  // -------------------------------------------------------------

  final MobileScannerController _controller = MobileScannerController(
    formats: [BarcodeFormat.qrCode],
  );

  String _scanResult = 'Ready to validate booking...';

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;

    String newResult = 'Scanning...';

    if (raw != null) {
      try {
        final decoded = utf8.decode(base64Decode(raw));
        newResult = decoded;
      } catch (e) {
        newResult = raw;
      }

      if (newResult != _scanResult) {
        HapticFeedback.mediumImpact();
      }
    }

    if (newResult != _scanResult) {
      setState(() {
        _scanResult = newResult;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (_currentLang != ownerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    loadAllTurfs();
    ownerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    ownerAppLanguageNotifier.removeListener(_languageChangeListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkOwnerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme
            : CustomThemes.customLightTheme;

        return Theme(
          data: theme,
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  title: Text(_getTranslation('Validate Booking QR')),
                  centerTitle: true,
                  backgroundColor: Color.fromRGBO(13, 71, 161, 1),
                  foregroundColor: Colors.white,
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _getTranslation(
                          "Scan the User's Booking QR Code to Check-In:",
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 🔹 QR Scanner
                      Center(
                        child: SizedBox(
                          height: 300,
                          width: 300,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.primary,
                                width: 4,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: MobileScanner(
                                controller: _controller,
                                onDetect: _onDetect,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Divider(height: 48, thickness: 2),

                      Text(
                        _getTranslation('Booking Data Decoded:'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.primary),
                        ),
                        child: SelectableText(
                          allQRCodes.contains(_scanResult)
                              ? "Success"
                              : "Ready to validate booking...",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.colorScheme.onBackground,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: allQRCodes.contains(_scanResult)
                            ? () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (_) => SuccessVerificationScreen(),
                                  ),
                                );
                              }
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "${_getTranslation('Attempt Failed')}",
                                    ),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.check_circle_outline, size: 28),
                        label: Text(
                          _getTranslation('VALIDATE BOOKING'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_translationsCache.isEmpty)
                const Positioned.fill(child: OwnerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }
}
