import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/Turf_Owner/Owner_TurfRegistered_Successful.dart';
// Assuming these imports define the necessary classes/notifiers:
// CustomThemes, OwnerThemeLangSettings, ownerAppLanguageNotifier, isDarkOwnerThemeNotifier, getTranslatedText, OwnerDrawer
import 'package:playz_user/Controller/owner_sharedpreferences.dart'; // Assumed import for OwnerThemeLangSettings
import 'package:playz_user/Helper/Owner_Loader.dart';
import 'package:playz_user/View/owner_view/Bookings_Screen.dart';
import 'package:playz_user/View/owner_view/DashBoard_Screen.dart';
import 'package:playz_user/View/owner_view/LanguageSelection_Screen.dart';
import 'package:playz_user/View/owner_view/MainTurfWorker_Screen.dart';
import 'package:playz_user/View/owner_view/Owner_Menu.dart';
import 'package:playz_user/View/owner_view/RegisterTurf_Screen.dart';
import 'package:playz_user/View/owner_view/owner_qr_scanner.dart';
import 'package:playz_user/View/user_view/home(sport)/homepage(sport).dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
  Map<String, String> _translationsCache = {};
  String _currentLang = "en"; 

// NOTE: Placeholder classes/functions are assumed to exist globally:
// CustomThemes, OwnerThemeLangSettings, ownerAppLanguageNotifier, 
// isDarkOwnerThemeNotifier, getTranslatedText, OwnerDrawer, etc.

class ownerAfterRegistrationTurfScreen extends StatefulWidget {
  const ownerAfterRegistrationTurfScreen({super.key});

  @override
  State<ownerAfterRegistrationTurfScreen> createState() =>
      _ownerAfterRegistrationTurfScreenState();
}

class _ownerAfterRegistrationTurfScreenState
    extends State<ownerAfterRegistrationTurfScreen> {
  int selected = 2;
  // Renamed for consistency with translation logic:
  List turfInfo = [
    {"turfName": "Cricket Turf Name 1"}, 
    {"turfName": "Football Turf Name 2"}
  ]; 
  
  // ================= CACHE TRANSLATION LOGIC START =================
  
  // 1. Translation Cache Map
  
  // Current language to track changes

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Turf Owner",
      "My Turfs", // Added this static key from the body
      "Add Another Turf", // Added this static key from the button
      "Home", "Bookings", "Turf", "Workers", // Bottom Nav keys
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", // Month keys (from original logic, kept for completeness)
      "Today's Income", "This Week's Income", "This Month's Income", "This Year's Income", // Income keys (from original logic, kept for completeness)
      "Reviews & Ratings", // Review key (from original logic, kept for completeness)
      "INR 8900", "INR 53900", "INR 238900", "INR 3253900", // Sample amounts (from original logic, kept for completeness)
      "Income", "Expenditure", // PieChart keys (from original logic, kept for completeness)
    };

    // Add dynamic keys from the turfInfo list
    for (var info in turfInfo) {
      if (info['turfName'] != null) {
        keys.add(info['turfName']);
      }
    }
    
    return keys.toList();
  }

  // 3. Load Translations function
  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;
    
    // Check if the language is the same and the number of keys matches the cached count.
    if (_currentLang == lang && _translationsCache.keys.length == keysToLoad.length) {
      return; 
    }
_translationsCache.clear();
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
  
  // 4. Helper to retrieve cached translation
  String _getTranslation(String key) {
    // Returns the cached translation or the original key if not found
    return _translationsCache[key] ?? key; 
  }

  // Listener function to call _loadTranslations when the language notifier changes
  void _languageChangeListener() {
    _loadTranslations(ownerAppLanguageNotifier.value);
  }

  Future<void> _loadSelectedTheme() async {
    // Assumed loadSelectedTheme exists in a shared class
    String? selectedTheme = await OwnerThemeLangSettings(theme: null).loadSelectedTheme();
    isDarkOwnerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    // Assumed loadSelectedLocale exists in a shared class
    String? selectedLang = await OwnerThemeLangSettings(theme: null).loadSelectedLocale(); 
    String langToSet = selectedLang ?? "en";
    ownerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet); // Initial load of translations
  }
  
  // ================= CACHE TRANSLATION LOGIC END =================
