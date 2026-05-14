import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:playz_user/Controller/Turf_Owner/Owner_Worker_Fetch_Data.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Helper/Owner_Loader.dart';
import 'package:playz_user/View/owner_view/Bookings_Screen.dart';
import 'package:playz_user/View/owner_view/DashBoard_Screen.dart';
import 'package:playz_user/View/owner_view/HireWorker_Screen.dart';
import 'package:playz_user/View/owner_view/LanguageSelection_Screen.dart';
import 'package:playz_user/View/owner_view/Owner_Menu.dart';
import 'package:playz_user/View/owner_view/Turf_Screen.dart';
import 'package:playz_user/View/owner_view/WorkerDetail_screen.dart';
import 'package:playz_user/View/owner_view/owner_qr_scanner.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

Map<String, String> _translationsCache = {};

String _currentLang = "en";

List<Map> workerList = [];

// Renamed class to follow PascalCase convention
class ownerTurfWorkerScreen extends StatefulWidget {
  const ownerTurfWorkerScreen({super.key});

  @override
  // Renamed state creation
  State<ownerTurfWorkerScreen> createState() => _ownerTurfWorkerScreenState();
}

// Renamed state class to follow convention
class _ownerTurfWorkerScreenState extends State<ownerTurfWorkerScreen> {
  // Local lists need to be defined here or globally to be accessed by _allTranslationKeys
  bool _loading = true;
  List<Map> securityWorker = [
    {
      "worker_name": "Shriraj Deshpande",
      "skills": ["Security"],
    },
    {"worker_name": "Aryan Mane", "skills": "Security"},
  ];
  List<Map> cleaningWorker = [
    {"worker_name": "Vivek Kumar", "skills": "Cleaning"},
    {"worker_name": "Riya Sharma", "skills": "Cleaning"},
  ];
  List<Map> maintenanceWorker = [
    {"worker_name": "Suresh Patel", "skills": "Maintenance"},
    {"worker_name": "Anjali Verma", "skills": "Maintenance"},
  ];
  List<Map> managerWorker = [
    {"worker_name": "Nikhil Raj", "skills": "Manager"},
    {"worker_name": "Priya Singh", "skills": "Manager"},
  ];

  // 1. Translation Cache Map

