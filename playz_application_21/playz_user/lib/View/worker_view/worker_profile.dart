import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';
import 'package:playz_user/Helper/Worker_Loader.dart';
import 'package:playz_user/View/worker_view/worker_drower.dart';
import 'package:playz_user/View/worker_view/worker_language.dart';

Map<String, String> _translationsCache = {};

const List<Map<String, dynamic>> turfInfo = [];
String _currentLang = "en";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Set<String> skills = {};
  Map<String, dynamic>? workerdata = {};
  final FirebaseFirestore firebaseFirestoreobj = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // ========================= LOAD PROFILE ===========================
  void loadprofile() async {
    WorkerSettings workerobj = await WorkerSettings().loadSettings();
    final profile = await firebaseFirestoreobj
        .collection("Turf_Worker")
        .doc(workerobj.email)
        .collection("Worker_Data")
        .doc("Profile_Data")
        .get();

    setState(() {
      workerdata = profile.data();
      if (workerdata?["skills"] != null) {
        skills = Set<String>.from(workerdata?["skills"]);
      }
    });

    log("✅ Worker profile loaded: $workerdata");
  }

  // ========================= FIRESTORE UPDATE ======================
  Future<void> _updateWorkerProfileField(String field, dynamic newValue) async {
    try {
      WorkerSettings workerobj = await WorkerSettings().loadSettings();

      await firebaseFirestoreobj
          .collection("Turf_Worker")
          .doc(workerobj.email)
          .collection("Worker_Data")
          .doc("Profile_Data")
          .update({field: newValue});

      setState(() {
        workerdata?[field] = newValue;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("$field updated successfully!")));
    } catch (e) {
      log("❌ Error updating $field: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update $field")));
    }
  }

  // ========================= IMAGE PICK & UPLOAD =====================
  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (pickedFile == null) return;

      File imageFile = File(pickedFile.path);
      WorkerSettings workerobj = await WorkerSettings().loadSettings();

      String storagePath =
          "worker_profile_images/${workerobj.email}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      UploadTask uploadTask = storage.ref(storagePath).putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await _updateWorkerProfileField("profile_image", downloadUrl);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Profile image updated!")));
    } catch (e) {
      log("❌ Error uploading image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to upload image")));
    }
  }

  // ========================= TEXT EDIT DIALOG =======================
  void _showEditDialog({
    required String title,
    required String field,
    required String currentValue,
  }) {
    TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter new $title"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              onPressed: () async {
                if (controller.text.trim().isNotEmpty) {
                  await _updateWorkerProfileField(
                    field,
                    controller.text.trim(),
                  );
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // ========================= LANGUAGE HANDLING ======================
  List<String> get _allTranslationKeys {
    Set<String> keys = {
      "Worker Profile",
      "Full-Time Worker",
      "Part-Time Worker",
      "Contact Information",
      "Skills & Expertise",
      "Add New Skill",
      "E.g., Event Management",
      "Cancel",
      "Add",
      "No skills added yet. Tap '+' to add your expertise.",
      ...skills,
    };
    for (var info in turfInfo) {
      if (info['turfName'] is String) keys.add(info['turfName'] as String);
    }
    return keys.toList();
  }

  Future<void> _loadTranslations(String lang) async {
    final keysToLoad = _allTranslationKeys;
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
    _loadTranslations(workerAppLanguageNotifier.value);
  }

  @override
  void initState() {
    super.initState();
    _loadSelectedTheme();
    _loadSelectedLang();
    loadprofile();
    workerAppLanguageNotifier.addListener(_languageChangeListener);
  }

  @override
  void dispose() {
    workerAppLanguageNotifier.removeListener(_languageChangeListener);
    super.dispose();
  }

  Future<void> _loadSelectedTheme() async {
    String? selectedTheme = await WorkerThemeLangSettings(
      theme: null,
    ).loadSelectedTheme();
    isDarkWorkerThemeNotifier.value = selectedTheme == "Dark";
  }

  Future<void> _loadSelectedLang() async {
    String? selectedLang = await WorkerThemeLangSettings(
      theme: null,
    ).loadSelectedLocale();
    String langToSet = selectedLang ?? "en";
    workerAppLanguageNotifier.value = langToSet;
    await _loadTranslations(langToSet);
  }

  String _getTranslation(String key) => _translationsCache[key] ?? key;

  void _addNewSkill() {
    TextEditingController skillController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(_getTranslation("Add New Skill")),
          content: TextField(
            controller: skillController,
            decoration: InputDecoration(
              hintText: _getTranslation("E.g., Event Management"),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(_getTranslation("Cancel")),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text(
                _getTranslation("Add"),
                style: TextStyle(color: theme.colorScheme.onPrimary),
              ),
              onPressed: () async {
                if (skillController.text.isNotEmpty) {
                  setState(() {
                    String newSkill = _toTitleCase(skillController.text.trim());
                    skills.add(newSkill);
                  });
                  await _updateWorkerProfileField("skills", skills.toList());
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  String _toTitleCase(String text) => text.isEmpty
      ? text
      : text
            .split(' ')
            .map(
              (word) => word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
                  : '',
            )
            .join(' ');

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkWorkerThemeNotifier,
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
                  title: Text(_getTranslation("Worker Profile")),
                  backgroundColor: theme.colorScheme.surface,
                ),
                drawer: const WorkerDrawer(),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileHeaderCard(
                        userName: workerdata?["worker_name"] ?? "",
                        isFullTime: workerdata?["work_type"] ?? "",
                        profileImageUrl: workerdata?["profile_image"],
                        theme: theme,
                        getTranslation: _getTranslation,
                        onEditAvatar: _pickAndUploadImage,
                        onEditName: () => _showEditDialog(
                          title: "Name",
                          field: "worker_name",
                          currentValue: workerdata?["worker_name"] ?? "",
                        ),
                      ),
                      const SizedBox(height: 20),
                      ContactInfoCard(
                        userPhone: workerdata?["contact_no"] ?? "",
                        userEmail: workerdata?["email"] ?? "",
                        theme: theme,
                        getTranslation: _getTranslation,
                        onEditPhone: () => _showEditDialog(
                          title: "Phone",
                          field: "contact_no",
                          currentValue: workerdata?["contact_no"] ?? "",
                        ),
                        onEditEmail: () => _showEditDialog(
                          title: "Email",
                          field: "email",
                          currentValue: workerdata?["email"] ?? "",
                        ),
                      ),
                      const SizedBox(height: 20),
                      SkillsCard(
                        skills: skills,
                        theme: theme,
                        getTranslation: _getTranslation,
                        onDelete: (skill) async {
                          setState(() => skills.remove(skill));
                          await _updateWorkerProfileField(
                            "skills",
                            skills.toList(),
                          );
                        },
                        onAdd: _addNewSkill,
                      ),
                    ],
                  ),
                ),
              ),
              if (_translationsCache.isEmpty)
                const Positioned.fill(child: WorkerLoaderScreen()),
            ],
          ),
        );
      },
    );
  }
}

