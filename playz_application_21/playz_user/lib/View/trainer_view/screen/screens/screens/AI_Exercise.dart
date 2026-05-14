import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
// Note: Assuming these imports are correct and available
import 'package:playz_user/Controller/Trainer_Controller/Trainer_User_Chat_Controller.dart';
import 'package:playz_user/Controller/User_Controller/User_Group_Chat_Controller.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
import 'package:playz_user/Helper/Trainer_Loader.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/Trainer_User_Chat.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/language_screen.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/trainer_menu.dart';
import 'package:playz_user/View/user_view/home(sport)/Friends/Friend_Chat.dart';
import 'package:url_launcher/url_launcher.dart';
import 'coach_home_screen.dart';
import 'package:http/http.dart' as http;

// END MOCK AREA

const String geminiApiKey = "AIzaSyAIqRzXGO72L94qsjQGKbkbW6163ujXITM";
const String geminiModel = "gemini-2.5-flash";
String get apiUrl =>
    "https://generativelanguage.googleapis.com/v1beta/models/$geminiModel:generateContent?key=$geminiApiKey";
Map<String, String> _translationsCache = {};
String _currentLang = "en";

const List<Map<String, dynamic>> turfInfo = [];
// ----------------------------------------------------------------------

class ChatMessage {
  final String role;
  final String content;
  final DateTime dateTime; // Added to show message time

  ChatMessage({
    required this.role,
    required this.content,
    required this.dateTime,
  });
}

class AIExerciseGen extends StatefulWidget {
  String selectedSport = "";
  String exerciseType = "";
  String afterBefore = "";
  String groupID = "";
  AIExerciseGen({
    super.key,
    required this.exerciseType,
    required this.selectedSport,
    required this.groupID,
    required this.afterBefore,
  });

  @override
  State<AIExerciseGen> createState() => _AIExerciseGenState();
}

class _AIExerciseGenState extends State<AIExerciseGen> {
  String currentSelectedSport = "";
  String currentExerciseType = "";
  String currentAfterBefore = "";
  List<dynamic> exerciseList = [];
  String userInput = "";
  final List<ChatMessage> _messages = [];
  bool _sending = false;

  final Set<Map<String, dynamic>> _selectedExercises = {};

