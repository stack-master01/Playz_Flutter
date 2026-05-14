import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';

class HostGameController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  /// Creates the full Solo Queue Object for the Host
  Map<String, dynamic> createSoloQueueObject({
    required String hostName,
    required String hostProfileUrl,
    required String hostEmail,
    required String hostSkillLevel,
    required dynamic hostLevelColor,
    required int hostLevelPercent,
    required String sport,
    required String gameType,
    required String gameAccess,
    required String skillLimit,
    required String price,
    required String totalPlayers,
    required LatLng? selectedLatLng,
    required String? selectedAddress,
    required String date,
    required String time,
    required bool isHost,
    required String playerEmail
    
  }) {
    return {
      "Players": [
        {
          "ishost": isHost,
          "player_email":playerEmail,
          "player_name": hostName,
          "profile_image": hostProfileUrl,
          "skill_level": {
            "skill_color": hostLevelColor,
            "skill_level": hostSkillLevel,
            "skill_level_percent": hostLevelPercent,
          },
        }
      ],
      "solo_Queue_Info": {
        "address": selectedAddress ?? "",
        "applied_players": 1,
        "date": date,
        "game_access": gameAccess,
        "game_type": gameType,
        "host_level_color": hostLevelColor,
        "host_level_percent": hostLevelPercent,
        "host_name": hostName,
        "host_profile_url": hostProfileUrl,
        "host_skill_level": hostSkillLevel,
        "location_latlan": {
          "latitude": selectedLatLng?.latitude.toString(),
          "longitude": selectedLatLng?.longitude.toString(),
        },
        "pay_and_join": true,
        "price": price,
        "skill_limit": skillLimit,
        "sport": sport,
        "time":time,
        "total_players": totalPlayers,
      }
    };
  }

  /// Uploads Solo Game data to Firestore under the user's document
  Future<void> uploadSoloGame(Map<String, dynamic> soloQueueObj) async {
    try {
      UserSettings userSettings = await UserSettings().loadSettings();
      String? email = userSettings.email;
      if (email == null) throw Exception("User email not found.");

      await _firestore
          .collection("Turf_User")
          .doc(email)
          .collection("User_Data")
          .doc("Solo_Games")
          .collection("Solo_Games_List")
          .add(soloQueueObj);

   
    } catch (e, st) {
      log("❌ Failed to upload solo game: $e");
      log("Stacktrace: $st");
      rethrow;
    }
  }
}
