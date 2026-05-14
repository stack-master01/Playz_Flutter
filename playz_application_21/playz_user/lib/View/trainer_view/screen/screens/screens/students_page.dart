import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/Trainer_Controller/Trainer_User_Chat_Controller.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
import 'package:playz_user/Helper/Trainer_Loader.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/Trainer_User_Chat.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/language_screen.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/trainer_menu.dart';

// --- MOCK IMPLEMENTATIONS FOR EXTERNAL DEPENDENCIES ---

// MOCK: Shared Preferences and Settings








// --- GLOBAL MOCK DATA/UTILITIES ---
Map<String, String> _translationsCache = {};
String _currentLang = "en";
const List<Map<String, dynamic>> turfInfo = [];
// MOCK: FirebaseFirestore instance (Only used for data structure, no real DB access)
final FirebaseFirestore _mockFirestore = FirebaseFirestore.instance;


// ⚠️ IMPORTANT: Define a structure for a student
class StudentData {
  final String name;
  final String imageUrl;
  final String email;

  StudentData({
    required this.name,
    required this.imageUrl,
    required this.email,
  });

  factory StudentData.fromMap(Map<String, dynamic> map) {
    return StudentData(
      name: map['student_name'] as String,
      imageUrl: map['image_url'] as String? ?? 'assets/profile_placeholder.png',
      email: map['student_email'] as String,
    );
  }
}

// ----------------------------------------------------------------------
// -------------------- COACH STUDENTS SCREEN -----------------------------
// ----------------------------------------------------------------------

class CoachStudentsScreen extends StatefulWidget {
  const CoachStudentsScreen({super.key});

  @override
  State<CoachStudentsScreen> createState() => _CoachStudentsScreenState();
}

class _CoachStudentsScreenState extends State<CoachStudentsScreen> {
  // 1. STATE VARIABLES
  Map<String, List<StudentData>> _studentsBySport = {};
  String selectedSport = "";
  // ⭐️ NEW STATE VARIABLE: To hold the trainer's list of sports
  List<String> _trainerSports = [];
  final List<String> studentNames = []; // Kept for the _allTranslationKeys getter

