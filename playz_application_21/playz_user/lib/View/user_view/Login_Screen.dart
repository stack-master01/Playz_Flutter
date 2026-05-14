import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // Required for Timer
import 'dart:math' hide log; // Required for Random/shuffling
import 'dart:developer'; // Added for logging Firebase errors
import 'package:firebase_auth/firebase_auth.dart'; // ADDED FIREBASE AUTH
import 'package:playz_user/Helper/User_Loader.dart';

// Assuming these are your local imports
import 'package:playz_user/View/user_view/ForgotPassword_Screen.dart';
import 'package:playz_user/View/user_view/Register_Screen.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/user_view/navigation(sport).dart';
import 'package:playz_user/View/user_view/reusable.dart';

class UserLoginScreen extends StatefulWidget {
  const UserLoginScreen({super.key});

  @override
  State<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends State<UserLoginScreen> {
  bool _isLoading = false;

  // ------------------------------------------------------------------
  // Firebase Initialization
  // ------------------------------------------------------------------
  final FirebaseAuth _firebaseAuth =
      FirebaseAuth.instance; // Initialize Firebase Auth

  // --- 1. List of Network Image URLs ---
  final List<String> _networkBackgroundUrls = [
    "https://plus.unsplash.com/premium_photo-1722351690065-210079a0a82c?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8Y3JpY2tldCUyMHBsYXllcnxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500",
    "https://images.unsplash.com/photo-1610736342165-4eeb4aef66ca?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8Zm9vdGJhbGwlMjBwbGF5ZXJ8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=500",
    "https://images.unsplash.com/photo-1720515226352-b0b1dec6813b?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8YmFkbWludG9uJTIwcGxheWVyfGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=500",
    "https://images.unsplash.com/photo-1584992120020-defa7d36fdfb?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fGJhc2tldGJhbGwlMjBwbGF5ZXJ8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=500",
    "https://images.unsplash.com/photo-1614743758466-e569f4791116?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8dGVubmlzJTIwcGxheWVyfGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=500",
    "https://plus.unsplash.com/premium_photo-1664297510120-354f5adbb9eb?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTN8fHJ1bm5pbmclMjByYWNlfGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=500",
  ];

  // --- 2. State & Timer Variables ---
  int _currentIndex = 0;
  Timer? _timer;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _startBackgroundChangeTimer();
  }

  // --- 3. Timer Logic for Background Change ---
  void _startBackgroundChangeTimer() {
    _networkBackgroundUrls.shuffle(Random());

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % _networkBackgroundUrls.length;
        });
      }
    });
  }
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- Helper for Snackbar ---
  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ------------------------------------------------------------------
  // Firebase Login Logic (Replaces the old _handleLogin)
  // ------------------------------------------------------------------
  Future<void> _handleLogin() async {
    // 1. Validate form fields first (using the Form Key for built-in validation)
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showSnackbar('Please enter valid email and password.', Colors.red);
      return;
    }

    final String email = _emailController.text.trim();
    final String passwordInput = _passwordController.text.trim();
    setState(() => _isLoading = true);
    try {
      // **CRITICAL STEP:** Modify password as seen in the original Firebase code
      // This suggests the password is stored with a static suffix for turf user.
      String modifiedPassword = "${passwordInput}Turf_User";

      // 2. Authenticate the user with Firebase Email and Password
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: modifiedPassword);

      log("User Logged In: ${userCredential.user?.uid}");
      log("User Email: ${userCredential.user?.email}");
      log("User Password: $modifiedPassword");

      UserSettings.saveEmail(userCredential.user?.email ?? '');
      UserSettings.saveUserId(userCredential.user?.uid ?? '');
      UserSettings.saveIsLoggedIn(true);

      final userDoc = await _firestore.collection('Turf_User')
      .doc(email)
      .collection('User_Data')
      .doc('Profile_Data').get();

      final userMap = userDoc.data();
      UserSettings.saveUserBio(userMap?['user_bio'] ?? "Bio");
      UserSettings.saveUserName(userMap?['user_name'] ?? "New User");
      UserSettings.saveUserProfileImageURL(userMap?['image_url'] ?? "https://t3.ftcdn.net/jpg/07/24/59/76/360_F_724597608_pmo5BsVumFcFyHJKlASG2Y2KpkkfiYUU.jpg");

      // 3. Success Handling
      _showSnackbar("Login Successfully", Reusable.getGreen());
      _emailController.clear();
      _passwordController.clear();

      // Navigate to the main application screen (NavigationSport)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NavigationSport()),
      );
    } on FirebaseAuthException catch (error) {
      log("Login Error Code: ${error.code}");
      log("Login Error Message: ${error.message}");

      // 4. Error Handling
      String message = error.message ?? 'An unknown login error occurred.';
      _showSnackbar(message, Colors.red);
    } catch (e) {
      log("General Login Error: $e");
      _showSnackbar(
        "An unexpected error occurred. Please try again.",
        Colors.red,
      );
    } finally {
      setState(() => _isLoading = false); // 📴 Hide loader
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _goToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const UserRegisterScreen()),
    );
  }

  void _goToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const UserForgotPasswordScreen()),
    );
  }

  // ------------------------------------------------------------------
  // 5. Build Method (UI remains unchanged)
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background Image Layer
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            key: ValueKey<int>(_currentIndex),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(_networkBackgroundUrls[_currentIndex]),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.55),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),

          // 2. Foreground Content Layer
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 40.0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Title (White for contrast) ---
                      const SizedBox(height: 40),
                      const Text(
                        "Welcome Back",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Sign in to continue your adventure.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 50),

                      // --- Email Field ---
                      _buildInputField(
                        controller: _emailController,
                        label: "Email ID",
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      // --- Password Field ---
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        style: const TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Reusable.getGreen(),
                          ),
                          hintText: "Password",
                          labelStyle: const TextStyle(
                            color: Color.fromARGB(255, 80, 80, 80),
                          ),
                          hintStyle: const TextStyle(color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Reusable.getGreen(),
                              width: 2,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Reusable.getGreen(),
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // --- Forgot Password ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _goToForgotPassword,
                          child: const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // --- Login Button ---
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed:
                              _handleLogin, // Calls the Firebase Login Logic
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Reusable.getGreen(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // --- Register Link ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _goToRegister,
                            child: Text(
                              "Register Now",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Reusable.getGreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) UserLoaderScreen(),
        ],
      ),
    );
  }

  // 6. Extracted function for a reusable input field (Unchanged)
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Reusable.getGreen()),
        hintText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Reusable.getGreen(), width: 2),
        ),
      ),
    );
  }
}
