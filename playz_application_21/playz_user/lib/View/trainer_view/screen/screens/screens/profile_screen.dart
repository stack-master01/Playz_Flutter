import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Corrected import
// Note: Assuming these imports are correct and available
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:playz_user/Controller/trainer_sharedpreferences.dart'; 
import 'package:playz_user/Helper/Trainer_Loader.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/language_screen.dart'; 
import 'package:playz_user/View/trainer_view/screen/screens/screens/trainer_menu.dart'; 

// --- MOCK IMPLEMENTATIONS FOR EXTERNAL DEPENDENCIES ---


// --- GLOBAL MOCK DATA/UTILITIES ---
Map<String, String> _translationsCache = {};
String _currentLang = "en";
const List<Map<String, dynamic>> turfInfo = [];

// ----------------------------------------------------------------------

class CoachProfileScreen extends StatefulWidget {
  const CoachProfileScreen({super.key});

  @override
  State<CoachProfileScreen> createState() => _CoachProfileScreenState();
}

class _CoachProfileScreenState extends State<CoachProfileScreen> {

  // 1. DYNAMIC STATE VARIABLES
  String _coachName = "";
  String _phoneNumber = "";
  String _emailAddress = "";
  String _aboutMeText = "";
  List<String> _sports = []; // Editable list of sports (loaded from Firestore)
  String _profileImageUrl = 'assets/Images/profile_placeholder.jpg'; // Initial asset placeholder
  File? _selectedImageFile; // Holds the file selected by ImagePicker
  bool _loadingProfile = true;
  double _averageStars = 0.0;
  int _totalReviews = 0;
  List<Map<String, dynamic>> _reviews = [];
  List<Map<String, dynamic>> _violationHistory = [];

  // Text Editing Controllers for the Bottom Sheet
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  
  // ⭐️ NEW: Controller for the Add Sport TextField
  final TextEditingController _sportController = TextEditingController();


  // 2. Data Loading and Initialization
  Future<void> _fetchProfileData() async {
    // Load profile from Firestore for the current trainer (if trainer email is set in TrainerSettings)
    try {
      setState(() {
        _loadingProfile = true;
      });

      final trainerSettings = await TrainerSettings().loadSettings();
      final trainerEmail = trainerSettings.trainerEmail;
      if (trainerEmail == null || trainerEmail.isEmpty) {
        // keep defaults
        _nameController.text = _coachName;
        _phoneController.text = _phoneNumber;
        _aboutController.text = _aboutMeText;
        setState(() {
          _loadingProfile = false;
        });
        return;
      }

      final docRef = FirebaseFirestore.instance
          .collection('Turf_Trainer')
          .doc(trainerEmail)
          .collection('Trainer_Data')
          .doc('Profile_Data');

      final snapshot = await docRef.get();
      if (!snapshot.exists) {
        _nameController.text = _coachName;
        _phoneController.text = _phoneNumber;
        _aboutController.text = _aboutMeText;
        setState(() {
          _loadingProfile = false;
        });
        return;
      }

      final data = snapshot.data();
      if (data != null) {
        // Safely parse and assign fields
        final trainerName = data['trainer_name'];
        final contactNo = data['contact_no'];
        final email = data['email'];
        final about = data['about'];
        final avg = data['average_stars'];
        final total = data['total_reviews'];
        final reviewsRaw = data['reviews'];
        final violationsRaw = data['violation_history'];
        final profileImages = data['trainer_images'];

        if (trainerName is String && trainerName.isNotEmpty) _coachName = trainerName;
        if (contactNo is String && contactNo.isNotEmpty) _phoneNumber = contactNo;
        if (email is String && email.isNotEmpty) _emailAddress = email;
        if (about is String && about.isNotEmpty) _aboutMeText = about;
        if (avg is num) _averageStars = avg.toDouble();
        if (total is num) _totalReviews = total.toInt();

        // reviews
        _reviews = [];
        if (reviewsRaw is List) {
          for (var r in reviewsRaw) {
            if (r is Map<String, dynamic>) _reviews.add(r);
            else if (r is Map) _reviews.add(Map<String, dynamic>.from(r));
          }
        }

        // violation history
        _violationHistory = [];
        if (violationsRaw is List) {
          for (var v in violationsRaw) {
            if (v is Map<String, dynamic>) _violationHistory.add(v);
            else if (v is Map) _violationHistory.add(Map<String, dynamic>.from(v));
          }
        }

        // pick first trainer image if available
        if (profileImages is List && profileImages.isNotEmpty) {
          final p0 = profileImages[0];
          if (p0 is String && p0.isNotEmpty) _profileImageUrl = p0;
        }

        // populate controllers
        _nameController.text = _coachName;
        _phoneController.text = _phoneNumber;
        _aboutController.text = _aboutMeText;
        // sports
        final sportsRaw = data['sports'];
        if (sportsRaw is List) {
          _sports = [];
          for (var s in sportsRaw) {
            if (s is String && s.isNotEmpty) _sports.add(s);
          }
        }
      }
    } catch (e, st) {
      log('Error loading profile data: $e');
      log('$st');
    } finally {
      if (mounted) setState(() {
        _loadingProfile = false;
      });
    }
  }

