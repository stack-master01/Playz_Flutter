import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';

class TrainerProfileController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseStorage _storage = FirebaseStorage.instance;


  /// Creates the full Profile_Data Object for the Host
  Map<String, dynamic> createProfileObject({
    required String user_name,
    required String user_bio,
    required String image_url,
  }) {
    return {
      "user_name":user_name,
      "user_bio":user_bio,
      "image_url":image_url
    };
  }

  /// Uploads Profile_Data data to Firestore under the user's document
  Future<void> uploadUserProfile(Map<String, dynamic> profileDataObj) async {
    try {
      UserSettings userSettings = await UserSettings().loadSettings();
      String? email = userSettings.email;
      if (email == null) throw Exception("User email not found.");

      await _firestore
          .collection("Turf_User")
          .doc(email)
          .collection("User_Data")
          .doc("Profile_Data")
          .set(profileDataObj);

      log(" Profile_Data successfully uploaded for $email");
    } catch (e, st) {
      log("Failed to upload Profile_Data: $e");
      log("Stacktrace: $st");
      rethrow;
    }
  }


  Future<String?> uploadProfileImage(File file) async {


        try {
      TrainerSettings trainerSettings = await TrainerSettings().loadSettings();
      final email = trainerSettings.trainerEmail!;

      final profileFolderRef =
          _storage.ref().child('Trainer_Data').child(email).child('Profile_Image');

      final listResult = await profileFolderRef.listAll();
      for (var item in listResult.items) {
        await item.delete();
        log("🗑️ Deleted image: ${item.name}");
      }

      log("✅ All images deleted for user: $email");
    } catch (e) {
      log("❌ Failed to delete images: $e");
    }
  


    try {
      // 🔹 Load current user info
      UserSettings userSettings = await UserSettings().loadSettings();
      final email = userSettings.email!;
      log("📤 Starting upload for user: $email");

      // 🔹 Reference to the folder where profile images are stored
      final profileFolderRef =
          _storage.ref().child('Trainer_Data').child(email).child('Profile_Images');

      // 🔹 Delete all old images
      final listResult = await profileFolderRef.listAll();
      for (var item in listResult.items) {
        await item.delete();
        log("🗑️ Deleted old image: ${item.name}");
      }

      // 🔹 Create a new unique file name
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
      final newFileRef = profileFolderRef.child(fileName);

      // 🔹 Upload file
      await newFileRef.putFile(file);
      log("✅ Upload complete: $fileName");

      // 🔹 Get download URL
      final downloadUrl = await newFileRef.getDownloadURL();
      log("🌐 Download URL: $downloadUrl");

      return downloadUrl;
    } catch (e) {
      log("❌ Upload failed: $e");
      return null;
    }
  }

  /// Fetches the list of reviews for the currently signed-in trainer.
  /// Returns an empty list when no reviews are found or on error.
  Future<List<Map<String, dynamic>>> fetchTrainerReviews() async {
    try {
      TrainerSettings trainerSettings = await TrainerSettings().loadSettings();
      final email = trainerSettings.trainerEmail;
      if (email == null || email.isEmpty) {
        log('fetchTrainerReviews: trainer email is null or empty');
        return [];
      }

      final doc = await _firestore
          .collection('Turf_Trainer')
          .doc(email)
          .collection('Trainer_Data')
          .doc('Profile_Data')
          .get();

      if (!doc.exists) return [];
      final data = doc.data();
      if (data == null) return [];

      final reviewsRaw = data['reviews'];
      if (reviewsRaw == null || reviewsRaw is! List) return [];

      final List<Map<String, dynamic>> reviews = [];
      for (var item in reviewsRaw) {
        if (item is Map<String, dynamic>) {
          reviews.add(item);
        } else if (item is Map) {
          reviews.add(Map<String, dynamic>.from(item));
        }
      }

      return reviews;
    } catch (e, st) {
      log('Error fetching trainer reviews: $e');
      log('$st');
      return [];
    }
  }

  
}