  Future<List<dynamic>> _sendMessage(String userInput) async {
    if (userInput.trim().isEmpty || _sending) return [];

    final now = DateTime.now();
    setState(() {
      _sending = true;
      _messages.add(
        ChatMessage(role: "user", content: userInput.trim(), dateTime: now),
      );
    });

    // Build Gemini request body
    final Map<String, dynamic> requestBody = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": userInput},
          ],
        },
      ],
      "systemInstruction": {
        "parts": [
          {
            "text":
                "You are a helpful assistant. Keep responses concise. Only return the JSON array as requested. Do not include any markdown fences, backticks, or extra text.",
          },
        ],
      },
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String reply =
            (data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '[]')
                .toString()
                .trim();

        // Ensure we extract only the JSON array structure
        int startIndex = reply.indexOf('[');
        int endIndex = reply.lastIndexOf(']');
        if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
          reply = reply.substring(startIndex, endIndex + 1);
        }

        List<dynamic> parsedList = [];
        try {
          parsedList = jsonDecode(reply);
          log("✅ Parsed exercise list: $parsedList");
        } catch (e) {
          log("❌ Error parsing JSON: $e");
          log("Raw reply: $reply");
        }

        setState(() {
          exerciseList = parsedList;
          _messages.add(
            ChatMessage(
              role: "assistant",
              content: reply,
              dateTime: DateTime.now(),
            ),
          );
        });

        return parsedList;
      } else {
        log('Response (${response.statusCode}): ${response.body}');
        String errorMsg;
        switch (response.statusCode) {
          case 400:
            errorMsg = 'Bad request. The input may be too long or invalid.';
            break;
          case 401:
            errorMsg = 'Invalid API key. Please check your Gemini API key.';
            break;
          case 429:
            errorMsg = 'Rate limit exceeded. Please try again later.';
            break;
          case 500:
            errorMsg = 'Gemini server error. Please try again later.';
            break;
          default:
            errorMsg = 'Failed to connect to AI. Status ${response.statusCode}';
        }
        log('❌ $errorMsg');
        return [];
      }
    } catch (e) {
      log("❌ Error: $e");
      return [];
    } finally {
      setState(() => _sending = false);
    }
  }

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Students",
      "Generate Plan",
      "Type your custom request here...",
      "Warm-up Exercises",
      "Stretching Exercises",
      "Choose Exercise Type",
      "No exercises generated yet.",
      "Regenerate",
    };

    for (var info in turfInfo) {
      if (info['turfName'] is String) (info['turfName'] as String);
    }

    return keys.toList();
  }

  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;

    if (_currentLang == lang &&
        _translationsCache.keys.length == keysToLoad.length) {
      return;
    }

    _currentLang = lang;
    Map<String, String> newTranslations = {};

    for (String key in keysToLoad) {
      String translated = key;
      newTranslations[key] = translated;
    }

    if (mounted) {
      setState(() {
        _translationsCache = newTranslations;
      });
    }
  }

  void _languageChangeListener() {
    _loadTranslations(trainerAppLanguageNotifier.value);
  }

  @override
  void initState() {
    super.initState();
    currentSelectedSport = widget.selectedSport;
    currentExerciseType = widget.exerciseType;
    currentAfterBefore = widget.afterBefore;

    userInput =
        'Generate a JSON array containing multiple $currentExerciseType exercises specifically designed $currentAfterBefore playing $currentSelectedSport. Each object in the array must strictly adhere to the following structure: {"exercise": "name of exercise", "no of repetetions": "number or duration", "how to do it": "steps to perform", "youtube link" : "reference of a youtube video so that the student can directly see how its done"}. Return only this JSON array, with absolutely no preceding or succeeding text, explanations, or markdown formatting (like code fences)';

    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadSelectedLang();
    await _loadSelectedTheme();

    final result = await _sendMessage(userInput);
    if (result.isNotEmpty) {
      log("✅ Exercises fetched successfully");
    } else {
      log("⚠️ No exercises returned");
    }

    if (_currentLang != trainerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }

    trainerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  Future<void> _regenerateExercises() async {
    setState(() {
      exerciseList.clear();
      _selectedExercises.clear();
    });
    final result = await _sendMessage(userInput);
    if (result.isNotEmpty) {
      log("✅ Exercises regenerated successfully");
    } else {
      log("⚠️ No exercises returned on regeneration");
    }
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

  Future<void> _loadSelectedLocation() async {}

  void _toggleExerciseSelection(Map<String, dynamic> exercise) {
    setState(() {
      // Since the exercises are generated dynamically, we compare the entire map object.
      // Note: This relies on the exercise maps being identical references if selected immediately after generation.
      if (_selectedExercises.contains(exercise)) {
        _selectedExercises.remove(exercise);
      } else {
        _selectedExercises.add(exercise);
      }
    });
  }

  Future<void> _processSelectedExercises() async {
    if (_selectedExercises.isEmpty) {
      log("No exercises selected to process.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one exercise.')),
      );
      return;
    }

    // Convert the Set of Maps back into a List
    final List<Map<String, dynamic>> selectedList = _selectedExercises.toList();

    // Convert List<dynamic> into a single string (JSON format)
    final String selectedListString = jsonEncode(selectedList);

    // Print the resulting string to the log
    log('--- SELECTED EXERCISES PLAN ---');
    log(selectedListString);
    log('-------------------------------');

    TrainerSettings userSettings = await TrainerSettings().loadSettings();
    final now = DateTime.now(); // Capture time once

    final groupMessage = UserGroupChatController().createGroupChatObject(
      created_at: now,
      from_id: userSettings.trainerEmail!,
      from_name: userSettings.trainerName ?? "Anonymous",
      image_url: "image_url",
      is_image: false,
      text: selectedListString,
    );

    UserGroupChatController().uploadGroupChat(
      groupMessage,
      groupId: widget.groupID,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Plan generated and logged! (${_selectedExercises.length} exercises)',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  // --- WIDGET BUILD METHODS ---

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkTrainerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme
            : CustomThemes.customLightTheme;

        final String generatePlanKey = "Send Plan";

        return Theme(
          data: theme,
          child: Scaffold(
            backgroundColor: theme.colorScheme.background,
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
            drawer: const TrainerDrawer(),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  Expanded(
                    child: exerciseList.isEmpty
                        ? Center(
                            child: _sending
                                ? const CircularProgressIndicator()
                                : Text(
                                    _getTranslation(
                                      "No exercises generated yet.",
                                    ),
                                    style: TextStyle(
                                      color: theme.colorScheme.onBackground
                                          .withOpacity(0.7),
                                    ),
                                  ),
                          )
                        : ListView.builder(
                            itemCount: exerciseList.length,

                            itemBuilder: (context, index) {
                              final exercise = exerciseList[index];
                              final bool isSelected = _selectedExercises
                                  .contains(exercise);

                              // Use surface/container colors to ensure good contrast in both themes
                              final Color cardColor = isSelected
                                  ? theme.colorScheme.primaryContainer
                                  : theme.colorScheme.surface;

                              final Color titleColor = isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.onSurface;

                              final Color subtitleColor = isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                        .withOpacity(0.9)
                                  : theme.colorScheme.onSurface.withOpacity(
                                      0.7,
                                    );

                              return Card(
                                color: cardColor,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: isSelected
                                      ? BorderSide(
                                          color: theme.colorScheme.primary,
                                          width: 2,
                                        )
                                      : BorderSide.none,
                                ),
                                child: ListTile(
                                  leading: Checkbox(
                                    value: isSelected,
                                    onChanged: (bool? value) {
                                      _toggleExerciseSelection(exercise);
                                    },
                                    activeColor: theme.colorScheme.primary,
                                    checkColor: theme.colorScheme.onPrimary,
                                  ),
                                  title: Text(
                                    exercise['exercise'] ?? 'N/A',
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Reps: ${exercise['no of repetetions'] ?? 'N/A'}",
                                        style: TextStyle(color: subtitleColor),
                                      ),
                                      Text(
                                        "How to: ${exercise['how to do it'] ?? 'N/A'}",
                                        style: TextStyle(color: subtitleColor),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      if (exercise['youtube link'] != null &&
                                          (exercise['youtube link'] as String)
                                              .isNotEmpty)
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  theme.colorScheme.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                            ),
                                            icon: const Icon(
                                              Icons.play_circle_fill,
                                              color: Colors.white,
                                            ),
                                            label: const Text(
                                              "Watch on YouTube",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onPressed: () async {
                                              final url = Uri.parse(
                                                exercise['youtube link'],
                                              );
                                              if (await canLaunchUrl(url)) {
                                                await launchUrl(
                                                  url,
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              } else {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "Could not open YouTube link",
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                  onTap: () {
                                    _toggleExerciseSelection(exercise);
                                  },
                                ),
                              );
                            },
                          ),
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _sending ? null : _regenerateExercises,
                          icon: const Icon(Icons.refresh),
                          label: Text(_getTranslation("Regenerate")),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.secondary,
                            foregroundColor: theme.colorScheme.onSecondary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _sending || exerciseList.isEmpty
                              ? null
                              : _processSelectedExercises,
                          icon: const Icon(Icons.send_to_mobile),
                          label: Text(_getTranslation(generatePlanKey)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.tertiary,
                            foregroundColor: theme.colorScheme.onTertiary,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// --- Placeholder Widgets/Classes (Keep these accessible in your project) ---

class TrainerDrawer extends StatelessWidget {
  const TrainerDrawer({super.key});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Trainer Menu',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Home',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const CoachHomeScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Language',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LanguageScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Dummy Classes to prevent compile errors based on imports used
class TrainerThemeLangSettings {
  final dynamic theme;
  TrainerThemeLangSettings({required this.theme});
  Future<String?> loadSelectedTheme() async => "Light";
  Future<String?> loadSelectedLocale() async => "en";
}

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Language Settings')),
      body: const Center(child: Text('Language Screen')),
    );
  }
}

class CoachHomeScreen extends StatelessWidget {
  const CoachHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coach Home')),
      body: const Center(child: Text('Coach Home Screen')),
    );
  }
}
