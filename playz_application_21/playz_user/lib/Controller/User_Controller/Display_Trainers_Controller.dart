import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisplayTrainersController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fetch all Solo Games from every user's Solo_Games_List
  Future<List<Map<String, dynamic>>> fetchAlltrainer() async {
    List<Map<String, dynamic>> alltrainer = [];

    try {
      // Step 1: Get all user documents under "Turf_User"
      final userSnapshot = await _firestore.collection('Turf_Trainer').get();
      for (var userDoc in userSnapshot.docs) {
        final userEmail = userDoc.id;

        final trainerRef = _firestore
            .collection('Turf_Trainer')
            .doc(userEmail)
            .collection('Trainer_Data')
            .doc('Profile_Data');

        final alltrainerSnapshot = await trainerRef.get();

          final turfData = alltrainerSnapshot.data();
          // keep track of which user it came from
         
          alltrainer.add(turfData!);
        
      }

    } catch (e) {
      log("❌ Error fetching trainer: $e");
    }

    return alltrainer;
  }
}
