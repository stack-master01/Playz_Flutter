import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';

class OwnerWorkerFetchData {
  static Future<List<Map<String, dynamic>>> getHireNewWorkerData() async {
    List<Map<String, dynamic>> workerNewHireList = [];
    CollectionReference workersCol = FirebaseFirestore.instance.collection(
      'Turf_Worker',
    );
    QuerySnapshot workerHireDetail = await workersCol.get();
    log('workerHireDetail docs: ${workerHireDetail.docs.length}');
    for (var workerDoc in workerHireDetail.docs) {
      String workerEmail = workerDoc.id;
      final profileDocSnap = await FirebaseFirestore.instance
          .collection('Turf_Worker')
          .doc(workerEmail)
          .collection('Worker_Data')
          .doc('Profile_Data')
          .get();

      if (profileDocSnap.exists) {
        workerNewHireList.add(profileDocSnap.data() as Map<String, dynamic>);
      }
    }
    log("List: ${workerNewHireList.length} => $workerNewHireList");
    return workerNewHireList;
  }

  static void setHiredWorker({
    required String? email_ID,
    required String worker_name,
    required String email,
    required int contact_no,
    required String DOB,
    String? worker_profile_image,
    required String worker_upi_id,
    required String worker_gender,
    required List skills
  }) {
    FirebaseFirestore.instance
        .collection('Turf_Owner')
        .doc(email_ID)
        .collection("Worker")
        .doc(email)
        .set({
          'worker_name': worker_name,
          'email': email,
          'contact_no': contact_no,
          'DOB': DOB,
          'worker_upi_id': worker_upi_id,
          'worker_gender': worker_gender,
          'worker_profile_image':
              worker_profile_image ??
              'https://www.shutterstock.com/image-vector/image-icon-architect-engineer-profile-260nw-321183128.jpg',
          'skills':skills    
        });
  }

  
}
