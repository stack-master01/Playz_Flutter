import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class OwnerRegisterController {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Future<List<String>> uploadImages(List<XFile> images, String ownerEmail) async {
  List<String> downloadUrls = [];
  final storageRef = FirebaseStorage.instance.ref();

  // Sanitize the owner email for folder naming
  String sanitizedEmail = ownerEmail.replaceAll(RegExp(r'[^\w]'), '_');

  for (int i = 0; i < images.length; i++) {
    File file = File(images[i].path);

    // Construct file name with index and timestamp for uniqueness and order
    String fileName = "image_${i + 1}_${DateTime.now().millisecondsSinceEpoch}.jpg";

    // Use folder structure with owner email
    Reference imageRef = storageRef.child('turfs/$sanitizedEmail/$fileName');

    UploadTask uploadTask = imageRef.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    downloadUrls.add(downloadUrl);
  }
  return downloadUrls;
}
void saveTurfData({required String turfName, required String turfDescription, required List<String> imageUrls,required String email_ID}) {
  FirebaseFirestore.instance.collection('Turf_Owner').doc(email_ID).collection("Turfs").doc(turfName).set({'turfName':turfName,'turfDescription':turfDescription,'turfImages':imageUrls,});
}
void updateTurfData({required String turfName, required String turfDescription, required List<String> imageUrls,required String email_ID}) {
  FirebaseFirestore.instance.collection('Turf_Owner').doc(email_ID).collection("Turfs").doc(turfName).update({'turfName':turfName,'turfDescription':turfDescription,'turfImages':imageUrls,});
}
}