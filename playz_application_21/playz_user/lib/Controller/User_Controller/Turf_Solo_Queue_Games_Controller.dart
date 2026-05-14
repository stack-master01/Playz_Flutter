import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class TurfSoloGamesController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all Solo Games from every user's Solo_Games_List
  Future<List<Map<String, dynamic>>> fetchAllSoloGames() async {
    List<Map<String, dynamic>> allGames = [];

    try {
      // Step 1: Get all user documents under "Turf_User"
      final userSnapshot = await _firestore.collection('Turf_User').get();
// UserSettings userSettings = await UserSettings().loadSettings();
      for (var userDoc in userSnapshot.docs) {
        final userEmail = userDoc.id;

        // Step 2: Go deep into each user's Solo_Games_List collection
        final soloGamesRef =  _firestore
            .collection('Turf_User')
            .doc(userEmail)
            .collection('User_Data')
            .doc('Solo_Games')
            .collection('Solo_Games_List');

        final soloGamesSnapshot = await soloGamesRef.get();

        for (var gameDoc in soloGamesSnapshot.docs) {
          final gameData = gameDoc.data();
          gameData['gameId'] = gameDoc.id;
          gameData['userEmail'] = userEmail;
           // keep track of which user it came from
          allGames.add(gameData);
        }
      }



    } catch (e) {
      log("❌ Error fetching Solo Games: $e");
    }

    return allGames;
  }
}
