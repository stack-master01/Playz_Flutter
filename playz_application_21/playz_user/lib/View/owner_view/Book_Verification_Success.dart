import 'dart:math';
import 'package:flutter/material.dart';

// --- WIDGETS ---

class SuccessVerificationScreen extends StatefulWidget {
  const SuccessVerificationScreen({super.key});

  @override
  State<SuccessVerificationScreen> createState() =>
      _SuccessVerificationScreenState();
}

class _SuccessVerificationScreenState extends State<SuccessVerificationScreen>
    with TickerProviderStateMixin {
  late AnimationController _checkController;
  late AnimationController _glowController;
  late AnimationController _textController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<Offset> _floatAnimation; // ⭐️ Added for cleaner floating

  final List<_Particle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // 1. Checkmark floating/scaling
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // 2. Glow effect
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // 3. Text shimmer
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );
    _floatAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: const Offset(0, -0.05),
    ).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 8, end: 28).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );

    _generateParticles();
  }

  void _generateParticles() {
    for (int i = 0; i < 25; i++) {
      _particles.add(
        _Particle(
          // Use slightly larger range for particles to spread out
          dx: _random.nextDouble() * 250 - 125,
          dy: _random.nextDouble() * 250 - 125,
          size: _random.nextDouble() * 4 + 2,
          opacity: _random.nextDouble(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    _glowController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double circleSize = MediaQuery.of(context).size.width * 0.40;

    return Scaffold(
      body: Container(
        // Using a static Container with Gradient is cleaner than AnimatedContainer
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A2342), // deep royal blue
              Color(0xFF1446A0), // mid royal blue
              Color(0xFF2E8FFF), // bright blue accent
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Animated Checkmark Icon
              AnimatedBuilder(
                animation: Listenable.merge([_checkController, _glowController]),
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sparkle Particles (moved inside Stack)
                      ..._particles.map((p) {
                        // Particle movement based on sine/cosine
                        final t = _checkController.value * 2 * pi;
                        final dx = p.dx * sin(t);
                        final dy = p.dy * cos(t);
                        return Transform.translate(
                          offset: Offset(dx, dy),
                          child: Opacity(
                            opacity: p.opacity * (0.5 + 0.5 * _glowController.value),
                            child: Container(
                              width: p.size,
                              height: p.size,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      }),
                      // Glowing Container
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.lightBlue.withOpacity(0.5), // Changed glow color to white for contrast
                              blurRadius: _glowAnimation.value,
                              spreadRadius: _glowAnimation.value / 3,
                            ),
                          ],
                        ),
                        // Scale and Float Animation applied to the icon container
                        child: SlideTransition(
                          position: _floatAnimation, // Float animation
                          child: ScaleTransition(
                            scale: _scaleAnimation, // Scale pulse
                            child: Container(
                              width: circleSize,
                              height: circleSize,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Color(0xFF00C853), Color(0xFF69F0AE)], // Green Gradient
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: circleSize * 0.6, // Dynamic icon size
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 50),

              // 2. Animated Shimmer Text
              ShimmerText(
                animation: _shimmerAnimation,
                text: "Verification Successful!",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------

/// Custom widget for the Shimmering Text effect.
class ShimmerText extends AnimatedWidget {
  const ShimmerText({
    super.key,
    required this.animation,
    required this.text,
  }) : super(listenable: animation);

  final Animation<double> animation;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          colors: const [
            Colors.white70,
            Colors.white,
            Colors.white70,
          ],
          // Creates a moving shimmer effect based on the animation value
          stops: [
            animation.value - 0.3,
            animation.value,
            animation.value + 0.3
          ],
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.3,
          shadows: [
            Shadow(
              color: Colors.black54,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------

// Particle model
class _Particle {
  final double dx;
  final double dy;
  final double size;
  final double opacity;

  _Particle({
    required this.dx,
    required this.dy,
    required this.size,
    required this.opacity,
  });
}