// ===================================================================
// --- Reusable Widgets ---
// ===================================================================

class CustomCard extends StatelessWidget {
  final Widget child;
  final ThemeData theme;
  const CustomCard({super.key, required this.child, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ProfileHeaderCard extends StatelessWidget {
  final String userName;
  final String isFullTime;
  final String? profileImageUrl;
  final VoidCallback onEditAvatar;
  final VoidCallback onEditName;
  final ThemeData theme;
  final String Function(String) getTranslation;

  const ProfileHeaderCard({
    super.key,
    required this.userName,
    required this.isFullTime,
    required this.onEditAvatar,
    required this.onEditName,
    required this.theme,
    required this.getTranslation,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      theme: theme,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: theme.colorScheme.outline,
                backgroundImage:
                    profileImageUrl != null && profileImageUrl!.isNotEmpty
                    ? NetworkImage(profileImageUrl!)
                    : const NetworkImage(
                        "https://images.unsplash.com/photo-1519085360753-af025f9e71ce?q=80&w=2670&auto=format&fit=crop",
                      ),
              ),
              InkWell(
                onTap: onEditAvatar,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(
                    Icons.photo_camera,
                    size: 16,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                userName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: onEditName,
                child: Icon(
                  Icons.edit_outlined,
                  size: 30,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: theme.colorScheme.primary,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.work_outline_rounded,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 5),
                Text(
                  isFullTime,
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContactInfoCard extends StatelessWidget {
  final String userPhone;
  final String userEmail;
  final VoidCallback onEditPhone;
  final VoidCallback onEditEmail;
  final ThemeData theme;
  final String Function(String) getTranslation;

  const ContactInfoCard({
    super.key,
    required this.userPhone,
    required this.userEmail,
    required this.onEditPhone,
    required this.onEditEmail,
    required this.theme,
    required this.getTranslation,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            getTranslation("Contact Information"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          Divider(height: 20, color: theme.colorScheme.outline),
          Row(
            children: [
              const Icon(Icons.phone_outlined),
              const SizedBox(width: 5),
              Text(userPhone, style: const TextStyle(fontSize: 18)),
              const Spacer(),
              InkWell(
                onTap: onEditPhone,
                child: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.email_outlined),
              const SizedBox(width: 5),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(userEmail, style: const TextStyle(fontSize: 18)),
                ),
              ),
              InkWell(
                onTap: onEditEmail,
                child: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SkillsCard extends StatelessWidget {
  final Set<String> skills;
  final Function(String) onDelete;
  final VoidCallback onAdd;
  final ThemeData theme;
  final String Function(String) getTranslation;

  const SkillsCard({
    super.key,
    required this.skills,
    required this.onDelete,
    required this.onAdd,
    required this.theme,
    required this.getTranslation,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                getTranslation("Skills & Expertise"),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.add_circle_outline,
                  color: theme.colorScheme.primary,
                ),
                onPressed: onAdd,
              ),
            ],
          ),
          Divider(height: 15, color: theme.colorScheme.outline),
          const SizedBox(height: 5),
          skills.isEmpty
              ? Text(
                  getTranslation(
                    "No skills added yet. Tap '+' to add your expertise.",
                  ),
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                )
              : Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: skills
                      .map(
                        (skill) => Chip(
                          label: Text(getTranslation(skill)),
                          backgroundColor: theme.colorScheme.secondary
                              .withOpacity(0.1),
                          deleteIcon: Icon(
                            Icons.close,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          onDeleted: () => onDelete(skill),
                        ),
                      )
                      .toList(),
                ),
        ],
      ),
    );
  }
}
