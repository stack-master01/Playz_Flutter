import 'package:flutter/material.dart';
import 'package:playz_user/View/trainer_view/trainerLogin_Screen.dart';
// Assuming these are your local imports

class TrainerPasswordResetScreen extends StatefulWidget {
 const TrainerPasswordResetScreen({super.key});

 @override
 State<TrainerPasswordResetScreen> createState() =>
   _TrainerPasswordResetScreenState();
}

class _TrainerPasswordResetScreenState extends State<TrainerPasswordResetScreen> {
 // Global Key for Form Validation
 final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

 // Text Controllers
 final TextEditingController _newPasswordController = TextEditingController();
 final TextEditingController _confirmPasswordController = TextEditingController();

 // State for password visibility toggles
 bool _isNewPasswordVisible = false;
 bool _isConfirmPasswordVisible = false;

 @override
 void dispose() {
  _newPasswordController.dispose();
  _confirmPasswordController.dispose();
  super.dispose();
 }

 // Function to handle password saving
 void _handlePasswordSave() {
  if (_formKey.currentState?.validate() ?? false) {
   // TODO: Implement API call to save the new password

   // Show success message and navigate to Login Screen
   ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Password reset successfully!')),
   );

   // Navigate to the login screen and remove all other routes
   Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => const TrainerLoginScreen()),
    (route) => false,
   );
  }
 }

 @override
 Widget build(BuildContext context) {
  final Color primaryColor = Colors.deepOrange;

  return Scaffold(
   // 🏆 PRO IMPROVEMENT 1: Use AppBar for navigation and title
   appBar: AppBar(
    // Back button navigates to the Login Screen (as you originally intended)
    leading: IconButton(
     icon: Icon(Icons.arrow_back_ios, color: primaryColor),
     onPressed: () {
      // Navigate back to login screen on back button press
      Navigator.of(context).pushAndRemoveUntil(
       MaterialPageRoute(builder: (context) => const TrainerLoginScreen()),
       (route) => false,
      );
     },
    ),
    title: Text(
     "Reset Password",
     style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: primaryColor,
     ),
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
    elevation: 0,
   ),
   body: SafeArea(
    child: Center(
     // 🏆 PRO IMPROVEMENT 2: Use SingleChildScrollView and Padding for responsiveness
     child: SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      // 🏆 PRO IMPROVEMENT 3: Use Form for validation
      child: Form(
       key: _formKey,
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
         const SizedBox(height: 20),
         
         const Text(
          "Enter your new password below.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
          textAlign: TextAlign.center,
         ),
         
         const SizedBox(height: 40),

         // --- New Password Field ---
         _buildPasswordField(
          controller: _newPasswordController,
          label: "New Password",
          isVisible: _isNewPasswordVisible,
          toggleVisibility: () {
           setState(() => _isNewPasswordVisible = !_isNewPasswordVisible);
          },
          validator: (value) {
           if (value == null || value.isEmpty) {
            return 'Please enter a new password';
           }
           if (value.length < 8) {
            return 'Password must be at least 8 characters';
           }
           return null;
          },
         ),
         const SizedBox(height: 20),

         // --- Confirm Password Field ---
         _buildPasswordField(
          controller: _confirmPasswordController,
          label: "Confirm Password",
          isVisible: _isConfirmPasswordVisible,
          toggleVisibility: () {
           setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
          },
          validator: (value) {
           if (value == null || value.isEmpty) {
            return 'Please confirm your new password';
           }
           if (value != _newPasswordController.text) {
            return 'Passwords do not match';
           }
           return null;
          },
         ),

         const SizedBox(height: 40),

         // --- Save Password Button ---
         SizedBox(
          height: 55,
          child: ElevatedButton(
           onPressed: _handlePasswordSave,
           style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
           ),
           child: const Text(
            "Save Password",
            style: TextStyle(
             fontSize: 20,
             fontWeight: FontWeight.bold,
             color: Colors.white,
            ),
           ),
          ),
         ),
        ],
       ),
      ),
    ),
   ),
  ));
 }

 // 🏆 PRO IMPROVEMENT 4: Extracted Reusable Password Field Widget
 Widget _buildPasswordField({
  required TextEditingController controller,
  required String label,
  required bool isVisible,
  required VoidCallback toggleVisibility,
  String? Function(String?)? validator,
 }) {
  final Color primaryColor = Colors.deepOrange;

  return TextFormField(
   controller: controller,
   // Toggle based on state
   obscureText: !isVisible, 
   validator: validator,
   style: const TextStyle(color: Colors.black),
   decoration: InputDecoration(
    prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
    labelText: label,
    labelStyle: const TextStyle(color: Colors.black54),
    border: OutlineInputBorder(
     borderRadius: BorderRadius.circular(12), // Smoother border radius
    ),
    focusedBorder: OutlineInputBorder(
     borderRadius: BorderRadius.circular(12),
     borderSide: BorderSide(color: primaryColor, width: 2),
    ),
    // Correctly implement the visibility toggle
    suffixIcon: IconButton(
     onPressed: toggleVisibility,
     icon: Icon(
      isVisible ? Icons.visibility : Icons.visibility_off,
      color: primaryColor,
     ),
    ),
   ),
  );
 }
}