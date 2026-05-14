import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';

class UserSendBookingController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Creates the full Profile_Data Object for the Host
  Map<String, dynamic> createBookingObject({
    required String day_date,
    required String payment_status,
    required String qr_code_text,
    required String sport,
    required String time,
    required String user_name,
  }) {
    return {
      "day_date": day_date,
      "payment_status": payment_status,
      "qr_code_text": qr_code_text,
      "sport": sport,
      "time": time,
      "user_name": user_name,
    };
  }

  /// Uploads Profile_Data data to Firestore under the user's document
  Future<void> uploadUserBooking(
    Map<String, dynamic> bookDataObj,
    String ownerEmail,
    String turfName,
  ) async {
    try {
      await _firestore
          .collection("Turf_Owner")
          .doc(ownerEmail)
          .collection("Turfs")
          .doc(turfName)
          .collection("Booking")
          .doc()
          .set(bookDataObj);

      log(" book data successfully uploaded for $ownerEmail");
    } catch (e, st) {
      log("Failed to upload Profile_Data: $e");
      log("Stacktrace: $st");
      rethrow;
    }
  }

  Future<String?> uploadGroupProfileImage(
    File file, {
    required String groupName,
  }) async {
    try {
      UserSettings userSettings = await UserSettings().loadSettings();
      final email = userSettings.email!;

      final profileFolderRef = _storage
          .ref()
          .child('User_Data')
          .child(email)
          .child('Groups')
          .child(groupName)
          .child('Group_Profile_Image');

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
      final profileFolderRef = _storage
          .ref()
          .child('User_Data')
          .child(email)
          .child('Groups')
          .child(groupName)
          .child('Group_Profile_Image');

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

  Future<List<Map<String, dynamic>>> fetchAllBookData() async {
    List<Map<String, dynamic>> allGroups = [];
    OwnerSettings ownerSettings = await OwnerSettings().loadSettings();
    log("owner email: ${ownerSettings.ownerEmail}");

    try {
      // Step 1: Get all user documents under "Turf_User"
      final userSnapshot = await _firestore
          .collection('Turf_Owner')
          .doc(ownerSettings.ownerEmail)
          .collection("Turfs")
          .get();
      // UserSettings userSettings = await UserSettings().loadSettings();
      for (var userDoc in userSnapshot.docs) {
        final turfName = userDoc.id;

        final friendsRef = await _firestore
            .collection('Turf_Owner')
            .doc(ownerSettings.ownerEmail)
            .collection("Turfs")
            .doc(turfName)
            .collection('Booking')
            .get();

        for (var userDoc in friendsRef.docs) {
          final groupData = userDoc.data();
          groupData['bookingId'] = userDoc.id;

          // keep track of which user it came from
          allGroups.add(groupData);
          log("bookings data: $groupData");
        }
      }

    } catch (e) {
      log("❌ Error fetching bookings: $e");
    }

    return allGroups;
  }
}
