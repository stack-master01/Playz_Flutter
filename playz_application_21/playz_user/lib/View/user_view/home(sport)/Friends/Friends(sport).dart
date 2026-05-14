import 'dart:developer'; // Required for log()
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/User_Controller/User_Friend_List_Controller.dart';
import 'package:playz_user/Controller/User_Controller/User_Group_Chat_Controller.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/home(sport)/Friends/Friend_Chat.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Needed for Firestore logic

// Assuming these are defined elsewhere in your project
// Future<String> getTranslatedText(String key, String lang) async => key;
// final ValueNotifier<String> appLanguageNotifier = ValueNotifier("en");
// final ValueNotifier<ThemeSettings> appSettingsNotifier = ValueNotifier(ThemeSettings(theme: "Light"));
// final ValueNotifier<String?> selectedLocationNotifier = ValueNotifier(null);

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class FriendsSport extends StatefulWidget {
  const FriendsSport({super.key});

  @override
  State<FriendsSport> createState() => _FriendsSportState();
}

// List stores the CURRENT USER's friends
List<Map<String, dynamic>> FriendsSportCardList = [];

class _FriendsSportState extends State<FriendsSport> {
  // ===================================================================
  // CACHED TRANSLATION LOGIC 🌍
  // ===================================================================

  List<Map<String, dynamic>> turfInfo =
      []; // Kept for translation structure compatibility

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Friends",
      "Search by Name",
      "Suggestions", // Added for search mode title
      "My Friends", // Added for friend list title
    };

    for (var info in FriendsSportCardList) {
      if (info['member_name'] is String) {
        keys.add(info['member_name'] as String);
      }
    }

    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }
    _extractStrings(FriendsSportCardList, keys);
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
      // NOTE: Replace with your actual translation function
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

  Map<String, dynamic> friendData = {};
  String _getTranslation(String key) => _translationsCache[key] ?? key;
  // ------------------------------------------------------------------

  // ===================================================================
  // FRIEND/USER DATA AND SEARCH LOGIC
  // ===================================================================
  final TextEditingController _searchController = TextEditingController();
  // List stores ALL users in the database (for searching)
  List<Map<String, dynamic>> _allUsersForSearch = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  String currentUserEmail = '';

  Future<void> loadCurrentUser() async {
    UserSettings userSettings = await UserSettings().loadSettings();
    currentUserEmail = userSettings.email!;
  }

  // 🔽 NEW: Method to run the search filter 🔽
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _searchResults.clear();
      } else {
        _isSearching = true;

        // Filter the list of ALL users
        _searchResults = _allUsersForSearch.where((user) {
          final userName = user['member_name']?.toLowerCase() ?? '';
          final userEmail = user['email']?.toLowerCase() ?? '';

          // 1. Check for name or email match
          final bool matchesQuery =
              userName.contains(query) || userEmail.contains(query);

          // 2. Exclude the current user from suggestions
          final bool isCurrentUser =
              userEmail == currentUserEmail.toLowerCase();

          // 3. Exclude users already in the FriendsSportCardList (already friends)
          final bool isAlreadyFriend = FriendsSportCardList.any(
            (friend) => friend['email']?.toLowerCase() == userEmail,
          );

          // Suggest if matches query AND is NOT current user AND is NOT already a friend
          return matchesQuery && !isCurrentUser && !isAlreadyFriend;
        }).toList();
      }
    });
  }

  // 🔽 MODIFIED: Combines fetching all users for search and current user's friends 🔽
  Future<void> loadAllUsersAndFriends() async {
    // 1. Fetch ALL users for searching (MUST be implemented in your Controller)
    final allUsersData = await UserFriendListController().fetchAllFriends();
    final friendList = await UserFriendListController().fetchFriendList();
    log("fetched friend list: $friendList");

    _allUsersForSearch.clear();
    for (var user in allUsersData) {
      if (user['email'] != null &&
          user['name'] != null &&
          user['email'] != currentUserEmail) {
        _allUsersForSearch.add({
          "image": user['image_url'] ?? 'default_url',
          "member_name": user['name'],
          "email": user['email'],
        });
      }
    }

    FriendsSportCardList.clear(); // Clear the list before adding new friends

    for (var friendDataMap in friendList) {
      // Check if the map contains the 'friend_list' key and it's a List
      if (friendDataMap.containsKey('friend_list') &&
          friendDataMap['friend_list'] is List) {
        // Iterate through the actual list of friends
        for (var friend in (friendDataMap['friend_list'] as List)) {
          // 'friend' is the individual friend map: {image_url: ..., name: ..., email: ...}
          if (friend['email'] != null &&
              friend['name'] != null &&
              friend['email'] != currentUserEmail) {
            FriendsSportCardList.add({
              // Map the keys to the required format
              "image": friend['image_url'] ?? 'default_url',
              "member_name": friend['name'],
              "email": friend['email'],
            });
          }
        }
      }
    }

    // 2. Fetch the current user's friend list (Existing friend data)
    // await loadCurrentUserFriends();

    if (mounted) {
      setState(() {
        _loadTranslations(appLanguageNotifier.value);
      });
    }
  }

  // 🔽 NEW: Focus on loading the current user's friend list (More typical structure) 🔽
  // Future<void> loadCurrentUserFriends() async {
  //   // NOTE: Assuming your UserFriendListController().fetchCurrentUserFriends()
  //   // is a method that correctly queries the current user's friends list
  //   // If fetchAllFriends() is the right method, keep it, but it seems wrong.

  //   // Placeholder: Since your original loadAllFriends was complex, we'll keep the list structure.
  //   // Replace this with your actual logic to populate FriendsSportCardList
  //   FriendsSportCardList.clear();
  //   // Example dummy data
  //   FriendsSportCardList.addAll([
  //     {
  //       "image": "url1",
  //       "member_name": "Sly Stallone",
  //       "email": "sly@example.com",
  //     },
  //     {"image": "url2", "member_name": "Jane Doe", "email": "jane@example.com"},
  //   ]);

  //   log("List: $FriendsSportCardList");
  // }
  // ------------------------------------------------------------------

  // ===================================================================
  // LIFECYCLE AND UTILITY METHODS
  // ===================================================================
  String chatID = "";


  @override
  void initState() {
    super.initState();
    FriendsSportCardList.clear();
    loadCurrentUser(); // Load email first
    if (_currentLang != appLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadSelectedLocation();

    _searchController.addListener(_onSearchChanged);
    loadAllUsersAndFriends(); // Load users for search and friends

    appLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    appLanguageNotifier.removeListener(_languageChangeListener);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
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

  String? selectedLocation;

  Future<void> _loadSelectedLocation() async {
    String? selected = await Appsharedpreferences().loadSelectedCity();
    selectedLocationNotifier.value = selected;
    log("city in home page: $selected");
    setState(() {
      selectedLocation = selected;
    });
  }

  // 🔽 NEW: Add Friend Dialog 🔽
  Future<bool?> showAddFriendDialog(BuildContext context, String friendName) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Add Friend?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Do you want to send a friend request to '$friendName'?",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }


String generateChatRoomId({required String currentUserId, required String otherUserId}) {
  // 1. Create a list of the two IDs
  List<String> userIds = [currentUserId, otherUserId];

  // 2. Sort the list alphabetically (lexicographically)
  userIds.sort(); // This ensures the smaller ID always comes first.

  // 3. Join them with a consistent separator
  // The result will ALWAYS be "smallerId_largerId"
  return userIds.join('_');
}
  // ------------------------------------------------------------------

  // ===================================================================
  // WIDGET BUILDER
  // ===================================================================

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier,
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          body: Stack(
            children: [
              // 🔹 Green header background (Remains the same)
              Container(
                // ... (header styling and back button/title) ...
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
                        Text(
                          _getTranslation("Friends"),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
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

              // 🔹 White rounded bottom sheet (Main content area)
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
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      // 🔹 Search bar for members (MODIFIED)
                      Container(
                        height: Reusable.getDeviceHeight(context, H: 60),
                        width: Reusable.getDeviceWidth(context, W: 388),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 30),
                          ),
                        ),
                        child: TextField(
                          controller: _searchController, // ⬅️ ADDED
                          onChanged: (value) => _onSearchChanged(), // ⬅️ ADDED
                          style: TextStyle(
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getDarkGrey(),
                          ),
                          cursorColor: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getGreen(),
                          decoration: InputDecoration(
                            hintText: _getTranslation("Search by Name"),
                            hintStyle: TextStyle(
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getDarkGrey(),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Reusable.getDarkModeBlack()
                                : Reusable.getWhite(),
                            suffixIcon: Icon(
                              Icons.search,
                              color: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                              size: Reusable.getDeviceWidth(context, W: 30),
                            ),
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
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      // 🔹 Section title (MODIFIED)
                      Padding(
                        padding: EdgeInsets.only(
                          left: Reusable.getDeviceWidth(context, W: 20),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _getTranslation(
                              _isSearching ? "Suggestions" : "My Friends",
                            ), // ⬅️ Dynamic Title
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
                        height: Reusable.getDeviceHeight(context, H: 10),
                      ),

                      // 🔹 List of Members/Suggestions (CONDITIONAL)
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: _isSearching
                              ? _searchResults.length
                              : FriendsSportCardList.length,
                          itemBuilder: (context, index) {
                            final list = _isSearching
                                ? _searchResults
                                : FriendsSportCardList;
                            final userCard = list[index];
                            final memberName =
                                userCard['member_name'] ?? "User";
                            final userEmail = userCard['email'] ?? "";

                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    UserSettings userSettings =
                                        await UserSettings().loadSettings();
                                    if (_isSearching) {
                                      // 🚀 Show dialog for adding a friend
                                      bool? confirmed =
                                          await showAddFriendDialog(
                                            context,
                                            memberName,
                                          );

                                      if (confirmed == true) {
                                        // 🛠️ Implement Add Friend Logic here
                                        // Example: UserFriendListController().sendFriendRequest(userEmail);
                                        log(
                                          "Friend request sent to $userEmail",
                                        );

                                        // Clear search to exit suggestion mode
                                        setState(() {
                                          _searchController.clear();
                                        });
                                      }
                                    } else {
                                      // 🗑️ Existing friend: Delete logic (from your original code)
                                      // The delete button is visible, but this handles the card tap
                                      log(
                                        "Tapped on existing friend: $memberName",
                                      );

                                      // email:
                                      //                                                           _searchResults[index]['email'],
                                      //                                                       image_url:
                                      //                                                           _searchResults[index]['image'],
                                      //                                                       name:
                                      //                                                           _searchResults[index]['member_name'],

                                      friendData = {
                                        "email":
                                            list[index]['email'] ?? "email",
                                        "image_url":
                                            list[index]['image'] ?? "image url",
                                        "name":
                                            list[index]['member_name'] ??
                                            "name",
                                      };
                                      chatID = generateChatRoomId(currentUserId: list[index]['email'], otherUserId: userSettings.email!);

                                      friendData['groupID'] = "$chatID";
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return FriendChat(
                                              groupDataMap: friendData,
                                            );
                                          },
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: Reusable.getDeviceHeight(
                                      context,
                                      H: 70,
                                    ),
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 388,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Reusable.getDarkModeGrey()
                                          : Reusable.getWhite(),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                          blurRadius: 3,
                                          color: Color.fromRGBO(0, 0, 0, 0.25),
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: Reusable.getDeviceWidth(
                                          context,
                                          W: 10,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // 🔹 Member details (Image + Name + Email)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Profile image
                                              Container(
                                                height:
                                                    Reusable.getDeviceHeight(
                                                      context,
                                                      H: 50,
                                                    ),
                                                width: Reusable.getDeviceWidth(
                                                  context,
                                                  W: 50,
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
                                                    userCard['image'] ?? "URL",
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: Reusable.getDeviceWidth(
                                                  context,
                                                  W: 15,
                                                ),
                                              ),

                                              // Name + Email
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  // Member name
                                                  Text(
                                                    _getTranslation(memberName),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: isDark
                                                          ? Reusable.getLightGreen()
                                                          : Reusable.getBlack(),
                                                    ),
                                                  ),
                                                  // Display email/role only in search suggestions
                                                  if (_isSearching)
                                                    Text(
                                                      userEmail,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: isDark
                                                            ? Reusable.getLightGrey()
                                                            : Reusable.getDarkGrey(),
                                                      ),
                                                    ),
                                                  SizedBox(
                                                    height:
                                                        Reusable.getDeviceHeight(
                                                          context,
                                                          H: 5,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),

                                          // 🔽 Icon (Add for suggestions, Delete for friends)
                                          _isSearching
                                              ? IconButton(
                                                  onPressed: () async {
                                                    //                                           {
                                                    //   "image": "url1",
                                                    //   "member_name": "Sly Stallone",
                                                    //   "email": "sly@example.com",
                                                    // },
                                                    friendData = UserFriendListController()
                                                        .createFriendObject(
                                                          email:
                                                              _searchResults[index]['email'],
                                                          image_url:
                                                              _searchResults[index]['image'],
                                                          name:
                                                              _searchResults[index]['member_name'],
                                                        );
                                                    Map<String, dynamic>
                                                    friendList = {
                                                      "friend_list": [
                                                        friendData,
                                                      ],
                                                    };

                                                    await UserFriendListController()
                                                        .uploadFriendData(
                                                          friendData,
                                                        );
                                                    UserSettings userSettings =
                                                        await UserSettings()
                                                            .loadSettings();
                                                    final groupMessage =
                                                        UserGroupChatController()
                                                            .createGroupChatObject(
                                                              created_at:
                                                                  DateTime.timestamp(),
                                                              from_id:
                                                                  userSettings
                                                                      .email!,
                                                              from_name:
                                                                  userSettings
                                                                      .userName ??
                                                                  "Anonymous",
                                                              image_url:
                                                                  "image_url",
                                                              is_image: false,
                                                              text:
                                                                  "Hey, There!",
                                                            );
 chatID = generateChatRoomId(currentUserId: _searchResults[index]['email'], otherUserId: userSettings.email!);
                                                    UserGroupChatController()
                                                        .uploadGroupChat(
                                                          groupMessage,
                                                          groupId:
                                                              "$chatID",
                                                        );
                                                  },
                                                  icon: Icon(
                                                    // Show ADD icon for search results
                                                    Icons.person_add_alt_1,
                                                    size:
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 30,
                                                        ),
                                                    color: Colors.blue,
                                                  ),
                                                )
                                              : IconButton(
                                                  // Show DELETE icon for existing friends
                                                  onPressed: () {},
                                                  icon: Icon(
                                                    Icons.delete_outlined,
                                                    size:
                                                        Reusable.getDeviceWidth(
                                                          context,
                                                          W: 30,
                                                        ),
                                                    color: isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getDarkGrey(),
                                                  ),
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
                                    H: 10,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
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
