import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:playz_user/View/owner_view/Login_Screen.dart';

class ownerForgotPasswordScreen extends StatefulWidget {
  const ownerForgotPasswordScreen({super.key});

  @override
  State<ownerForgotPasswordScreen> createState() =>
      _OwnerForgotPasswordScreenState();
}

class _OwnerForgotPasswordScreenState extends State<ownerForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text("Password Reset Link Sent! Check Your Email."),
        ),
      );
      // Navigate after showing dialog
      Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const OwnerLoginScreen()),
        (route) => false,
      );
    });
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(e.message ?? "Something went wrong."),
        ),
      );
      return;
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.chevron_left_sharp,
                      color: Color.fromRGBO(13, 71, 161, 1),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color.fromRGBO(13, 71, 161, 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.only(left: 50),
                child: Text(
                  "Check your email for a link to reset your password",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: _buildInputField(
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
              ),
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  width: 280,
                  height: 50,
                  child: ElevatedButton (
                    onPressed: ()async{
                      await _resetPassword();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(13, 71, 161, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              // const Center(
              //   child: Text(
              //     "Didn't receive it? Retry in (*Timer)",
              //     style: TextStyle(
              //       fontSize: 15,
              //       fontWeight: FontWeight.w400,
              //       color: Colors.black87,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
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
        prefixIcon: Icon(icon, color: const Color.fromRGBO(13, 71, 161, 1)),
        hintText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color.fromRGBO(13, 71, 161, 1),
            width: 2,
          ),
        ),
      ),
    );
  }
}

