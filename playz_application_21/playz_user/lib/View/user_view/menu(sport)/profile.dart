import 'dart:developer';
import 'dart:io'; // Import for File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/User_Controller/User_Profile_Controller.dart';
// Note: Assuming these external files provide necessary classes/widgets
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/Helper/User_Loader.dart';
import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';
import 'package:playz_user/View/user_view/menu(sport)/preflocation.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
// ⚠️ You MUST add the 'image_picker: ^latest_version' dependency to your pubspec.yaml file
import 'package:image_picker/image_picker.dart';

Map<String, String> _translationsCache = {};
String _currentLang = "en";

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

// 🔹 Dummy list of group members (image, name, role)
List<Map<String, dynamic>> UserProfileCardList = [
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "member_name": "Arnold Schwarzenegger",
  },
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "member_name": "Arnold Schwarzenegger",
  },
  {
    "image": "https://images.pexels.com/photos/139762/pexels-photo-139762.jpeg",
    "member_name": "Arnold Schwarzenegger",
  },
];
// Sample data: sport name and number of times played
List<Map<String, dynamic>> sportsData = [
  {'sport': 'Cricket', 'timesPlayed': 12},
  {'sport': 'Football', 'timesPlayed': 8},
  {'sport': 'Badminton', 'timesPlayed': 5},
  {'sport': 'Table Tennis', 'timesPlayed': 3},
];

// Optional: Assign colors to each sport dynamically
List<Color> colors = [Colors.blue, Colors.green, Colors.orange, Colors.purple];

class _UserProfileState extends State<UserProfile> {
  bool isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // ------------------------------------------------------------------
  // STATE VARIABLES FOR PROFILE DATA
  // ------------------------------------------------------------------
  // Use String? for local file path; null means use the default/network image
  String? _profileImagePath;
  String? _uploadedImageUrl;

  // Initial values for profile data
  String? _initialProfileImgUrl;

  String _userName = "User Name";

  final int totalGames = 56;
  String _userBioText = "Add something about you";

  // ------------------------------------------------------------------
  // TEXT EDITING CONTROLLERS FOR EDIT PROFILE SHEET
  // ------------------------------------------------------------------
  // Use late final for controllers initialized in initState
  TextEditingController? _nameController;
  TextEditingController? _bioController;

  // ===================================================================
  // CACHED TRANSLATION LOGIC (ADDED EXACTLY AS GIVEN) 🌍
  // ===================================================================

  // Example dynamic data (used for translation key collection)
  List<Map<String, dynamic>> turfInfo = [];

  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // START: Add default english text here (STATIC TEXT)
      "Profile",
      "Edit Profile",
      "Total Games",
      "PRO",
      "Reputation",
      "Sharp Timer",
      "TrustPay",
      "Team-Player",
      "Your Sports Activity",
      "Name",
      "Bio",
      "Change Photo",
      "Save",
      "Select Image Source", // ⬅️ NEW KEY for image picker
      "Gallery", // ⬅️ NEW KEY for image picker
      "Camera", // ⬅️ NEW KEY for image picker
      // END: Add default english text here

