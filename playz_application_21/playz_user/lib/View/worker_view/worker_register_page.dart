
import 'package:flutter/material.dart';
import 'dart:async'; // Required for Timer
import 'dart:math' hide log; // Required for Random/shuffling
import 'dart:developer'; // Required for log

// Firebase Import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';

// Assuming these are your local imports
import 'package:playz_user/View/worker_view/worker_login_page.dart';
import 'package:playz_user/View/worker_view/worker_navigator_page.dart';
import 'package:playz_user/View/worker_view/worker_welcom_page.dart';

// Placeholder for the screen to navigate to upon successful registration


class WorkerRegisterScreen extends StatefulWidget {
  const WorkerRegisterScreen({super.key});

  @override
  State<WorkerRegisterScreen> createState() => _WorkerRegisterScreenState();
}

class _WorkerRegisterScreenState extends State<WorkerRegisterScreen> {
  // ------------------------------------------------------------------
  // 1. Updated List of Network Image URLs
  // ------------------------------------------------------------------
  final List<String> _networkBackgroundUrls = [
    "https://plus.unsplash.com/premium_photo-1669904021308-567d085a0ee7?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8d29ya2luZ3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500",
    "https://plus.unsplash.com/premium_photo-1669904021345-2a95691cb188?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDEwfHx8ZW58MHx8fHx8&auto=format&fit=crop&q=60&w=500",
   "https://plus.unsplash.com/premium_photo-1669904021811-8ef2141ce37c?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=688"
  ];

  // --- 2. State & Timer Variables ---
  int _currentIndex = 0; // Tracks the current image index
  Timer? _timer; // The timer object for background cycling
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();

  // State for password visibility
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // FIREBASE INITIALIZATION
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    // Start the timer when the screen initializes
    _startBackgroundChangeTimer();
  }

  // ------------------------------------------------------------------
  // 3. Timer Logic for Background Change
  // ------------------------------------------------------------------
  void _startBackgroundChangeTimer() {
    // Optional: Shuffle the list to start with a random image on app launch
    _networkBackgroundUrls.shuffle(Random());

    // Timer fires every 5 seconds (5000 milliseconds)
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          // Calculate the next index, wrapping around to 0
          _currentIndex = (_currentIndex + 1) % _networkBackgroundUrls.length;
        });
      }
    });
  }

  @override
  void dispose() {
    // IMPORTANT: Cancel the timer to prevent memory leaks and errors
    _timer?.cancel();
    _usernameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------
  // 4. Firebase Registration Logic
  // ------------------------------------------------------------------
  void _handleRegister() async {
    // Validate all form fields first
    if (!(_formKey.currentState?.validate() ?? false)) {
      // If validation fails, show a generic error (although the TextFormField validators handle specifics)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fix the errors in the form.'),
          backgroundColor: Colors.red[700],
        ),
      );
      return;
    }

    try {
      // **SECURITY NOTE**: The original code modifies the password before sending.
      // Assuming this is still desired but changing the appended string to reflect a 'User' .
      // If this is a mistake, use _passwordController.text directly.
      String password = "${_passwordController.text}Turf_Worker";

      // Firebase Auth Call: Create user with email and password
      UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: password,
      );

      // Log success details
      log("Password Used: $password");
      log("User Detail: $userCredential");
WorkerSettings.saveEmail(_emailController.text.trim());
      WorkerSettings.saveIsLoggedIn(true);
      WorkerSettings. saveworkerId(userCredential.user!.uid);
WorkerSettings workerSettings = await WorkerSettings().loadSettings();
      log("shared Email: ${workerSettings.email}");
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registered Successfully!'),
          backgroundColor: Color.fromARGB(255, 109, 77, 65),
        ),
      );

      // Navigate to the welcome/home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const WorkerWelcomePage(), // Change to your intended home screen
        ),
      );

    } on FirebaseAuthException catch (error) {
      log("Error Code: ${error.code}");
      log("Error Message: ${error.message}");

      String displayMessage = error.message ?? "An unknown error occurred.";

      if (error.code == "invalid-email") {
        displayMessage = "The email address is not valid.";
      } else if (error.code == "email-already-in-use") {
        displayMessage = "This email is already registered.";
      } else if (error.code == "weak-password") {
        displayMessage = "The password is too weak. Must be at least 6 characters.";
      }
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(displayMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const WorkerLoginScreen(),
      ),
    );
  }

  // ------------------------------------------------------------------
  // 5. Build Method with AnimatedSwitcher
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
                            // Basic regex for email format validation
                            const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                            final regExp = RegExp(pattern);
                            if (!regExp.hasMatch(value)) return 'Enter a valid email address';
                            return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      _buildInputField(
                        controller: _contactController,
                        label: "Contact Number",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: (value) => value!.length < 10 ? 'Enter a valid 10-digit number' : null,
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

                      // --- Sign-Up Button (Now calls the Firebase logic) ---
                      SizedBox(
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _handleRegister, // <-- **Updated Call**
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 109, 77, 65),
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
                            child: Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Highlighting the action link
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

  // --- Reusable Input Field Widget for non-password fields ---
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
      style: const TextStyle(color: Colors.black), // Input text color
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white, // Solid background for contrast
        prefixIcon: Icon(icon, color: Color.fromARGB(255, 109, 77, 65)),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Smoother radius
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color.fromARGB(255, 109, 77, 65), width: 2),
        ),
      ),
    );
  }

  // --- Extracted Password Field Widget with toggle logic ---
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
        prefixIcon: Icon(Icons.lock_outline, color: Color.fromARGB(255, 109, 77, 65)),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color.fromARGB(255, 109, 77, 65), width: 2),
        ),
        suffixIcon: IconButton(
          onPressed: toggleVisibility,
          icon: Icon(
            isVisible ? Icons.visibility : Icons.visibility_off,
            color: Color.fromARGB(255, 109, 77, 65),
          ),
        ),
      ),
    );
  }
}