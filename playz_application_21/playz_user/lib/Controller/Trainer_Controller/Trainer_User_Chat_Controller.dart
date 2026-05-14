import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';

class TrainerUserChatController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Creates the full Profile_Data Object for the Host
  Map<String, dynamic> createProfileObject({
    required String user_name,
    required String user_bio,
    required String image_url,
  }) {
    return {
      "user_name": user_name,
      "user_bio": user_bio,
      "image_url": image_url,
    };
  }

  /// Uploads Profile_Data data to Firestore under the user's document
  Future<List<Map<String, dynamic>>> fetchAllStudents() async {
    List<Map<String, dynamic>> allGames = [];
    TrainerSettings trainerSettings = await TrainerSettings().loadSettings();
    try {
      // Step 1: Get all user documents under "Turf_User"
      final userSnapshot = await _firestore
          .collection('Turf_Trainer')
          .doc(trainerSettings.trainerEmail)
          .collection('Students_List')
          .get();
      // UserSettings userSettings = await UserSettings().loadSettings();
      for (var userDoc in userSnapshot.docs) {
        final userSport = userDoc.id;
        log(userSport);

        // Step 2: Go deep into each user's Solo_Games_List collection
        final soloGamesRef = _firestore
            .collection('Turf_Trainer')
            .doc(trainerSettings.trainerEmail)
            .collection('Students_List')
            .doc(userSport);

        final soloGamesSnapshot = await soloGamesRef.get();

          final gameData = soloGamesSnapshot.data();
          gameData?['gameId'] = soloGamesSnapshot.id;
          gameData?['userSport'] = userSport;
          // keep track of which user it came from
          allGames.add(gameData!);
        
      }

      log("✅ Total Solo Games Fetched: ${allGames.length}");
      log("✅ Total Solo Games Fetched: ${allGames}");
    } catch (e) {
      log("❌ Error fetching Solo Games: $e");
    }

    return allGames;
  }
}
