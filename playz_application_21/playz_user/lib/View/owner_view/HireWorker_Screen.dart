import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/Turf_Owner/Owner_Worker_Fetch_Data.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Helper/Owner_Loader.dart';
// Assuming necessary classes like CustomThemes, OwnerThemeLangSettings,
// ownerAppLanguageNotifier, isDarkOwnerThemeNotifier, getTranslatedText, OwnerDrawer exist globally
// import 'package:playz_user/Controller/owner_sharedpreferences.dart'; // Assumed import if needed
import 'package:playz_user/View/owner_view/Bookings_Screen.dart';
import 'package:playz_user/View/owner_view/DashBoard_Screen.dart';
import 'package:playz_user/View/owner_view/LanguageSelection_Screen.dart';
import 'package:playz_user/View/owner_view/MainTurfWorker_Screen.dart';
import 'package:playz_user/View/owner_view/Owner_Menu.dart';
import 'package:playz_user/View/owner_view/Turf_Screen.dart';
import 'package:playz_user/View/owner_view/owner_qr_scanner.dart';
import 'package:playz_user/View/user_view/home(sport)/homepage(sport).dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

Map<String, String> _translationsCache = {};

// NOTE: Placeholder classes/functions (CustomThemes, OwnerThemeLangSettings, etc.) are assumed to be defined elsewhere.

List<Map> hiredWorkerList =
    []; // Assuming this list is accessible or passed correctly

class ownerHireWorkerScreen extends StatefulWidget {
  final List<Map> workerList; // This is the list of currently hired workers
  const ownerHireWorkerScreen({required this.workerList, super.key});
  @override
  State<ownerHireWorkerScreen> createState() => _ownerHireWorkerScreenState();
}

class _ownerHireWorkerScreenState extends State<ownerHireWorkerScreen> {
  // Local state for filtering/searching
  String _searchQuery = "";
  String _filterType = '';
  int selected = 3;

  // List of workers available for hire
  List<Map<String, dynamic>> availableWorkers = [];

  // ================= CACHE TRANSLATION LOGIC START =================

  // 1. Translation Cache Map

