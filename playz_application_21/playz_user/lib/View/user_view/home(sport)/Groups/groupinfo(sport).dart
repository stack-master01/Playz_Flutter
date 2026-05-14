import 'dart:developer'; // Required for log()
import 'package:flutter/material.dart';
import 'package:playz_user/Helper/User_Loader.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/View/user_view/home(sport)/Groups/groupmembers.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';
  Map<String, String> _translationsCache = {};
  String _currentLang = "en";


class GroupInfo extends StatefulWidget {
  Map<String,dynamic> groupDataMap = {};
   GroupInfo({super.key, required this.groupDataMap});

  @override
  State<GroupInfo> createState() => _GroupInfoState();
}

class _GroupInfoState extends State<GroupInfo> {
   Map<String,dynamic> currentGroupDataMap = {};
  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  // 🔹 State variable to control notification toggle switch
  bool isOn = false;

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Group Info",
      "Cricket Legends Hub", // Group name
      "A vibrant space for cricket fans to connect, share, and celebrate the sport we love.", // Group description
      "356 Players", // Member count
      "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground", // Location
      "Notifications are controlled here",
      "Exit Group",
      "Report Group",
      "Are you sure you want to exit group?",
      "Cancel",
      "Exit",
      "Submit",
      "Type a Message", // For report sheet text field hint
      // END: Add default english text here
    };

    // Dynamically collect keys from the list items
    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
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

  // Define static keys for text elements
  static const String _titleKey = "Group Info";
  static const String _groupNameKey = "Cricket Legends Hub";
  static const String _groupDescKey =
      "A vibrant space for cricket fans to connect, share, and celebrate the sport we love.";
  static const String _memberCountKey = "356 Players";
  static const String _locationKey =
      "23 Greenfield Sports Complex, Near City Mall, MG Road, Camp, Pune, Maharashtra – 411001, Opposite Victory Cricket Ground";
  static const String _notificationLabelKey = "Notifications are controlled here";
  static const String _exitGroupKey = "Exit Group";
  static const String _reportGroupKey = "Report Group";
  static const String _exitConfirmKey = "Are you sure you want to exit group?";
  static const String _cancelKey = "Cancel";
  static const String _exitKey = "Exit";
  static const String _reportHintKey = "Type a Message";
  static const String _submitKey = "Submit";

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: [
              // 🔹 Green background header with back button and title
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color:
                    isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
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
                        // Screen title
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

              // 🔹 White bottom sheet containing group info details
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
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Spacing
                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 30),
                      ),

                      // 🔹 Group profile image
                      Container(
                        height: Reusable.getDeviceHeight(context, H: 150),
                        width: Reusable.getDeviceWidth(context, W: 150),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceHeight(context, H: 75),
                          ),
                          color: Colors.amber,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(
                            Reusable.getDeviceHeight(context, H: 75),
                          ),
                          child: Image.network(
                            currentGroupDataMap['group_data']['group_profile_url'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      // 🔹 Group name
                      Text(
                        _getTranslation(currentGroupDataMap['group_data']['group_name']), // 🌍 Translated
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getBlack(),
                        ),
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 10),
                      ),

                      // 🔹 Group description
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              Reusable.getDeviceWidth(context, W: 30),
                        ),
                        child: Text(
                          _getTranslation(currentGroupDataMap['group_data']['group_description']), // 🌍 Translated
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? Reusable.getLightGrey()
                                : Reusable.getDarkGrey(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      // 🔹 Total members container with navigation to GroupMembers screen
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>  GroupMembers(groupDataMap: currentGroupDataMap,),
                            ),
                          );
                        },
                        child: Container(
                          height: Reusable.getDeviceHeight(context, H: 70),
                          width: Reusable.getDeviceWidth(context, W: 388),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Reusable.getDarkModeGrey()
                                : Reusable.getWhite(),
                            borderRadius: BorderRadius.circular(
                              Reusable.getDeviceWidth(context, W: 10),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 2,
                                color: Color.fromRGBO(0, 0, 0, 0.25),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Reusable.getDeviceWidth(
                                context,
                                W: 20,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                // Left side: Icon + total members
                                Row(
                                  children: [
                                    Icon(
                                      Icons.groups_3_outlined,
                                      size: Reusable.getDeviceWidth(
                                        context,
                                        W: 30,
                                      ),
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                    SizedBox(
                                      width: Reusable.getDeviceWidth(
                                        context,
                                        W: 15,
                                      ),
                                    ),
                                    Text(
                                      _getTranslation("${currentGroupDataMap['group_data']['group_members'].length}"), // 🌍 Translated
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? Reusable.getLightGreen()
                                            : Reusable.getGreen(),
                                      ),
                                    ),
                                  ],
                                ),

                                // Right side: overlapping member images + arrow
                                Row(
                                  children: [
                                    // Overlapping member images
                                    Stack(
                                      children: [
                                        Container(
                                          height: Reusable.getDeviceHeight(
                                            context,
                                            H: 40,
                                          ),
                                          width: Reusable.getDeviceWidth(
                                            context,
                                            W: 40,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 20,
                                              ),
                                            ),
                                            color: Colors.amber,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(
                                              Reusable.getDeviceWidth(
                                                context,
                                                W: 20,
                                              ),
                                            ),
                                            child: Image.network(
                                              "${currentGroupDataMap['group_data']['group_members'][0]['user_image']}",
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        currentGroupDataMap['group_data']['group_members'].length >= 2 ?
                                        Padding(
                                          padding: EdgeInsets.only(
                                            left: Reusable.getDeviceWidth(
                                              context,
                                              W: 20,
                                            ),
                                          ),
                                          child: Container(
                                            height: Reusable.getDeviceHeight(
                                              context,
                                              H: 40,
                                            ),
                                            width: Reusable.getDeviceWidth(
                                              context,
                                              W: 40,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                Reusable.getDeviceWidth(
                                                  context,
                                                  W: 20,
                                                ),
                                              ),
                                              color: Colors.amber,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                Reusable.getDeviceWidth(
                                                  context,
                                                  W: 20,
                                                ),
                                              ),
                                              child: Image.network(
                                                "${currentGroupDataMap['group_data']['group_members'][1]['user_image']}",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ):SizedBox(),
                                      ],
                                    ),
                                    SizedBox(
                                      width: Reusable.getDeviceWidth(
                                        context,
                                        W: 10,
                                      ),
                                    ),

                                    // Forward arrow icon
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: Reusable.getDeviceWidth(
                                        context,
                                        W: 20,
                                      ),
                                      color: isDark
                                          ? Reusable.getLightGreen()
                                          : Reusable.getDarkGrey(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      // 🔹 Group location container
                      Container(
                        height: Reusable.getDeviceHeight(context, H: 100),
                        width: Reusable.getDeviceWidth(context, W: 388),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Reusable.getDarkModeGrey()
                              : Reusable.getWhite(),
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 10),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 2,
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                Reusable.getDeviceWidth(context, W: 10),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size:
                                    Reusable.getDeviceHeight(context, H: 30),
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getDarkGrey(),
                              ),
                              SizedBox(
                                width: Reusable.getDeviceWidth(context, W: 10),
                              ),
                              // Expandable location text
                              Expanded(
                                child: Text(
                                  _getTranslation("${currentGroupDataMap['group_data']['group_location']}",), // 🌍 Translated
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? Reusable.getLightGrey()
                                        : Reusable.getDarkGrey(),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      // 🔹 Notification toggle switch
                      Container(
                        height: Reusable.getDeviceHeight(context, H: 60),
                        width: Reusable.getDeviceWidth(context, W: 388),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Reusable.getDarkModeGrey()
                              : Reusable.getWhite(),
                          borderRadius: BorderRadius.circular(
                            Reusable.getDeviceWidth(context, W: 10),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 2,
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Text label
                            Text(
                              _getTranslation(_notificationLabelKey), // 🌍 Translated
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? Reusable.getLightGreen()
                                    : Reusable.getDarkGrey(),
                              ),
                            ),

                            // Volume icon that changes color with toggle
                            Icon(
                              Icons.volume_up,
                              size: Reusable.getDeviceWidth(context, W: 30),
                              color: isOn
                                  ? isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen()
                                  : isDark
                                      ? Reusable.getLightGrey()
                                      : Reusable.getDarkGrey(),
                            ),

                            // Switch widget to toggle notifications
                            Switch(
                              activeTrackColor: isDark
                                  ? Reusable.getLightGreen()
                                  : Reusable.getGreen(),
                              activeColor: isDark
                                  ? Reusable.getDarkModeBlack()
                                  : Reusable.getWhite(),
                              inactiveThumbColor: Reusable.getDarkGrey(),
                              inactiveTrackColor: Reusable.getLightGrey(),
                              value: isOn,
                              onChanged: (bool value) {
                                setState(() {
                                  isOn = value; // update toggle state
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 20),
                      ),

                      // 🔹 Exit group & Report group section
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              Reusable.getDeviceWidth(context, W: 40),
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            // Exit Group (with confirmation dialog)
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible:
                                      false, // user must tap button
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: isDark
                                          ? Reusable.getDarkModeGrey()
                                          : Reusable.getWhite(),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                        top: 20,
                                        left: 30,
                                        right: 30,
                                        bottom: 10,
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Warning icon
                                          Row(
                                            children: [
                                              Text(
                                                _getTranslation(_exitGroupKey), // 🌍 Translated
                                                textAlign:
                                                    TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.w400,
                                                  color: isDark
                                                      ? Reusable
                                                          .getLightGreen()
                                                      : Reusable
                                                          .getDarkGrey(),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 20),

                                          // Warning text
                                          Text(
                                            _getTranslation(_exitConfirmKey), // 🌍 Translated
                                            textAlign:
                                                TextAlign.center,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Reusable.getLightGrey()
                                                  : Reusable.getDarkGrey(),
                                              fontSize: 14,
                                              fontWeight:
                                                  FontWeight.w400,
                                            ),
                                          ),

                                          const SizedBox(height: 25),

                                          // Buttons: Cancel + Exit
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceEvenly,
                                            children: [
                                              // Cancel Button
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(),
                                                child: Text(
                                                  _getTranslation(_cancelKey), // 🌍 Translated
                                                  style: TextStyle(
                                                    color: isDark
                                                        ? Reusable
                                                            .getLightGreen()
                                                        : Reusable
                                                            .getDarkGrey(),
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),

                                              // Exit Button with gradient
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12),
                                                  gradient:
                                                      const LinearGradient(
                                                    colors: [
                                                      Colors.redAccent,
                                                      Colors.red,
                                                    ],
                                                  ),
                                                ),
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shadowColor:
                                                        Colors.transparent,
                                                    padding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 25,
                                                      vertical: 12,
                                                    ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                        12,
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop();
                                                    // TODO: Replace with actual exit logic
                                                    log("User logged out");
                                                  },
                                                  child: Text(
                                                    _getTranslation(_exitKey), // 🌍 Translated
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.exit_to_app,
                                    size: 30, // Use a static size or convert to W:30
                                    color: Color.fromRGBO(211, 47, 47, 1),
                                  ),
                                  SizedBox(
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 10,
                                    ),
                                  ),
                                  Text(
                                    _getTranslation(_exitGroupKey), // 🌍 Translated
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Color.fromRGBO(211, 47, 47, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Report Group option
                            GestureDetector(
                              onTap: () {
                                showReportSheet(isDark);
                              },
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.report_outlined,
                                    size: 30, // Use a static size or convert to W:30
                                    color: Color.fromRGBO(211, 47, 47, 1),
                                  ),
                                  SizedBox(
                                    width: Reusable.getDeviceWidth(
                                      context,
                                      W: 10,
                                    ),
                                  ),
                                  Text(
                                    _getTranslation(_reportGroupKey), // 🌍 Translated
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Color.fromRGBO(211, 47, 47, 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
if (_translationsCache.isEmpty)
              const Positioned.fill(
                child: UserLoaderScreen(),
              ),
              // TODO: Bottom navigation can be added here
            ],
          ),
        );
      },
    );
  }

  void showReportSheet(bool isDark) {
    showModalBottomSheet(
      isScrollControlled: true, // for keyboard resize
      isDismissible: false, // disable tap outside to close
      enableDrag: false,
      backgroundColor:
          isDark ? Reusable.getDarkModeGrey() : Reusable.getWhite(),
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Reusable.getDeviceWidth(context, W: 30)),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: Reusable.getDeviceHeight(context, H: 5),
                  right: Reusable.getDeviceWidth(context, W: 20),
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark
                          ? Reusable.getLightGreen()
                          : Reusable.getGreen(),
                      size: Reusable.getDeviceWidth(context, W: 30),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: Reusable.getDeviceHeight(context, H: 0),
                  left: Reusable.getDeviceWidth(context, W: 20),
                  right: Reusable.getDeviceWidth(context, W: 20),
                ),
                child: Column(
                  children: [
                    Container(
                      child: TextField(
                        style: TextStyle(
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getBlack(),
                        ),
                        cursorColor: isDark
                            ? Reusable.getLightGreen()
                            : Reusable.getGreen(),
                        textAlign: TextAlign.left, // horizontal alignment
                        textAlignVertical: TextAlignVertical.top,
                        minLines: null, // Start with 2 lines tall
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getDarkGrey(),
                          ),
                          hintText: _getTranslation(_reportHintKey), // 🌍 Translated
                          hintStyle: TextStyle(
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Reusable.getDarkGrey(),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Reusable.getDarkModeBlack()
                              : Reusable.getWhite(),
                          // background color inside field
                          // 🔹 Border when enabled (not focused)
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Reusable.getLightGrey(),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(
                              Reusable.getDeviceWidth(context, W: 30),
                            ),
                          ),

                          // 🔹 Border when focused
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

                          // 🔹 Border when error
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(
                              color: Colors.orange,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),

                          // 🔹 Border when focused + error
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? Reusable.getDarkModeBlack()
                            : Reusable.getWhite(),
                      ),
                      child: Text(
                        _getTranslation(_submitKey), // 🌍 Translated
                        style: TextStyle(
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getGreen(),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}