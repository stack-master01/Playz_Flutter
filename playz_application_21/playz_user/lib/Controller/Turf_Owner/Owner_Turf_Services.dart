import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TurfService {
  Future<void> saveTurfDetails({
    required BuildContext context,
    required List<String> sports,
    required List<String> amenities,
    required String address,
    required double latitude,
    required double longitude,
    required String email_ID,
    required String turfName
  }) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    // Save to Firestore
    try {
      await _firestore.collection('Turf_Owner').doc(email_ID).collection("Turfs").doc(turfName).update({
        'sports': sports,
        'amenities': amenities,
        'location': {
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
        },
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Turf details saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save turf details: $e')),
      );
    }
  }
}
