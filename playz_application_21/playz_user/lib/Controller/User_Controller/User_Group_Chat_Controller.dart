import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';

class UserGroupChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Creates the full Profile_Data Object for the Host
  Map<String, dynamic> createGroupChatObject({
    required DateTime created_at,
    required String from_id,
    required String from_name,
    required String image_url,
    required bool is_image,
    required String text,
  }) {
    return {
      "created_at": created_at,
      "from_id": from_id,
      "from_name": from_name,
      "image_url": image_url,
      "is_image": is_image,
      "text": text,
    };
  }

  // /// Uploads Profile_Data data to Firestore under the user's document
  // Future<void> uploadGroupChat(
  //   Map<String, dynamic> groupChatObject, {
  //   required String groupId,
  // }) async {
  //   try {
  //     UserSettings userSettings = await UserSettings().loadSettings();
  //     String? email = userSettings.email;
  //     if (email == null) throw Exception("User email not found.");

  //     await _firestore
  //         .collection("Turf_User")
  //         .doc(email)
  //         .collection("User_Data")
  //         .doc("Groups")
  //         .collection("My_Group_List")
  //         .doc(groupId)
  //         .collection("Messages")
  //         .doc()
  //         .set(groupChatObject);

  //     log(" Group data successfully uploaded for $email");
  //   } catch (e, st) {
  //     log("Failed to upload Profile_Data: $e");
  //     log("Stacktrace: $st");
  //     rethrow;
  //   }
  // }

// User_Group_Chat_Controller.dart

Future<void> uploadGroupChat(
    Map<String, dynamic> groupChatObject, {
    required String groupId,
}) async {
    try {
        await _firestore
            .collection("groups") // Central Collection
            .doc(groupId)
            .collection("messages") // Shared messages for this group
            .doc()
            .set(groupChatObject);

        log("Group message successfully uploaded to centralized chat: $groupId");
    } catch (e) {
        log("Failed to upload group chat message: $e");
        rethrow;
    }
}

  Future<String?> uploadGroupChatImage(
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



  

  // Future<List<Map<String, dynamic>>> fetchAllChats({
  //   required String groupId,
  // }) async {
  //   List<Map<String, dynamic>> allChats = [];

  //   try {
  //     // Step 1: Get all user documents under "Turf_User"
  //     final userSnapshot = await _firestore.collection('Turf_User').get();
  //     // UserSettings userSettings = await UserSettings().loadSettings();
  //     for (var userDoc in userSnapshot.docs) {
  //       final userEmail = userDoc.id;
  //       log("fetch group email: $userEmail");

  //       // Step 2: Go deep into each user's Solo_Games_List collection
  //       final groupsRef = _firestore
  //           .collection('Turf_User')
  //           .doc(userEmail)
  //           .collection('User_Data')
  //           .doc('Groups')
  //           .collection('My_Group_List')
  //           .doc(groupId)
  //           .collection("Messages");

  //       final groupsSnapshot = await groupsRef.get();

  //       for (var chatDoc in groupsSnapshot.docs) {
  //         final chatData = chatDoc.data();
  //         chatData['chatId'] = chatDoc.id;

  //         // keep track of which user it came from
  //         allChats.add(chatData);
  //         log("chat data: $chatData");
  //       }
  //     }

  //     log("✅ Total  chats Fetched: ${allChats.length}");
  //     log("✅ Total  chats Fetched: ${allChats}");
  //   } catch (e) {
  //     log("❌ Error fetching chats: $e");
  //   }

  //   return allChats;
  // }


// User_Group_Chat_Controller.dart

Stream<List<Map<String, dynamic>>> streamCentralGroupChats({
    required String groupId,
}) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('created_at', descending: false) // Efficient single query
        .snapshots() // The single, dynamic stream
        .map((snapshot) {
            return snapshot.docs.map((doc) {
                final data = doc.data();
                data['chatId'] = doc.id;
                return data;
            }).toList();
        });
}

}
