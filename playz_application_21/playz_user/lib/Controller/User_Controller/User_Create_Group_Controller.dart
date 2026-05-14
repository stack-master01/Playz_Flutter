import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';

class UserCreateGroupController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseStorage _storage = FirebaseStorage.instance;


  /// Creates the full Profile_Data Object for the Host
  Map<String, dynamic> createGroupObject({
    required DateTime created_at,
    required String created_by,
    required String group_description,
    required List<Map<String,dynamic>> group_members,
    required String group_name,
    required String group_profile_url,
        required String group_location

    
  }) {
    return {
      "created_at":created_at,
      "created_by":created_by,
      "group_description":group_description,
      "group_members":group_members,
      "group_name":group_name,
      "group_profile_url":group_profile_url,
      "group_location":group_location
      
    };
  }

  /// Uploads Profile_Data data to Firestore under the user's document
  Future<void> uploadUserGroup(Map<String, dynamic> groupDataObj) async {
    try {
      UserSettings userSettings = await UserSettings().loadSettings();
      String? email = userSettings.email;
      if (email == null) throw Exception("User email not found.");

      await _firestore
          .collection("groups")
          .doc()
          .set(groupDataObj);

    } catch (e, st) {
      log("Failed to upload Profile_Data: $e");
      log("Stacktrace: $st");
      rethrow;
    }
  }


  Future<String?> uploadGroupProfileImage(File file,{required String groupName}) async {


        try {
      UserSettings userSettings = await UserSettings().loadSettings();
      final email = userSettings.email!;

      final profileFolderRef =
          _storage.ref().child('User_Data').child(email).child('Groups').child(groupName).child('Group_Profile_Image');

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
          _storage.ref().child('User_Data').child(email).child('Groups').child(groupName).child('Group_Profile_Image');

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


    Future<List<Map<String, dynamic>>> fetchAllGroups() async {
    List<Map<String, dynamic>> allGroups = [];

    try {
      // Step 1: Get all user documents under "Turf_User"
      final userSnapshot = await _firestore.collection('groups').get();
// UserSettings userSettings = await UserSettings().loadSettings();
      for (var userDoc in userSnapshot.docs) {
        

          final groupData = userDoc.data();
          groupData['groupId'] = userDoc.id;
           // keep track of which user it came from
          allGroups.add(groupData);
          log("Group data: $groupData");
        
      }

      log("✅ Total  Groups Fetched: ${allGroups.length}");
      log("✅ Total  Groups Fetched: ${allGroups}");

    } catch (e) {
      log("❌ Error fetching Groups: $e");
    }

    return allGroups;
  }

  
}