  // 2. Dynamic Getter for all translation keys
  @override
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Students",
      // Use the filtered list of sports for translation keys
      ..._studentsBySport.keys,
      // Add all Student names
      ..._studentsBySport.values.expand(
        (list) => list.map((student) => student.name),
      ),
      for (var info in turfInfo)
        if (info['turfName'] is String) (info['turfName'] as String),
    };
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
      // Mocking getTranslatedText
      String translated = key;
      newTranslations[key] = translated;
    }

    if (mounted) {
      setState(() {
        _translationsCache = newTranslations;
      });
    }
  }

  String chatID = "";
  void _languageChangeListener() {
    _loadTranslations(trainerAppLanguageNotifier.value);
  }

  String generateChatRoomId({required String currentUserId, required String otherUserId}) {
    List<String> userIds = [currentUserId, otherUserId];
    userIds.sort();
    return userIds.join('_');
  }

  // ⭐️ NEW: Load the trainer's sport list from Firestore (MOCKED)
  Future<void> _loadTrainerSports() async {
    try {
      TrainerSettings trainerSettings = await TrainerSettings().loadSettings();
      if (trainerSettings.trainerEmail == null) return;

      // ⚠️ MOCKING FIREBASE FETCH: Trainer is registered for Cricket and Football
      if (trainerSettings.trainerEmail == "trainer123@playz.com") {
        _trainerSports = ["Cricket", "Football"];
      } else {
        // Fallback for other mock users
        _trainerSports = ["Cricket", "Football", "Badminton"];
      }
      
      log("Trainer Sports Loaded: $_trainerSports");
    } catch (e) {
      log("Error loading trainer sports: $e");
      _trainerSports = [];
    }
  }

  // 4. MODIFIED: Load and Process All Students Data
  Future<void> loadAllStudents() async {
    // 1. Load Trainer Sports first
    await _loadTrainerSports(); // ⬅️ Fetches and sets _trainerSports

    // 2. Fetch all student data (unfiltered)
    final studentDataList = await TrainerUserChatController().fetchAllStudents();
    log("fetched all students: $studentDataList");

    // 3. Process the data, only keeping sports that are in _trainerSports
    Map<String, List<StudentData>> newStudentsBySport = {};

    for (var sportData in studentDataList) {
      final sportName = sportData['userSport'] as String?;
      final studentList = sportData['student_list'] as List<dynamic>?;

      // ⭐️ CHECK: Only proceed if the sport is in the trainer's list
      if (sportName != null && studentList != null && _trainerSports.contains(sportName)) {
        List<StudentData> students = studentList
            .whereType<Map<String, dynamic>>()
            .map((e) => StudentData.fromMap(e))
            .toList();

        newStudentsBySport[sportName] = students;
      } else {
        if (sportName != null) {
          log("Skipping sport '$sportName' as it's not in trainer's sports list ($_trainerSports).");
        }
      }
    }

    // 4. Update state
    if (mounted) {
      setState(() {
        _studentsBySport = newStudentsBySport;

        // Set the initial selected sport to the first one available
        if (_studentsBySport.isNotEmpty && selectedSport.isEmpty) {
          selectedSport = _studentsBySport.keys.first;
        } else if (_studentsBySport.isEmpty) {
          // Clear selection if no sports are available after filter
          selectedSport = "";
        }
      });
      // Important: Reload translations as new sports and student names are now available
      _loadTranslations(trainerAppLanguageNotifier.value);
    }
  }

  @override
  void initState() {
    super.initState();
    if (_currentLang != trainerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    loadAllStudents();
    trainerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    trainerAppLanguageNotifier.removeListener(_languageChangeListener);
    super.dispose();
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await TrainerThemeLangSettings(
      theme: null,
    ).loadSelectedTheme();
    isDarkTrainerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await TrainerThemeLangSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    trainerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet);
  }

  String _getTranslation(String key) {
    return _translationsCache[key] ?? key;
  }

  // --- WIDGET BUILD METHODS ---

  @override
  Widget build(BuildContext context) {
    final currentStudents = _studentsBySport[selectedSport] ?? [];

    return ValueListenableBuilder<bool>(
      valueListenable: isDarkTrainerThemeNotifier,
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

                // 🔸 App Bar
                appBar: AppBar(
                  backgroundColor: theme.colorScheme.primary,
                  elevation: 0,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: theme.colorScheme.onPrimary,
                        size: 28,
                      ),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  actions: [
                    Icon(
                      Icons.notifications_none,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 15),
                    Icon(
                      Icons.chat_bubble_outline,
                      color: theme.colorScheme.onPrimary,
                    ),
                    const SizedBox(width: 15),
                  ],
                ),

                // 🔸 Drawer
                drawer: const TrainerDrawer(),

                // 🔸 Body
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTranslation("Students"),
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // 🔹 Tabs: DYNAMICALLY BUILT FROM FILTERED _studentsBySport KEYS
                      SizedBox(
                        height: 40,
                        child: _studentsBySport.isEmpty
                            ? Center(
                                child: Text(
                                  _trainerSports.isEmpty 
                                      ? "No sports configured for this trainer."
                                      : "No students found in your registered sports.",
                                  style: TextStyle(
                                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                                  ),
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _studentsBySport.keys.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  final sportKey =
                                      _studentsBySport.keys.elementAt(index);
                                  return _buildSportTab(sportKey, theme);
                                },
                              ),
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Students List
                      Expanded(
                        child: currentStudents.isEmpty
                            ? Center(
                                child: Text(
                                  _studentsBySport.isNotEmpty
                                      ? "No students found for ${_getTranslation(selectedSport)}"
                                      : "Loading students...",
                                  style: TextStyle(
                                    color: theme.colorScheme.onBackground,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: currentStudents.length,
                                itemBuilder: (context, index) {
                                  final student = currentStudents[index];
                                  return _buildStudentTile(student, theme);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              // Show loader if translations are loading OR if data hasn't been fetched yet
              if (_studentsBySport.isEmpty && selectedSport.isEmpty && _trainerSports.isEmpty)
                const Positioned.fill(child: TrainerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }

  // 🔹 Helper: Sport Tabs
  Widget _buildSportTab(String sportKey, ThemeData theme) {
    final isSelected = selectedSport == sportKey;
    return GestureDetector(
      onTap: () {
        log("student data: $sportKey");
        setState(() => selectedSport = sportKey);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _getTranslation(sportKey),
          style: TextStyle(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // 🔹 Helper: Student Card
  Widget _buildStudentTile(StudentData student, ThemeData theme) {
    final nameKey = student.name;

    return GestureDetector(
      onTap: () async {
        TrainerSettings trainerSettings = await TrainerSettings().loadSettings();
        Map<String, dynamic> friendData = {
          "email": student.email,
          "image_url": student.imageUrl,
          "name": student.name,
        };
        chatID = generateChatRoomId(
          otherUserId: student.email,
          currentUserId: trainerSettings.trainerEmail!,
        );

        friendData['groupID'] = chatID;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return TrainerUserChat(
                groupDataMap: friendData,
                selectedSport: selectedSport,
              );
            },
          ),
        );
        log("student data: ${student.email}");
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withOpacity(0.08),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: theme.colorScheme.surfaceVariant,
              backgroundImage: student.imageUrl.startsWith('http')
                  ? NetworkImage(student.imageUrl) as ImageProvider<Object>?
                  : const AssetImage('assets/Images/profile_placeholder.jpg'),
            ),
            const SizedBox(width: 15),
            Text(
              _getTranslation(nameKey),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}