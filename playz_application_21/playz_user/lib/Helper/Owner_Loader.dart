import 'dart:async';
import 'package:flutter/material.dart';
import 'package:playz_user/Controller/owner_sharedpreferences.dart';
import 'dart:math' as math;

import 'package:playz_user/View/owner_view/Owner_Menu.dart';

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
class OwnerLoaderScreen extends StatefulWidget {
  const OwnerLoaderScreen({super.key});

  @override
  _OwnerLoaderScreenState createState() => _OwnerLoaderScreenState();
}

class _OwnerLoaderScreenState extends State<OwnerLoaderScreen>
    with SingleTickerProviderStateMixin {
  bool isDark = isDarkOwnerThemeNotifier.value;
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
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkOwnerThemeNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = isDarkOwnerThemeNotifier.value;
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
                          color: Colors.blueAccent.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color.fromRGBO(13, 71, 161, 1),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(50),
                            child: Image.asset(
                              "assets/Images/owner_loader_logo.png",
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
              Color.fromRGBO(8, 48, 110, 1), // Deep navy blue
              Color.fromRGBO(20, 88, 178, 1), // Strong royal blue
              Color.fromRGBO(58, 124, 204, 1), // Bright medium blue
              Color.fromRGBO(102, 161, 229, 1), // Soft sky blue
              // Soft pastel lime
            ]
          : [
              Color.fromRGBO(70, 109, 208, 1), // Medium bright blue
              Color.fromRGBO(115, 148, 223, 1), // Soft cornflower blue
              Color.fromRGBO(160, 186, 233, 1), // Pale light blue
              Color.fromRGBO(199, 215, 245, 1), // Very light pastel blue
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
