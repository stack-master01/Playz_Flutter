import 'package:flutter/material.dart';
import 'package:playz_user/View/user_view/Login_Screen.dart';
import 'package:playz_user/View/user_view/reusable.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:math';



class UserWalkthroughScreen extends StatefulWidget {
  const UserWalkthroughScreen({super.key});

  @override
  State<UserWalkthroughScreen> createState() => _UserWalkthroughScreenState();
}

class _UserWalkthroughScreenState extends State<UserWalkthroughScreen> {
  int currentPageIndex = 0;
  final PageController _pageController = PageController();
  final int _numPages = 3;
  double _page = 0.0;

  final List<Color> _colors = [
Color.fromARGB(255, 0, 140, 58),  // dark green (rich base)
Color.fromARGB(255, 0, 170, 70),  // medium dark green
Color.fromARGB(255, 0, 200, 83),  // original sporty green (lighter dark)

  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _page = _pageController.page ?? 0.0;
         currentPageIndex = _page.round();

        
      });
    });
  }

  void _onNext() {
    if (_page < _numPages - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Walkthrough Complete!')),
      // );
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) {
        return UserLoginScreen();
      },), (Route<dynamic> route)=>false);
    }
  }

  void _onSkip() {
    _pageController.animateToPage(
      _numPages - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    int baseIndex = _page.floor();
    double t = _page - baseIndex;
    Color color = Color.lerp(
        _colors[baseIndex],
        _colors[(baseIndex + 1) >= _colors.length ? baseIndex : baseIndex + 1],
        t)!;

    return Scaffold(
      body: Stack(
        children: [
          // 🔹 Background with circles and bubbles
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              color: Colors.transparent,
              child: Stack(
                children: [
                  CustomPaint(
                    painter: ConcentricShadedCirclesPainter(primaryColor: color),
                    size: Size.infinite,
                  ),
                  WobblingCenterBox(currentPage: currentPageIndex, pageOffset: _page,),

                  const FloatingBubbles(),
                ],
              ),
            ),
          ),

          // 🔹 Page content
          PageView.builder(
            controller: _pageController,
            itemCount: _numPages,
            itemBuilder: (context, index) => _buildPageContent(index),
          ),

          // 🔹 Bottom controls
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                SmoothPageIndicator(
                  controller: _pageController,
                  count: _numPages,
                  effect: const WormEffect(
                    dotHeight: 10,
                    dotWidth: 10,
                    spacing: 8.0,
                    activeDotColor: Colors.white,
                    dotColor: Colors.white54,
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_page < _numPages - 1)
                      TextButton(
                        onPressed: _onSkip,
                        child: const Text(
                          'SKIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 44),
                    ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: color,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _page >= _numPages - 1 ? 'GET STARTED' : 'NEXT',
                        style:  TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Reusable.getGreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(int index) {
    final List<String> titles = [
      "Join the Sports Community",
"Book Solo or Team Matches",
"Track Scores & Improve Skills"
    ];
    final List<String> subtitles = [
      "Connect with players nearby, join leagues, and make new friends!",
"Reserve turf slots for solo practice or friendly games anytime!",
"Monitor performance, leaderboard stats, and learn from trainers!"
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 220),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            titles[index],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            subtitles[index],
            style: const TextStyle(fontSize: 16, color: Colors.white70
),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

// 🟣 Painter for shaded concentric circles (centered between top & mid)
class ConcentricShadedCirclesPainter extends CustomPainter {
  final Color primaryColor;

  ConcentricShadedCirclesPainter({required this.primaryColor});

  Color adjustColorBrightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Center between top and middle (~35-40%)
    final center = Offset(size.width / 2, size.height * 0.35);

    final maxRadius =
        (size.width > size.height ? size.width : size.height) * 0.6;

    final radii = [
      maxRadius * 1.3,
      maxRadius * 1.1,
      maxRadius * 0.7,
      maxRadius * 0.5,
      maxRadius * 0.35,
      maxRadius * 0.2,
      maxRadius * 0.1,
    ];

    final shadeAmounts = [0.3, 0.25, 0.1,0.05, -0.05, -0.2, -0.35];

    final random = Random(10); // keep consistent wobble

  for (int i = 0; i < radii.length; i++) {
    // Slight random offset for each circle center
    final offsetCenter = Offset(
      center.dx + (random.nextDouble() - 0.5) , // horizontal wobble
      center.dy + (random.nextDouble() - 0.5) * 60, // vertical wobble
    );

    final shadeColor = adjustColorBrightness(primaryColor, shadeAmounts[i]);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          shadeColor.withOpacity(0.4),
          adjustColorBrightness(shadeColor, 0.27).withOpacity(1),
        ],
        radius: 0.9,
      ).createShader(Rect.fromCircle(center: offsetCenter, radius: radii[i]));

    canvas.drawCircle(offsetCenter, radii[i], paint);
  }
  }

  @override
  bool shouldRepaint(covariant ConcentricShadedCirclesPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor;
  }
}

// 💫 Floating soft “bubbles” overlays for depth
class FloatingBubbles extends StatefulWidget {
  const FloatingBubbles({super.key});

  @override
  State<FloatingBubbles> createState() => _FloatingBubblesState();
}

class _FloatingBubblesState extends State<FloatingBubbles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Bubble> _bubbles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat(reverse: true);

    // Generate bubble positions ONCE to avoid flicker
    _bubbles = List.generate(6, (index) {
      return _Bubble(
        dx: _random.nextDouble(),
        dy: _random.nextDouble(),
        size: 60.0 + _random.nextDouble() * 80,
        opacity: 0.15 + _random.nextDouble() * 0.2,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height * 0.8;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: _bubbles.map((bubble) {
            return Positioned(
              left: bubble.dx * width,
              top: bubble.dy * height,
              child: Transform.translate(
                offset: Offset(0,
                    sin(_controller.value * 2 * pi + bubble.dx) * 20),
                child: Container(
                  width: bubble.size,
                  height: bubble.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(bubble.opacity),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _Bubble {
  final double dx;
  final double dy;
  final double size;
  final double opacity;
  _Bubble({
    required this.dx,
    required this.dy,
    required this.size,
    required this.opacity,
  });
}


// 🟢 Wobbling black container aligned with circle center

class WobblingCenterBox extends StatefulWidget {
  final int currentPage;
  final double pageOffset; // pass the page offset to animate color dynamically
  const WobblingCenterBox({
    super.key,
    required this.currentPage,
    required this.pageOffset,
  });

  @override
  State<WobblingCenterBox> createState() => _WobblingCenterBoxState();
}

class _WobblingCenterBoxState extends State<WobblingCenterBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const double boxSize = 300.0;

  final List<String> images = [
    'assets/Images/user1.png',
    'assets/Images/user2.png',
    'assets/Images/user3.png',
  ];

  @override
  void initState() {
    super.initState();

    // Wobble + rotation + pulse animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getContainerColor() {
    // If swiping, change color dynamically
    if ((widget.pageOffset - widget.pageOffset.round()).abs() > 0.01) {
      return Colors.blueAccent.withOpacity(0.7); // swipe color
    }
    return Colors.white70; // normal
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final centerY = screenHeight * 0.35;
    final centerX = screenWidth / 2;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Subtle wobble offsets
        final wobbleX = sin(_controller.value * 2 * pi) * 4;
        final wobbleY = cos(_controller.value * 2 * pi) * 10;
        final rotation = sin(_controller.value * 2 * pi) * 0.03; // radians
        final scale = 1 + sin(_controller.value * 2 * pi) * 0.03; // slight pulse

        return Positioned(
          top: centerY - boxSize / 2 + wobbleY,
          left: centerX - boxSize / 2 + wobbleX,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                // decoration: BoxDecoration(
                //   // color: _getContainerColor(),
                //   borderRadius: BorderRadius.circular(50),
                //   boxShadow: [
                //     BoxShadow(
                //       color: Colors.black26,
                //       blurRadius: 15,
                //       offset: const Offset(0, 8),
                //     ),
                //   ],
                // ),
                height: boxSize,
                width: boxSize,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: ClipRRect(
                    key: ValueKey(widget.currentPage),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 96, 58, 47),   
               borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                      child: Image.asset(
                        images[widget.currentPage],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
