import 'package:flutter/material.dart';
import 'package:playz_user/View/navigationformodules.dart';
import 'package:playz_user/View/user_view/reusable.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _curveAnimationController;
  late Animation<double> _curveAnimation;

  late AnimationController _logoTextAnimationController;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // 1️⃣ Green background animation (goes upward)
    _curveAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    );
    _curveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _curveAnimationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // 2️⃣ Logo + Text animations
    _logoTextAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoTextAnimationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoTextAnimationController,
        curve: Interval(0.0, 0.6, curve: Curves.bounceOut),
      ),
    );
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoTextAnimationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _curveAnimationController.forward().then((_) {
      _logoTextAnimationController.forward();
    });

    _logoTextAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(Duration(milliseconds: 1000), () {
          Navigator.of(
            context,
          ).pushReplacement(MaterialPageRoute(builder: (_) => DummyNavigatorScreen()));
        });
      }
    });
  }

  @override
  void dispose() {
    _curveAnimationController.dispose();
    _logoTextAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _curveAnimationController,
        builder: (context, child) {
          final screenHeight = MediaQuery.of(context).size.height;
          final greenHeight = screenHeight * _curveAnimation.value;

          return Stack(
            children: <Widget>[
              // --- Animated Curved Background ---
              Align(
                alignment: Alignment.bottomCenter,
                child: CustomPaint(
                  size: Size(double.infinity, greenHeight),
                  painter: CurvedFillPainter(progress: _curveAnimation.value),
                ),
              ),

              // --- Logo and Text ---
              if (_curveAnimation.value > 0.5)
                FadeTransition(
                  opacity: _logoOpacityAnimation,
                  child: ScaleTransition(
                    scale: _logoScaleAnimation,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            // padding: EdgeInsets.all(20),
                            height: 200,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              
                              borderRadius: BorderRadius.circular(50),
                              child: Image.asset(
                                "assets/Images/logo1.png",
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          FadeTransition(
                            opacity: _textOpacityAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'PLAYZ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Push. Power. Progress.',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// --- Custom Painter with dynamic curvature ---
class CurvedFillPainter extends CustomPainter {
  final double progress; // 0.0 (bottom) → 1.0 (top)
  CurvedFillPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF00C853), const Color.fromARGB(255, 0, 168, 70)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();

    // Start from bottom-left
    path.moveTo(0, size.height);

    // Dynamic curve height: high at start, low near top
    double curveDepth = (1 - progress) * 120; // decreases to 0 at top

    // Draw curved top edge
    path.quadraticBezierTo(
      size.width / 2,
      size.height - curveDepth, // control point
      size.width,
      size.height, // end point
    );

    // Close to top
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CurvedFillPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// --- Dummy Home Screen ---
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home Screen')),
      body: Center(
        child: Text(
          'Welcome to your Sports App!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
