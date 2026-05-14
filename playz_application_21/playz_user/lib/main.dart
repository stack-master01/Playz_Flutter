import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/View/splashScreen.dart';
import 'package:playz_user/View/user_view/home(sport)/Bookings/Bookqr(sport).dart';
import 'package:playz_user/View/user_view/navigation(sport).dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
    apiKey: "AIzaSyDL9_LyheV1-s9sSBX4nTFB2q_mZIBWu0w",
    appId: "1:1095969048979:android:20b842f94a32707a8cc066",
    messagingSenderId: "1095969048979",
    projectId: "stack-smasher-playz")
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      routes: {
  '/userNavigation': (_) => NavigationSport(), // your bottom navigation page
  // other routes
},
      debugShowCheckedModeBanner: false,
      home: SplashScreen());
  }
}