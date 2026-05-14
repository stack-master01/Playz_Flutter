import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';
import 'package:playz_user/Helper/Worker_Loader.dart';
import 'package:playz_user/View/worker_view/worker_drower.dart';
import 'package:playz_user/View/worker_view/worker_language.dart';

Map<String, String> _translationsCache = {};

String _currentLang = "en";

const List<Map<String, dynamic>> turfInfo =
    []; // Empty list as used in your provided snippet

class WorkerhomePage extends StatefulWidget {
  const WorkerhomePage({super.key});

  @override
  State<WorkerhomePage> createState() => _WorkerhomePageState();
}

class _WorkerhomePageState extends State<WorkerhomePage> {
  final FirebaseFirestore firestoreobj = FirebaseFirestore.instance;

  // 1. Translation Cache Map
  // Current language to track changes

  final TextEditingController searchController = TextEditingController();
  int selectedFilterValue = 0;
  int selectedSortValue = 0;

  // Initial data lists (labels will be translated later)
  final List<Map<String, dynamic>> filterOptions = const [
    {'label': "All Jobs", 'value': 0},
    {'label': "Groundkeeper", 'value': 1},
    {'label': "Maintenance Staff", 'value': 2},
    {'label': "Cleaning Staff", 'value': 3},
    {'label': "Security Guard", 'value': 4},
    {'label': "Parking Attendant", 'value': 5},
    {'label': "Receptionist", 'value': 6},
    {'label': "Booking Manager", 'value': 7},
    {'label': "Referee / Umpire", 'value': 8},
    {'label': "Medical Assistant", 'value': 9},
  ];

  final List<Map<String, dynamic>> sortOptions = const [
    {'label': "Default", 'value': 0},
    {'label': "Salary", 'value': 1},
    {'label': "Time", 'value': 2},
    {'label': "Distance", 'value': 3},
  ];

  final List<Map<String, String>> jobListings = const [
    {
      'title': 'Security Guard',
      'turf': 'Arena 51',
      'location': 'Baner, Pune (6.5km)',
      'schedule': '10-08-2025, 10 AM - 11 PM',
      'pay': '₹2000/day',
      'applied': '4 Applied',
      'type': 'Per-Day',
    },
    {
      'title': 'Groundkeeper',
      'turf': 'Sporting Club',
      'location': 'Kothrud, Pune (3.2km)',
      'schedule': '11-08-2025, 8 AM - 4 PM',
      'pay': '₹1500/day',
      'applied': '1 Applied',
      'type': 'Full-Time',
    },
    {
      'title': 'Cleaning Staff',
      'turf': 'Gymkhana Grounds',
      'location': 'Viman Nagar, Pune (10.0km)',
      'schedule': '12-08-2025, 6 PM - 10 PM',
      'pay': '₹800/shift',
      'applied': '7 Applied',
      'type': 'Part-Time',
    },
  ];

