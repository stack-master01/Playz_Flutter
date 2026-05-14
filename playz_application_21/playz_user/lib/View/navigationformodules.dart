// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'package:playz_user/Controller/trainer_sharedpreferences.dart';
import 'package:playz_user/Controller/worker_sharedpreferences.dart';
import 'package:playz_user/View/owner_view/DashBoard_Screen.dart';
import 'dart:ui'; // REQUIRED for ImageFilter.blur (Glassmorphism)

import 'package:playz_user/View/owner_view/Owner_Walkthrough.dart';
import 'package:playz_user/View/trainer_view/Trainer_Walkthrough.dart';
import 'package:playz_user/View/trainer_view/screen/screens/screens/coach_home_screen.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'package:playz_user/View/trainer_view/trainer_navigation.dart';
import 'package:playz_user/View/user_view/User_Walkthrough.dart';
import 'package:playz_user/View/user_view/navigation(sport).dart';
import 'package:playz_user/View/worker_view/Worker_Walkthrough.dart';
import 'package:playz_user/View/worker_view/worker_navigator_page.dart';



// --- Constants (Centralized and Professional) ---
class AppColors {
 // Primary color: A vibrant, energetic green
 static const Color primaryGreen = Color(0xFF4CAF50); // A bright, standard material green
 // Secondary color: A darker shade for contrast and depth
 static const Color darkGreen = Color(0xFF1E88E5); // A deep blue for better contrast against green/white
 // Accent color: White/light for text on dark/blurred backgrounds
 static const Color accentText = Colors.white; 
 // Base background overlay color for the blurred effect
 static Color glassBase = Colors.white.withOpacity(0.08);
}

// Background image URL for a clean, energetic sports/nature feel
const String _kBgImageUrl =
"assets/Images/navigator.png";

// --- Pulsating Role Card Widget (Interactive & Beautiful) ---
class RoleSelectionCard extends StatefulWidget {
 final String label;
 final String subLabel;
 final IconData icon;
 final VoidCallback onPressed;
 final Color color; // Base color for the glass tint

 const RoleSelectionCard({
  super.key,
  required this.label,
  required this.subLabel,
  required this.icon,
  required this.onPressed,
  required this.color,
 });

 @override
 State<RoleSelectionCard> createState() => _RoleSelectionCardState();
}

class _RoleSelectionCardState extends State<RoleSelectionCard> with SingleTickerProviderStateMixin {
 late AnimationController _controller;
 late Animation<double> _scaleAnimation;
 late Animation<Color?> _colorAnimation;

 @override
 void initState() {
  super.initState();
  _controller = AnimationController(
   vsync: this,
   duration: const Duration(milliseconds: 150), // Quick, snappy press effect
  );

  // Subtle scale down on press for haptic feedback feel
  _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(_controller);
  
  // Color change on press for visual feedback
  _colorAnimation = ColorTween(
   begin: widget.color.withOpacity(0.2), 
   end: widget.color.withOpacity(0.35),
  ).animate(_controller);
 }

 @override
 void dispose() {
  _controller.dispose();
  super.dispose();
 }

 void _onTapDown(TapDownDetails details) => _controller.forward();
 void _onTapUp(TapUpDetails details) => _controller.reverse();
 void _onTapCancel() => _controller.reverse();
 void _onTap() {
  _controller.reverse();
  widget.onPressed();
 }

