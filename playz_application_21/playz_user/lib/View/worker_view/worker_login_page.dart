import 'package:flutter/material.dart';
import 'dart:async'; // Required for Timer
import 'dart:math' hide log; // Required for Random/shuffling
import 'dart:developer'; // Added for logging Firebase errors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';
import 'package:playz_user/View/worker_view/workerForgotPassword_Screen.dart';
import 'package:playz_user/View/worker_view/worker_navigator_page.dart';
import 'package:playz_user/View/worker_view/worker_register_page.dart'; // ADDED FIREBASE AUTH

// Assuming these are your local imports

class WorkerLoginScreen extends StatefulWidget {
  const WorkerLoginScreen({super.key});

  @override
  State<WorkerLoginScreen> createState() => _WorkerLoginScreenState();
}

class _WorkerLoginScreenState extends State<WorkerLoginScreen> {
  // ------------------------------------------------------------------
  // Firebase Initialization
  // ------------------------------------------------------------------
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Initialize Firebase Auth

  // --- 1. List of Network Image URLs ---
  final List<String> _networkBackgroundUrls = [
    "https://plus.unsplash.com/premium_photo-1669904021308-567d085a0ee7?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8d29ya2luZ3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500",
    "https://plus.unsplash.com/premium_photo-1669904021345-2a95691cb188?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDEwfHx8ZW58MHx8fHx8&auto=format&fit=crop&q=60&w=500",
   "https://plus.unsplash.com/premium_photo-1669904021811-8ef2141ce37c?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=688"
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

    try {
      // **CRITICAL STEP:** Modify password as seen in the original Firebase code
      // This suggests the password is stored with a static suffix for turf user.
      String modifiedPassword = "${passwordInput}Turf_Worker";

      // 2. Authenticate the user with Firebase Email and Password
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: modifiedPassword,
      );

      log("User Logged In: ${userCredential.user?.uid}");
      log("User Email: ${userCredential.user?.email}");
      log("User Password: $modifiedPassword");

      WorkerSettings.saveEmail(userCredential.user?.email ?? '');
      WorkerSettings.saveworkerId(userCredential.user?.uid ?? '');
      WorkerSettings.saveIsLoggedIn(true);
      

      // 3. Success Handling
      _showSnackbar("Login Successfully", Color.fromARGB(255, 109, 77, 65));
      _emailController.clear();
      _passwordController.clear();
      
      // Navigate to the main application screen (NavigationSport)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const WorkernavigatorPage(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      log("Login Error Code: ${error.code}");
      log("Login Error Message: ${error.message}");

      // 4. Error Handling
      String message = error.message ?? 'An unknown login error occurred.';
      _showSnackbar(message, Colors.red);
    } catch (e) {
      log("General Login Error: $e");
      _showSnackbar("An unexpected error occurred. Please try again.", Colors.red);
    }
  }


  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _goToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const WorkerRegisterScreen(),
      ),
    );
  }

  void _goToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const WorkerForgotPasswordScreen(),
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
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
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 50),

                      // --- Email Field ---
                      _buildInputField(
                        controller: _emailController,
                        label: "Email ID",
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
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
                          if (value == null || value.isEmpty || value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Color.fromARGB(255, 109, 77, 65),
                          ),
                          hintText: "Password",
                          labelStyle: const TextStyle(color: Color.fromARGB(255, 80, 80, 80)),
                          hintStyle: const TextStyle(color: Colors.black54),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color.fromARGB(255, 109, 77, 65), width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: Color.fromARGB(255, 109, 77, 65),
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
                          onPressed: _handleLogin, // Calls the Firebase Login Logic
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 109, 77, 65),
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
                                color: Colors.white,
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
        prefixIcon: Icon(
          icon,
          color: Color.fromARGB(255, 109, 77, 65),
        ),
        hintText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color.fromARGB(255, 109, 77, 65), width: 2),
        ),
      ),
    );
  }
}