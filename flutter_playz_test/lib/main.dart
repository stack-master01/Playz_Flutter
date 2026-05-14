import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter_playz_test/services/storage_service.dart';
import 'package:flutter_playz_test/services/notification_service.dart';
import 'package:flutter_playz_test/controllers/user_controller.dart';
import 'package:flutter_playz_test/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Critical Local Setup (Extremely fast)
  await StorageService.init();
  
  // 2. Global State Injection
  Get.put(UserController());

  // 3. Non-blocking Network & Plugin Initialization
  // By NOT awaiting this directly here, we guarantee runApp fires instantly,
  // completely eliminating any possibility of a black screen hang.
  _initHeavyServices();

  runApp(const MyApp());
}

Future<void> _initHeavyServices() async {
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAeP3zXsut8YWKAsrMaRsX21qup-DLwwac",
        appId: "1:1022281600399:android:9f59cd9ba22fbf29e0cffa",
        messagingSenderId: "1022281600399",
        projectId: "playztest",
        storageBucket: "playztest.firebasestorage.app",
      ),
    );
    await NotificationService().init();
  } catch (e) {
    debugPrint("Background Service Init Error: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use GetMaterialApp so GetX navigation/snackbars work
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PLAYZ',
      home: const SplashScreen(),
    );
  }
}