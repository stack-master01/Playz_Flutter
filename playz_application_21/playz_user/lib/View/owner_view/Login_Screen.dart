import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // New Import
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Helper/Owner_Loader.dart';
import 'dart:developer'; // New Import for logging
import 'dart:async';
import 'dart:math' hide log;
import 'package:playz_user/Helper/custom_Snackbar.dart';
import 'package:playz_user/View/owner_view/DashBoard_Screen.dart';
import 'package:playz_user/View/owner_view/ForgotPassword_Screen.dart';
import 'package:playz_user/View/owner_view/Register_Screen.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';

class OwnerLoginScreen extends StatefulWidget {
  const OwnerLoginScreen({super.key});

  @override
  State<OwnerLoginScreen> createState() => _OwnerLoginScreenState();
}

class _OwnerLoginScreenState extends State<OwnerLoginScreen> {
  bool isLoading = false;

  // --- FIREBASE LOGIC INTEGRATION START ---
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  // --- FIREBASE LOGIC INTEGRATION END ---

  final List<String> _networkBackgroundUrls = [
    "https://plus.unsplash.com/premium_photo-1685088557702-a2558e0ecbb9?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTE3fHxjcmlja2V0JTIwc3RhZGl1bXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500",
    "https://images.unsplash.com/photo-1546608235-3310a2494cdf?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=638",
    "https://images.unsplash.com/photo-1564769353575-73f33a36d84f?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8YmFkbWludG9uJTIwY291cnR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=500",
    "https://plus.unsplash.com/premium_photo-1675364966937-c2bdf5bce9b5?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8YmFza2V0YmFsbCUyMGNvdXJ0fGVufDB8fDB8fHww&auto=format&fit=crop&q=60&w=500",
    "https://plus.unsplash.com/premium_photo-1666914146602-680176b297ad?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8dGVubmlzJTIwY291cnR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&q=60&w=500"
  ];

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  // --- FIREBASE LOGIC REPLACEMENT IN _handleLogin START ---
  Future<void> _handleLogin() async {
    // 1. Validate form fields first
    if (!(_formKey.currentState?.validate() ?? false)) {
      CustomSnackbar().showCustomSnackbar(
        context,
        "Enter Valid Data",
        bgColour: Colors.red,
      );
      return;
    }

    // Get trimmed values
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
setState(() {
  isLoading = true;
});
    try {
      // 2. Modify password and call Firebase sign-in
      String securedPassword = "${password}Turf_Owner";

      UserCredential ownerCredential = await _firebaseAuth
          .signInWithEmailAndPassword(
            email: email,
            password: securedPassword,
          );

      // 3. Handle Success
      log("Successful Login. owner: ${ownerCredential.user?.uid}");
      log("owner Email: ${ownerCredential.user?.email}");
      log("owner Password: $securedPassword");

      OwnerSettings.saveIsLoggedIn(true);
      OwnerSettings.saveOwnerId("${ownerCredential.user?.uid}");
      OwnerSettings.saveownerEmail("${ownerCredential.user?.email}");

      CustomSnackbar().showCustomSnackbar(
        context,
        "Login Successfully",
        bgColour: Colors.green,
      );
      
      // Clear fields and navigate
      _emailController.clear();
      _passwordController.clear();
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OwnerDashBoardScreen(),
        ),
      );

    } on FirebaseAuthException catch (error) {
      // 4. Handle Firebase Authentication Errors
      log("Error Code: ${error.code}");
      log("Error Message: ${error.message}");
      
      CustomSnackbar().showCustomSnackbar(
        context,
        error.message ?? "An unknown error occurred",
        bgColour: Colors.red,
      );
    } catch (e) {
      // 5. Handle Other Errors (e.g., network issues)
      log("General Error: $e");
      CustomSnackbar().showCustomSnackbar(
        context,
        "Login failed. Please check your connection.",
        bgColour: Colors.red,
      );
    }finally{
      setState(() {
  isLoading = false;
});
    }
  }
  // --- FIREBASE LOGIC REPLACEMENT IN _handleLogin END ---

  void _goToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ownerRegisterScreen(),
      ),
    );
  }

  void _goToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ownerForgotPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Color.fromRGBO(13, 71, 161, 1),
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
                            borderSide: const BorderSide(color: Color.fromRGBO(13, 71, 161, 1), width: 2),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: const Color.fromRGBO(13, 71, 161, 1),
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
                          onPressed: _handleLogin, // Calls the modified login logic
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(13, 71, 161, 1),
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
                            child: const Text(
                              "Register Now",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(13, 71, 161, 1),
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
          ),if(isLoading) OwnerLoaderScreen(),
        ],
      ),
    );
  }

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
          color: const Color.fromRGBO(13, 71, 161, 1),
        ),
        hintText: label,
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
}