  // Current language to track changes

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // Keys from this screen
      "Home", "Bookings", "Turf", "Workers",
      "Choose Date", "All", "Security", "Cleaning", "Maintenance", "Manager",
      "on-Duty", "Off-Duty", "No Worker Hired", "Add a New Worker",
    };

    // Add dynamic keys from the turfInfo list
    // NOTE: Using a placeholder for turfInfo as it's not defined in the snippet
    const List<Map<String, String>> turfInfo = [
      {'turfName': 'Turf A'},
      {'turfName': 'Turf B'},
    ];
    for (var info in turfInfo) {
      if (info['turfName'] != null) {
        keys.add(info['turfName']!);
      }
    }

    // ADDING ALL WORKER NAMES
    final allLocalWorkers = [
      ...securityWorker,
      ...cleaningWorker,
      ...maintenanceWorker,
      ...managerWorker,
    ];
    for (var worker in allLocalWorkers) {
      if (worker['skills'] != null && worker['skills'] != null) {
        keys.add(worker['skills']!);
        keys.add(worker['skills']!);
      }
    }

    // Add keys from worker workType (Security, Cleaning, Maintenance, Manager)
    keys.add(securityWorker.first['skills'] ?? "Security");
    keys.add(cleaningWorker.first['skills'] ?? "Cleaning");
    keys.add(maintenanceWorker.first['skills'] ?? "Maintenance");
    keys.add(managerWorker.first['skills'] ?? "Manager");

    return keys.toList();
  }

  // 3. Load Translations function
  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;

    // Simple check: if the language is the same and the number of keys matches the cached count, skip.
    if (_currentLang == lang &&
        _translationsCache.keys.length == keysToLoad.length) {
      return;
    }
    _translationsCache.clear();
    _currentLang = lang;
    Map<String, String> newTranslations = {};

    // Fetch all translations
    for (String key in keysToLoad) {
      // NOTE: getTranslatedText must be an available function
      // Assuming a mock function if the actual is not available
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
    // NOTE: ownerAppLanguageNotifier is assumed to be accessible.
    _loadTranslations(ownerAppLanguageNotifier.value);
  }

  // Future for loading theme and language
  Future<void> _loadSelectedTheme() async {
    // NOTE: OwnerThemeLangSettings and isDarkOwnerThemeNotifier are assumed to be accessible.
    String? selectedTheme = await OwnerThemeLangSettings(
      theme: null,
    ).loadSelectedTheme();
    isDarkOwnerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    // NOTE: OwnerThemeLangSettings and ownerAppLanguageNotifier are assumed to be accessible.
    String? selectedLang = await OwnerThemeLangSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    ownerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet); // Initial load of translations
  }

  // 4. Helper to retrieve cached translation
  String _getTranslation(String key) {
    // Returns the cached translation or the original key if not found
    return _translationsCache[key] ?? key;
  }
  // ----------------- End of Translation Logic -----------------

  int selected = 3;
  TextEditingController date = TextEditingController();
  int workingIndex = 4;
  late List<Map> allWorker = [];

  // Worker lists are now defined above (or outside the state class) for _allTranslationKeys to access them.

  @override
  void initState() {
    super.initState();
    if (_currentLang != ownerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    // allWorker = [
    //   ...securityWorker,
    //   ...cleaningWorker,
    //   ...maintenanceWorker,
    //   ...managerWorker,
    // ];
    // Translation logic initialization
    _loadSelectedTheme();
    _loadSelectedLang();
    // Start listening for language changes to reload translations
    ownerAppLanguageNotifier.addListener(_languageChangeListener);
    fetchHiredWorkers();
  }

  Future<void> fetchHiredWorkers() async {
    OwnerSettings _ownerSetting = await OwnerSettings().loadSettings();
    log("Loaded ownerEmail: ${_ownerSetting.ownerEmail}");
    String? email_ID = await _ownerSetting
        .ownerEmail; // Or however you get the turf owner email

    if (email_ID == null) return; // Validation

    // Get all hired workers for this owner
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Turf_Owner')
        .doc(email_ID)
        .collection('Worker')
        .get();

    List<Map> tempAll = [];
    List<Map> tempSecurity = [];
    List<Map> tempCleaning = [];
    List<Map> tempMaintenance = [];
    List<Map> tempManager = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> worker = doc.data() as Map<String, dynamic>;
      tempAll.add(worker);

      List<dynamic> skillsList = [];
      if (worker['skills'] is List) {
        skillsList = worker['skills'];
      } else if (worker['skills'] != null) {
        skillsList = [worker['skills'].toString()];
      }

      // Add worker to each skill category list if present
      if (skillsList.contains('security') || skillsList.contains('Security')) {
        tempSecurity.add(worker);
      }
      if (skillsList.contains('cleaning') || skillsList.contains('Cleaning')) {
        tempCleaning.add(worker);
      }
      if (skillsList.contains('maintenance') ||
          skillsList.contains('Maintenance')) {
        tempMaintenance.add(worker);
      }
      if (skillsList.contains('manager') || skillsList.contains('Manager')) {
        tempManager.add(worker);
      }
    }

    setState(() {
      allWorker = tempAll;
      securityWorker.clear();
      cleaningWorker.clear();
      maintenanceWorker.clear();
      managerWorker.clear();
      securityWorker.addAll(tempSecurity);
      cleaningWorker.addAll(tempCleaning);
      maintenanceWorker.addAll(tempMaintenance);
      managerWorker.addAll(tempManager);
      _loading = false;
    });
  }

  @override
  void dispose() {
    // Stop listening for language changes
    ownerAppLanguageNotifier.removeListener(_languageChangeListener);
    super.dispose();
  }

  Widget _buildTabButton(String titleKey, int index, Color primaryColor) {
    String title = _getTranslation(titleKey); // Use translated text
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: workingIndex == index
            ? primaryColor
            : Colors.grey[200],
        foregroundColor: workingIndex == index ? Colors.white : primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        setState(() {
          workingIndex = index;
        });
      },
      child: Text(title),
    );
  }

  Widget _buildBookingList(Color primaryColor) {
    switch (workingIndex) {
      case 0:
        workerList = securityWorker;
        break;
      case 1:
        workerList = cleaningWorker;
        break;
      case 2:
        workerList = maintenanceWorker;
        break;
      case 3:
        workerList = managerWorker;
        break;
      case 4:
        workerList = allWorker;
        break;
      default:
        workerList = securityWorker;
    }

    if (_loading) {
      return Center(child: CircularProgressIndicator());
    }
    if (workerList.isEmpty) {
      return Center(child: Text(_getTranslation("No Worker Hired")));
    }
    // Use translated text

    return ListView.builder(
      itemCount: workerList.length,
      itemBuilder: (context, index) {
        final worker = workerList[index];
        final status = index % 2 == 0 ? "on-Duty" : "Off-Duty";
        final translatedStatus = _getTranslation(status); // Use translated text
        // Translate the worker's name if available in the cache
        final translatedName = _getTranslation(worker['worker_name'] ?? "");

        List<dynamic> skillsList = [];
        if (worker['skills'] is List) {
          skillsList = worker['skills'];
        } else if (worker['skills'] != null) {
          skillsList = [worker['skills'].toString()];
        }
        String skillText = skillsList.join(', ');

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: ListTile(
            onTap: () {
             
              // Get the email from worker map
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OwnerWorkerDetailScreen(
                    worker: worker, // Pass the email
                  ),
                ),
              );


            },
            title: Text(
              translatedName, // Use translated name
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            subtitle: Text(skillText, style: TextStyle(fontSize: 15)),

            trailing: Container(
              margin: EdgeInsets.only(top: 4),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: index % 2 == 0 ? Colors.green[400] : Colors.orange[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                translatedStatus,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                  title: Text(
                    _getTranslation("Turf Owner"), // Use translated text
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
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => BookingQRScannerScreen(),
                          ),
                        );
                      },
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
                body: Center(
                  child: Column(
                    children: [
                      SizedBox(height: 15),
                      SizedBox(
                        width: 388,
                        height: 60,
                        child: TextField(
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2025),
                              lastDate: DateTime(2026),
                            );
                            if (pickedDate != null) {
                              date.text = DateFormat.yMMMd().format(pickedDate);
                            }
                          },
                          controller: date,
                          decoration: InputDecoration(
                            labelText: _getTranslation(
                              "Choose Date",
                            ), // Use translated text
                            suffix: Icon(
                              Icons.calendar_month_outlined,
                              color: primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildTabButton(
                                "All",
                                4,
                                primaryColor,
                              ), // Use key
                              SizedBox(width: 15),
                              _buildTabButton(
                                "Security",
                                0,
                                primaryColor,
                              ), // Use key
                              SizedBox(width: 15),
                              _buildTabButton(
                                "Cleaning",
                                1,
                                primaryColor,
                              ), // Use key
                              SizedBox(width: 15),
                              _buildTabButton(
                                "Maintenance",
                                2,
                                primaryColor,
                              ), // Use key
                              SizedBox(width: 15),
                              _buildTabButton(
                                "Manager",
                                3,
                                primaryColor,
                              ), // Use key
                            ],
                          ),
                        ),
                      ),
                      Expanded(child: _buildBookingList(primaryColor)),
                      Container(
                        child: Column(
                          children: [
                            SizedBox(
                              width: 388,
                              height: 60,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ownerHireWorkerScreen(
                                            workerList: allWorker,
                                          ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _getTranslation(
                                      "Add a New Worker",
                                    ), // Use translated text
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                bottomNavigationBar: StylishBottomBar(
                  backgroundColor: primaryColor,
                  items: [
                    BottomBarItem(
                      icon: const Icon(Icons.home, color: Colors.white),
                      title: Text(
                        _getTranslation('Home'),
                        style: const TextStyle(color: Colors.white),
                      ), // Use translated text
                      backgroundColor: primaryColor,
                      selectedIcon: const Icon(
                        Icons.read_more,
                        color: Colors.white,
                      ),
                    ),
                    BottomBarItem(
                      icon: const Icon(
                        Icons.calendar_month_sharp,
                        color: Colors.white,
                      ),
                      title: Text(
                        _getTranslation('Bookings'),
                        style: const TextStyle(color: Colors.white),
                      ), // Use translated text
                      backgroundColor: primaryColor,
                    ),
                    BottomBarItem(
                      icon: const Icon(
                        Icons.sports_basketball,
                        color: Colors.white,
                      ),
                      title: Text(
                        _getTranslation('Turf'),
                        style: const TextStyle(color: Colors.white),
                      ), // Use translated text
                      backgroundColor: primaryColor,
                    ),
                    BottomBarItem(
                      icon: const Icon(
                        Icons.people_rounded,
                        color: Colors.white,
                      ),
                      title: Text(
                        _getTranslation('Workers'),
                        style: const TextStyle(color: Colors.white),
                      ), // Use translated text
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
                      case 2:
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) =>
                                ownerAfterRegistrationTurfScreen(),
                          ),
                        );
                        break;
                      case 3:
                        break;
                    }
                  },
                ),
              ),
              // if (_translationsCache.isEmpty)
              //   const Positioned.fill(child: OwnerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }
}