 @override
 Widget build(BuildContext context) {
  const double buttonRadius = 24.0;
  
  // Using a GestureDetector for precise tap control (down, up, cancel)
  return GestureDetector(
   onTapDown: _onTapDown,
   onTapUp: _onTapUp,
   onTapCancel: _onTapCancel,
   onTap: _onTap,
   child: AnimatedBuilder(
    animation: _controller,
    builder: (context, child) {
     return Transform.scale(
      scale: _scaleAnimation.value,
      child: Padding(
       padding: const EdgeInsets.symmetric(vertical: 10.0), // Reduced spacing
       child: Container(
        width: double.infinity,
        height: 80, // Increased height for better tap target and design
        decoration: BoxDecoration(
         borderRadius: BorderRadius.circular(buttonRadius),
         boxShadow: [
          BoxShadow(
           color: Colors.black.withOpacity(0.25), // Stronger shadow for lift
           blurRadius: 20,
           offset: const Offset(0, 10),
          ),
         ],
        ),
        child: ClipRRect(
         borderRadius: BorderRadius.circular(buttonRadius),
         child: Stack(
          children: [
           // 1. Blur Effect (BackdropFilter)
           BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Stronger blur
            child: Container(
             color: AppColors.glassBase,
            ),
           ),
           // 2. Tint Overlay & Border
           Container(
            decoration: BoxDecoration(
             border: Border.all(
              color: Colors.white.withOpacity(0.4), // Thicker, more prominent border
              width: 2.0,
             ),
             gradient: LinearGradient(
              colors: [
               _colorAnimation.value!, // Dynamic tint on press
               widget.color.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
             ),
            ),
           ),
           // 3. Content
           Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
              Row(
               children: [
                Icon(widget.icon, color: AppColors.accentText, size: 36), // Larger icon
                const SizedBox(width: 18),
                Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                  Text(
                   widget.label,
                   style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentText,
                    letterSpacing: 1.0,
                   ),
                  ),
                  Text(
                   '(${widget.subLabel})',
                   style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.accentText.withOpacity(0.7),
                   ),
                  ),
                 ],
                ),
               ],
              ),
              const Icon(Icons.arrow_forward_ios, color: AppColors.accentText, size: 20),
             ],
            ),
           ),
          ],
         ),
        ),
       ),
      ),
     );
    },
   ),
  );
 }
}


// --- NEW WIDGET FOR STAGGERED BOTTOM-UP ANIMATION ---

class AnimatedRoleCardWrapper extends StatefulWidget {
 final Widget child;
 final int index; // Determines the delay for staggered effect
 const AnimatedRoleCardWrapper({
  super.key,
  required this.child,
  required this.index,
 });

 @override
 State<AnimatedRoleCardWrapper> createState() => _AnimatedRoleCardWrapperState();
}

class _AnimatedRoleCardWrapperState extends State<AnimatedRoleCardWrapper> with SingleTickerProviderStateMixin {
 late AnimationController _controller;
 late Animation<Offset> _slideAnimation;
 late Animation<double> _opacityAnimation;

 @override
 void initState() {
  super.initState();
  _controller = AnimationController(
   vsync: this,
   duration: const Duration(milliseconds: 700), // Total animation duration
  );

  // Slide from slightly below (Y: 0.1) to its final position (Y: 0.0)
  _slideAnimation = Tween<Offset>(
   begin: const Offset(0.0, 0.5), // Start 50% height below
   end: const Offset(0.0, 0.0),
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  // Fade from transparent (0.0) to fully opaque (1.0)
  _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

  // Apply a staggered delay based on the index (0, 1, 2, 3)
  Future.delayed(Duration(milliseconds: 100 * widget.index), () {
   if (mounted) {
    _controller.forward();
   }
  });
 }

 @override
 void dispose() {
  _controller.dispose();
  super.dispose();
 }

 @override
 Widget build(BuildContext context) {
  return FadeTransition(
   opacity: _opacityAnimation,
   child: SlideTransition(
    position: _slideAnimation,
    child: widget.child,
   ),
  );
 }
}


// ----------------------------------------------------------------------

// --- Main Screen (Improved) ---
class DummyNavigatorScreen extends StatelessWidget {
 const DummyNavigatorScreen({super.key});

 void _navigate(BuildContext context, Widget page) {
  Navigator.of(context).pushAndRemoveUntil(
   MaterialPageRoute(builder: (context) => page),
   (Route<dynamic> route) => false,
  );
 }

