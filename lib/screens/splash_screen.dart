import 'dart:async';
import 'package:flutter/material.dart';
import 'onboarding_screen.dart';
import 'dart:math';

class _ParticlePainter extends CustomPainter {
  final List<Offset> particles;

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.2);
    for (var p in particles) {
      final dx = p.dx * size.width;
      final dy = p.dy * size.height;
      canvas.drawCircle(Offset(dx, dy), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoJumpAnimation;
  late Animation<double> _logoRotateAnimation;
  late Timer _timer;

  final Random _random = Random();
  final List<Offset> _particles = [];

  @override
  void initState() {
    super.initState();

    // Generate particles
    for (int i = 0; i < 50; i++) {
      _particles.add(Offset(_random.nextDouble(), _random.nextDouble()));
    }

    // Logo controller for jumping
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _logoJumpAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -50.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -50.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 100,
      ),
    ]).animate(_logoController);

    _logoRotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoController.repeat(reverse: true);

    // Navigate after 4 seconds
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          AnimatedContainer(
            duration: const Duration(seconds: 6),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Floating particles
          CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ParticlePainter(particles: _particles),
          ),
          // Animated hopping logo
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _logoJumpAnimation.value),
                  child: Transform.rotate(
                    angle: _logoRotateAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.15),
                            blurRadius: 40,
                            spreadRadius: 12,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 220,
                          height: 220,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
