import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';

class UserFriendListController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Creates the full Profile_Data Object for the Host
  Map<String, dynamic> createFriendObject({
    required String email,
    required String image_url,
    required String name,
  }) {
    return {
        "email":email,
        "image_url":image_url,
        "name":name,
      
    };
  }

  // Future<List<Map<String, dynamic>>> fetchAllFriends() async {
  //   List<Map<String, dynamic>> allFriends = [];

  //   try {
  //     // Step 1: Get all user documents under "Turf_User"
  //     final userSnapshot = await _firestore.collection('Turf_User').get();
  //     for (var userDoc in userSnapshot.docs) {
  //       final userEmail = userDoc.id;
  //       log(userEmail);

  //     Map<String,dynamic> turfData = {};
  //       turfData['email'] = userEmail;

  //       allFriends.add(turfData);
  //     }

  //     log("✅ Total friends Fetched: ${allFriends.length}");
  //     log("✅ Total friends Fetched: ${allFriends}");
  //   } catch (e) {
  //     log("❌ Error fetching friends: $e");
  //   }

  //   return allFriends;
  // }

  Future<void> uploadFriendData(Map<String, dynamic> friendObject) async {
    UserSettings userSettings = await UserSettings().loadSettings();
   try {
      // 1. Target the specific document
      DocumentReference docRef = _firestore
          .collection("Turf_User")
          .doc(userSettings.email)
          .collection("User_Data")
          .doc("Friends");

      // 2. Perform the update using arrayUnion
      await docRef.update(
        {
          // Add the friendObject to the 'friend_list' array. 
          // arrayUnion prevents duplicates.
          'friend_list': FieldValue.arrayUnion([friendObject])
        },
      );

      log("Friend data appended (union) to Firestore: $friendObject");
    } on FirebaseException catch (e) {
      // Handle the case where the document might not exist yet (error code: 'not-found')
      if (e.code == 'not-found') {
        log("Friends document not found. Using .set() with merge to create it and the array.");
        
        // If the document doesn't exist, use .set() with merge: true to create the 'friend_list' array.
        await _firestore
            .collection("Turf_User")
            .doc(userSettings.email)
            .collection("User_Data")
            .doc("Friends")
            .set(
              { 'friend_list': [friendObject] },
              SetOptions(merge: true) // merge: true ensures only 'friend_list' is created/set.
            );
        log("Friend data created and uploaded: $friendObject");
      } else {
        log("Failed to append friend data: $e");
        rethrow;
      }
    } catch (e) {
      log("An unexpected error occurred: $e");
      rethrow;
    }
  }
  


  Future<List<Map<String, dynamic>>> fetchFriendList() async {
    List<Map<String, dynamic>> allFriendList = [];

    try {
      // Step 1: Get all user documents under "Turf_User"
      final userSnapshot = await _firestore.collection('Turf_User').get();
      for (var userDoc in userSnapshot.docs) {
        final userEmail = userDoc.id;

        final friendsRef = _firestore
            .collection('Turf_User')
            .doc(userEmail)
            .collection('User_Data')
            .doc('Friends');

        final allFriendsSnapshot = await friendsRef.get();

        Map<String, dynamic>? turfData = allFriendsSnapshot.data();


        allFriendList.add(turfData ?? {});
      }

    } catch (e) {
      log("❌ Error fetching friends: $e");
    }

    return allFriendList;
  }


  Future<List<Map<String, dynamic>>> fetchAllFriends() async {
    List<Map<String, dynamic>> allFriends = [];

    try {
      // Step 1: Get all user documents under "Turf_User"
      final userSnapshot = await _firestore.collection('Turf_User').get();
      for (var userDoc in userSnapshot.docs) {
        final userEmail = userDoc.id;
        log(userEmail);

        final friendsRef = _firestore
            .collection('Turf_User')
            .doc(userEmail)
            .collection('User_Data')
            .doc('Profile_Data');

        final allFriendsSnapshot = await friendsRef.get();

        Map<String, dynamic>? turfData = allFriendsSnapshot.data();
        // keep track of which user it came from
        turfData?['email'] = userEmail;
        turfData?['image_url'] = turfData['image_url'];
        turfData?['name'] = turfData['user_name'];

        allFriends.add(turfData ?? {});
      }

      log("✅ Total friends Fetched: ${allFriends.length}");
      log("✅ Total friends Fetched: ${allFriends}");
    } catch (e) {
      log("❌ Error fetching friends: $e");
    }

    return allFriends;
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