      // Dynamic keys/text
      _userName, // Use state variable
      _userBioText, // Use state variable
    };

    // Dynamically collect keys from sportsData (sport names)
    for (var data in sportsData) {
      if (data['sport'] is String) {
        keys.add(data['sport'] as String);
      }
    }
    // Dynamically collect keys from the list items (turfInfo not used here, but kept as per logic)
    for (var info in turfInfo) {
      if (info['turfName'] is String) {
        keys.add(info['turfName'] as String);
      }
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

    _loadAllData();

    if (_currentLang != appLanguageNotifier.value) {
      _translationsCache.clear();
      appLanguageNotifier.addListener(_languageChangeListener);
    }
  }

  Future<void> _loadAllData() async {
    // 1. Load data
    await _loadSingleImage();
    await loadUserName_And_UserBio(); // Now updates _userName & _userBioText

    // 2. Load settings
    await _loadSelectedTheme();
    await _loadSelectedLang();
    await _loadSelectedLocation();
    setState(() {
      isLoading = false;
    });

    // 3. Update state and controllers *after* data is loaded
    // if (mounted) {
    //   setState(() {
    //     // ✅ FIX 1: Initialize the controllers here, using the newly loaded state variables.
    //     // This is the first time they get their values, which are NOT the defaults.
    //     _nameController = TextEditingController(text: _userName);
    //     _bioController = TextEditingController(text: _userBioText);
    //     log(_nameController!.text);

    //     // FIX 2: This setState triggers the UI (Text widgets) to rebuild,
    //     // showing the loaded _userName and _userBioText.
    //   });
    // }
  }

  Future<void> _loadSingleImage() async {
    UserSettings userSettings = await UserSettings().loadSettings();
    try {
      // 🔹 Folder path where the image is stored
      final storageRef = FirebaseStorage.instance
          .ref()
          .child("User_Data")
          .child(userSettings.email!)
          .child("Profile_Image");

      // 🔹 List all files in that folder
      final listResult = await storageRef.listAll();

      if (listResult.items.isNotEmpty) {
        // Get the first (or only) file’s URL
        final ref = listResult.items.first;
        final url = await ref.getDownloadURL();

        setState(() {
          _initialProfileImgUrl = url;
          // log(_initialProfileImgUrl!);
        });
      } else {
        print("No images found in this folder.");
      }
    } catch (e) {
      print("Error fetching image: $e");
    }
  }

  // ✅ Correct: Only loads data and updates state variables.
  Future<void> loadUserName_And_UserBio() async {
    UserSettings userSettings = await UserSettings().loadSettings();

    // 1. Update the state variables with the loaded data
    _userName = userSettings.userName ?? "User Name";
    _userBioText = userSettings.userBio ?? "Add something about you!";
    log("load : ${userSettings.userName}");
    log("${userSettings.userBio}");
    _nameController = TextEditingController(text: _userName);
    _bioController = TextEditingController(text: _userBioText);
  }

  @override
  void dispose() {
    // Dispose controllers
    _nameController?.dispose();
    _bioController!.dispose();
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

  // ===================================================================
  XFile? pickedFile;
  // NEW: Image Picker Implementation
  // ------------------------------------------------------------------
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, StateSetter localSetState) async {
    pickedFile = await _picker.pickImage(source: source, imageQuality: 75);
    if (pickedFile != null) {
      // 1. Update the state of the main widget to show the new image on the profile screen
      setState(() {
        _profileImagePath = pickedFile?.path;
        log("New image selected: $_profileImagePath");
      });
      // 2. Update the state of the bottom sheet itself to show the new image instantly
      localSetState(() {});

      if (mounted) Navigator.pop(context); // Close the source selection sheet
    }
  }

  void _showImageSourceSelectionSheet(bool isDark, StateSetter localSetState) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: isDark ? Reusable.getDarkModeBlack() : Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                _getTranslation("Select Image Source"),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getDarkGrey(),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: Icon(Icons.photo_library, color: Reusable.getGreen()),
                title: Text(_getTranslation("Gallery")),
                // Pass the localSetState function to the picker
                onTap: () => _pickImage(ImageSource.gallery, localSetState),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: Reusable.getGreen()),
                title: Text(_getTranslation("Camera")),
                // Pass the localSetState function to the picker
                onTap: () => _pickImage(ImageSource.camera, localSetState),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // UPDATED METHOD: Show Edit Profile Bottom Sheet
  // ------------------------------------------------------------------
  void _showEditProfileSheet(BuildContext context, bool isDark) {
    // Ensure controllers are synchronized with current state before showing the sheet
    _nameController?.text = _userName;
    _bioController?.text = _userBioText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Required for custom shape
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Reusable.getDarkModeBlack() : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            // ⬅️ WRAP THE BOTTOM SHEET CONTENT IN STATEFULBUILDER
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter localSetState) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // Title
                      Text(
                        _getTranslation("Edit Profile"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Reusable.getLightGreen()
                              : Reusable.getDarkGrey(),
                        ),
                      ),
                      const Divider(height: 25, thickness: 1),

                      // Profile Photo Edit Option
                      GestureDetector(
                        onTap: () {
                          // Pass the localSetState to the source selection sheet
                          _showImageSourceSelectionSheet(isDark, localSetState);
                        },
                        child: Center(
                          child: Column(
                            children: [
                              // This image will now rebuild when localSetState is called
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: _profileImagePath != null
                                    ? FileImage(File(_profileImagePath!))
                                          as ImageProvider<Object>
                                    : (_initialProfileImgUrl != null
                                          ? NetworkImage(
                                                  _initialProfileImgUrl ?? "",
                                                )
                                                as ImageProvider<Object>
                                          : NetworkImage(
                                                  "https://t3.ftcdn.net/jpg/07/24/59/76/360_F_724597608_pmo5BsVumFcFyHJKlASG2Y2KpkkfiYUU.jpg",
                                                )
                                                as ImageProvider<
                                                  Object
                                                > // ⬅️ Fallback to a local asset
                                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getTranslation("Change Photo"),
                                style: TextStyle(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getGreen(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Name Text Field
                      _buildTextField(
                        context,
                        controller: _nameController!,
                        label: _getTranslation("Name"),
                        isDark: isDark,
                        maxLines: 1,
                      ),

                      const SizedBox(height: 20),

                      // Bio Text Field
                      _buildTextField(
                        context,
                        controller: _bioController!,
                        label: _getTranslation("Bio"),
                        isDark: isDark,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 30),

                      // Save Button
                      ElevatedButton(
                        onPressed: () async {
                          // Update the main profile state variables
                          setState(() {
                            _userName = _nameController!.text;
                            _userBioText = _bioController!.text;
                          });
                          UserSettings.saveUserName(_userName);
                          UserSettings.saveUserBio(_userBioText);

                          UserSettings userSettings = await UserSettings()
                              .loadSettings();
                          String? image_url = await UserProfileController()
                              .uploadProfileImage(File(pickedFile!.path));
                          Map<String, dynamic> profileData =
                              UserProfileController().createProfileObject(
                                user_name: _userName,
                                user_bio: _userBioText,
                                image_url: image_url!,
                              );
                          UserProfileController().uploadUserProfile(
                            profileData,
                          );
                          UserSettings.saveUserProfileImageURL(image_url);
                          log("shared img: ${userSettings.imageURL}");
                          Navigator.pop(context); // Close the bottom sheet
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Reusable.getGreen(),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          _getTranslation("Save"),
                          style: const TextStyle(
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

  // ------------------------------------------------------------------
  // HELPER WIDGET: Custom Text Field for Edit Profile (UNMODIFIED)
  // ------------------------------------------------------------------
  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required bool isDark,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Reusable.getLightGrey() : Reusable.getDarkGrey(),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // We use a ValueListenableBuilder inside to listen for translation/theme changes
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          body: Stack(
            children: [
              // 🔹 Gradient header background with profile overlap
              Container(
                width: double.infinity,
                height: 245,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Reusable.getLightGreen(), Colors.black]
                        : [
                            Reusable.getGreen().withOpacity(0.95),
                            Colors.green.shade400,
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                child: Stack(
                  children: [
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.arrow_back_ios_new,
                                size: Reusable.getDeviceWidth(context, W: 30),
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                              ),
                            ),
                            // Title Text with translation
                            Text(
                              _getTranslation("Profile"), // 🌍 Translated
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                              ),
                            ),
                            // Edit button ⬅️ CONNECTED TO NEW METHOD
                            IconButton(
                              onPressed: () =>
                                  _showEditProfileSheet(context, isDark),
                              icon: Icon(
                                Icons.edit,
                                size: Reusable.getDeviceWidth(context, W: 25),
                                color: isDark
                                    ? Reusable.getDarkModeBlack()
                                    : Reusable.getWhite(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main white/dark sheet
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                margin: const EdgeInsets.only(top: 160),
                decoration: BoxDecoration(
                  color: isDark ? Reusable.getDarkModeBlack() : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: SingleChildScrollView(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Avatar (positioned here inside the scroll view) ⬅️ UPDATED
                      CircleAvatar(
                        radius: 53,
                        backgroundColor: isDark
                            ? Reusable.getLightGreen().withOpacity(0.7)
                            : Reusable.getGreen(),
                        child: CircleAvatar(
                          radius: 48,
                          // Use the state variable for the image
                          backgroundImage: _profileImagePath != null
                              ? FileImage(File(_profileImagePath!))
                                    as ImageProvider<Object>
                              : (_initialProfileImgUrl != null
                                    ? NetworkImage(_initialProfileImgUrl ?? "")
                                          as ImageProvider<Object>
                                    : NetworkImage(
                                            "https://t3.ftcdn.net/jpg/07/24/59/76/360_F_724597608_pmo5BsVumFcFyHJKlASG2Y2KpkkfiYUU.jpg",
                                          )
                                          as ImageProvider<
                                            Object
                                          > // ⬅️ Fallback to a local asset
                                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // User name ⬅️ UPDATED
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _getTranslation(_userName), // 🌍 Translated
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Reusable.getLightGreen()
                                : Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Total Games
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          // Concatenate translated "Total Games" with the number
                          "${_getTranslation("Total Games")} - $totalGames", // 🌍 Translated
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Reusable.getGreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // User bio text ⬅️ UPDATED
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _getTranslation(_userBioText), // 🌍 Translated
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Pro Level Progress with badge (UNMODIFIED)
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.grey[50],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: 0.4,
                                color: Reusable.getGreen(),
                                backgroundColor: isDark
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                                minHeight: 18,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Reusable.getGreen(),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.25),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _getTranslation("PRO"), // 🌍 Translated
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Reputation Card (UNMODIFIED)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isDark
                              ? Reusable.getDarkModeGrey()
                              : Colors.white,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 2,
                              color: Color.fromRGBO(0, 0, 0, 0.3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _getTranslation("Reputation"), // 🌍 Translated
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getDarkGrey(),
                                ),
                              ),
                            ),
                            Divider(
                              thickness: 1,
                              color: isDark
                                  ? Reusable.getLightGrey()
                                  : const Color.fromRGBO(0, 0, 0, 0.20),
                            ),

                            const SizedBox(height: 10),

                            // Reputation Items Grid Row (3 items)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildReputationItem(
                                  icon: Icons.timelapse_rounded,
                                  labelKey: "Sharp Timer", // 🌍 Translated
                                  value: "7",
                                  isDark: isDark,
                                ),
                                _buildReputationItem(
                                  icon: Icons.payments_outlined,
                                  labelKey: "TrustPay", // 🌍 Translated
                                  value: "7",
                                  isDark: isDark,
                                ),
                                _buildReputationItem(
                                  icon: Icons.group_work_outlined,
                                  labelKey: "Team-Player", // 🌍 Translated
                                  value: "7",
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Doughnut Chart Section with Title & Icon (UNMODIFIED)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.sports_soccer,
                                color: Reusable.getGreen(),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getTranslation(
                                  'Your Sports Activity',
                                ), // 🌍 Translated
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 250,
                            child: SfCircularChart(
                              legend: Legend(
                                isVisible: true,
                                position: LegendPosition.bottom,
                                textStyle: TextStyle(
                                  color: isDark
                                      ? Reusable.getLightGreen()
                                      : Reusable.getDarkGrey(),
                                ),
                                overflowMode: LegendItemOverflowMode.wrap,
                              ),
                              series: [
                                DoughnutSeries<Map<String, dynamic>, String>(
                                  // Data Source contains translatable sport names
                                  dataSource: sportsData.map((data) {
                                    return {
                                      'sport': _getTranslation(
                                        data['sport'],
                                      ), // 🌍 Translated sport name
                                      'timesPlayed': data['timesPlayed'],
                                    };
                                  }).toList(),
                                  xValueMapper: (data, index) =>
                                      data['sport'] as String,
                                  yValueMapper: (data, index) =>
                                      data['timesPlayed'] as int,
                                  pointColorMapper: (data, index) => index == 0
                                      ? Reusable.getGreen()
                                      : colors[index % colors.length],
                                  dataLabelSettings: const DataLabelSettings(
                                    isVisible: true,
                                    labelPosition:
                                        ChartDataLabelPosition.inside,
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  innerRadius: '65%',
                                  radius: '95%',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: Reusable.getDeviceHeight(context, H: 60),
                      ),
                    ],
                  ),
                ),
              ),
              if (isLoading) UserLoaderScreen(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReputationItem({
    required IconData icon,
    required String labelKey,
    required String value,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[850] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: Reusable.getDeviceWidth(context, W: 30),
              color: isDark ? Reusable.getLightGreen() : Reusable.getGreen(),
            ),
            const SizedBox(height: 8),
            Text(
              _getTranslation(labelKey), // 🌍 Translated
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? Reusable.getLightGrey()
                    : Reusable.getDarkGrey(),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.thumb_up_off_alt,
                  size: Reusable.getDeviceWidth(context, W: 20),
                  color: isDark
                      ? Reusable.getLightGreen()
                      : Reusable.getGreen(),
                ),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? Reusable.getLightGreen()
                        : Reusable.getGreen(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