  // 2. Dynamic Getter for all translation keys (Static + Dynamic)
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // AppBar & Sections
      "Available Jobs",
      "Job Listings",
      // Search Bar & Chips
      "Search for a specific job...",
      "Filter",
      "Sort",
      // Bottom Sheet Titles
      "Filter by Job Type",
      "Sort by",
      // Filter Options (Job Titles)
      for (var option in filterOptions) option['label'] as String,
      // Sort Options
      for (var option in sortOptions) option['label'] as String,
      // Job Card Static/Repeated Text
      "Apply Now",
      // Dynamic Keys (Job Titles, Turf Names)
      for (var job in jobListings) job['title'] as String,
      for (var job in jobListings) job['turf'] as String,
      for (var job in jobListings) job['type'] as String,
      // TurfInfo (from the original logic)
    };

    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }

    return keys.toList();
  }

  // 3. Load Translations function
  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;

    if (_currentLang == lang &&
        _translationsCache.keys.length == keysToLoad.length) {
      return;
    }

    _currentLang = lang;
    Map<String, String> newTranslations = {};

    for (String key in keysToLoad) {
      String translated = await getTranslatedText(key, lang);
      newTranslations[key] = translated;
    }

    if (mounted) {
      setState(() {
        _translationsCache = newTranslations;
      });
    }
  }

  // Listener function to call _loadTranslations when the language notifier changes
  void _languageChangeListener() {
    _loadTranslations(workerAppLanguageNotifier.value);
  }

  @override
  void initState() {
    super.initState();
    if (_currentLang != workerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    // Use WorkerThemeLangSettings/isDarkTrainerThemeNotifier as in the provided context
    _loadSelectedTheme();
    _loadSelectedLang();
    // Start listening for language changes
    workerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    workerAppLanguageNotifier.removeListener(_languageChangeListener);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await WorkerThemeLangSettings(
      theme: null,
    ).loadSelectedTheme();
    // Sync with worker notifier for local theme management
    isDarkWorkerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await WorkerThemeLangSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    workerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet); // Initial load of translations
  }

  // 4. Helper to retrieve cached translation
  String _getTranslation(String key) {
    // Returns the cached translation or the original key if not found
    return _translationsCache[key] ?? key;
  }

  // --- Utility Functions (Updated for translation) ---

  /// Generic function to display a modal bottom sheet for options.
  void _showOptionsBottomSheet({
    required String titleKey, // Changed to key
    required List<Map<String, dynamic>> options,
    required int selectedValue,
    required Function(int) onOptionSelected,
    required ThemeData theme,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: StatefulBuilder(
            builder: (context, setStateBottom) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getTranslation(titleKey), // ⬅️ TRANSLATED
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...options.map(
                      (option) => RadioListTile<int>(
                        title: Text(
                          _getTranslation(option['label']!), // ⬅️ TRANSLATED
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        value: option['value']!,
                        groupValue: selectedValue,
                        activeColor: theme.colorScheme.primary,
                        onChanged: (val) {
                          setStateBottom(() {
                            selectedValue = val!;
                          });
                          setState(() {
                            onOptionSelected(val!);
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void showFilterBottomSheet(ThemeData theme) {
    _showOptionsBottomSheet(
      titleKey: "Filter by Job Type", // Used the key
      options: filterOptions,
      selectedValue: selectedFilterValue,
      onOptionSelected: (value) => setState(() => selectedFilterValue = value),
      theme: theme,
    );
  }

  void showSortBottomSheet(ThemeData theme) {
    _showOptionsBottomSheet(
      titleKey: "Sort by", // Used the key
      options: sortOptions,
      selectedValue: selectedSortValue,
      onOptionSelected: (value) => setState(() => selectedSortValue = value),
      theme: theme,
    );
  }

  // --- WIDGET BUILD ---
  @override
  Widget build(BuildContext context) {
    // Only build if translations are loaded (basic check)

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkWorkerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme
            : CustomThemes.customLightTheme;

        return Theme(
          data: theme,
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: theme.colorScheme.background,
                appBar: AppBar(
                  title: Text(
                    _getTranslation('Available Jobs'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  centerTitle: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    IconButton(
                      onPressed: () async {
                        WorkerSettings workerSettingsobj =
                            await WorkerSettings().loadSettings();
                        final workermap = await firestoreobj
                            .collection("Turf_Worker")
                            .doc(workerSettingsobj.email)
                            .get();
                        Map<String, dynamic>? mapworker = workermap.data();
                        log("recived data succefully! ${mapworker}");
                      },
                      icon: Icon(
                        Icons.notifications_none,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                drawer: const WorkerDrawer(),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _buildSearchBar(theme),
                        const SizedBox(height: 20),
                        Text(
                          _getTranslation("Job Listings"), // ⬅️ TRANSLATED
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Pass the _getTranslation function to JobCard
                        ...jobListings
                            .map(
                              (job) => JobCard(
                                job: job,
                                theme: theme,
                                getTranslation:
                                    _getTranslation, // ⬅️ PASSED TRANSLATION HELPER
                              ),
                            )
                            .toList(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              if (_translationsCache.isEmpty)
                const Positioned.fill(child: WorkerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          style: TextStyle(color: theme.colorScheme.onBackground),
          decoration: InputDecoration(
            hintText: _getTranslation(
              "Search for a specific job...",
            ), // ⬅️ TRANSLATED
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: theme.colorScheme.onSurface),
                    onPressed: () {
                      searchController.clear();
                      setState(() {});
                    },
                  )
                : null,
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ActionChip(
              avatar: Icon(
                Icons.filter_list,
                color: selectedFilterValue != 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              label: Text(
                _getTranslation('Filter'), // ⬅️ TRANSLATED
                style: TextStyle(
                  color: selectedFilterValue != 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              onPressed: () => showFilterBottomSheet(theme),
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selectedFilterValue != 0
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ActionChip(
              avatar: Icon(
                Icons.sort,
                color: selectedSortValue != 0
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              label: Text(
                _getTranslation('Sort'), // ⬅️ TRANSLATED
                style: TextStyle(
                  color: selectedSortValue != 0
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              onPressed: () => showSortBottomSheet(theme),
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selectedSortValue != 0
                      ? theme.colorScheme.primary.withOpacity(0.5)
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------

class JobCard extends StatelessWidget {
  final Map<String, String> job;
  final ThemeData theme;
  // ⬅️ Accept the translation helper function
  final String Function(String) getTranslation;

  const JobCard({
    super.key,
    required this.job,
    required this.theme,
    required this.getTranslation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tapped on ${getTranslation(job['title']!)}'),
            ), // ⬅️ TRANSLATED
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.onBackground.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: theme.colorScheme.onBackground.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                  child: Text(
                    getTranslation(job['type']!), // ⬅️ TRANSLATED
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getTranslation(job['title']!), // ⬅️ TRANSLATED
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: theme.colorScheme.onSurface,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            getTranslation(job['turf']!), // ⬅️ TRANSLATED
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onBackground,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Schedule and Pay are dynamic values (dates, times, currency) and typically not translated,
                    // but the labels (like 'Applied') would be if they were present next to the values.
                    // Example: 'Applied' label is not shown in this row, but the number is.
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: theme.colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          job['schedule']!,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          color: theme.colorScheme.secondary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          job['pay']!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.secondary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 42),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                        ),
                        icon: const Icon(Icons.send, size: 18),
                        label: Text(
                          getTranslation("Apply Now"), // ⬅️ TRANSLATED
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                getTranslation('Applied for ${job['title']}!'),
                              ),
                            ), // ⬅️ TRANSLATED
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
