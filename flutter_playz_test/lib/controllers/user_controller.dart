import 'package:get/get.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_playz_test/services/storage_service.dart';

/// Global reactive user state managed by GetX.
/// Register once with: Get.put(UserController());
class UserController extends GetxController {
  // ── Reactive fields ──────────────────────────────────────────────
  final RxString email    = ''.obs;
  final RxString phone    = ''.obs;
  final RxString password = ''.obs;
  final RxString name     = ''.obs;

  // ── Lifecycle ────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  /// Hydrate reactive vars from SharedPreferences on startup.
  void _loadFromStorage() {
    email.value    = StorageService.email;
    phone.value    = StorageService.phone;
    password.value = StorageService.password;
    name.value     = StorageService.name;
  }

  // ── Public API ───────────────────────────────────────────────────

  /// Called after login or registration.
  Future<void> setUser({
    String email = '',
    String phone = '',
    String password = '',
    String name = '',
  }) async {
    String userOtp = StorageService.userOtp;
    
    String finalEmail = email;
    String finalPhone = phone;
    String finalName = name;

    // Fetch from Firestore using UID for scalability
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final uid = user.uid;
        final docRef = FirebaseFirestore.instance.collection('test_data').doc(uid);
        
        // OPTIMIZATION: If logging in with phone, check for existing account with this phone number
        if (finalPhone.isNotEmpty) {
          final phoneQuery = await FirebaseFirestore.instance
              .collection('test_data')
              .where('phone_no', isEqualTo: finalPhone)
              .limit(1)
              .get();
              
          if (phoneQuery.docs.isNotEmpty) {
            final matchData = phoneQuery.docs.first.data();
            if (finalEmail.isEmpty && matchData.containsKey('email')) {
              finalEmail = matchData['email'] ?? '';
            }
            if (finalName.isEmpty && matchData.containsKey('name')) {
              finalName = matchData['name'] ?? '';
            }
            if (matchData.containsKey('userOtp') && matchData['userOtp'] != null) {
              userOtp = matchData['userOtp'];
            }
          }
        }

        final snapshot = await docRef.get();

        if (snapshot.exists) {
          final data = snapshot.data()!;
          
          if (data.containsKey('userOtp') && data['userOtp'] != null) {
            userOtp = data['userOtp'];
          } else {
            if (userOtp == StorageService.userOtp || userOtp.isEmpty) {
              final rnd = Random();
              userOtp = (rnd.nextInt(900000) + 100000).toString();
            }
            await docRef.set({'userOtp': userOtp}, SetOptions(merge: true));
          }

          if (finalEmail.isEmpty && data.containsKey('email')) finalEmail = data['email'] ?? '';
          if (finalPhone.isEmpty && data.containsKey('phone_no')) finalPhone = data['phone_no'] ?? '';
          if (finalName.isEmpty && data.containsKey('name')) finalName = data['name'] ?? '';

          final updates = <String, dynamic>{};
          if (finalEmail.isNotEmpty) updates['email'] = finalEmail;
          if (finalPhone.isNotEmpty) updates['phone_no'] = finalPhone;
          if (finalName.isNotEmpty) updates['name'] = finalName;
          if (updates.isNotEmpty) {
            await docRef.set(updates, SetOptions(merge: true));
          }
        } else {
          if (userOtp == StorageService.userOtp || userOtp.isEmpty) {
            final rnd = Random();
            userOtp = (rnd.nextInt(900000) + 100000).toString();
          }
          await docRef.set({
            'email': finalEmail,
            'phone_no': finalPhone,
            'name': finalName,
            'userOtp': userOtp,
          }, SetOptions(merge: true));
        }
      } catch (e) {
        // Fallback for network timeouts or offline mode: Generate OTP locally so SharedPreferences works.
        debugPrint('Firestore sync failed: $e');
        if (userOtp.isEmpty || userOtp == StorageService.userOtp) {
          final rnd = Random();
          userOtp = (rnd.nextInt(900000) + 100000).toString();
        }
      }
    }

    this.email.value    = finalEmail;
    this.phone.value    = finalPhone;
    this.password.value = password;
    this.name.value     = finalName;

    await StorageService.saveUser(
      email: finalEmail,
      phone: finalPhone,
      password: password,
      name: finalName,
      userOtp: userOtp,
    );
  }

  /// Update email only (from Edit Profile) and sync to Firebase.
  Future<void> updateEmail(String newEmail) async {
    email.value = newEmail;
    await StorageService.setEmail(newEmail);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('test_data').doc(user.uid).set(
          {'email': newEmail}, SetOptions(merge: true)
        );
      } catch (e) {
        debugPrint('Firestore updateEmail failed: $e');
      }
    }
  }

  /// Update phone only (from Edit Profile) and sync to Firebase.
  Future<void> updatePhone(String newPhone) async {
    phone.value = newPhone;
    await StorageService.setPhone(newPhone);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('test_data').doc(user.uid).set(
          {'phone_no': newPhone}, SetOptions(merge: true)
        );
      } catch (e) {
        debugPrint('Firestore updatePhone failed: $e');
      }
    }
  }

  /// Update name only (from Edit Profile) and sync to Firebase.
  Future<void> updateName(String newName) async {
    name.value = newName;
    await StorageService.setName(newName);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('test_data').doc(user.uid).set(
          {'name': newName}, SetOptions(merge: true)
        );
      } catch (e) {
        debugPrint('Firestore updateName failed: $e');
      }
    }
  }

  /// Clears all user state and SharedPreferences on logout.
  Future<void> logout() async {
    email.value    = '';
    phone.value    = '';
    password.value = '';
    name.value     = '';
    await StorageService.clearUser();
  }

  /// Convenience getter — true if any credential is stored.
  bool get isLoggedIn => email.value.isNotEmpty || phone.value.isNotEmpty;
}
