import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer'; // Added for logging
import 'dart:math' hide log;
import 'package:firebase_auth/firebase_auth.dart'; // Added Firebase Auth import
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Model_Class/Turf_Owner/Owner_Register_Model.dart';
// Assuming these exist for navigation/snackbars:
import 'package:playz_user/View/owner_view/Login_Screen.dart';
import 'package:playz_user/View/owner_view/RegisterSuccessful_Screen.dart';
import 'package:playz_user/View/owner_view/Welcome_Screen.dart'; 

class ownerRegisterScreen extends StatefulWidget {
  const ownerRegisterScreen({super.key});

  @override
  State<ownerRegisterScreen> createState() => _ownerRegisterScreenState();
}

class _ownerRegisterScreenState extends State<ownerRegisterScreen> {
  bool   isLoading = false;

  // ------------------------------------------------------------------
  // Firebase Authentication Initialization
  // ------------------------------------------------------------------
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // Firebase instance
  // ------------------------------------------------------------------
  // Firebase Store Initialization
  // ------------------------------------------------------------------
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance; // Firebase instance

  // ------------------------------------------------------------------
  // 1. Updated List of Network Image URLs
  // ------------------------------------------------------------------
  final List<String> _networkBackgroundUrls = [
    "https://plus.unsplash.com/premium_photo-1685088557702-a2558e0ecbb9?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTE3fHxjcmlja2V0JTIwc3RhZGl1bXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500",
    "https://images.unsplash.com/photo-1546608235-3310a2494cdf?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=638",
    "https://images.unsplash.com/photo-1564769353575-73f33a36d84f?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8YmFkbWludG9uJTIwY291cnR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=500",
    "https://plus.unsplash.com/premium_photo-1675364966937-c2bdf5bce9b5?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8YmFza2V0YmFsbCUyMGNvdXJ0fGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=500",
    "https://plus.unsplash.com/premium_photo-1666914146602-680176b297ad?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8dGVubmlzJTIwY291cnR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=500"
  ];

  // --- 2. State & Timer Variables ---
  int _currentIndex = 0;
  Timer? _timer;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text Controllers (Used the final code's naming convention)
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  // State for password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _startBackgroundChangeTimer();
  }

