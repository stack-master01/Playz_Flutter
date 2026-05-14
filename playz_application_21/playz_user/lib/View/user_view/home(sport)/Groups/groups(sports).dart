import 'dart:developer'; // Required for log()
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playz_user/Controller/User_Controller/User_Create_Group_Controller.dart';
import 'package:playz_user/Helper/User_Loader.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/View/user_view/home(sport)/Groups/groupchat(sport).dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/play(sport)/mappicker.dart';
import 'package:playz_user/View/user_view/reusable.dart';

Map<String, String> _translationsCache = {};

String _currentLang = "en";

// Main Stateful widget for displaying sports groups
class GroupsSports extends StatefulWidget {
  const GroupsSports({super.key});

  @override
  State<GroupsSports> createState() => _GroupsSportsState();
}

// Dummy data for group cards
List<Map<String, dynamic>> GroupCardList = [];

class _GroupsSportsState extends State<GroupsSports> {
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Groups",
      "Search by Name",
      "My Groups",
      "Public",
      "Private",
      "Players",
      "Search Results"
      // END: Add default english text here
    };

    // Dynamically collect keys from the list items (turfInfo not used here, but kept as per logic)
    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }

    // Dynamically collect keys from GroupCardList
    for (var group in GroupCardList) {
      if (group['group_name'] is String) {
        keys.add(group['group_name'] as String);
      }
      if (group['group_access'] is String) {
        keys.add(group['group_access'] as String);
      }
    }
    _extractStrings(GroupCardList, keys);
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

  Future<void> loadAllGroups() async {
    final allGroups = await UserCreateGroupController().fetchAllGroups();
    log("fetched list: $allGroups");

    for (var newItem in allGroups) {
      //   {
      //   "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
      //   "group_name": "Badminton Buddies", // Changed name for translation key
      //   "group_access": "Public",
      //   "total_members": "88",
      // },
      Map<String, dynamic> turfCard = {
        "image": newItem['group_profile_url'],
        "group_name": newItem['group_name'],
        "group_access": "Public",
        "total_members": newItem['group_members'].length,
        "group_data": newItem,
      };

      GroupCardList.add(turfCard);
    }

    log("List: $GroupCardList");

    if (mounted) {
      setState(() {
        // Reload translations to include dynamic text from newly loaded games
        _loadTranslations(appLanguageNotifier.value);
      });
    }
  }

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching =
      false; // To toggle between 'My Groups' and 'Search Results'

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _searchResults.clear();
      } else {
        _isSearching = true;
        // Filter groups that the user is NOT already a member of
        _searchResults = GroupCardList.where((group) {
          final bool isMember =
              group['group_data']['group_members']?.any(
                (member) => member['user_email'] == currentUserEmail,
              ) ??
              false;

          final bool matchesName = group['group_name'].toLowerCase().contains(
            query,
          );

          // Show the group if it matches AND the user is NOT already a member
          return matchesName && !isMember;
        }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
    GroupCardList.clear();
    _searchController.addListener(_onSearchChanged);
    if (_currentLang != appLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadSelectedLocation();
    loadAllGroups();
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

  String currentUserEmail = '';
  Future<void> loadCurrentUser() async {
    UserSettings userSettings = await UserSettings().loadSettings();
    currentUserEmail = userSettings.email!;
  }

  // Define static keys
  static const String _titleKey = "Groups";
  static const String _searchHintKey = "Search by Name";
  static const String _myGroupsKey = "My Groups";
  static const String _publicKey = "Public";
  static const String _privateKey = "Private";
  static const String _playersKey = "Players";

void _handleVerticalDragEnd(DragEndDetails details) {
  // Check if the vertical velocity is positive (moving downwards).
  // 500 is a common velocity threshold for a noticeable swipe.
  const double minVelocity = 500; 

  if (details.primaryVelocity != null && details.primaryVelocity! > minVelocity) {
    // Swipe is fast AND in the positive direction (Top -> Down)
    log("swiped down successfully");
      loadAllGroups();
  }
}
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          body: GestureDetector(
            onVerticalDragEnd: _handleVerticalDragEnd,
            child: Stack(
              children: [
                // Green background with top bar
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 40,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        children: [
                          // Back button
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
                          // Page title
                          Text(
                            _getTranslation(_titleKey), // 🌍 Translated
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {
                              showCreateGroupSheet(context);
                            },
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: 30,
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
            
                // White rounded container at bottom (acts like bottom sheet)
                Positioned(
                  top: (MediaQuery.of(context).size.height) * 0.097192,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Space
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 20),
                        ),
            
                        // Search bar for groups
                        Container(
                          height: Reusable.getDeviceHeight(context, H: 60),
                          width: Reusable.getDeviceWidth(context, W: 388),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              Reusable.getDeviceWidth(context, W: 30),
                            ),
                          ),
                          child: TextField(
                            onChanged: (value) =>
                                _onSearchChanged(), // Ensure listener triggers
            
                            controller: _searchController,
                            style: TextStyle(
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getDarkGrey(),
                            ),
                            cursorColor: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getGreen(),
                            decoration: InputDecoration(
                              hintText: _getTranslation(
                                _searchHintKey,
                              ), // 🌍 Translated
                              hintStyle: TextStyle(
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getDarkGrey(),
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(), // background color
                              // 🔍 Search icon
                              suffixIcon: Icon(
                                Icons.search,
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getGreen(),
                                size: Reusable.getDeviceWidth(context, W: 30),
                              ),
            
                              // Borders
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: isDark
                                      ? Reusable.getLightGrey()
                                      : Reusable.getLightGrey(),
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
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.orange,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.purple,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 15),
                        ),
            
                        // Section title "My Groups"
                        Padding(
                          padding: EdgeInsets.only(
                            left: Reusable.getDeviceWidth(context, W: 20),
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                             _isSearching ?_getTranslation("Search Results") : _getTranslation(_myGroupsKey), // 🌍 Translated
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getDarkGrey(),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Reusable.getDeviceHeight(context, H: 15),
                        ),
            
                        // Dynamic list of group cards
                        _isSearching
                            ? Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: _searchResults.length,
                                  itemBuilder: (context, index) {
                                    final groupCard = _searchResults[index];
                                    final groupNameKey =
                                        groupCard['group_name'] as String;
                                    final groupAccessKey =
                                        groupCard['group_access'] as String;
            
                                    return Column(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            UserSettings userSettings = await UserSettings().loadSettings();
                                            // THIS TRIGGERS THE JOIN DIALOG
                                           bool? isJoining =
                                                      await showJoinGroupDialog(
                                                        context,
                                                        _searchResults[index]['group_name'],
                                                      );
                                                  if (isJoining!) {
                                                    // Map<String, dynamic>
                                                    // groupData = UserCreateGroupController().createGroupObject(
                                                    //   created_at:
                                                    //       GroupCardList[index]['group_data']['created_at'] ,
                                                    //   created_by:
                                                    //       GroupCardList[index]['group_data']['created_by'],
                                                    //   group_description:
                                                    //       GroupCardList[index]['group_data']['group_description'],
                                                    //   group_members:
                                                    //       GroupCardList[index]['group_data']['group_members']
                                                    //           .add({
                                                    //             "user_name":
                                                    //                 userSettings.userName ??
                                                    //                 "Anonymous(Member)",
                                                    //             "user_email":
                                                    //                 userSettings.email,
                                                    //             "user_image":
                                                    //                 userSettings.imageURL,
                                                    //             "user_role": "Member",
                                                    //           }),
                                                    //   group_name:
                                                    //       GroupCardList[index]['group_data']['group_name'],
                                                    //   group_profile_url:
                                                    //       GroupCardList[index]['group_data']['group_profile_url'],
                                                    // );
                                                    // UserCreateGroupController()
                                                    //     .uploadUserGroup(groupData);
            
                                                    final FirebaseFirestore
                                                    _firestore = FirebaseFirestore
                                                        .instance;
            
                                                    try {
                                                      // 1. Get the DocumentReference for the group
                                                      // Assuming you have a centralized 'Groups' collection now:
                                                      DocumentReference
                                                      groupRef = _firestore
                                                          .collection('groups')
                                                          .doc(
                                                            _searchResults[index]['group_data']['groupId'],
                                                          );
            
                                                      // 2. Use FieldValue.arrayUnion to efficiently add the map to the array
                                                      await groupRef.update({
                                                        'group_members':
                                                            FieldValue.arrayUnion([
                                                              {
                                                                "user_name":
                                                                    userSettings
                                                                        .userName ??
                                                                    "Anonymous(Member)",
                                                                "user_email":
                                                                    userSettings
                                                                        .email,
                                                                "user_image":
                                                                    userSettings
                                                                        .imageURL ??
                                                                    'https://t3.ftcdn.net/jpg/07/24/59/76/360_F_724597608_pmo5BsVumFcFyHJKlASG2Y2KpkkfiYUU.jpg',
                                                                "user_role":
                                                                    "Member",
                                                              },
                                                            ]),
                                                      });
            
                                                      log(
                                                        "✅ Successfully added new member to group ${_searchResults[index]['group_data']['groupId']}.",
                                                      );
                                                    } catch (e) {
                                                      log(
                                                        "❌ Error adding member to group: $e",
                                                      );
                                                      rethrow;
                                                    }
            
                                                    // Navigator.of(context).push(
                                                    //   MaterialPageRoute(
                                                    //     builder: (context) =>
                                                    //         GroupChat(
                                                    //           groupDataMap:
                                                    //               GroupCardList[index],
                                                    //         ),
                                                    //   ),
                                                    // );
                                                    setState(() {
                                                      loadAllGroups();
                                                    });
                                                  }
                                          },
                                          child: Container(
                                            // ... Use the styling from your original card layout ...
                                            height: Reusable.getDeviceHeight(
                                              context,
                                              H: 100,
                                            ),
                                            width: Reusable.getDeviceWidth(
                                              context,
                                              W: 388,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? Reusable.getDarkModeGrey()
                                                  : Reusable.getWhite(),
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  blurRadius: 3,
                                                  color: Color.fromRGBO(
                                                    0,
                                                    0,
                                                    0,
                                                    0.25,
                                                  ),
                                                  offset: Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                left: Reusable.getDeviceWidth(
                                                  context,
                                                  W: 15,
                                                ),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // ... (Keep Image Container setup) ...
                                                  Container(
                                                    height:
                                                        Reusable.getDeviceHeight(
                                                          context,
                                                          H: 70,
                                                        ),
                                                    width:
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 70,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            Reusable.getDeviceWidth(
                                                              context,
                                                              W: 35,
                                                            ),
                                                          ),
                                                      border: Border.all(
                                                        color: isDark
                                                            ? Reusable.getLightGreen()
                                                            : Reusable.getGreen(),
                                                        width: 1,
                                                      ),
                                                      color: Reusable.getBlack(),
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            Reusable.getDeviceWidth(
                                                              context,
                                                              W: 35,
                                                            ),
                                                          ),
                                                      child: Image.network(
                                                        groupCard['image'],
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 25,
                                                        ),
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        _getTranslation(
                                                          groupNameKey,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: isDark
                                                              ? Reusable.getLightGreen()
                                                              : Reusable.getBlack(),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            Reusable.getDeviceHeight(
                                                              context,
                                                              H: 10,
                                                            ),
                                                      ),
                                                      Row(
                                                        children: [
                                                          groupAccessKey ==
                                                                  _publicKey
                                                              ? Icon(
                                                                  Icons.public,
                                                                  size:
                                                                      Reusable.getDeviceWidth(
                                                                        context,
                                                                        W: 20,
                                                                      ),
                                                                  color: isDark
                                                                      ? Reusable.getLightGreen()
                                                                      : Reusable.getGreen(),
                                                                )
                                                              : Icon(
                                                                  Icons
                                                                      .public_off,
                                                                  size:
                                                                      Reusable.getDeviceWidth(
                                                                        context,
                                                                        W: 20,
                                                                      ),
                                                                  color:
                                                                      Colors.red,
                                                                ),
                                                          SizedBox(
                                                            width:
                                                                Reusable.getDeviceWidth(
                                                                  context,
                                                                  W: 5,
                                                                ),
                                                          ),
                                                          Text(
                                                            _getTranslation(
                                                              groupAccessKey,
                                                            ),
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight.w400,
                                                              color: isDark
                                                                  ? Reusable.getLightGrey()
                                                                  : Reusable.getDarkGrey(),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                Reusable.getDeviceWidth(
                                                                  context,
                                                                  W: 10,
                                                                ),
                                                          ),
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    Reusable.getDeviceHeight(
                                                                      context,
                                                                      H: 12,
                                                                    ),
                                                                  ),
                                                              border: Border.all(
                                                                color: isDark
                                                                    ? Reusable.getLightGreen()
                                                                    : Reusable.getGreen(),
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal: 5,
                                                                  ),
                                                              child: Text(
                                                                "${groupCard['total_members']} ${_getTranslation(_playersKey)}",
                                                                style: TextStyle(
                                                                  fontSize: 10,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: isDark
                                                                      ? Reusable.getLightGreen()
                                                                      : Reusable.getDarkGrey(),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: Reusable.getDeviceHeight(
                                            context,
                                            H: 20,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: GroupCardList.length,
                                  itemBuilder: (context, index) {
                                    final groupNameKey =
                                        GroupCardList[index]['group_name']
                                            as String;
                                    final groupAccessKey =
                                        GroupCardList[index]['group_access']
                                            as String;
            
                                    for (
                                      var i = 0;
                                      i <
                                          GroupCardList[index]['group_data']['group_members']
                                              .length;
                                      i++
                                    ) {
                                      if (currentUserEmail ==
                                          GroupCardList[index]['group_data']['group_members'][i]['user_email']) {
                                        return Column(
                                          children: [
                                            // Each group card clickable → opens GroupChat page
                                            GestureDetector(
                                              onTap: () async {
                                                bool? isJoining;
                                                bool notJoined = true;
                                                UserSettings userSettings =
                                                    await UserSettings()
                                                        .loadSettings();
            
                                                // 1. SAFELY REFERENCE the List of members and cast it as a List
                                                final List<dynamic> groupMembers =
                                                    GroupCardList[index]['group_data']['group_members']
                                                        as List<
                                                          dynamic
                                                        >; // ⬅️ Explicit CAST
            
                                                // Iterate over the list using the integer index i
                                                for (
                                                  int i = 0;
                                                  i < groupMembers.length;
                                                  i++
                                                ) {
                                                  // 2. ACCESS the item using the integer index i
                                                  final Map<String, dynamic>
                                                  member = groupMembers[i];
            
                                                  // 3. CHECK the email
                                                  if (member['user_email'] ==
                                                      userSettings.email) {
                                                    // ⬅️ CORRECT ACCESS
                                                    notJoined = false;
            
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            GroupChat(
                                                              groupDataMap:
                                                                  GroupCardList[index],
                                                            ),
                                                      ),
                                                    );
                                                    // Once found, you can break the loop
                                                    break;
                                                  }
                                                }
            
                                                if (notJoined) {
                                                  isJoining =
                                                      await showJoinGroupDialog(
                                                        context,
                                                        GroupCardList[index]['group_name'],
                                                      );
                                                  if (isJoining!) {
                                                    // Map<String, dynamic>
                                                    // groupData = UserCreateGroupController().createGroupObject(
                                                    //   created_at:
                                                    //       GroupCardList[index]['group_data']['created_at'] ,
                                                    //   created_by:
                                                    //       GroupCardList[index]['group_data']['created_by'],
                                                    //   group_description:
                                                    //       GroupCardList[index]['group_data']['group_description'],
                                                    //   group_members:
                                                    //       GroupCardList[index]['group_data']['group_members']
                                                    //           .add({
                                                    //             "user_name":
                                                    //                 userSettings.userName ??
                                                    //                 "Anonymous(Member)",
                                                    //             "user_email":
                                                    //                 userSettings.email,
                                                    //             "user_image":
                                                    //                 userSettings.imageURL,
                                                    //             "user_role": "Member",
                                                    //           }),
                                                    //   group_name:
                                                    //       GroupCardList[index]['group_data']['group_name'],
                                                    //   group_profile_url:
                                                    //       GroupCardList[index]['group_data']['group_profile_url'],
                                                    // );
                                                    // UserCreateGroupController()
                                                    //     .uploadUserGroup(groupData);
            
                                                    final FirebaseFirestore
                                                    _firestore = FirebaseFirestore
                                                        .instance;
            
                                                    try {
                                                      // 1. Get the DocumentReference for the group
                                                      // Assuming you have a centralized 'Groups' collection now:
                                                      DocumentReference
                                                      groupRef = _firestore
                                                          .collection('groups')
                                                          .doc(
                                                            GroupCardList[index]['group_data']['groupId'],
                                                          );
            
                                                      // 2. Use FieldValue.arrayUnion to efficiently add the map to the array
                                                      await groupRef.update({
                                                        'group_members':
                                                            FieldValue.arrayUnion([
                                                              {
                                                                "user_name":
                                                                    userSettings
                                                                        .userName ??
                                                                    "Anonymous(Member)",
                                                                "user_email":
                                                                    userSettings
                                                                        .email,
                                                                "user_image":
                                                                    userSettings
                                                                        .imageURL ??
                                                                    'https://t3.ftcdn.net/jpg/07/24/59/76/360_F_724597608_pmo5BsVumFcFyHJKlASG2Y2KpkkfiYUU.jpg',
                                                                "user_role":
                                                                    "Member",
                                                              },
                                                            ]),
                                                      });
            
                                                      log(
                                                        "✅ Successfully added new member to group ${GroupCardList[index]['group_data']['groupId']}.",
                                                      );
                                                    } catch (e) {
                                                      log(
                                                        "❌ Error adding member to group: $e",
                                                      );
                                                      rethrow;
                                                    }
            
                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            GroupChat(
                                                              groupDataMap:
                                                                  GroupCardList[index],
                                                            ),
                                                      ),
                                                    );
                                                    setState(() {
                                                      loadAllGroups();
                                                    });
                                                  }
                                                }
                                              },
                                              child: Container(
                                                height: Reusable.getDeviceHeight(
                                                  context,
                                                  H: 100,
                                                ),
                                                width: Reusable.getDeviceWidth(
                                                  context,
                                                  W: 388,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isDark
                                                      ? Reusable.getDarkModeGrey()
                                                      : Reusable.getWhite(),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      blurRadius: 3,
                                                      color: Color.fromRGBO(
                                                        0,
                                                        0,
                                                        0,
                                                        0.25,
                                                      ),
                                                      offset: Offset(0, 0),
                                                    ),
                                                  ],
                                                ),
            
                                                // Group details row
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: Reusable.getDeviceWidth(
                                                      context,
                                                      W: 15,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.center,
                                                    children: [
                                                      // Group Image
                                                      Container(
                                                        height:
                                                            Reusable.getDeviceHeight(
                                                              context,
                                                              H: 70,
                                                            ),
                                                        width:
                                                            Reusable.getDeviceWidth(
                                                              context,
                                                              W: 70,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Reusable.getDeviceWidth(
                                                                  context,
                                                                  W: 35,
                                                                ),
                                                              ),
                                                          border: Border.all(
                                                            color: isDark
                                                                ? Reusable.getLightGreen()
                                                                : Reusable.getGreen(),
                                                          ),
                                                          color:
                                                              Reusable.getBlack(),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                Reusable.getDeviceWidth(
                                                                  context,
                                                                  W: 35,
                                                                ),
                                                              ),
                                                          child: Image.network(
                                                            GroupCardList[index]['image'],
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
            
                                                      SizedBox(
                                                        width:
                                                            Reusable.getDeviceWidth(
                                                              context,
                                                              W: 25,
                                                            ),
                                                      ),
            
                                                      // Group Info (name + status + members)
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          // Group Name
                                                          Text(
                                                            _getTranslation(
                                                              groupNameKey,
                                                            ), // 🌍 Translated (Dynamic data)
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight.w400,
                                                              color: isDark
                                                                  ? Reusable.getLightGreen()
                                                                  : Reusable.getBlack(),
                                                            ),
                                                          ),
            
                                                          SizedBox(
                                                            height:
                                                                Reusable.getDeviceHeight(
                                                                  context,
                                                                  H: 10,
                                                                ),
                                                          ),
            
                                                          // Group access + member count
                                                          Row(
                                                            children: [
                                                              // Show icon based on group type
                                                              groupAccessKey ==
                                                                      _publicKey
                                                                  ? Icon(
                                                                      Icons
                                                                          .public,
                                                                      size: Reusable.getDeviceWidth(
                                                                        context,
                                                                        W: 20,
                                                                      ),
                                                                      color:
                                                                          isDark
                                                                          ? Reusable.getLightGreen()
                                                                          : Reusable.getGreen(),
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .public_off,
                                                                      size: Reusable.getDeviceWidth(
                                                                        context,
                                                                        W: 20,
                                                                      ),
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                              SizedBox(
                                                                width:
                                                                    Reusable.getDeviceWidth(
                                                                      context,
                                                                      W: 5,
                                                                    ),
                                                              ),
            
                                                              // Group status text
                                                              Text(
                                                                _getTranslation(
                                                                  groupAccessKey,
                                                                ), // 🌍 Translated (Dynamic data)
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: isDark
                                                                      ? Reusable.getLightGrey()
                                                                      : Reusable.getDarkGrey(),
                                                                ),
                                                              ),
            
                                                              SizedBox(
                                                                width:
                                                                    Reusable.getDeviceWidth(
                                                                      context,
                                                                      W: 10,
                                                                    ),
                                                              ),
            
                                                              // Member count badge
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        Reusable.getDeviceHeight(
                                                                          context,
                                                                          H: 12,
                                                                        ),
                                                                      ),
                                                                  border: Border.all(
                                                                    color: isDark
                                                                        ? Reusable.getLightGreen()
                                                                        : Reusable.getGreen(),
                                                                    // border color
                                                                    width:
                                                                        1, // border width
                                                                  ),
                                                                ),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            5,
                                                                      ),
                                                                  child: Text(
                                                                    // Note: We only translate 'Players', not the number
                                                                    "${GroupCardList[index]['total_members']} ${_getTranslation(_playersKey)}", // 🌍 Translated
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          10,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w400,
                                                                      color:
                                                                          isDark
                                                                          ? Reusable.getLightGreen()
                                                                          : Reusable.getDarkGrey(),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // Space between cards
                                            SizedBox(
                                              height: Reusable.getDeviceHeight(
                                                context,
                                                H: 20,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                if (_translationsCache.isEmpty)
                  const Positioned.fill(child: UserLoaderScreen()),
                // (TODO: Bottom navigation can be added here if needed)
              ],
            ),
          ),
        );
      },
    );
  }

  LatLng? selectedLatLng;
  String selectedAddress = '';
  XFile? image;
  // Placeholder for the external Image Picker logic.
  // This should use a package like 'image_picker' and update the state with the file path.
  Future<String?> _pickImage() async {
    // Implementation using image_picker:

    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(source: ImageSource.gallery);
    return image?.path;
  }

  // Placeholder for navigating to a separate location page and returning a result.
  // Replace 'LocationPickerPage' with your actual page and logic.
  Future<String?> _navigateToLocationPicker(BuildContext context) async {
    // Implementation using Navigator to push a new page and wait for a result:

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapPickerPage(
          onLocationPicked: (LatLng pos, String address) async {
            setState(() {
              selectedLatLng = pos;
              selectedAddress = address;
              locationController.text = address;
            });
            log("Selected Address: $address");
            log("Selected LatLng: $pos");
          },
        ),
      ),
    );
    return result as String?;

    // // For demonstration, returning a dummy address after a delay.
    // await Future.delayed(const Duration(milliseconds: 500));
    // return '123 Main St, Anytown, USA';
  }

  final TextEditingController locationController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? imagePath; // Local state for the selected image file path
  String? locationAddress; // Local state for the selected address

  /// Shows the bottom sheet for creating a new group.
  void showCreateGroupSheet(BuildContext context) {
    // Text editing controllers for the text fields

    // Controller for the location text field (it's read-only and updated programmatically)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Essential for keyboard handling
      backgroundColor: Colors.transparent, // For custom shape
      builder: (context) {
        // Use Padding to lift the content when the keyboard appears
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white, // Change to your preferred background color
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            // StatefulBuilder allows the bottom sheet content to manage its own state
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter localSetState) {
                // Update the location text field when the state is rebuilt
                if (locationAddress != null) {
                  locationController.text = locationAddress!;
                } else {
                  locationController.text = ''; // Clear if null
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text(
                        'Create New Group',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Divider(height: 20, thickness: 1),

                      // Group Image Picker Button
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final String? path = await _pickImage();
                            if (path != null) {
                              localSetState(() {
                                imagePath = path;
                              });
                            }
                          },
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              // Circular image container (or placeholder)
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.grey.shade300,
                                backgroundImage: imagePath != null
                                    ? FileImage(File(imagePath!))
                                          as ImageProvider<Object>?
                                    : null,
                                child: imagePath == null
                                    ? Icon(
                                        Icons.groups,
                                        size: 40,
                                        color: Colors.grey.shade600,
                                      )
                                    : null,
                              ),
                              // Plus icon button
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .blueAccent, // Custom color for plus icon
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Group Name Text Field
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Group Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Group Description Text Field
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Location Text Field
                      GestureDetector(
                        onTap: () async {
                          final String? address =
                              await _navigateToLocationPicker(context);
                          if (address != null) {
                            localSetState(() {
                              locationAddress = address;
                              // The locationController.text update is handled outside
                              // the onTap but inside the localSetState block for consistency.
                            });
                          }
                        },
                        child: AbsorbPointer(
                          // Makes the TextField non-editable and redirects tap to GestureDetector
                          child: TextField(
                            controller: locationController,
                            decoration: const InputDecoration(
                              labelText: 'Group Location (Required)',
                              hintText: 'Tap to select location',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                              suffixIcon: Icon(Icons.navigate_next),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Create Button
                      ElevatedButton(
                        onPressed: () async {
                          UserSettings userSettings = await UserSettings()
                              .loadSettings();
                          String? imageURL = await UserCreateGroupController()
                              .uploadGroupProfileImage(
                                File(imagePath!),
                                groupName: nameController.text,
                              );
                          Map<String, dynamic>
                          groupData = UserCreateGroupController().createGroupObject(
                            created_at: DateTime.timestamp(),
                            created_by: userSettings.email!,
                            group_description: descriptionController.text,
                            group_members: [
                              {
                                "user_name":
                                    userSettings.userName ?? "Anonymous(Admin)",
                                "user_email": userSettings.email,
                                "user_image":
                                    userSettings.imageURL ??
                                    'https://t3.ftcdn.net/jpg/07/24/59/76/360_F_724597608_pmo5BsVumFcFyHJKlASG2Y2KpkkfiYUU.jpg',
                                "user_role": "Admin",
                              },
                            ],
                            group_name: nameController.text,
                            group_profile_url: imageURL ?? "URL",
                            group_location:
                                locationController.text ?? "Update Location",
                          );
                          UserCreateGroupController().uploadUserGroup(
                            groupData,
                          );

                          setState(() {
                            GroupCardList.clear();
                            loadAllGroups();
                          });

                          Navigator.of(context).pop(); // Close the bottom sheet
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Create Group',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Function to display the dialog
  Future<bool?> showJoinGroupDialog(BuildContext context, String groupName) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          // You can use your existing green/dark mode logic here for colors
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),

          title: Text(
            "Join Group?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          content: Text(
            "Would you like to join the group '$groupName'?",
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),

          actions: <Widget>[
            // -------------------- NO Button --------------------
            TextButton(
              child: Text(
                "No",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(false); // Closes the dialog and returns 'false'
                // Add 'No' action logic here (e.g., show a snackbar)
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Joining cancelled.')));
              },
            ),

            // -------------------- YES Button --------------------
            TextButton(
              child: Text(
                "Yes",
                style: TextStyle(
                  // Use your app's main green color here
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              onPressed: () {
                Navigator.of(
                  context,
                ).pop(true); // Closes the dialog and returns 'true'
                // Add 'Yes' action logic here (e.g., call the join group function)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Request to join sent!')),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
