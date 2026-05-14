import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:playz_user/View/trainer_view/trainerPasswordReset_Screen.dart';

// Assuming these are your local imports

class TrainerForgotPasswordScreen extends StatefulWidget {
 const TrainerForgotPasswordScreen({super.key});

 @override
 State<TrainerForgotPasswordScreen> createState() =>
   _TrainerForgotPasswordScreenState();
}

class _TrainerForgotPasswordScreenState extends State<TrainerForgotPasswordScreen> {
 // --- OTP Logic Variables ---
 final int _otpLength = 6;
 final List<TextEditingController> _otpControllers = [];
 final List<FocusNode> _focusNodes = [];
 final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

 // --- Timer Logic Variables ---
 int _resendSeconds = 60;
 late Timer _timer;
 bool _isResendActive = false;
 
 @override
 void initState() {
  super.initState();
  // Initialize controllers and focus nodes
  for (int i = 0; i < _otpLength; i++) {
   _otpControllers.add(TextEditingController());
   _focusNodes.add(FocusNode());
  }
  _startTimer();
 }

 @override
 void dispose() {
  for (var controller in _otpControllers) {
   controller.dispose();
  }
  for (var node in _focusNodes) {
   node.dispose();
  }
  _timer.cancel();
  super.dispose();
 }

 void _startTimer() {
  _resendSeconds = 60;
  _isResendActive = true;
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
   if (_resendSeconds == 0) {
    setState(() {
     _isResendActive = false;
     timer.cancel();
    });
   } else {
    setState(() {
     _resendSeconds--;
    });
   }
  });
 }

 void _resendOtp() {
  if (!_isResendActive) {
   // TODO: Implement API call to resend OTP
   _startTimer();
   ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('New OTP sent!')),
   );
  }
 }

 void _submitOtp() {
  if (_formKey.currentState!.validate()) {
   String otp = _otpControllers.map((c) => c.text).join();
   
   // TODO: Implement API call to verify OTP
   print('Submitting OTP: $otp');

   // Navigate to Password Reset Screen on successful verification
   Navigator.of(context).pushReplacement(
    MaterialPageRoute(builder: (context) => const TrainerPasswordResetScreen()),
   );
  } else {
   ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please enter the complete 6-digit OTP.')),
   );
  }
 }

 @override
 Widget build(BuildContext context) {
  // Get the green color once for cleaner code
  final Color primaryColor = Colors.deepOrange; 
    // final Size screenSize = MediaQuery.of(context).size;

  return Scaffold(
   // Use AppBar for better navigation and header management
   appBar: AppBar(
    leading: IconButton(
     icon: Icon(Icons.arrow_back_ios, color: primaryColor),
     onPressed: () => Navigator.of(context).pop(),
    ),
    title: Text(
     "Forgot Password",
     style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: primaryColor,
     ),
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
    elevation: 0, // Remove shadow
   ),
   body: SafeArea(
    child: SingleChildScrollView(
     padding: const EdgeInsets.all(24),
     child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
       const SizedBox(height: 15),

       // Instructions
       const Text(
        "Verify with OTP to change Password",
        style: TextStyle(
         fontSize: 18,
         fontWeight: FontWeight.bold,
         color: Colors.black,
        ),
        textAlign: TextAlign.center,
       ),
       const SizedBox(height: 8),
       const Text(
        "A 6-digit code has been sent to your contact number.",
        style: TextStyle(
         fontSize: 15,
         color: Colors.grey,
        ),
        textAlign: TextAlign.center,
       ),
       const SizedBox(height: 40),

       // --- OTP Input Fields ---
       Form(
        key: _formKey,
        child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceAround,
         children: List.generate(_otpLength, (index) {
          return OtpInput(
           controller: _otpControllers[index],
           focusNode: _focusNodes[index],
           primaryColor: primaryColor,
           onSubmitted: (value) {
            if (value.isNotEmpty) {
             // Move focus to the next field
             if (index < _otpLength - 1) {
              _focusNodes[index + 1].requestFocus();
             } else {
              // Last field reached, dismiss keyboard
              _focusNodes[index].unfocus();
              _submitOtp(); // Optionally auto-submit
             }
            }
           },
           onBackspace: () {
            if (index > 0) {
             _focusNodes[index - 1].requestFocus();
            }
           },
          );
         }),
        ),
       ),
       const SizedBox(height: 40),

       // --- Submit Button ---
       ElevatedButton(
        onPressed: _submitOtp,
        style: ElevatedButton.styleFrom(
         backgroundColor: primaryColor,
         padding: const EdgeInsets.symmetric(vertical: 15),
         shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
         ),
        ),
        child: const Text(
         "Verify",
         style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
         ),
        ),
       ),
       const SizedBox(height: 20),

       // --- Resend Timer/Button ---
       Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         const Text(
          "Didn't receive the code? ",
          style: TextStyle(fontSize: 15, color: Colors.grey),
         ),
         GestureDetector(
          onTap: _resendOtp,
          child: Text(
           _isResendActive
            ? "Retry in ($_resendSeconds)"
            : "Resend Code",
           style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: _isResendActive ? Colors.grey : primaryColor,
           ),
          ),
         ),
        ],
       ),
      ],
     ),
    ),
   ),
  );
 }
}

// ----------------------------------------------------------------------
// 🏆 PRO IMPROVEMENT: Extracted OTP Input Widget
// ----------------------------------------------------------------------
class OtpInput extends StatelessWidget {
 final TextEditingController controller;
 final FocusNode focusNode;
 final Color primaryColor;
 final ValueChanged<String> onSubmitted;
 final VoidCallback onBackspace;

 const OtpInput({
  super.key,
  required this.controller,
  required this.focusNode,
  required this.primaryColor,
  required this.onSubmitted,
  required this.onBackspace,
 });

 @override
 Widget build(BuildContext context) {
  return SizedBox(
      // Ensure equal size for all OTP boxes, relative to screen width
   width: MediaQuery.of(context).size.width / 8, 
   child: TextFormField(
    controller: controller,
    focusNode: focusNode,
    onChanged: (value) {
     if (value.length == 1) {
      onSubmitted(value);
     } else if (value.isEmpty) {
      onBackspace();
     }
    },
    validator: (value) {
          if (value == null || value.isEmpty) {
            // Returning an empty string prevents the form from validating 
            // without showing a huge error text under the tiny box.
            return ''; 
          }
          return null;
        },
    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    keyboardType: TextInputType.number,
    textAlign: TextAlign.center,
    inputFormatters: [
     LengthLimitingTextInputFormatter(1),
     FilteringTextInputFormatter.digitsOnly,
    ],
    decoration: InputDecoration(
     contentPadding: const EdgeInsets.symmetric(vertical: 15),
     border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
     ),
     focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: primaryColor, width: 2),
     ),
    ),
   ),
  );
 }
}