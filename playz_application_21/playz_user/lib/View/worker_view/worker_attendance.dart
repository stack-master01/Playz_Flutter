import 'package:flutter/material.dart';
import 'package:playz_user/Helper/Owner_Loader.dart';
import 'package:playz_user/Helper/Worker_Loader.dart';
import 'package:playz_user/View/worker_view/worker_drower.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';
import 'package:playz_user/View/worker_view/worker_language.dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

const List<Map<String, dynamic>> turfInfo = [];

class WorkerAttendancePage extends StatefulWidget {
  const WorkerAttendancePage({super.key});

  @override
  State<WorkerAttendancePage> createState() => _WorkerAttendancePageState();
}

class _WorkerAttendancePageState extends State<WorkerAttendancePage> {
  final List<Map<String, String>> assignedTurfs = const [
    {
      'name': 'Arena 51',
      'location': 'Baner, Pune, Maharashtra',
      'schedule': '9 AM - 5 PM',
      'status': 'Checked In',
      'imageUrl':
          "https://images.unsplash.com/photo-1570498839593-e565b39455fc?auto=format&fit=crop&q=60&w=600",
    },
    {
      'name': 'Sporting Club',
      'location': 'Kothrud, Pune, Maharashtra',
      'schedule': '8 AM - 4 PM',
      'status': 'Checked Out',
      'imageUrl':
          "https://images.unsplash.com/photo-1570498839593-e565b39455fc?auto=format&fit=crop&q=60&w=600",
    },
    {
      'name': 'Gymkhana Grounds',
      'location': 'Viman Nagar, Pune, Maharashtra',
      'schedule': '6 PM - 10 PM',
      'status': 'Pending',
      'imageUrl':
          "https://images.unsplash.com/photo-1570498839593-e565b39455fc?auto=format&fit=crop&q=60&w=600",
    },
  ];

  @override
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      'My Work Attendance',
      "Today's Assignments",
      'View Map',
      'Checked In',
      'Checked Out',
      'Pending',
      'View Attendance',
    };

    for (var turf in assignedTurfs) {
      if (turf['name'] is String) keys.add(turf['name']!);
      if (turf['location'] is String) keys.add(turf['location']!);
      if (turf['schedule'] is String) keys.add(turf['schedule']!);
    }

    for (var info in turfInfo) {
      if (info['turfName'] is String) keys.add(info['turfName'] as String);
    }

    return keys.toList();
  }

  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;

    if (_currentLang == lang &&
        _translationsCache.keys.length == keysToLoad.length)
      return;

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

  void _languageChangeListener() {
    _loadTranslations(workerAppLanguageNotifier.value);
  }

  @override
  void initState() {
    super.initState();
    if (_currentLang != workerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    workerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    workerAppLanguageNotifier.removeListener(_languageChangeListener);
    super.dispose();
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await WorkerThemeLangSettings(
      theme: null,
    ).loadSelectedTheme();
    isDarkWorkerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await WorkerThemeLangSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    workerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet);
  }

  String _getTranslation(String key) {
    return _translationsCache[key] ?? key;
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status) {
      case 'Checked In':
        return theme.colorScheme.secondary;
      case 'Checked Out':
        return Colors.blueGrey;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getActionLabelKey(String status) {
    return 'View Attendance'; // 🔄 Always show View Attendance
  }

  // 🧾 Show Modal Bottom Sheet with attendance info
  void _showAttendanceDetails(BuildContext context, Map<String, String> turf) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                turf['name'] ?? 'Unknown Turf',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      turf['location'] ?? '',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time, color: theme.colorScheme.secondary),
                  const SizedBox(width: 8),
                  Text(
                    'Schedule: ${turf['schedule']}',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: _getStatusColor(turf['status']!, theme),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${turf['status']}',
                    style: TextStyle(
                      color: _getStatusColor(turf['status']!, theme),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(180, 45),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text("Close"),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    _getTranslation('My Work Attendance'),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  centerTitle: false,
                ),
                drawer: const WorkerDrawer(),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20.0,
                        10.0,
                        20.0,
                        10.0,
                      ),
                      child: Text(
                        _getTranslation("Today's Assignments"),
                        style: TextStyle(
                          color: theme.colorScheme.onBackground,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        itemCount: assignedTurfs.length,
                        itemBuilder: (context, index) {
                          return _TurfCard(
                            turf: assignedTurfs[index],
                            theme: theme,
                            getTranslation: _getTranslation,
                            getActionLabelKey: _getActionLabelKey,
                            getStatusColor: _getStatusColor,
                            onViewAttendance: _showAttendanceDetails, // ✅
                          );
                        },
                      ),
                    ),
                  ],
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
}

class _TurfCard extends StatelessWidget {
  final Map<String, String> turf;
  final ThemeData theme;
  final String Function(String key) getTranslation;
  final String Function(String status) getActionLabelKey;
  final Color Function(String status, ThemeData theme) getStatusColor;
  final void Function(BuildContext, Map<String, String>) onViewAttendance;

  const _TurfCard({
    super.key,
    required this.turf,
    required this.theme,
    required this.getTranslation,
    required this.getActionLabelKey,
    required this.getStatusColor,
    required this.onViewAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final statusKey = turf['status']!;
    final statusColor = getStatusColor(statusKey, theme);
    final translatedName = getTranslation(turf['name']!);
    final translatedLocation = getTranslation(turf['location']!);
    final translatedSchedule = getTranslation(turf['schedule']!);
    final translatedStatus = getTranslation(statusKey);
    final translatedActionLabel = getTranslation('View Attendance');
    final translatedViewMap = getTranslation('View Map');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.onBackground.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(turf['imageUrl']!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translatedName,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 22,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              translatedLocation,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(
                                  0.7,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              translatedSchedule,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onBackground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    translatedStatus,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 1.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: theme.colorScheme.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      translatedViewMap,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => onViewAttendance(context, turf),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(140, 40),
                    elevation: 3,
                  ),
                  icon: const Icon(Icons.remove_red_eye),
                  label: Text(translatedActionLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}