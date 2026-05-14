import 'dart:math';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';



class TurfAboutPage extends StatefulWidget {
  const TurfAboutPage({super.key});

  @override
  State<TurfAboutPage> createState() => _TurfAboutPageState();
}

class _TurfAboutPageState extends State<TurfAboutPage>
    with TickerProviderStateMixin {
  late AnimationController orbitController;
  late AnimationController colorController;
  late AnimationController fadeController;

  late Animation<double> fade1;
  late Animation<double> fade2;
  late Animation<double> fade3;

  double _scale = 1.0;
  double _hoverScale = 1.08;

  final List<String> logos = [
    'assets/logos/flutter.jpg',
    'assets/logos/firebase1.jpg',
    'assets/logos/python.jpg',
    'assets/logos/dart.jpg',
    'assets/logos/java.jpg',
    'assets/logos/gitlab.jpg',
    'assets/logos/cpp.jpg',
  ];

  @override
  void initState() {
    super.initState();

    orbitController =
        AnimationController(vsync: this, duration: const Duration(seconds: 25))
          ..repeat();

    colorController =
        AnimationController(vsync: this, duration: const Duration(seconds: 6))
          ..repeat();

    fadeController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    fade1 = CurvedAnimation(
        parent: fadeController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn));
    fade2 = CurvedAnimation(
        parent: fadeController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn));
    fade3 = CurvedAnimation(
        parent: fadeController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn));

    fadeController.forward();
  }

  @override
  void dispose() {
    orbitController.dispose();
    colorController.dispose();
    fadeController.dispose();
    super.dispose();
  }

  Color _getAnimatedColor(double t) {
    final h = (t * 360) % 360;
    return HSVColor.fromAHSV(1, h, 0.35, 1.0).toColor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([orbitController, colorController]),
        builder: (context, _) {
          final color = _getAnimatedColor(colorController.value);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // 🌌 3D Model with Orbiting Logos
                FadeTransition(
                  opacity: fade1,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 220,
                          width: 360,
                          child: AnimatedScale(
                            scale: _scale,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: color.withOpacity(0.7), width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    ..._buildOrbitingLogos(color),

                                    // 🌀 Hoverable 3D Model
                                    MouseRegion(
                                      onEnter: (_) {
                                        setState(() {
                                          _scale = _hoverScale;
                                        });
                                      },
                                      onExit: (_) {
                                        setState(() {
                                          _scale = 1.0;
                                        });
                                      },
                                      child: AnimatedScale(
                                        scale: _scale,
                                        duration:
                                            const Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                        child: ModelViewer(
                                          src: 'assets/models/3d_model.glb',
                                          alt: "3D model",
                                          cameraControls: true,
                                          autoRotate: false,
                                          backgroundColor: Colors.transparent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          child: Column(
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    color.withOpacity(0.95),
                                    Colors.white.withOpacity(0.9),
                                    color.withOpacity(0.75),
                                  ],
                                ).createShader(bounds),
                                child: const Text(
                                  "Shashi Sir",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // 🌈 About App Section
                FadeTransition(
                  opacity: fade2,
                  child: Column(
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [Colors.lightBlueAccent, color],
                        ).createShader(bounds),
                        child: const Text(
                          "About Our App",
                          style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: 150,
                        height: 2,
                        color: color.withOpacity(0.8),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 📜 Extended Information
                FadeTransition(
                  opacity: fade3,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                          height: 1.7,
                          fontFamily: 'serif',
                        ),
                        children: [
                          _highlight("We are Stack Smasher"),
                          const TextSpan(
                              text: ", a passionate team of innovators — "),
                          _highlight("Shriraj Deshpande"),
                          const TextSpan(text: ", "),
                          _highlight("Aryan Mane"),
                          const TextSpan(text: ", "),
                          _highlight("Rushikesh Pawar"),
                          const TextSpan(text: ", and "),
                          _highlight("Manish Wagh"),
                          const TextSpan(
                              text:
                                  " — driven by creativity and technology. Our journey has been deeply inspired and guided by the incredible learning environment at "),
                          _highlight("Core2Web"),
                          const TextSpan(
                              text:
                                  ", under the mentorship of the ever-inspiring "),
                          _highlight("Shashi Sir"),
                          const TextSpan(text: " and "),
                          _highlight("Akshay Sir"),
                          const TextSpan(
                              text:
                                  ", whose knowledge and dedication have shaped our technical foundation. We extend our heartfelt gratitude to our mentors "),
                          _highlight("Rahu Hatkar"),
                          const TextSpan(text: " and "),
                          _highlight("Prajwal Kadam"),
                          const TextSpan(
                              text:
                                  ", for their constant support and valuable insights, and to our team lead "),
                          _highlight("Vedant Mahajan"),
                          const TextSpan(
                              text:
                                  " for his leadership and vision. Together, we aim to build impactful digital solutions that reflect the excellence and spirit of collaboration instilled in us by our mentors and institute.\n\n"),
                          const TextSpan(
                            text:
                                "Our Turf Booking App revolutionizes how players, trainers, and turf owners interact within the sports community. The app eliminates the hassle of manual scheduling and brings all turf-related activities to your fingertips. From finding nearby grounds to real-time booking, online payments, and feedback tracking — everything happens seamlessly through an intuitive interface.\n\n",
                          ),
                          const TextSpan(
                            text:
                                "With four smart login roles — Turf Owner, Worker, Trainer, and User — the platform creates a connected ecosystem where everyone contributes to the sports experience:\n\n",
                          ),
                          _highlight("Turf Owners"),
                          const TextSpan(
                              text:
                                  " can manage ground availability, pricing, slot control, and booking analytics. "),
                          _highlight("Workers"),
                          const TextSpan(
                              text:
                                  " maintain turf conditions, lighting, and cleanliness schedules efficiently. "),
                          _highlight("Trainers"),
                          const TextSpan(
                              text:
                                  " can advertise training programs, monitor attendance, and grow their client base. "),
                          _highlight("Users"),
                          const TextSpan(
                              text:
                                  " enjoy a simple booking flow — search, select, and play.\n\n"),
                          const TextSpan(
                            text:
                                "The app also supports features like smart recommendations using AI, in-app wallet, loyalty rewards, live chat, event creation, and auto refund processing.\n\n",
                          ),
                          const TextSpan(
                            text:
                                "Built with Flutter and Firebase, it ensures speed, security, and real-time connectivity for a seamless user journey. Our mission is to promote community sports engagement by simplifying access to professional facilities and enabling players, trainers, and owners to connect effortlessly.",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🧩 Feature Cards
                FadeTransition(
                  opacity: fade3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        _buildFeatureCard(Icons.business, "Turf Owner",
                            "Manage turfs, bookings, and revenue analytics in real-time."),
                        _buildFeatureCard(Icons.engineering, "Worker",
                            "Stay organized with maintenance tasks and turf readiness updates."),
                        _buildFeatureCard(Icons.fitness_center, "Trainer",
                            "Promote sessions, manage trainees, and expand your network."),
                        _buildFeatureCard(Icons.person, "User",
                            "Book grounds, make payments, and track your match history easily."),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🌌 Orbiting Logo Animation
  List<Widget> _buildOrbitingLogos(Color color) {
    final double radius = 140;

    return List.generate(logos.length, (index) {
      final double angle =
          (orbitController.value * 2 * pi) + (index * (2 * pi / logos.length));
      final double x = radius * cos(angle);
      final double y = radius * sin(angle);

      return Positioned(
        left: 180 + x - 25,
        top: 200 + y - 25,
        child: Transform.rotate(
          angle: angle,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                logos[index],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2C), Color(0xFF23232F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.lightBlueAccent, blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.lightBlueAccent, size: 35),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white)),
          const SizedBox(height: 5),
          Text(
            desc,
            style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 13,
                height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  TextSpan _highlight(String name) => TextSpan(
        text: name,
        style: const TextStyle(
          color: Color(0xFF00C6FF),
          fontWeight: FontWeight.bold,
        ),
      );
}
