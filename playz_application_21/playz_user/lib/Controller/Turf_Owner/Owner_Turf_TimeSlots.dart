import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class TurfSlotService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
    Reference imageRef = storageRef.child('turfs/$sanitizedEmail/IDs/$fileName');

    UploadTask uploadTask = imageRef.putFile(file);
    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    downloadUrls.add(downloadUrl);
  }
  return downloadUrls;
}

  Future<void> saveTurfSlots({
    required Map<String, List<Map<String, dynamic>>> slotsData,
    required String email_ID,
    required String turfName
  }) async {
    try {
      await _firestore.collection('Turf_Owner').doc(email_ID).collection("Turfs").doc(turfName).collection("TimeSlots").add({
        'slots': slotsData,
      });
    } catch (e) {
      throw Exception('Failed to save turf slots: $e');
    }
  }
  Future<void> saveTurfOwnerInfo({
    required String upiId,
    required List<String> idProofUrl,
    required String email_ID,
    required String turfName
  }) async {
    try {
      await _firestore.collection('Turf_Owner').doc(email_ID).collection("Turfs").doc(turfName).update({
        'upiId': upiId,
        'idProofUrl': idProofUrl, 
      });
    } catch (e) {
      throw Exception('Failed to save turf slots: $e');
    }
  }
}