 @override
 Widget build(BuildContext context) {
  return Scaffold(
   extendBodyBehindAppBar: true,
   appBar: AppBar(
    systemOverlayStyle: SystemUiOverlayStyle.light,
    backgroundColor: Colors.transparent,
    elevation: 0,
    title: null,
    centerTitle: true,
    // actions: [
    //  Padding(
    //   padding: const EdgeInsets.only(right: 20.0),
    //   child: Icon(Icons.fitness_center, color: AppColors.accentText.withOpacity(0.8), size: 30),
    //  ),
    // ],
   ),
   body: Stack(
    fit: StackFit.expand,
    children: [
     // 1. Background Image
     Image.asset(
      _kBgImageUrl,
      fit: BoxFit.cover,
      // loadingBuilder: (context, child, loadingProgress) {
      //  if (loadingProgress == null) return child;
      //  // Placeholder for image loading, making it look professional
      //  return Container(color: Colors.black);
      // },
      errorBuilder: (context, error, stackTrace) => Container(
       color: AppColors.darkGreen, // Fallback color
       child: Center(child: Icon(Icons.broken_image, color: Colors.white70, size: 50)),
      ),
      color: Colors.black.withOpacity(0.2), // Darker overlay for better text readability
      colorBlendMode: BlendMode.darken,
     ),
     
     // 2. Content
     SafeArea(
      child: Padding(
       padding: const EdgeInsets.symmetric(horizontal: 24), // Slightly smaller horizontal padding
       child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
         // Header
         const SizedBox(height: 30), // Extra space after SafeArea for better top alignment
         const Text(
          'PLAYZ',
          style: TextStyle(
           fontSize: 54, // Larger, more impactful title
           fontWeight: FontWeight.w900,
           color: AppColors.accentText,
           letterSpacing: 4.0, // Wider letter spacing for drama
           shadows: [
            Shadow(
             blurRadius: 15, // Softer shadow
             color: Colors.black87,
             offset: Offset(0, 5),
            ),
           ],
          ),
          textAlign: TextAlign.center,
         ),
         const SizedBox(height: 8),
         Text(
          'Your All-in-One Sports Platform. Choose your path.',
          style: TextStyle(
           fontSize: 17,
           fontWeight: FontWeight.w400,
           color: AppColors.accentText.withOpacity(0.85),
           letterSpacing: 0.8,
           shadows: const [
            Shadow(
             blurRadius: 4,
             color: Colors.black38,
             offset: Offset(0, 1),
            ),
           ],
          ),
          textAlign: TextAlign.center,
         ),

         // Dynamic spacing to push buttons towards the center/bottom
         const Spacer(), 

         // Role Selection Buttons (Wrapped with the new Animator)
         Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           AnimatedRoleCardWrapper(
            index: 0,
            child: RoleSelectionCard(
             label: "User",
             subLabel: "Player / Athlete",
             icon: Icons.sports_soccer_outlined,
             color: AppColors.primaryGreen,
             onPressed: () async {
              UserSettings userSettings = await UserSettings().loadSettings();
              if (userSettings.isLoggedIn) {
               _navigate(context, const NavigationSport());
              } else {
               _navigate(context, const UserWalkthroughScreen());
              }
             },
            ),
           ),
           AnimatedRoleCardWrapper(
            index: 1,
            child: RoleSelectionCard(
             label: "Owner",
             subLabel: "Venue Manager",
             icon: Icons.store_mall_directory_outlined,
             color: AppColors.darkGreen,
             onPressed: () async {
              OwnerSettings ownerSettings = await OwnerSettings().loadSettings();
              if (ownerSettings.isLoggedIn) {
               _navigate(context, const OwnerDashBoardScreen());
              } else {
               _navigate(context, const OwnerWalkthroughScreen());
              }
             },
            ),
           ),
           AnimatedRoleCardWrapper(
            index: 2,
            child: RoleSelectionCard(
             label: "Trainer",
             subLabel: "Coach / Instructor",
             icon: Icons.fitness_center_outlined,
             color: Colors.orange.shade600, // A vibrant accent color
             onPressed: () async {
              TrainerSettings ownerSettings = await TrainerSettings().loadSettings();
              if (ownerSettings.isLoggedIn) {
               _navigate(context, const TrainerNavigation());
              } else {
               _navigate(context, const TrainerWalkthroughScreen());
              }
             },
            ),
           ),
           AnimatedRoleCardWrapper(
            index: 3,
            child: RoleSelectionCard(
             label: "Worker",
             subLabel: "Staff / Support",
             icon: Icons.handyman_outlined,
             color: Colors.blueGrey.shade600, // A neutral, professional color
             onPressed: () async {
              WorkerSettings workerSettings = await WorkerSettings().loadSettings();
              if (workerSettings.isLoggedIn) {
               _navigate(context, const WorkernavigatorPage());
              } else {
               _navigate(context, const WorkerWalkthroughScreen());
              }
             },
            ),
           ),
          ],
         ),
         
         // Dynamic Spacing
         const SizedBox(height: 40), 

         // Footer
         Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
            Icon(Icons.copyright, color: AppColors.accentText.withOpacity(0.6), size: 16),
            const SizedBox(width: 6),
            Text(
             'Playz - All rights reserved.',
             style: TextStyle(
              color: AppColors.accentText.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
             ),
            ),
           ],
          ),
         ),
        ],
       ),
      ),
     ),
    ],
   ),
  );
 }
}