  // 3. Dynamic Getter for all translation keys
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      // Static Text Keys
      "Contact Information", "About Me", "Add Sport", "Search a Sport", 
      "Upload images/videos", "Tap to upload images/videos", "Edit Profile", 
      "Save Changes", "Name", "Phone Number", "Add",
      
      // Dynamic/Data Text Keys
      _coachName, _phoneNumber, _emailAddress, _aboutMeText, ..._sports,
    };
    return keys.toList();
  }

  // 4. Load Translations function
  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;
    if (_currentLang == lang && _translationsCache.keys.length == keysToLoad.length) {
      return;
    }
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
    _loadTranslations(trainerAppLanguageNotifier.value);
  }

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    if (_currentLang != trainerAppLanguageNotifier.value) {
      _translationsCache.clear();
    }
    _loadSelectedTheme();
    _loadSelectedLang();
    trainerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _aboutController.dispose();
    _sportController.dispose(); // ⭐️ Dispose the new controller
    trainerAppLanguageNotifier.removeListener(_languageChangeListener);
    super.dispose();
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await TrainerThemeLangSettings(theme: null).loadSelectedTheme();
    isDarkTrainerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await TrainerThemeLangSettings(theme: null).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    trainerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet);
  }

  String _getTranslation(String key) {
    return _translationsCache[key] ?? key;
  }

  // ⭐️ NEW: Logic to add a sport from the TextField
  void _addSportToList() async {
    final sport = _sportController.text.trim();
    if (sport.isNotEmpty && !_sports.contains(sport)) {
      setState(() {
        _sports.add(sport);
        _sportController.clear();
      });
      FocusScope.of(context).unfocus();
      // Important: Reload translations for the new sport name
      await _loadTranslations(trainerAppLanguageNotifier.value);
      
      // Persist to Firestore
      try {
        final trainerSettings = await TrainerSettings().loadSettings();
        final trainerEmail = trainerSettings.trainerEmail;
        if (trainerEmail != null && trainerEmail.isNotEmpty) {
          final docRef = FirebaseFirestore.instance
              .collection('Turf_Trainer')
              .doc(trainerEmail)
              .collection('Trainer_Data')
              .doc('Profile_Data');
          await docRef.set({
            'sports': FieldValue.arrayUnion([sport])
          }, SetOptions(merge: true));
        }
        log("Added new sport: $sport. Sports list: $_sports");
      } catch (e) {
        log('Failed to add sport to firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_getTranslation('Failed to add sport'))));
      }
    } else if (_sports.contains(sport)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${_getTranslation(sport)} is already added.")),
      );
    }
  }

  Future<void> _removeSport(String sport) async {
    setState(() {
      _sports.remove(sport);
    });
    try {
      final trainerSettings = await TrainerSettings().loadSettings();
      final trainerEmail = trainerSettings.trainerEmail;
      if (trainerEmail != null && trainerEmail.isNotEmpty) {
        final docRef = FirebaseFirestore.instance
            .collection('Turf_Trainer')
            .doc(trainerEmail)
            .collection('Trainer_Data')
            .doc('Profile_Data');
        await docRef.set({
          'sports': FieldValue.arrayRemove([sport])
        }, SetOptions(merge: true));
      }
      await _loadTranslations(trainerAppLanguageNotifier.value);
    } catch (e) {
      log('Failed to remove sport from firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_getTranslation('Failed to remove sport'))));
    }
  }
  
  // 5. IMAGE PICKER & UPLOAD LOGIC 🖼️
  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      if (mounted) Navigator.pop(context);

      setState(() {
        _selectedImageFile = File(pickedFile.path);
      });
      
      await _uploadProfileImage();
    } else {
      log('No image selected.');
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_selectedImageFile == null) return;
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploading image...")),
      );
      await Future.delayed(const Duration(seconds: 2)); 

      String newUrl = _selectedImageFile!.path; 
      
      if (mounted) {
        setState(() {
          _profileImageUrl = newUrl;
          _selectedImageFile = null;
        });
        _loadTranslations(trainerAppLanguageNotifier.value);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile image updated successfully!")),
        );
      }
    } catch (e) {
      log('Error during image upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to upload image: ${e.toString()}")),
        );
    }
  }

  // 6. BOTTOM SHEETS 📝📸
  Future<void> _showEditProfileDataSheet(ThemeData theme) async {
    _nameController.text = _coachName;
    _phoneController.text = _phoneNumber;
    _aboutController.text = _aboutMeText;
    
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20, left: 20, right: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_getTranslation("Edit Profile"), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                const SizedBox(height: 20),
                _buildTextField(theme, label: "Name", controller: _nameController, icon: Icons.person),
                const SizedBox(height: 15),
                _buildTextField(theme, label: "Phone Number", controller: _phoneController, icon: Icons.phone, keyboardType: TextInputType.phone),
                const SizedBox(height: 15),
                _buildTextField(theme, label: "About Me", controller: _aboutController, icon: Icons.info_outline, maxLines: 4),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      _saveProfileData();
                      Navigator.pop(context);
                    },
                    child: Text(_getTranslation("Save Changes"), style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Future<void> _showImageSourceSheet(ThemeData theme) async {
    return showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera_alt, color: theme.colorScheme.primary),
              title: Text('Take a Picture', style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: theme.colorScheme.primary),
              title: Text('Choose from Gallery', style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }

  void _saveProfileData() async {
    setState(() {
      _coachName = _nameController.text;
      _phoneNumber = _phoneController.text;
      _aboutMeText = _aboutController.text;
    });

    await _loadTranslations(trainerAppLanguageNotifier.value);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile data saved!")),
    );
  }

  // --- WIDGET BUILD METHODS ---

  @override
  Widget build(BuildContext context) {
    
    ImageProvider<Object> profileImage;
    if (_selectedImageFile != null) {
      profileImage = FileImage(_selectedImageFile!);
    } else if (_profileImageUrl.startsWith('http') || _profileImageUrl.startsWith('file')) {
      profileImage = NetworkImage(_profileImageUrl);
    } else {
      profileImage = AssetImage(_profileImageUrl);
    }

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
                appBar: AppBar(
                  backgroundColor: theme.colorScheme.primary,
                  elevation: 0,
                  leading: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(Icons.menu, color: theme.colorScheme.onPrimary, size: 28),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  ),
                  actions: [
                    Icon(Icons.notifications_none, color: theme.colorScheme.onPrimary),
                    const SizedBox(width: 15),
                    Icon(Icons.chat_bubble_outline, color: theme.colorScheme.onPrimary),
                    const SizedBox(width: 15),
                  ],
                ),
                drawer: const TrainerDrawer(),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      
                      // 🔹 Profile Image and Edit Icon
                      GestureDetector(
                        onTap: () => _showImageSourceSheet(theme),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.colorScheme.surfaceVariant,
                              backgroundImage: profileImage,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: theme.colorScheme.background,
                                      width: 2),
                                ),
                                child: Icon(Icons.add, size: 18, color: theme.colorScheme.onPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // 🔹 Name and Edit Icon
                      GestureDetector(
                        onTap: () => _showEditProfileDataSheet(theme),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_getTranslation(_coachName), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
                            const SizedBox(width: 5),
                            Icon(Icons.edit, size: 18, color: theme.colorScheme.primary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Contact Info (Clickable Card)
                      GestureDetector(
                        onTap: () => _showEditProfileDataSheet(theme),
                        child: _buildSectionCard(
                          theme: theme,
                          title: _getTranslation("Contact Information"),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.phone, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text("Phone: ${_getTranslation(_phoneNumber)}", style: TextStyle(fontSize: 15, color: theme.colorScheme.onBackground)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.email, color: theme.colorScheme.primary),
                                  const SizedBox(width: 8),
                                  Text("Email: ${_getTranslation(_emailAddress)}", style: TextStyle(fontSize: 15, color: theme.colorScheme.onBackground)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // 🔹 About Me (Clickable Card)
                      GestureDetector(
                        onTap: () => _showEditProfileDataSheet(theme),
                        child: _buildSectionCard(
                          theme: theme,
                          title: _getTranslation("About Me"),
                          child: Text(_getTranslation(_aboutMeText), style: TextStyle(fontSize: 14.5, color: theme.colorScheme.onBackground)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 🔹 Ratings Summary
                      _buildSectionCard(
                        theme: theme,
                        title: 'Rating',
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(Icons.star, color: theme.colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(_averageStars.toStringAsFixed(1), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
                            const SizedBox(width: 12),
                            Text('($_totalReviews ${_getTranslation("reviews")})', style: TextStyle(color: theme.colorScheme.onBackground)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // 🔹 Sports Section
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_getTranslation("Add Sport"), style: TextStyle(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      const SizedBox(height: 10),
                      
                      // ⭐️ UPDATED: TextField with Suffix Button
                      TextField(
                        controller: _sportController, // ⭐️ Added Controller
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        onSubmitted: (value){
                          _addSportToList();
                          
                        }, // Allow adding by pressing Enter
                        decoration: InputDecoration(
                          hintText: _getTranslation("Search a Sport"),
                          hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.add, color: theme.colorScheme.primary),
                            onPressed: _addSportToList, // ⭐️ Trigger the add function
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      // 🔹 Dynamic Sport Chips
                      Wrap(
                        spacing: 8,
                        children: _sports.map((sport) {
                          return _buildChip(_getTranslation(sport), theme, () {
                            _removeSport(sport);
                          });
                        }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Reviews Section
                      if (_reviews.isNotEmpty) ...[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_getTranslation('Reviews'), style: TextStyle(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final r = _reviews[index];
                            final senderName = r['senders_name'] ?? r['sender_name'] ?? 'Anonymous';
                            final msg = r['message'] ?? '';
                            final stars = (r['stars'] is num) ? r['stars'].toInt() : 0;
                            final avatar = r['sender_profile'] ?? '';
                            return Card(
                              color: theme.colorScheme.surface,
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: (avatar is String && avatar.startsWith('http')) ? NetworkImage(avatar) : null,
                                      child: (avatar == null || (avatar is String && avatar.isEmpty)) ? Icon(Icons.person, color: theme.colorScheme.onSurface) : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(senderName, style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
                                              Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < stars ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.3)))),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(msg, style: TextStyle(color: theme.colorScheme.onBackground)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],

                      // 🔹 Violation history summary
                      if (_violationHistory.isNotEmpty) ...[
                        // const SizedBox(height: 12),
                        // _buildSectionCard(
                        //   theme: theme,
                        //   title: 'Reports',
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Text('${_violationHistory.length} ${_getTranslation('reports')}', style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onBackground)),
                        //       const SizedBox(height: 8),
                        //       Builder(builder: (ctx) {
                        //         final latest = _violationHistory.last;
                        //         final message = latest['message'] ?? '';
                        //         final reporter = latest['reporter_name'] ?? latest['reporter'] ?? '';
                        //         final reportedAt = latest['reported_at'];
                        //         String timeText = '';
                        //         try {
                        //           if (reportedAt is Timestamp) timeText = reportedAt.toDate().toLocal().toString();
                        //           else if (reportedAt is DateTime) timeText = reportedAt.toLocal().toString();
                        //         } catch (_) {}
                        //         return Column(
                        //           crossAxisAlignment: CrossAxisAlignment.start,
                        //           children: [
                        //             Text(message, style: TextStyle(color: theme.colorScheme.onBackground)),
                        //             const SizedBox(height: 6),
                        //             Text('${reporter ?? ''} · $timeText', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12)),
                        //           ],
                        //         );
                        //       }),
                        //     ],
                        //   ),
                        // ),
                      ],

                      // 🔹 Upload Section
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_getTranslation("Upload images/videos"), style: TextStyle(color: theme.colorScheme.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          _showImageSourceSheet(theme);
                        },
                        child: DottedBorderContainer(
                          theme: theme,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined, color: theme.colorScheme.onSurface, size: 40),
                              const SizedBox(height: 8),
                              Text(_getTranslation("Tap to upload images/videos"), style: TextStyle(color: theme.colorScheme.onSurface)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // // 🔹 Image Placeholder with close button
                      // Align(
                      //   alignment: Alignment.centerLeft,
                      //   child: Stack(
                      //     children: [
                      //       ClipRRect(
                      //         borderRadius: BorderRadius.circular(8),
                      //         child: Image.asset('assets/Images/placeholder_media.jpg', width: 100, height: 100, fit: BoxFit.cover,), // Mock Media Placeholder
                      //       ),
                      //       Positioned(
                      //         top: 4,
                      //         right: 4,
                      //         child: GestureDetector(
                      //           onTap: () {},
                      //           child: Container(
                      //             decoration: BoxDecoration(
                      //               color: theme.colorScheme.surface,
                      //               shape: BoxShape.circle,
                      //             ),
                      //             child: Icon(Icons.close, color: theme.colorScheme.primary, size: 20),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              if (_loadingProfile || _translationsCache.isEmpty)
                const Positioned.fill(child: TrainerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }

  // 🔸 Helper - Section Card
  Widget _buildSectionCard({
    required ThemeData theme,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.onBackground)),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // Helper for bottom sheet text fields
  Widget _buildTextField(
    ThemeData theme, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: TextStyle(color: theme.colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: _getTranslation(label),
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.colorScheme.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5))),
      ),
    );
  }
  
  // 🔸 Helper - Sport Chip
  Widget _buildChip(String label, ThemeData theme, VoidCallback onDelete) {
    return Chip(
      label: Text(label, style: TextStyle(color: theme.colorScheme.primary, fontSize: 14)),
      backgroundColor: theme.colorScheme.surface,
      shape: StadiumBorder(side: BorderSide(color: theme.colorScheme.primary)),
      deleteIcon: Icon(Icons.close, color: theme.colorScheme.primary, size: 18),
      onDeleted: onDelete,
    );
  }
}

// 🔸 Dotted Border Placeholder
class DottedBorderContainer extends StatelessWidget {
  final Widget child;
  final ThemeData theme;
  const DottedBorderContainer({
    super.key,
    required this.child,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}