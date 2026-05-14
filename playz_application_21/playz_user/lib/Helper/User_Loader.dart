import 'dart:async';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/user_sharedpreferences.dart';
import 'dart:math' as math;

import 'package:playz_user/View/user_view/menu(sport)/menu(sport).dart';

// bool isDark = appSettingsNotifier.value.theme == "Dark";

// ---------------- TRANSPARENT ROUTE (The Fix) ----------------
class TransparentRoute extends PageRouteBuilder {
  TransparentRoute({
    required Widget Function(BuildContext) builder,
    Duration transitionDuration = const Duration(milliseconds: 300),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) =>
             builder(context),
         // KEY FIX: Setting opaque to false allows underlying routes to be visible
         opaque: false,
         transitionDuration: transitionDuration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           // Simple fade transition for the loader screen
           return FadeTransition(opacity: animation, child: child);
         },
       );
}

// ---------------- LOADER SCREEN ----------------
class UserLoaderScreen extends StatefulWidget {
  const UserLoaderScreen({super.key});

  @override
  _UserLoaderScreenState createState() => _UserLoaderScreenState();
}

class _UserLoaderScreenState extends State<UserLoaderScreen>
    with SingleTickerProviderStateMixin {
  bool isDark = appSettingsNotifier.value.theme == "Dark";
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1250),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: -math.pi / 4,
      end: math.pi / 4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeSettings>(
      valueListenable: appSettingsNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = settings.theme == "Dark";
        return Scaffold(
          // Keep background transparent to see Page 1 underneath
          backgroundColor: Colors.black.withOpacity(0.6),
          body: Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final angle = _animation.value;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002) // perspective
                    ..rotateY(angle),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating 3D sphere
                      CustomPaint(
                        painter: RealisticSpherePainter(angle, isDark),
                        size: Size(150, 150),
                      ),

                      // Overlay dummy container (replace with Image.asset if needed)
                      Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.greenAccent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(50),
                            child: Image.asset(
                              "assets/Images/user_loader_logo.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

// ---------------- REALISTIC 3D SPHERE PAINTER ----------------
class RealisticSpherePainter extends CustomPainter {
  final double angle;

  bool isDark;
  RealisticSpherePainter(this.angle, this.isDark);
  // bool isDark = appSettingsNotifier.value.theme == "Dark";
  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    // ---------- Base gradient for curvature ----------
    final baseGradient = RadialGradient(
      colors: isDark
          ? [
              Color.fromRGBO(103, 196, 0, 1), // Dark vivid lime green
              Color.fromRGBO(147, 224, 30, 1), // Vibrant yellow-green
              Color.fromRGBO(183, 245, 79, 1), // Bright greenish yellow
              Color.fromRGBO(213, 255, 130, 1), // Soft pastel lime
            ]
          : [
              Color.fromRGBO(0, 150, 68, 1),
              Color.fromRGBO(0, 200, 83, 1),
              Color.fromRGBO(51, 225, 120, 1),
              Color.fromRGBO(102, 255, 179, 1),
            ],
      stops: [0.0, 0.4, 0.75, 1.0],
      center: Alignment(-0.3, -0.3),
    );

    final basePaint = Paint()
      ..shader = baseGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, basePaint);

    // ---------- Rotating light reflection ----------
    final lightX = radius + radius * 0.5 * math.cos(angle);
    final lightY = radius + radius * 0.3 * math.sin(angle);

    final reflectionPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.6), Colors.transparent],
        stops: [0.0, 1.0],
        center: Alignment(
          (lightX - radius) / radius,
          (lightY - radius) / radius,
        ),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, reflectionPaint);

    // ---------- Add shadow edge for depth ----------
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.black.withOpacity(0.4), Colors.transparent],
        stops: [0.0, 1.0],
        center: Alignment(0.5, 0.5),
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.2));

    canvas.drawCircle(center, radius, shadowPaint);

    // ---------- Add subtle inner gloss ----------
    final glossPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.15), Colors.transparent],
        stops: [0.0, 1.0],
        center: Alignment(-0.4, -0.5),
      ).createShader(Rect.fromCircle(center: center, radius: radius * 0.9));

    canvas.drawCircle(center, radius, glossPaint);
  }

  @override
  bool shouldRepaint(covariant RealisticSpherePainter oldDelegate) => true;
}
