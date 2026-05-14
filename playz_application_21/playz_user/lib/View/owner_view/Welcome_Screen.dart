import 'package:flutter/material.dart';
import 'package:playz_user/View/owner_view/RegisterTurf_Screen.dart';
import 'package:playz_user/View/user_view/reusable.dart';

class ownerWelcomeAddTurf extends StatefulWidget {
  final String? email_ID;
   ownerWelcomeAddTurf({this.email_ID,super.key});

  @override
  State<ownerWelcomeAddTurf> createState() => _ownerWelcomeAddTurfState();
}

class _ownerWelcomeAddTurfState extends State<ownerWelcomeAddTurf> {
  // Define a consistent primary color
  final Color primaryColor = const Color.fromRGBO(13, 71, 161, 1);
  final Color secondaryTextColor = const Color.fromRGBO(109, 109, 109, 1);
  
  // Use a suitable network image URL for a sports/turf theme
  final String networkImageUrl =
      'https://images.unsplash.com/photo-1748586208847-4f608975fee5?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDM1fHx8ZW58MHx8fHx8&auto=format&fit=crop&q=60&w=500'; // Turf image

  // Placeholder for dynamic data
  final String userName = "Alex"; // Assuming the username will be dynamic

  @override
  Widget build(BuildContext context) {
    String? email = widget.email_ID;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Full-Screen Background Image with Opacity 0.5 🖼️
          Opacity(
            opacity: 0.7,
            child: Image.network(
              networkImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.lightGreen.shade100), // Fallback color
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                    child: CircularProgressIndicator(
                        color: primaryColor.withOpacity(0.5)));
              },
            ),
          ),
const Opacity(
            opacity: 0.5,
            child: ColoredBox(
              color: Colors.black,
            ),
          ),
          // 2. Main Content Overlay 📝
          SafeArea(
            child: Padding(
              // Consistent horizontal padding for all content
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: SingleChildScrollView(
                // Ensures the content is scrollable on small screens
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Spacing
                    const SizedBox(height: 50),

                    // Welcome Text Block - Wrapped for better contrast 🌟
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9), // Semi-transparent white card
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome $userName!",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            "Let's get your turf set up.",
                            style: TextStyle(
                              fontSize: 32,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Text(
                            'Ready to get started? Add your turf\'s details to make it available for booking.',
                            style: TextStyle(
                              fontSize: 18,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Visual Element to break up the screen ⚽
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 60.0),
                    //   child: Center(
                    //     child: Icon(
                    //       Icons.sports_soccer_outlined,
                    //       size: 150,
                    //       color: primaryColor.withOpacity(0.7),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: Reusable.getDeviceHeight(context, H: 250),),

                    // Flexible spacer to push the button closer to the bottom
                    SizedBox(height: MediaQuery.of(context).size.height * 0.15),

                    // Primary Call-to-Action Button
                    SizedBox(
                      height: 60,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_business, color: Colors.white),
                        label: const Text(
                          "Add Your Turf",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          // Use the original navigation logic
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  ownerRegisterTurfScreen(email_ID: email,)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // Modern rounded corners
                          ),
                          elevation: 8, // Prominent shadow
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 30), // Bottom spacing
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