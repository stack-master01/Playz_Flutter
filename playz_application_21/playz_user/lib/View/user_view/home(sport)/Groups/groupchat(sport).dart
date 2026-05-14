import 'dart:developer'; // Required for log()
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:playz_user/Controller/User_Controller/User_Group_Chat_Controller.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:playz_user/View/user_view/home(sport)/Groups/groupinfo(sport).dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class GroupChat extends StatefulWidget {
  Map<String, dynamic> groupDataMap = {};
  GroupChat({super.key, required this.groupDataMap});

  @override
  State<GroupChat> createState() => _GroupChatState();
}

class _GroupChatState extends State<GroupChat> {
  String? currentUser;
  Map<String, dynamic> currentGroupDataMap = {};
  TextEditingController messageController = TextEditingController();

  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  // ✅ Dummy chat data (Moved inside state for dynamic key collection)
  List<Map<String, dynamic>> chatMessages = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Cricket Legends Hub", // Group name
      "Type a Message",
      "Cricket Legends Hub Cricket Legends Hub Cricket Legends Hub", // Pinned message text
      // END: Add default english text here
    };

    // Dynamically collect keys from the list items
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

  // Helper function to recursively extract all string values
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

  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;
    if (_currentLang == lang &&
        _translationsCache.keys.length == keysToLoad.length) {
      return;
    }

    _currentLang = lang;
    Map<String, String> newTranslations = {};

    for (String key in keysToLoad) {
      String translated = await getTranslatedText(
        key,
        lang,
      ); // Must be defined in your project
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
    UserSettings userSettings = await UserSettings().loadSettings();
    currentUser = userSettings.email;
  }

  // List<Map<String, dynamic>> sortMessagesByTime(
  //   List<Map<String, dynamic>> messageList,
  // ) {
  //   // Create a mutable copy to sort
  //   List<Map<String, dynamic>> sortedList = List.from(messageList);

  //   sortedList.sort((a, b) {
  //     // 1. Safely retrieve the Timestamp objects
  //     final Timestamp timestampA = a['timestamp'] as Timestamp;
  //     final Timestamp timestampB = b['timestamp'] as Timestamp;

  //     // 2. Convert to DateTime for comparison
  //     final DateTime dateTimeA = timestampA.toDate();
  //     final DateTime dateTimeB = timestampB.toDate();

  //     // 3. Compare DateTime objects
  //     // .compareTo returns:
  //     // -1 if A comes before B (A is earlier/smaller)
  //     // 1 if A comes after B (A is later/larger)
  //     // 0 if they are equal
  //     return dateTimeA.compareTo(dateTimeB);
  //   });

  //   return sortedList;
  // }

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



  @override
  void initState() {
    super.initState();
    loadCurrentUser();
    currentGroupDataMap = widget.groupDataMap;
    if (_currentLang != appLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadSelectedLocation();
    // sortMessagesByTime(chatMessages);
    appLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
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
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        // Define static text keys
        final String groupNameKey = currentGroupDataMap['group_name'];
        final String groupImage = currentGroupDataMap['image'];
        const String pinnedMessageKey =
            "Cricket Legends Hub Cricket Legends Hub Cricket Legends Hub";
        const String inputHintKey = "Type a Message";

        return Scaffold(
          body: Stack(
            children: [
              // ✅ Green header
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
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
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                size: Reusable.getDeviceWidth(context, W: 25),
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                              ),
                            ),
                            const SizedBox(width: 5),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>  GroupInfo(groupDataMap: currentGroupDataMap),
                                  ),
                                );
                              },
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
                                        Reusable.getDeviceWidth(context, W: 25),
                                      ),
                                      color: Colors.amber,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        Reusable.getDeviceWidth(context, W: 25),
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
                                      color: isDark
                                          ? Reusable.getDarkModeBlack()
                                          : Reusable.getWhite(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.share_outlined,
                            size: Reusable.getDeviceWidth(context, W: 30),
                            color: isDark
                                ? Reusable.getDarkModeBlack()
                                : Reusable.getWhite(),
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
                    color: isDark
                        ? Reusable.getDarkModeBlack()
                        : Reusable.getWhite(),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
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
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                        child: Opacity(
                          opacity: 0.1,
                          child: Container(
                            decoration: BoxDecoration(
                            color: Colors.white,
                            image: DecorationImage(image: AssetImage(isDark ? "assets/Images/dark1.png":"assets/Images/light1_upscaled.png"),fit: BoxFit.cover)
                          ),
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 20),
                          ),
                      
                          // Pinned message container
                          Container(
                            width: Reusable.getDeviceWidth(context, W: 388),
                            height: Reusable.getDeviceHeight(context, H: 50),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                Reusable.getDeviceWidth(context, W: 25),
                              ),
                              border: Border.all(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Reusable.getDeviceWidth(context, W: 10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.push_pin,
                                    size: Reusable.getDeviceWidth(context, W: 30),
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
                                  ),
                                  SizedBox(
                                    width: Reusable.getDeviceWidth(context, W: 5),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _getTranslation(
                                        pinnedMessageKey,
                                      ), // 🌍 Translated
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getDarkGrey(),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      
                          // 🔹 Chat messages ListView
                          // Expanded(
                          //   child: ListView.builder(
                          //     padding: const EdgeInsets.all(10),
                          //     itemCount: chatMessages.length,
                          //     itemBuilder: (context, index) {
                          //       final chat = chatMessages[index];
                          //       final nameKey = chat['name']?? 'Unknown Sender';
                          //       final messageKey = chat['message']?? '...';
                          //       // Assuming "Alice" is the current user for demonstration
                          //       bool isMe = chat['email'] == currentUser;
                          //       return Align(
                          //         alignment: isMe
                          //             ? Alignment.centerRight
                          //             : Alignment.centerLeft,
                          //         child: ConstrainedBox(
                          //           constraints: BoxConstraints(
                          //             maxWidth:
                          //                 MediaQuery.of(context).size.width * 0.8,
                          //           ),
                          //           child: Container(
                          //             margin: const EdgeInsets.symmetric(
                          //               vertical: 10,
                          //             ),
                          //             padding: const EdgeInsets.all(10),
                          //             decoration: BoxDecoration(
                          //               color: isMe
                          //                   ? isDark
                          //                         ? Reusable.getLightGreen()
                          //                         : Reusable.getGreen()
                          //                   : Colors.grey[300],
                          //               borderRadius: BorderRadius.only(
                          //                 topLeft: Radius.circular(
                          //                   Reusable.getDeviceWidth(context, W: 20),
                          //                 ),
                          //                 topRight: Radius.circular(
                          //                   Reusable.getDeviceWidth(context, W: 20),
                          //                 ),
                          //                 bottomLeft: Radius.circular(
                          //                   Reusable.getDeviceWidth(
                          //                     context,
                          //                     W: isMe ? 20 : 0,
                          //                   ),
                          //                 ),
                          //                 bottomRight: Radius.circular(
                          //                   Reusable.getDeviceWidth(
                          //                     context,
                          //                     W: isMe ? 0 : 20,
                          //                   ),
                          //                 ),
                          //               ),
                          //             ),
                          //             child: Column(
                          //               crossAxisAlignment:
                          //                   CrossAxisAlignment.start,
                          //               children: [
                          //                 if (!isMe)
                          //                   Text(
                          //                     _getTranslation(
                          //                       nameKey,
                          //                     ), // 🌍 Translated (Dynamic data)
                          //                     style: const TextStyle(
                          //                       fontWeight: FontWeight.bold,
                          //                       color: Colors.black87,
                          //                     ),
                          //                   ),
                          //                 const SizedBox(height: 5),
                          //                 Text(
                          //                   _getTranslation(
                          //                     messageKey,
                          //                   ), // 🌍 Translated (Dynamic data)
                          //                   style: TextStyle(
                          //                     color: isMe
                          //                         ? isDark
                          //                               ? Reusable.getDarkModeBlack()
                          //                               : Reusable.getWhite()
                          //                         : Colors.black87,
                          //                   ),
                          //                 ),
                          //                 const SizedBox(height: 5),
                          //                 Text(
                          //                   chat['time']!, // Time usually not translated
                          //                   style: const TextStyle(
                          //                     fontSize: 10,
                          //                     color: Colors.black54,
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //         ),
                          //       );
                          //     },
                          //   ),
                          // ),
                      
                          // 🔹 Chat messages ListView
                          Expanded(
                            child: StreamBuilder<List<Map<String, dynamic>>>(
                              // Use the efficient, dynamic stream here
                              stream: UserGroupChatController()
                                  .streamCentralGroupChats(
                                    groupId:
                                        currentGroupDataMap['group_data']['groupId'],
                                  ),
                              builder: (context, snapshot) {
                                // 1. Group and sort messages for display
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                if (snapshot.hasError) {
                                  log('Stream Error: ${snapshot.error}');
                                  return const Center(
                                    child: Text('Error loading messages.'),
                                  );
                                }
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(
                                    child: Text('Start a conversation!'),
                                  );
                                }
                      
                                final allGroupChats = snapshot.data!;
                      
                                // 1. Process Timestamps and create chatCards (Your old loadAllChats logic)
                                List<Map<String, dynamic>> processedChats = [];
                      
                                // This 'for' loop is CORRECT because allGroupChats is an Iterable (List)
                                for (var newItem in allGroupChats) {
                                  // Safely handle Timestamp retrieval
                                  final Timestamp? timestamp =
                                      newItem['created_at'] as Timestamp?;
                      
                                  // Use the null-safe operator or fallback
                                  if (timestamp == null) continue;
                      
                                  // 2. Convert to DateTime
                                  final DateTime dateTime = timestamp.toDate();
                      
                                  // 3. Format time
                                  final String formattedTime = DateFormat(
                                    'jm',
                                  ).format(dateTime);
                      
                                  Map<String, dynamic> chatCard = {
                                    "name": newItem['from_name'],
                                    "message": newItem['text'],
                                    "time": formattedTime,
                                    "email": newItem['from_id'],
                                    "timestamp": timestamp,
                                    "dateTime":
                                        dateTime, // Use the actual DateTime object
                                  };
                      
                                  processedChats.add(chatCard);
                                }
                      
                                // 2. Update local list for translation key collection
                                // Use a check to prevent unnecessary translations on every tiny stream update
                                if (chatMessages.length != processedChats.length) {
                                  chatMessages = processedChats;
                                  // Since this is called from within the StreamBuilder,
                                  // we don't need setState() inside _loadTranslations.
                                  _loadTranslations(appLanguageNotifier.value);
                                }
                      
                                // 3. Group and sort the messages for display (Oldest Date first)
                                final groupedMessages = groupAndSortMessages(
                                  processedChats,
                                );
                      
                                // 2. Create a flat list of ALL items (Date Headers + Messages)
                                // The items are ordered latest date first, and oldest message first within each day.
                                List<dynamic> chatItems = [];
                                groupedMessages.forEach((date, messages) {
                                  // Add the date header (the key is the date string)
                      
                                  // Add all messages for that date
                                  chatItems.addAll(messages);
                                  chatItems.add(date);
                                });
                      
                                // Since the list view should display items from the BOTTOM up
                                // (like a standard chat app), we should use reverse: true.
                                // But for simplicity and matching the request ("display the date at the top
                                // of first message where the date is changed"), we'll keep reverse: false
                                // and ensure the data is ordered correctly (latest date at the top).
                                // The current logic (latest date first in `groupedMessages`) handles this.
                      
                                // Now, reverse the flat list so the *latest* item in the list is the *last* // message of the *latest* day. This ensures when the user scrolls down,
                                // they see older messages, but the messages within a day are still oldest->newest.
                                // This is the trickiest part for standard ListView; let's reverse the final list
                                // to make the latest message the LAST item in the *list*, which is the bottom
                                // of a non-reversed ListView.
                      
                                // Let's use `reverse: true` which is simpler for chat, but requires reversing
                                // the data order: oldest date at the top, messages oldest-first within a day.
                                // For a non-reversed view (latest date at the top):
                      
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: ListView.builder(
                                    // Set reverse to false for "latest date at the top" display
                                    reverse: true,
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                      bottom: 20,
                                    ),
                                    itemCount: chatItems.length,
                                    itemBuilder: (context, index) {
                                      final item = chatItems[index];
                      
                                      // Check if the item is a Date String (the separator)
                                      if (item is String) {
                                        // This is the date header (top of the section)
                                        return Center(
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                            ),
                                            child: Text(
                                              item, // The formatted date string
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                      
                                      // Otherwise, it is a message map
                                      final chat = item as Map<String, dynamic>;
                                      final nameKey =
                                          chat['name'] ?? 'Unknown Sender';
                                      final messageKey = chat['message'] ?? '...';
                                      bool isMe = chat['email'] == currentUser;
                      
                                      // This is the message bubble rendering logic
                                      return Align(
                                        alignment: isMe
                                            ? Alignment.centerRight
                                            : Alignment.centerLeft,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth:
                                                MediaQuery.of(context).size.width *
                                                0.8,
                                          ),
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 4, // Reduced margin
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isMe
                                                  ? isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getGreen()
                                                  : Colors.grey[300],
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
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                if (!isMe)
                                                  Text(
                                                    _getTranslation(
                                                      nameKey,
                                                    ), // 🌍 Translated (Dynamic data)
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                const SizedBox(height: 5),
                                                Text(
                                                  _getTranslation(
                                                    messageKey,
                                                  ), // 🌍 Translated (Dynamic data)
                                                  style: TextStyle(
                                                    color: isMe
                                                        ? isDark
                                                              ? Reusable.getDarkModeBlack()
                                                              : Reusable.getWhite()
                                                        : Colors.black87,
                                                  ),
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      chat['time']!, // Time usually not translated
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        // Adjust color for time based on bubble color
                                                        color: isMe
                                                            ? Colors.black54
                                                            : Colors.black54,
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
                      
                          // Message input field
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: Reusable.getDeviceHeight(context, H: 60),
                              width: Reusable.getDeviceWidth(context, W: 388),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  Reusable.getDeviceWidth(context, W: 30),
                                ),
                              ),
                              child: TextField(
                                controller: messageController,
                                style: TextStyle(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                ),
                                cursorColor: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                decoration: InputDecoration(
                                  hintText: _getTranslation(
                                    inputHintKey,
                                  ), // 🌍 Translated
                                  hintStyle: TextStyle(
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getDarkGrey(),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? Reusable.getDarkModeBlack()
                                      : Reusable.getWhite(),
                                  suffixIcon: GestureDetector(
                                    onTap: () async {
                                      UserSettings userSettings =
                                          await UserSettings().loadSettings();
                                      final groupMessage = UserGroupChatController()
                                          .createGroupChatObject(
                                            created_at: DateTime.timestamp(),
                                            from_id: userSettings.email!,
                                            from_name:
                                                userSettings.userName ??
                                                "Anonymous",
                                            image_url: "image_url",
                                            is_image: false,
                                            text: messageController.text,
                                          );
                      
                                      UserGroupChatController().uploadGroupChat(
                                        groupMessage,
                                        groupId:
                                            currentGroupDataMap['group_data']['groupId'],
                                      );
                      
                                      // NEW CODE (ADDING 'dateTime' KEY)
                                      final now =
                                          DateTime.now(); // Capture the current time once
                                      Map<String, dynamic> chatCard = {
                                        "name": userSettings.userName,
                                        "message": messageController.text,
                                        "time": DateFormat('jm').format(now),
                                        "email": userSettings.email,
                                        "timestamp": Timestamp.fromDate(
                                          now,
                                        ), // Use Timestamp for consistency with loaded data
                                        "dateTime":
                                            now, // *** ADDED FOR LOCAL SORTING/GROUPING ***
                                      };
                                      setState(() {
                                        chatMessages.add(chatCard);
                                      });
                                      messageController.clear();
                                    },
                                    child: Icon(
                                      Icons.send,
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getGreen(),
                                      size: Reusable.getDeviceWidth(context, W: 30),
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.add_circle_outline,
                                    color: isDark
                                        ? Reusable.getLightGreen()
                                        : Reusable.getGreen(),
                                    size: Reusable.getDeviceWidth(context, W: 30),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Reusable.getLightGrey(),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      Reusable.getDeviceWidth(context, W: 30),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getGreen(),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      Reusable.getDeviceWidth(context, W: 30),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: Reusable.getDeviceHeight(context, H: 15),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_translationsCache.isEmpty)
                const Positioned.fill(child: UserLoaderScreen()),
            ],
          ),
        );
      },
    );
  }




}