StreamSubscription<DocumentSnapshot>? _banSubscription;
Future<void> _setupBanMonitoring() async {
// You can call this method at any time you need to (re)start the monitor
_banSubscription?.cancel(); // Cancel any existing one before starting anew
_banSubscription = await startOwnerBanMonitoring(
context: context,
firestoreInstance: FirebaseFirestore.instance, // Use your actual instance
);
}
  @override
  void initState() {
    super.initState();
    _setupBanMonitoring();

    
    if (_currentLang != ownerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    // Start listening for language changes to reload translations
    ownerAppLanguageNotifier.addListener(_languageChangeListener);
    turfInfo.clear();
    getTurfNameData();
    setState(() {
      
    });
  }
  
  void getTurfNameData()async{
    OwnerSettings _ownerSetting = await OwnerSettings().loadSettings();
    OwnerTurfregisteredSuccessful _getFirebaseData = OwnerTurfregisteredSuccessful();
    QuerySnapshot firebaseTurfData = await _getFirebaseData.getTurfData(_ownerSetting.ownerEmail);
    for(int i = 0 ; i < firebaseTurfData.docs.length ; i++){
      Map<String,dynamic> obj = {
        'turfName':firebaseTurfData.docs[i]['turfName']
      };
      turfInfo.add(obj);
    }
    setState(() {
      
    });
    log("List:${turfInfo}");
  }

  @override
  void dispose() {
    ownerAppLanguageNotifier.removeListener(_languageChangeListener);
    _banSubscription?.cancel();
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
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu,
                          color: theme.colorScheme.onPrimary, size: 25),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  // 🔴 Translated Text
                  title: Text(
                    _getTranslation("Turf Owner"),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: theme.colorScheme.primary,
                  actions: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return BookingQRScannerScreen();
                        }));
                      },
                      icon: Icon(Icons.qr_code_scanner_outlined,
                          color: theme.colorScheme.onPrimary, size: 25),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.message_outlined,
                          color: theme.colorScheme.onPrimary, size: 25),
                    ),
                  ],
                ),
                drawer: OwnerDrawer(),
                body: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          // 🔴 Translated Text
                          Text(
                            _getTranslation("My Turfs"),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 260,
                            child: ListView.builder(
                              itemCount: turfInfo.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 360,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: theme.colorScheme.primary,
                                          width: 1.9,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          Icon(Icons.sports_soccer_rounded,
                                              color: theme.colorScheme.primary,
                                              size: 35),
                                          const SizedBox(width: 20),
                                          // 🔴 Translated Text (Dynamic Turf Name)
                                          Text(
                                            _getTranslation(turfInfo[index]['turfName']),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) {
                                                    return ownerRegisterTurfScreen(email_ID:  OwnerSettings().ownerEmail, doEdit: true,turfName: turfInfo[index]['turfName'],);
                                                  },
                                                ),
                                              );
                                            },
                                            icon: Icon(Icons.edit,
                                                color: theme.colorScheme.primary,
                                                size: 35),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              },
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 370,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: () async{ 
                                OwnerSettings _ownerSetting = await OwnerSettings().loadSettings();
                                log("Loaded ownerEmail: ${_ownerSetting.ownerEmail}");
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ownerRegisterTurfScreen(email_ID:_ownerSetting.ownerEmail,doEdit:false);
                                    },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              // 🔴 Translated Text
                              child: Text(
                                _getTranslation("Add Another Turf"),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: StylishBottomBar(
                  backgroundColor: theme.colorScheme.primary,
                  items: [
                    BottomBarItem(
                      icon: Icon(Icons.home, color: theme.colorScheme.onPrimary),
                      // 🔴 Translated Text
                      title: Text(_getTranslation('Home'),
                          style: TextStyle(color: theme.colorScheme.onPrimary)),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    BottomBarItem(
                      icon: Icon(Icons.calendar_month_sharp,
                          color: theme.colorScheme.onPrimary),
                      // 🔴 Translated Text
                      title: Text(_getTranslation('Bookings'),
                          style: TextStyle(color: theme.colorScheme.onPrimary)),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    BottomBarItem(
                      icon: Icon(Icons.sports_basketball,
                          color: theme.colorScheme.onPrimary),
                      // 🔴 Translated Text
                      title: Text(_getTranslation('Turf'),
                          style: TextStyle(color: theme.colorScheme.onPrimary)),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    BottomBarItem(
                      icon: Icon(Icons.people_rounded,
                          color: theme.colorScheme.onPrimary),
                      // 🔴 Translated Text
                      title: Text(_getTranslation('Workers'),
                          style: TextStyle(color: theme.colorScheme.onPrimary)),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                  ],
                  option: DotBarOptions(
                    dotStyle: DotStyle.circle,
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.onPrimary,
                        theme.colorScheme.onPrimary
                      ],
                    ),
                  ),
                  hasNotch: true,
                  currentIndex: selected,
                  onTap: (index) {
                    setState(() {
                      selected = index;
                    });
                    switch (index) {
                      case 0:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => OwnerDashBoardScreen(),
                          ),
                        );
                        break;
                      case 1:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ownerBookingScreen(),
                          ),
                        );
                        break;
                      case 3:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => ownerTurfWorkerScreen(),
                          ),
                        );
                        break;
                    }
                  },
                ),
              ),if (_translationsCache.isEmpty)
                const Positioned.fill(child: OwnerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }
}