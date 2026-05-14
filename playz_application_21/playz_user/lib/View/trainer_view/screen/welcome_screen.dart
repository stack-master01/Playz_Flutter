import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playz_user/View/trainer_view/screen/create_profile_screen.dart';



// --- Constants for Professional Design ---
class AppDesign {
  // Energetic background image relevant to trainers/coaching
  static const String bgImageUrl =
      "https://images.unsplash.com/photo-1646072508060-ee17433e308e?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1yZWxhdGVkfDI1fHx8ZW58MHx8fHx8&auto=format&fit=crop&q=60&w=600";

  // Primary accent color (Deep Orange / Red for energy)
  static const Color primaryColor = Color(0xFFE65100); // Deep Orange 900
  // Secondary color for button/text contrast
  static const Color accentColor = Color(0xFFFF9800); // Orange 500
  // Text color against the dark background
  static const Color onBackgroundColor = Colors.white;
}

// --- Custom Elevated Button (Interactive) ---
class AnimatedActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AnimatedActionButton({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDesign.primaryColor,
          foregroundColor: AppDesign.onBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          elevation: 12, // Stronger lift
          shadowColor: AppDesign.primaryColor.withOpacity(0.8),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fitness_center, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Force light status bar icons for dark background
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Network Background Image with Dark Overlay
          Image.network(
            AppDesign.bgImageUrl,
            fit: BoxFit.cover,
            // Add a dark overlay for contrast
            color: Colors.black.withOpacity(0.4),
            colorBlendMode: BlendMode.darken,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(color: AppDesign.primaryColor),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              color: Colors.black,
              child: const Center(
                  child: Icon(Icons.error_outline,
                      color: Colors.white70, size: 50)),
            ),
          ),

          // 2. Vertical Gradient for Text Clarity (fades bottom to top)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.9), // Darkest at the bottom (button area)
                  Colors.black.withOpacity(0.5),
                  Colors.transparent, // Transparent at the top
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [0.0, 0.4, 0.8],
              ),
            ),
          ),

          // 3. Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Header (Larger, High-Contrast Text)
                  const SizedBox(height: 20),
                  const Text(
                    'Coach, Welcome.',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: AppDesign.onBackgroundColor,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.black54)
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let\'s get you set up to lead the way.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: AppDesign.onBackgroundColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 80),

                  // Image Placeholder (Using a dynamic Icon for better visual)
                  // Center(
                  //   child: Icon(
                  //     Icons.sports_whistle_outlined,
                  //     size: 120,
                  //     color: AppDesign.accentColor,
                  //     shadows: [
                  //       BoxShadow(
                  //         color: AppDesign.accentColor.withOpacity(0.5),
                  //         blurRadius: 20,
                  //       )
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 80),

                  // Description text
                  Text(
                    '“ Connect with players, manage training sessions, and showcase your expertise across multiple sports. We\'re excited to have you on the Playz team! ”',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppDesign.onBackgroundColor.withOpacity(0.9),
                      fontSize: 18,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                      shadows: const [
                        Shadow(blurRadius: 5, color: Colors.black54)
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Button
                  AnimatedActionButton(
                    text: 'CREATE MY PROFILE',
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const CreateProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}