  // ------------------------------------------------------------------
  // 3. Timer Logic for Background Change (Unchanged)
  // ------------------------------------------------------------------
  void _startBackgroundChangeTimer() {
    _networkBackgroundUrls.shuffle(Random());
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
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
    _usernameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // 4. Firebase Registration Logic (Replaced _handleRegister)
  // ------------------------------------------------------------------
  Future<void> _firebaseRegister() async {
    
    // 1. Validate form fields first
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showSnackbar('Please correct the errors in the form.', Colors.red);
      return;
    }
    String userName = _usernameController.text.trim();
    String email_ID = _emailController.text.trim();
    String contact_Number = _contactController.text.trim();
    String password = _passwordController.text.trim();

    OwnerRegisterModel resgisterObj = OwnerRegisterModel(userName: userName, email_ID: email_ID, contact_Number: contact_Number, password: password);
      final DateTime now = DateTime.now();
  // Store date in D-M-YYYY format, e.g. 5-11-2025
  final regMap = resgisterObj.toMAp();
    regMap['createdAt'] = "${now.day}-${now.month}-${now.year}";
    regMap['isBanned'] = false;

setState(() {
  isLoading = true;
});
    try {
      // Logic to append "Turf_Owner" to the password, as seen in the original code.
      String customPassword = "${password}Turf_Owner";

      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email_ID,
        password: customPassword,
      );
      await _firebaseFirestore.collection("Turf_Owner").doc(email_ID).set(resgisterObj.toMAp());


      log("User Detail: ${userCredential.user?.uid}");
      log("User Email: ${userCredential.user?.email}");
      log("User Password: $customPassword");
      OwnerSettings.saveownerEmail(_emailController.text.trim());
      OwnerSettings.saveIsLoggedIn(true);
      OwnerSettings.saveOwnerId(userCredential.user!.uid);
OwnerSettings owner = await OwnerSettings().loadSettings();
      log("shared Email: ${ owner.ownerEmail}");

      // Success: Show Snackbar and Navigate
      _showSnackbar("Registered Successfully", Colors.green);
      
      // Navigate to the success screen (ownerTurfRegisteredSuccessfulScreen is used from the final code's imports)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ownerWelcomeAddTurf(email_ID:email_ID),
        ),
      );
    } on FirebaseAuthException catch (error) {
      log("Error Code:${error.code}");
      log("Error Message:${error.message}");

      String message;
      if (error.code == "invalid-email") {
        message = "Enter a valid email ID.";
      } else if (error.code == "weak-password") {
        message = "Password is too weak. Must be at least 6 characters.";
      } else if (error.code == "email-already-in-use") {
        message = "An account already exists for that email.";
      } else {
        message = error.message ?? "An unknown error occurred.";
      }

      // Failure: Show Snackbar
      _showSnackbar(message, Colors.red);
    } catch (e) {
      log("General Registration Error: $e");
      _showSnackbar("An unexpected error occurred.", Colors.red);
    }finally{
      setState(() {
  isLoading = false;
});
    }
  }

  // Helper function to show a Snackbar
  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const OwnerLoginScreen(),
      ),
    );
  }

  // ------------------------------------------------------------------
  // 5. Build Method (UI is retained)
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color before image loads
      body: Stack(
        children: [
          // --- 1. Background Image Layer with AnimatedSwitcher ---
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000), // 1 second fade
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            // The key forces the AnimatedSwitcher to recognize the image has changed
            key: ValueKey<int>(_currentIndex),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              // Child's key needs to match the parent's key logic for AnimatedSwitcher
              key: ValueKey<String>(_networkBackgroundUrls[_currentIndex]),
              decoration: BoxDecoration(
                image: DecorationImage(
                  // Use the URL from the current index
                  image: NetworkImage(_networkBackgroundUrls[_currentIndex]),
                  fit: BoxFit.cover,
                  // Add a subtle dark overlay for better text contrast
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.55), // Darker overlay for high contrast
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
          ),

          // --- 2. Foreground Content Layer ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                // Use horizontal padding for responsiveness
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      // --- Title (White for contrast) ---
                      const Text(
                        "Create Account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // High contrast
                        ),
                      ),
                      const SizedBox(height: 40),

                      // --- Input Fields ---
                      _buildInputField(
                        controller: _usernameController,
                        label: "Username",
                        icon: Icons.person_outline,
                        validator: (value) => value!.isEmpty ? 'Enter a username' : null,
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: _emailController,
                        label: "Email ID",
                        icon: Icons.mail_outline,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                            if (value!.isEmpty) return 'Enter your email';
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Enter a valid email';
                            return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: _contactController,
                        label: "Contact Number",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.length < 10 ? 'Enter a valid 10-digit phone number' : null,
                      ),
                      const SizedBox(height: 20),

                      _buildPasswordField(
                        controller: _passwordController,
                        label: "Password",
                        isVisible: _isPasswordVisible,
                        toggleVisibility: () {
                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                        },
                        validator: (value) => value!.length < 6 ? 'Password must be at least 6 characters' : null,
                      ),
                      const SizedBox(height: 20),

                      _buildPasswordField(
                        controller: _rePasswordController,
                        label: "Confirm Password",
                        isVisible: _isConfirmPasswordVisible,
                        toggleVisibility: () {
                          setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                        },
                        validator: (value) {
                          if (value!.isEmpty) return 'Please confirm your password';
                          if (value != _passwordController.text) return 'Passwords do not match';
                          return null;
                        },
                      ),

                      const SizedBox(height: 30),

                      // --- Sign-Up Button ---
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _firebaseRegister, // CALL THE FIREBASE REGISTER FUNCTION
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(13, 71, 161, 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- Login Link (White text for visibility) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already Have An Account?",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: _goToLogin,
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(13, 71, 161, 1), // Highlighting the action link
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

  // --- Reusable Input Field Widget for non-password fields (Unchanged) ---
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
        prefixIcon: Icon(icon, color: const Color.fromRGBO(13, 71, 161, 1)),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(13, 71, 161, 1), width: 2),
        ),
      ),
    );
  }

  // --- Extracted Password Field Widget with toggle logic (Unchanged) ---
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      validator: validator,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        prefixIcon: const Icon(Icons.lock_outline, color: Color.fromRGBO(13, 71, 161, 1)),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color.fromRGBO(13, 71, 161, 1), width: 2),
        ),
        suffixIcon: IconButton(
          onPressed: toggleVisibility,
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: const Color.fromRGBO(13, 71, 161, 1),
          ),
        ),
      ),
    );
  }
}