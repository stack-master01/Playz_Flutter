import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisplayTurfController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all Solo Games from every user's Solo_Games_List
  Future<List<Map<String, dynamic>>> fetchAllTurfs() async {
    List<Map<String, dynamic>> allTurfs = [];

    try {
      // Step 1: Get all user documents under "Turf_User"
      final userSnapshot = await _firestore.collection('Turf_Owner').get();
      for (var userDoc in userSnapshot.docs) {
        final userEmail = userDoc.id;

        final turfsRef = _firestore
            .collection('Turf_Owner')
            .doc(userEmail)
            .collection('Turfs');

        final allTurfsSnapshot = await turfsRef.get();

        for (var turfDoc in allTurfsSnapshot.docs) {
          final turfData = turfDoc.data();
          // keep track of which user it came from
          turfData['userEmail'] = userEmail;
          turfData['turfID'] = turfDoc.id;
          allTurfs.add(turfData);
        }
      }

   
    } catch (e) {
      log("❌ Error fetching turfs: $e");
    }

    return allTurfs;
  }
}
