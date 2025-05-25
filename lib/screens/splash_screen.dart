import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _dotsOpacity;
  late Animation<Color?> _gradientColor;

  @override
  void initState() {
    super.initState();

    // Single controller for all animations
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // Logo scale animation
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );

    // Dots opacity animation
    _dotsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Background gradient animation
    _gradientColor = ColorTween(
      begin: Colors.deepPurple.shade700,
      end: Colors.indigo.shade700,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start animation
    _controller.forward();

    // Navigate after delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => LoginScreen(),
          transitionsBuilder:
              (_, a, __, c) => FadeTransition(opacity: a, child: c),
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildDot(double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _gradientColor.value!,
                  _gradientColor.value!.withOpacity(0.8),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _logoScale,
                    child: Column(
                      children: [
                        Icon(
                          Icons.eco,
                          size: 80,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'CropAI',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Smart Agriculture Solutions',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Opacity(
                    opacity: _dotsOpacity.value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDot(0.6),
                        _buildDot(1.0),
                        _buildDot(0.6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
