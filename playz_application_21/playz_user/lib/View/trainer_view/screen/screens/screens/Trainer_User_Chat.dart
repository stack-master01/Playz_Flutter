import 'dart:convert';
import 'dart:developer'; // Required for log()
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:playz_user/Controller/User_Controller/User_Group_Chat_Controller.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/AI_Exercise.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/trainer_menu.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:url_launcher/url_launcher.dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

// Assuming UserSettings, appLanguageNotifier, appSettingsNotifier, ThemeSettings,
// getTranslatedText, Appsharedpreferences, selectedLocationNotifier,
// UserGroupChatController are defined elsewhere and accessible.

class TrainerUserChat extends StatefulWidget {
  final String selectedSport;
  final Map<String, dynamic> groupDataMap;
  TrainerUserChat({
    super.key,
    required this.groupDataMap,
    required this.selectedSport,
  });

  @override
  State<TrainerUserChat> createState() => _TrainerUserChatState();
}

class _TrainerUserChatState extends State<TrainerUserChat> {
  String? currentUser;
  Map<String, dynamic> currentGroupDataMap = {};
  TextEditingController messageController = TextEditingController();

  // ===================================================================
  // CACHED TRANSLATION LOGIC (UNCHANGED, BUT RELEVANT) 🌍
  // ===================================================================

