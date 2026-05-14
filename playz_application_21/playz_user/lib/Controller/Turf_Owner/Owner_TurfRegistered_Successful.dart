import 'package:cloud_firestore/cloud_firestore.dart';

class OwnerTurfregisteredSuccessful {
  //FireStore
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Future<QuerySnapshot<Object?>> getTurfData(String? email_ID)async{
    QuerySnapshot firebaseTurfNameData = await _firebaseFirestore.collection("Turf_Owner").doc(email_ID).collection("Turfs").get();
    return firebaseTurfNameData;
  }
}