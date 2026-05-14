import 'dart:developer'; // Required for log()
import 'package:flutter/material.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class GroupMembers extends StatefulWidget {
  Map<String, dynamic> groupDataMap = {};
  GroupMembers({super.key, required this.groupDataMap});

  @override
  State<GroupMembers> createState() => _GroupMembersState();
}

// 🔹 Dummy list of group members (image, name, role) - Moved inside State for translation keys
List<Map<String, dynamic>> GroupMembersCardList = [
  
];

class _GroupMembersState extends State<GroupMembers> {
  Map<String, dynamic> currentGroupDataMap = {};

  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Players",
      "Search by Name",
      "Select a Role",
      "Owner",
      "Co-owner",
      "Member",
      "Confirm",
      // END: Add default english text here
    };

    // Dynamically collect keys from the list items (turfInfo not used here, but kept as per logic)
    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
    }

    // Dynamically collect keys from GroupMembersCardList
    for (var member in GroupMembersCardList) {
      if (member['member_name'] is String) {
        keys.add(member['member_name'] as String);
      }
      if (member['group_role'] is String) {
        keys.add(member['group_role'] as String);
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


  void loadAllMembers() {
    for (var newItem in currentGroupDataMap['group_data']['group_members']) {
      //     {
      //   "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
      //   "member_name": "Dwayne Johnson", // Changed name for better key collection demo
      //   "group_role": "Member",
      // },
      Map<String, dynamic> turfCard = {
        "image": newItem['user_image'],
        "member_name": newItem['user_name'],
        "group_role": newItem['user_role'],
      };

      GroupMembersCardList.add(turfCard);
    }

    log("List: $GroupMembersCardList");

    if (mounted) {
      setState(() {
        // Reload translations to include dynamic text from newly loaded games
        _loadTranslations(appLanguageNotifier.value);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    currentGroupDataMap = widget.groupDataMap;
    if (_currentLang != appLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    _loadSelectedLocation();
    GroupMembersCardList.clear();
    loadAllMembers() ;
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

  // Define static keys
  static const String _titleKey = "Players";
  static const String _searchHintKey = "Search by Name";
  static const String _selectRoleKey = "Select a Role";
  static const String _ownerRoleKey = "Owner";
  static const String _coOwnerRoleKey = "Co-owner";
  static const String _memberRoleKey = "Member";
  static const String _confirmKey = "Confirm";

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          body: Stack(
            // Stack is used to overlap top header and white sheet
            children: [
              // 🔹 Green header background
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
                        // 🔙 Back button
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
                        // 🔹 Title text
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

                      // 🔹 Search bar for members
                      Container(
                        height: Reusable.getDeviceHeight(context, H: 60),
                        width: Reusable.getDeviceWidth(context, W: 388),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 30),
                          ),
                        ),
                        child: TextField(
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

                      // 🔹 List of Group Members
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true, // prevents infinite height
                          itemCount: GroupMembersCardList.length,
                          itemBuilder: (context, index) {
                            final memberNameKey =
                                GroupMembersCardList[index]['member_name']
                                    as String;
                            final roleKey =
                                GroupMembersCardList[index]['group_role']
                                    as String;

                            return Column(
                              children: [
                                // 🔹 Member card container
                                Container(
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
                                        // 🔹 Member details (Image + Name + Role)
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Profile image
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
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Reusable.getDeviceWidth(
                                                        context,
                                                        W: 35,
                                                      ),
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
                                                  GroupMembersCardList[index]['image'],
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
                                            // Name + Role
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                // Member name
                                                Text(
                                                  _getTranslation(
                                                    memberNameKey,
                                                  ), // 🌍 Translated (Dynamic data)
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: isDark
                                                        ? Reusable.getLightGreen()
                                                        : Reusable.getBlack(),
                                                  ),
                                                ),

                                                SizedBox(
                                                  height:
                                                      Reusable.getDeviceHeight(
                                                        context,
                                                        H: 5,
                                                      ),
                                                ),
                                                // Member role
                                                Text(
                                                  _getTranslation(
                                                    roleKey,
                                                  ), // 🌍 Translated (Dynamic data)
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: isDark
                                                        ? Reusable.getLightGrey()
                                                        : Reusable.getDarkGrey(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),

                                        // 🔽 Dropdown icon (to change role)
                                        IconButton(
                                          onPressed: () {
                                            // Pass the current role to set as default in the sheet
                                            showMemberRoles(isDark, roleKey);
                                          },
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            size: Reusable.getDeviceWidth(
                                              context,
                                              W: 40,
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

  // 🔹 Bottom sheet to update member roles
  void showMemberRoles(bool isDark, String currentRoleKey) {
    var selectedOptionKey = currentRoleKey; // Default role key

    showModalBottomSheet(
      backgroundColor: isDark
          ? Reusable.getDarkModeGrey()
          : Reusable.getWhite(),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Reusable.getDeviceWidth(context, W: 30)),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          // Allows updating UI inside bottom sheet
          builder: (context, setStateBottom) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    _getTranslation(_selectRoleKey), // 🌍 Translated
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? Reusable.getLightGreen()
                          : Reusable.getBlack(),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 🔹 Radio Button: Owner
                  RadioListTile<String>(
                    title: Text(
                      _getTranslation(_ownerRoleKey), // 🌍 Translated
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getDarkGrey(),
                      ),
                    ),
                    value: _ownerRoleKey,
                    activeColor: isDark
                        ? Reusable.getLightGreen()
                        : Reusable.getGreen(),
                    groupValue: selectedOptionKey,
                    onChanged: (value) {
                      setStateBottom(() {
                        selectedOptionKey = value!;
                      });
                      // Only close the sheet when confirming the change, not on selection
                    },
                  ),

                  // 🔹 Radio Button: Co-owner
                  RadioListTile<String>(
                    title: Text(
                      _getTranslation(_coOwnerRoleKey), // 🌍 Translated
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getDarkGrey(),
                      ),
                    ),
                    value: _coOwnerRoleKey,
                    activeColor: isDark
                        ? Reusable.getLightGreen()
                        : Reusable.getGreen(),
                    groupValue: selectedOptionKey,
                    onChanged: (value) {
                      setStateBottom(() {
                        selectedOptionKey = value!;
                      });
                    },
                  ),

                  // 🔹 Radio Button: Member
                  RadioListTile<String>(
                    title: Text(
                      _getTranslation(_memberRoleKey), // 🌍 Translated
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getDarkGrey(),
                      ),
                    ),
                    value: _memberRoleKey,
                    activeColor: isDark
                        ? Reusable.getLightGreen()
                        : Reusable.getGreen(),
                    groupValue: selectedOptionKey,
                    onChanged: (value) {
                      setStateBottom(() {
                        selectedOptionKey = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Submit button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Reusable.getDarkModeBlack()
                          : Reusable.getWhite(),
                    ),
                    child: Text(
                      _getTranslation(_confirmKey), // 🌍 Translated
                      style: TextStyle(
                        color: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // close bottom sheet
                      // TODO: Implement logic to update the member's role with selectedOptionKey
                      log("Confirmed role change to: $selectedOptionKey");
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
