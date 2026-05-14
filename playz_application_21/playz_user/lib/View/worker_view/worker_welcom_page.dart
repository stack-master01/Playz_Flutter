import 'package:flutter/material.dart';
import 'package:playz_user/View/user_view/reusable.dart';
// Note: Assuming this import path is correct for your project
import 'worker_creat_profile.dart'; 

// --- Constants for better maintainability and theming ---
const Color _kPrimaryColor = Color.fromARGB(255, 109, 77, 65);
const Color _kAccentColor = Color.fromRGBO(91, 61, 59, 1);
const double _kHorizontalPadding = 30.0;
const double _kSpacingLg = 64.0;
const double _kSpacingMd = 48.0;

// --- Network Image URL Constant ---
const String _kNetworkImageUrl = 
    'https://plus.unsplash.com/premium_photo-1669904021308-567d085a0ee7?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OXx8d29ya2luZ3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&q=60&w=500';


class WorkerWelcomePage extends StatelessWidget {
  const WorkerWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // --- 1. Background Network Image Layer ---
          Positioned.fill(
            child: Opacity(
              
              opacity: 0.7,
              child: Image.network(
                _kNetworkImageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  // If loading is complete, return the image (child)
                  if (loadingProgress == null) return child;
                  
                  // CORRECTED CODE HERE: Use cumulativeBytesLoaded
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null, // null means indeterminate progress
                      color: _kAccentColor,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.white,
                ),
              ),
            ),
          ),



Positioned.fill(
            child: Opacity(
              
              opacity: 0.55,
              child: Container(color: Colors.black,)
            ),
          ),

          // --- 2. Content Layer (Your existing code goes here) ---
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: _kHorizontalPadding,
                  vertical: _kHorizontalPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center, 
                  children: [
                    // --- Welcome Text and Title ---
                    const Text(
                      "Welcome!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Let's get you set up.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: _kSpacingMd),

                    // --- SVG Image ---
                    // SvgPicture.asset(
                    //   "assets/SVG/engineering_100dp_000000_FILL0_wght400_GRAD0_opsz48.svg",
                    //   width: screenWidth * 0.6, 
                    //   height: screenWidth * 0.6,
                    //   colorFilter: const ColorFilter.mode(
                    //     _kAccentColor,
                    //     BlendMode.srcIn,
                    //   ),
                    // ),
SizedBox(height: Reusable.getDeviceHeight(context, H: 350),),
                    const SizedBox(height: _kSpacingMd),

                    // --- Descriptive Text / Call to Action Explanation ---
                    const Text(
                      "Start earning today. Complete your profile to showcase your skills and begin receiving hiring requests from turf owners.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: _kSpacingLg),

                    // --- Primary Action Button ---
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const WorkerCre_ProfilePage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Create My Profile",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}