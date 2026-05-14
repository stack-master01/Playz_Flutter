import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:playz_user/Controller/Trainer_Controller/Trainer_Profile_Controller.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
import 'package:playz_user/View/trainer_view/screen/screens/details_skills_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  File? _selectedImage;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
    }
  }
TextEditingController nameController = TextEditingController();
TextEditingController contactController = TextEditingController();
TextEditingController emailController = TextEditingController();

  void _removeImage() {
    setState(() => _selectedImage = null);
  }
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  "Create your Profile",
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                // Step indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.deepOrange,
                      child: Text("1", style: TextStyle(color: Colors.white)),
                    ),
                    Expanded(
                        child: Divider(color: Colors.grey, thickness: 2)),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.grey,
                      child: Text("2", style: TextStyle(color: Colors.white)),
                    ),
                    Expanded(
                        child: Divider(color: Colors.grey, thickness: 2)),
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.grey,
                      child: Text("3", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Full Name
                const Text(
                  "Full Name",
                  style: TextStyle(
                      color: Colors.deepOrange, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: "Full name",
                    suffixIcon: const Icon(Icons.person_outline,
                        color: Colors.deepOrange),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 20),

                // Phone Number
                const Text(
                  "Phone Number",
                  style: TextStyle(
                      color: Colors.deepOrange, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: contactController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: "Phone Number",
                    suffixIcon: const Icon(Icons.phone_outlined,
                        color: Colors.deepOrange),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 20),

                // Email
                const Text(
                  "Email",
                  style: TextStyle(
                      color: Colors.deepOrange, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    suffixIcon: const Icon(Icons.email_outlined,
                        color: Colors.deepOrange),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 20),

                // Profile image section
                const Text(
                  "Profile image",
                  style: TextStyle(
                      color: Colors.deepOrange, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        style: BorderStyle.solid,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              color: Colors.deepOrange, size: 32),
                          SizedBox(height: 8),
                          Text("Tap to upload images",
                              style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                ),

                if (_selectedImage != null) ...[
                  const SizedBox(height: 12),
                  Stack(
                    children: [
                      Image.file(
                        _selectedImage!,
                        height: 100,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: _removeImage,
                          child: const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.close,
                                size: 18, color: Colors.deepOrange),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 30),

                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                    TrainerSettings trainerSettings = await TrainerSettings().loadSettings();
                    String? downloadURL = await  TrainerProfileController().uploadProfileImage(File(_selectedImage!.path));

                    DocumentReference profileRef = _firestore.collection('Turf_Trainer').doc(trainerSettings.trainerEmail).collection('Trainer_Data').doc('Profile_Data');
                    await profileRef.update({
                      "contact_no":contactController.text.trim(),
                      "email":emailController.text.trim(),
                      "trainer_images":["${downloadURL}"],
                      "trainer_name":nameController.text.trim()
                    });

                     Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DetailsAndSkillsScreen(),
                    ),
                   );
                  },
                    child: const Text(
                      "NEXT",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