  // Current language to track changes
  String _currentLang = "en";

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Turf Owner",
      "Find & Hire Staff",
      "Search by Location or Name",
      "Security",
      "Manager",
      "Maintenance",
      "Cleaning", // Worker Types (Filter Chips)
      "Hired", "Hire", // Button text
      "Home", "Bookings", "Turf", "Workers", // Bottom Nav keys
      // Keys from original dashboard logic (retained for consistency with the provided template)
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Today's Income",
      "This Week's Income",
      "This Month's Income",
      "This Year's Income",
      "Reviews & Ratings",
      "INR 8900", "INR 53900", "INR 238900", "INR 3253900",
      "Income", "Expenditure",
    };

    // Add dynamic keys from the availableWorkers list (names and work types)
    for (var worker in availableWorkers) {
      if (worker['worker_name'] != null) {
        keys.add(worker['worker_name']);
      }
      if (worker['skills'] != null) {
        if (worker['skills'] is List) {
          for (var skill in worker['skills']) {
            keys.add(skill.toString());
          }
        } else {
          keys.add(worker['skills'].toString());
        }
      }
    }

    // Add dynamic keys from the currently Hired worker list (if they are passed in the widget.workerList)
    for (var hiredWorker in widget.workerList) {
      if (hiredWorker['worker_name'] != null) {
        keys.add(hiredWorker['worker_name']);
      }
    }

    return keys.toList();
  }

  // 3. Load Translations function
  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;

    // Simple check: if the language is the same and the number of keys matches the cached count, skip.
    if (_currentLang == lang &&
        _translationsCache.keys.length >= keysToLoad.length) {
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
    // Assumed implementation of theme loading
    // Replace with your actual implementation if different
    String? selectedTheme = await OwnerThemeLangSettings(
      theme: null,
    ).loadSelectedTheme();
    isDarkOwnerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    // Assumed implementation of language loading
    // Replace with your actual implementation if different
    String? selectedLang = await OwnerThemeLangSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    ownerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet); // Initial load of translations
  }
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
    loadAllNewWorker();
  }

  //Fetch Data Method
  void loadAllNewWorker() async {
    final data = await OwnerWorkerFetchData.getHireNewWorkerData();
    log('Fetched workers: ${data.length} => $data');
    setState(() {
      availableWorkers = data;
    });
  }

  @override
  void dispose() {
    ownerAppLanguageNotifier.removeListener(_languageChangeListener);
    _banSubscription?.cancel();
    super.dispose();
  }

  // ================= CACHE TRANSLATION LOGIC END =================

  // Utility function: remains as is, but uses the translated filter type
  List<Map> _filteredWorkerList() {
    List<Map> tempList = List.from(availableWorkers);

    // Filter by workType using the key, as the value will be the translated string
    if (_filterType.isNotEmpty) {
      tempList = tempList.where((w) {
        if (w['skills'] is List) {
          return (w['skills'] as List)
              .map((s) => s.toString().toLowerCase())
              .contains(_filterType.toLowerCase());
        } else {
          return (w['skills']?.toString().toLowerCase() ?? '') ==
              _filterType.toLowerCase();
        }
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      tempList = tempList
          .where(
            (w) => (_getTranslation(
              w['worker_name'] ?? '',
            )).toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return tempList;
  }

  // Utility function: uses translated text for label and updates state with the English key
  Widget _buildFilterChip(String key, Color primaryColor) {
    String translatedType = _getTranslation(key);
    return ChoiceChip(
      label: Text(translatedType),
      // Check against the English key (stored in _filterType)
      selected: _filterType == key,
      selectedColor: primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: _filterType == key ? primaryColor : Colors.black,
      ),
      // Update the state with the English key (key)
      onSelected: (selected) =>
          setState(() => _filterType = selected ? key : ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if translations are loaded

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkOwnerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme
            : CustomThemes.customLightTheme;
        final primaryColor = theme.colorScheme.primary;

        return Theme(
          data: theme,
          child: Stack(
            children: [
              Scaffold(
                appBar: AppBar(
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: Colors.white, size: 25),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  // 🔴 Translated Text
                  title: Text(
                    _getTranslation("Turf Owner"),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: true,
                  backgroundColor: primaryColor,
                  actions: [
                    IconButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookingQRScannerScreen(),
                        ),
                      ),
                      icon: Icon(
                        Icons.qr_code_scanner_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.message_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ],
                ),
                drawer: OwnerDrawer(),
                body: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔴 Translated Text
                      Text(
                        _getTranslation('Find & Hire Staff'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 21,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 14),
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          // 🔴 Translated Text
                          hintText: _getTranslation(
                            'Search by Location or Name',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onChanged: (value) =>
                            setState(() => _searchQuery = value),
                      ),
                      SizedBox(height: 14),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // 🔴 Use English keys for the chips, the helper translates them
                            _buildFilterChip('Security', primaryColor),
                            SizedBox(width: 10),
                            _buildFilterChip('Cleaning', primaryColor),
                            SizedBox(width: 10),
                            _buildFilterChip('Maintenance', primaryColor),
                            SizedBox(width: 10),
                            _buildFilterChip('Manager', primaryColor),
                          ],
                        ),
                      ),
                      SizedBox(height: 14),
                      Expanded(
                        child: availableWorkers.isEmpty ? Center(child: CircularProgressIndicator()) : ListView.builder(
                          itemCount: _filteredWorkerList().length,
                          itemBuilder: (context, index) {
                            final worker = _filteredWorkerList()[index];
                            // Check against the passed workerList (hired workers)
                            bool hired = widget.workerList.any(
                              (w) => w['worker_name'] == worker['worker_name'],
                            );
                            return Card(
                              child: ListTile(
                                leading: Icon(
                                  Icons.person,
                                  color: primaryColor,
                                ),
                                // 🔴 Translated Text (Worker Name)
                                title: Text(
                                  _getTranslation(worker['worker_name'] ?? ''),
                                ),
                                // 🔴 Translated Text (Work Type)
                                subtitle: Text(
                                  worker['skills'] is List
                                      ? worker['skills'].join(', ')
                                      : (worker['skills'] ?? ''),
                                ),

                                trailing: ElevatedButton(
                                  onPressed: hired
                                      ? null
                                      : () async{
                                        OwnerSettings _ownerSetting = await OwnerSettings().loadSettings();
                                        log("Loaded ownerEmail: ${_ownerSetting.ownerEmail}");
                                        String worker_name = worker['worker_name'] ?? '';
                                        String email = worker['email'] ?? '';
                                        List skills = worker['skills'];
                                        int contact_no = int.tryParse(worker['contact_no'].toString()) ?? 0;
                                        String DOB = worker['DOB'] ?? '';
                                        String worker_upi_id = worker['worker_upi_id'] ?? '';
                                        String worker_gender = worker['worker_gender'] ?? '';
                                        String? worker_profile_image = worker['worker_profile_image'];
                                        OwnerWorkerFetchData.setHiredWorker(email_ID: _ownerSetting.ownerEmail, worker_name: worker_name, email: email, contact_no: contact_no, DOB: DOB, worker_upi_id: worker_upi_id, worker_gender: worker_gender,skills: skills);
                                          
                                          // Note: This modifies the parent widget's list,
                                          // which might not be idiomatic Flutter state management.
                                          // For this code structure, we rely on the parent list update.
                                          setState(
                                            () => widget.workerList.add(worker),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            // 🔴 Translated Text
                                            SnackBar(
                                              content: Text(
                                                "${_getTranslation(worker['worker_name'] ?? '')} ${_getTranslation('hired!').toLowerCase()}",
                                              ),
                                            ),
                                          );
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hired
                                        ? Colors.grey
                                        : primaryColor,
                                  ),
                                  // 🔴 Translated Text
                                  child: Text(
                                    _getTranslation(hired ? "Hired" : "Hire"),style: TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                bottomNavigationBar: StylishBottomBar(
                  backgroundColor: primaryColor,
                  items: [
                    BottomBarItem(
                      icon: Icon(Icons.home, color: Colors.white),
                      // 🔴 Translated Text
                      title: Text(
                        _getTranslation('Home'),
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: primaryColor,
                      selectedIcon: Icon(Icons.read_more, color: Colors.white),
                    ),
                    BottomBarItem(
                      icon: Icon(
                        Icons.calendar_month_sharp,
                        color: Colors.white,
                      ),
                      // 🔴 Translated Text
                      title: Text(
                        _getTranslation('Bookings'),
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: primaryColor,
                    ),
                    BottomBarItem(
                      icon: Icon(Icons.sports_basketball, color: Colors.white),
                      // 🔴 Translated Text
                      title: Text(
                        _getTranslation('Turf'),
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: primaryColor,
                    ),
                    BottomBarItem(
                      icon: Icon(Icons.people_rounded, color: Colors.white),
                      // 🔴 Translated Text
                      title: Text(
                        _getTranslation('Workers'),
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: primaryColor,
                    ),
                  ],
                  option: DotBarOptions(
                    dotStyle: DotStyle.circle,
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.white],
                    ),
                  ),
                  hasNotch: true,
                  currentIndex: selected,
                  onTap: (index) {
                    setState(() => selected = index);
                    switch (index) {
                      case 0:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => OwnerDashBoardScreen(),
                          ),
                        );
                        break;
                      case 1:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ownerBookingScreen(),
                          ),
                        );
                        break;
                      case 2:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ownerAfterRegistrationTurfScreen(),
                          ),
                        );
                        break;
                      case 3:
                        // Navigate to the Workers screen itself (OwnerTurfWorkerScreen)
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ownerTurfWorkerScreen(),
                          ),
                        );
                        break;
                    }
                  },
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