  List<Map<String, dynamic>> turfInfo = [];
  // ✅ Dummy chat data (Used to collect dynamic keys for translation)
  List<Map<String, dynamic>> chatMessages = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Cricket Legends Hub",
      "Type a Message",
      "Cricket Legends Hub Cricket Legends Hub Cricket Legends Hub",
      // END: Add default english text here
    };

    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }

    // Dynamically collect keys from the chat messages (Names and Messages)
    for (var chat in chatMessages) {
      if (chat['name'] is String) {
        keys.add(chat['name'] as String);
      }
      if (chat['message'] is String) {
        keys.add(chat['message'] as String);
      }
    }
    _extractStrings(currentGroupDataMap, keys);
    return keys.toList();
  }

  void _extractStrings(dynamic data, Set<String> keys) {
    if (data is String) {
      if (data.isNotEmpty) {
        keys.add(data);
      }
    } else if (data is Map) {
      data.values.forEach((value) => _extractStrings(value, keys));
    } else if (data is List) {
      data.forEach((item) => _extractStrings(item, keys));
    }
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
      // NOTE: Replace with your actual translation fetch logic
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
    _loadTranslations(appLanguageNotifier.value);
  }

  Future<void> loadCurrentUser() async {
    // ⚠️ IMPORTANT: Ensure you await this call
    UserSettings userSettings = await UserSettings().loadSettings();
    currentUser = userSettings.email;
    log("Current User Email: $currentUser");
    // Force a re-render to update the 'isMe' logic in StreamBuilder
    if (mounted) {
      setState(() {});
    }
  }

  // ✅ CORRECTED: Group and Sort Messages for Chat Display
  Map<String, List<Map<String, dynamic>>> groupAndSortMessages(
    List<Map<String, dynamic>> messages,
  ) {
    if (messages.isEmpty) {
      return {};
    }

    // Create a mutable copy to sort (important because you're sorting in place)
    List<Map<String, dynamic>> sortedMessages = List.from(messages);
    // 1. Sort the entire list by time, oldest first (ascending)
    // This is the correct order for chronological chat history.
    sortedMessages.sort((a, b) {
      final DateTime dateTimeA = a['dateTime'] as DateTime;
      final DateTime dateTimeB = b['dateTime'] as DateTime;
      return dateTimeB.compareTo(dateTimeA); // Oldest messages come first
    });

    // 2. Group the messages by day
    Map<String, List<Map<String, dynamic>>> groupedMessages = {};
    final DateFormat dayFormatter = DateFormat('d MMMM yyyy');

    for (var message in sortedMessages) {
      final DateTime dateTime = message['dateTime'] as DateTime;
      // Format the date to use as the group key (e.g., "15 October 2025")
      final String dateKey = dayFormatter.format(dateTime);

      // If the key doesn't exist, create a new list for that date
      if (!groupedMessages.containsKey(dateKey)) {
        groupedMessages[dateKey] = [];
      }

      // Add the message to the list for that date
      groupedMessages[dateKey]!.add(message);
    }

    // 3. Reverse the order of the keys (dates) so the latest date is first
    // (Latest date at the top of the chat view)
    final sortedDateKeys = groupedMessages.keys.toList()
      ..sort((a, b) {
        final DateTime dateA = dayFormatter.parse(a);
        final DateTime dateB = dayFormatter.parse(b);
        // Compare in descending order (latest date first)
        return dateB.compareTo(dateA);
      });

    // 4. Create the final map with dates sorted latest-first,
    // and messages within each day are already sorted oldest-first from step 1.
    Map<String, List<Map<String, dynamic>>> finalGroupedMessages = {};
    for (var key in sortedDateKeys) {
      finalGroupedMessages[key] = groupedMessages[key]!;
    }

    return finalGroupedMessages;
  }

  String groupNameKey = "";
  String groupImage = "";
  @override
  void initState() {
    super.initState();
    currentGroupDataMap = widget.groupDataMap;
    log("message data: $currentGroupDataMap");
    if (_currentLang != appLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadSelectedLocation();

    // IMPORTANT: Make sure loadCurrentUser is done before the StreamBuilder runs
    // to ensure 'currentUser' is available for the 'isMe' logic.
    loadCurrentUser();

    groupNameKey = currentGroupDataMap['name'] ?? "name";
    groupImage = currentGroupDataMap['image_url'] ?? "image url";
    appLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    messageController.dispose();
    appLanguageNotifier.removeListener(_languageChangeListener);
    super.dispose();
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await ThemeSettings(
      theme: null,
    ).loadSelectedTheme();
    appSettingsNotifier.value = ThemeSettings(theme: selectedTheme);
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await ThemeSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    appLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet);
  }

  String _getTranslation(String key) => _translationsCache[key] ?? key;
  // ------------------------------------------------------------------

  String? selectedLocation;

  Future<void> _loadSelectedLocation() async {
    String? selected = await Appsharedpreferences().loadSelectedCity();
    selectedLocationNotifier.value = selected;
    log("city in home page: $selected");
    setState(() {
      selectedLocation = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    const String inputHintKey = "Type a Message";
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkTrainerThemeNotifier,
      builder: (context, isDarkMode, _) {
        final bool isDark = isDarkMode;
        final theme = isDarkMode
            ? CustomThemes.customDarkTheme
            : CustomThemes.customLightTheme;

        return Theme(
          data: theme,
          child: Stack(
            children: [
              Scaffold(
                body: Stack(
                  children: [
                    // ✅ Green header (Unchanged)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      // Use theme primary color for header
                      color: theme.colorScheme.primary,
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: Reusable.getDeviceHeight(context, H: 40),
                            left: Reusable.getDeviceHeight(context, H: 10),
                            right: Reusable.getDeviceHeight(context, H: 10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    icon: Icon(
                                      Icons.arrow_back_ios_new,
                                      size: Reusable.getDeviceWidth(
                                        context,
                                        W: 25,
                                      ),
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  GestureDetector(
                                    child: Row(
                                      children: [
                                        Container(
                                          height: Reusable.getDeviceHeight(
                                            context,
                                            H: 50,
                                          ),
                                          width: Reusable.getDeviceWidth(
                                            context,
                                            W: 50,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 25,
                                              ),
                                            ),
                                            color: Colors.amber,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 25,
                                              ),
                                            ),
                                            child: Image.network(
                                              groupImage,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: Reusable.getDeviceWidth(
                                            context,
                                            W: 10,
                                          ),
                                        ),
                                        Text(
                                          _getTranslation(
                                            groupNameKey,
                                          ), // 🌍 Translated
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: theme.colorScheme.onPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  showOptions(context);
                                },
                                icon: Icon(
                                  Icons.run_circle_outlined,
                                  size: Reusable.getDeviceWidth(context, W: 30),
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // ✅ White bottom sheet for chat
                    Positioned(
                      top: Reusable.getDeviceHeight(context, H: 110),
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(0),
                            topRight: Radius.circular(0),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(0),
                                topRight: Radius.circular(0),
                              ),
                              child: Opacity(
                                opacity: 0.1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    image: DecorationImage(
                                      image: AssetImage(
                                        isDark
                                            ? "assets/Images/dark1.png"
                                            : "assets/Images/light1_upscaled.png",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 20,
                                  ),
                                ),

                                // 🔹 Chat messages ListView (StreamBuilder)
                                Expanded(
                                  child: StreamBuilder<List<Map<String, dynamic>>>(
                                    stream: UserGroupChatController()
                                        .streamCentralGroupChats(
                                          groupId:
                                              currentGroupDataMap['groupID'],
                                        ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        // Show a loader while waiting for the initial connection
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        log('Stream Error: ${snapshot.error}');
                                        return const Center(
                                          child: Text(
                                            'Error loading messages.',
                                          ),
                                        );
                                      }
                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const Center(
                                          child: Text('Start a conversation!'),
                                        );
                                      }

                                      final allTrainerUserChats =
                                          snapshot.data!;
                                      List<Map<String, dynamic>>
                                      processedChats = [];

                                      // 1. Process Timestamps and create chatCards
                                      for (var newItem in allTrainerUserChats) {
                                        final Timestamp? timestamp =
                                            newItem['created_at'] as Timestamp?;
                                        if (timestamp == null) continue;

                                        final DateTime dateTime = timestamp
                                            .toDate();
                                        final String formattedTime = DateFormat(
                                          'jm',
                                        ).format(dateTime);

                                        Map<String, dynamic> chatCard = {
                                          "name": newItem['from_name'],
                                          "message": newItem['text'],
                                          "time": formattedTime,
                                          "email": newItem['from_id'],
                                          "dateTime":
                                              dateTime, // Used for sorting/grouping
                                        };
                                        processedChats.add(chatCard);
                                      }

                                      // 2. Update local list for translation key collection
                                      if (chatMessages.length !=
                                          processedChats.length) {
                                        chatMessages = processedChats;
                                        // Don't call setState here, StreamBuilder will handle the refresh,
                                        // but we still need to load new translation keys.
                                        _loadTranslations(
                                          appLanguageNotifier.value,
                                        );
                                      }

                                      // 3. Group and sort the messages
                                      final groupedMessages =
                                          groupAndSortMessages(processedChats);

                                      // 4. Create a flat list of items (Message or Date Header)
                                      List<dynamic> chatItems = [];
                                      // Iterate through dates (OLDEST FIRST)
                                      groupedMessages.forEach((date, messages) {
                                        // Add all messages for that date (OLDEST FIRST)

                                        chatItems.addAll(messages);
                                        chatItems.add(date);

                                        // Add the date header *after* the messages for that day
                                        // because we are using reverse: true on the ListView.
                                      });

                                      // Note on ListView `reverse: true`:
                                      // - `chatItems.last` will be the item at index 0 in the reversed view (the bottom).
                                      // - The list should be ordered: [OLD_MSG_1, OLD_MSG_2, ..., DATE_OLD, NEW_MSG_1, NEW_MSG_2, ..., DATE_NEW]
                                      // - With `reverse: true`, the NEWEST item is displayed at the bottom of the screen (the correct chat behaviour).

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                        ),
                                        child: ListView.builder(
                                          reverse:
                                              true, // Crucial for chat apps (newest message at the bottom)
                                          padding: const EdgeInsets.only(
                                            top: 10,
                                            bottom: 20,
                                          ),
                                          itemCount: chatItems.length,
                                          itemBuilder: (context, index) {
                                            final item = chatItems[index];

                                            // 🗓️ If it's a date header string
                                            if (item is String) {
                                              return Center(
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                      ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    item,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }

                                            // 💬 Otherwise it's a chat message
                                            final chat =
                                                item as Map<String, dynamic>;
                                            final nameKey =
                                                chat['name'] ??
                                                'Unknown Sender';
                                            final messageKey =
                                                chat['message'] ?? '...';
                                            final bool isMe =
                                                chat['email'] == currentUser;

                                            // 🧠 Try parsing the message as a JSON array (AI-sent exercise list)
                                            List<dynamic>? exerciseList;
                                            try {
                                              final parsed = jsonDecode(
                                                messageKey,
                                              );
                                              if (parsed is List &&
                                                  parsed.isNotEmpty &&
                                                  parsed.first is Map) {
                                                exerciseList = parsed;
                                              }
                                            } catch (_) {
                                              exerciseList = null;
                                            }

                                            return Align(
                                              alignment: isMe
                                                  ? Alignment.centerRight
                                                  : Alignment.centerLeft,
                                              child: ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.8,
                                                ),
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 4,
                                                      ),
                                                  padding: const EdgeInsets.all(
                                                    10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isMe
                                                        ? theme
                                                              .colorScheme
                                                              .primary
                                                        : theme
                                                              .colorScheme
                                                              .secondaryContainer,
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 20,
                                                        ),
                                                      ),
                                                      topRight: Radius.circular(
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 20,
                                                        ),
                                                      ),
                                                      bottomLeft: Radius.circular(
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: isMe ? 20 : 0,
                                                        ),
                                                      ),
                                                      bottomRight: Radius.circular(
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: isMe ? 0 : 20,
                                                        ),
                                                      ),
                                                    ),
                                                    // even shadow around the message box to lift it from background
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: theme.shadowColor
                                                            .withOpacity(0.08),
                                                        blurRadius: 10,
                                                        spreadRadius: 1,
                                                        offset: const Offset(
                                                          0,
                                                          0,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      if (!isMe)
                                                        Text(
                                                          _getTranslation(
                                                            nameKey,
                                                          ),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: theme
                                                                .colorScheme
                                                                .onSecondaryContainer,
                                                          ),
                                                        ),
                                                      // const SizedBox(height: 500),

                                                      // 🧩 CASE 1: If message is an exercise list (decoded JSON array)
                                                      if (exerciseList != null)
                                                        Column(
                                                          children: exerciseList.map((
                                                            exercise,
                                                          ) {
                                                            return Card(
                                                              margin:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical: 5,
                                                                  ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      12,
                                                                    ),
                                                              ),
                                                              color: theme
                                                                  .colorScheme
                                                                  .surfaceVariant,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets.all(
                                                                      12,
                                                                    ),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      exercise['exercise'] ??
                                                                          'N/A',
                                                                      style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            16,
                                                                        color: theme
                                                                            .colorScheme
                                                                            .onSurface,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 4,
                                                                    ),
                                                                    Text(
                                                                      "Reps: ${exercise['no of repetetions'] ?? 'N/A'}",
                                                                      style: TextStyle(
                                                                        color: theme
                                                                            .colorScheme
                                                                            .onSurface
                                                                            .withOpacity(
                                                                              0.7,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      "How to: ${exercise['how to do it'] ?? 'N/A'}",
                                                                      style: TextStyle(
                                                                        color: theme
                                                                            .colorScheme
                                                                            .onSurface
                                                                            .withOpacity(
                                                                              0.7,
                                                                            ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 6,
                                                                    ),
                                                                    if (exercise['youtube link'] !=
                                                                            null &&
                                                                        (exercise['youtube link']
                                                                                as String)
                                                                            .isNotEmpty)
                                                                      ElevatedButton.icon(
                                                                        style: ElevatedButton.styleFrom(
                                                                          backgroundColor: theme
                                                                              .colorScheme
                                                                              .error,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              8,
                                                                            ),
                                                                          ),
                                                                          padding: const EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                12,
                                                                            vertical:
                                                                                8,
                                                                          ),
                                                                        ),
                                                                        icon: Icon(
                                                                          Icons
                                                                              .play_circle_fill,
                                                                          color: theme
                                                                              .colorScheme
                                                                              .onError,
                                                                        ),
                                                                        label: Text(
                                                                          "Watch on YouTube",
                                                                          style: TextStyle(
                                                                            color:
                                                                                theme.colorScheme.onError,
                                                                          ),
                                                                        ),
                                                                        onPressed: () async {
                                                                          final url = Uri.parse(
                                                                            exercise['youtube link'],
                                                                          );
                                                                          if (await canLaunchUrl(
                                                                            url,
                                                                          )) {
                                                                            await launchUrl(
                                                                              url,
                                                                              mode: LaunchMode.inAppWebView,
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
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        )
                                                      // 💬 CASE 2: Normal text message
                                                      else
                                                        Text(
                                                          _getTranslation(
                                                            messageKey,
                                                          ),
                                                          style: TextStyle(
                                                            color: isMe
                                                                ? theme
                                                                      .colorScheme
                                                                      .onPrimary
                                                                : theme
                                                                      .colorScheme
                                                                      .onSecondaryContainer,
                                                          ),
                                                        ),

                                                      const SizedBox(height: 5),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            chat['time']!,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              color: isMe
                                                                  ? theme.colorScheme.onPrimary.withOpacity(0.9)
                                                                  : theme.colorScheme.onSecondaryContainer.withOpacity(0.85),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Message input field (Unchanged)
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 60,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 388,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(context, W: 30),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: messageController,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      cursorColor: theme.colorScheme.primary,
                                      decoration: InputDecoration(
                                        hintText: _getTranslation(
                                          inputHintKey,
                                        ), // 🌍 Translated
                                        hintStyle: TextStyle(
                                          color: theme.colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                        filled: true,
                                        fillColor: theme.colorScheme.surface,
                                        suffixIcon: GestureDetector(
                                          onTap: () async {
                                            FocusScope.of(context).unfocus();
                                            if (messageController.text
                                                .trim()
                                                .isEmpty)
                                              return; // Prevent sending empty messages

                                            TrainerSettings userSettings =
                                                await TrainerSettings()
                                                    .loadSettings();
                                            final now =
                                                DateTime.now(); // Capture time once

                                            final groupMessage =
                                                UserGroupChatController()
                                                    .createGroupChatObject(
                                                      created_at: now,
                                                      from_id: userSettings
                                                          .trainerEmail!,
                                                      from_name:
                                                          userSettings
                                                              .trainerName ??
                                                          "Anonymous",
                                                      image_url: "image_url",
                                                      is_image: false,
                                                      text: messageController
                                                          .text,
                                                    );

                                            UserGroupChatController()
                                                .uploadGroupChat(
                                                  groupMessage,
                                                  groupId:
                                                      currentGroupDataMap['groupID'],
                                                );

                                            // Clear input field immediately
                                            messageController.clear();

                                            // The StreamBuilder will handle the update and display once Firebase confirms the write.
                                            // Removing the manual local update (chatMessages.add) is better practice with streams.
                                          },
                                          child: Icon(
                                            Icons.send,
                                            color: theme.colorScheme.primary,
                                            size: Reusable.getDeviceWidth(
                                              context,
                                              W: 30,
                                            ),
                                          ),
                                        ),
                                        prefixIcon: Icon(
                                          Icons.add_circle_outline,
                                          color: theme.colorScheme.primary,
                                          size: Reusable.getDeviceWidth(
                                            context,
                                            W: 30,
                                          ),
                                        ),

                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: theme.colorScheme.outline,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            Reusable.getDeviceWidth(
                                              context,
                                              W: 30,
                                            ),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: theme.colorScheme.primary,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            Reusable.getDeviceWidth(
                                              context,
                                              W: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: Reusable.getDeviceHeight(
                                    context,
                                    H: 15,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_translationsCache.isEmpty || currentUser == null)
                      const Positioned.fill(child: UserLoaderScreen()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showOptions(BuildContext context) {
    log("Bottom sheet called!");
    showModalBottomSheet(
      context: context,
      // use a transparent modal surface so we can render a fully themed container
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ValueListenableBuilder<bool>(
          valueListenable: isDarkTrainerThemeNotifier,
          builder: (context, isDarkMode, _) {
            final theme = isDarkMode
                ? CustomThemes.customDarkTheme
                : CustomThemes.customLightTheme;

            // Choose a sheet background that contrasts with nearby widgets.
            // surfaceVariant can be close to surface; surface is safe. Use slight elevation via shadow.
            final Color sheetColor = theme.colorScheme.surface;

            return Theme(
              data: theme,
              child: Container(
                // fill width, align at bottom, rounded top corners
                decoration: BoxDecoration(
                  color: sheetColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.14),
                      blurRadius: 18,
                      spreadRadius: 1,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 25,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onSurface.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 15),

                      Text(
                        "Choose Exercise Type",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 🟠 Warm-up Exercises button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return AIExerciseGen(
                                  exerciseType: 'Warm-up',
                                  selectedSport: widget.selectedSport,
                                  groupID: currentGroupDataMap['groupID'],
                                  afterBefore: "before",
                                );
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.local_fire_department_outlined),
                        label: const Text("Warm-up Exercises"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.onSecondary,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 15),
                      // 🟢 Stretching Exercises button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return AIExerciseGen(
                                  exerciseType: 'Stretching',
                                  selectedSport: widget.selectedSport,
                                  groupID: currentGroupDataMap['groupID'],
                                  afterBefore: "after",
                                );
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.self_improvement_outlined),
                        label: const Text("Stretching Exercises"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // 🟣 Actual Exercises button
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return AIExerciseGen(
                                  exerciseType: 'Workout',
                                  selectedSport: widget.selectedSport,
                                  groupID: currentGroupDataMap['groupID'],
                                  afterBefore: "workout",
                                );
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.fitness_center),
                        label: const Text("Actual Exercises"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.tertiary,
                          foregroundColor: theme.colorScheme.onTertiary,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
