import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';

class EditTurfDataController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchTurfData({required String turfName}) async {
    OwnerSettings ownerSettings = await OwnerSettings().loadSettings();
    List<Map<String, dynamic>> allData = [];

    try {
      // Step 1: Get all user documents under "Turf_User"
      final userSnapshot = await _firestore.collection('Turf_Owner')
      .doc(ownerSettings.ownerEmail)
      .collection('Turfs')
      .doc(turfName)
      .get();

      final turfData = userSnapshot.data();



          // keep track of which user it came from
          allData.add(turfData!);
        
      

      log("✅ Total turf data Fetched: ${allData.length}");
      log("✅ Total turf data Fetched: ${allData}");
    } catch (e) {
      log("❌ Error fetching turf data: $e");
    }

    return allData;
  }
}