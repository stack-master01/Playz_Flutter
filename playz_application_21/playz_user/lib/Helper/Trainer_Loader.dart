import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:playz_user/View/trainer_view/screen/screens/screens/trainer_menu.dart';



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
class TrainerLoaderScreen extends StatefulWidget {
  const TrainerLoaderScreen({super.key});

  @override
  _TrainerLoaderScreenState createState() => _TrainerLoaderScreenState();
}

class _TrainerLoaderScreenState extends State<TrainerLoaderScreen>
    with SingleTickerProviderStateMixin {
  bool isDark = isDarkTrainerThemeNotifier.value;
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
      valueListenable: isDarkTrainerThemeNotifier, // listen for changes
      builder: (context, settings, _) {
        bool isDark = isDarkTrainerThemeNotifier.value;
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
                          color: Colors.deepOrangeAccent.withOpacity(0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.deepOrange,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(50),
                            child: Image.asset(
                              "assets/Images/trainer_loader_logo.png",
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
        Color.fromRGBO(110, 38, 0, 1),   // Deep burnt orange-brown
        Color.fromRGBO(156, 52, 0, 1),   // Strong deep orange
        Color.fromRGBO(204, 68, 0, 1),   // Vivid rich orange
        Color.fromRGBO(230, 85, 13, 1),  // Bright fiery orange
      ]
    : [
        Color.fromRGBO(255, 112, 30, 1),  // Warm bright orange
        Color.fromRGBO(255, 143, 64, 1),  // Soft tangerine orange
        Color.fromRGBO(255, 176, 102, 1), // Light peach-orange
        Color.fromRGBO(255, 210, 153, 1), // Very pale warm orange
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
