import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'dart:ui' as ui;
import '../widgets/animated_gradient_background.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                              0,
                              -20 *
                                  sin(_shimmerController.value * 2 * 3.14159)),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4cc9ff).withOpacity(
                                      0.5 +
                                          0.3 *
                                              (_shimmerController.value * 2 - 1)
                                                  .abs()),
                                  blurRadius: 30,
                                  spreadRadius: 8,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF8a2be2).withOpacity(
                                      0.3 +
                                          0.2 *
                                              (_shimmerController.value * 2 - 1)
                                                  .abs()),
                                  blurRadius: 20,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/student_mate_logo.png',
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // StudentMate Title with Orbitron Font and Shimmer
                FadeTransition(
                  opacity: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _fadeController,
                      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
                    ),
                  ),
                  child: AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (bounds) {
                          return LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFFFFD700), // Gold
                              const Color(0xFFFFA500), // Orange Gold
                              const Color(0xFFDAA520), // Goldenrod
                              const Color(0xFFFFCC00), // Yellow Gold
                              const Color(0xFFFFD700), // Back to Gold
                            ],
                            stops: [
                              0.0,
                              0.25,
                              0.5,
                              0.75,
                              1.0,
                            ],
                            tileMode: TileMode.mirror,
                            transform: GradientRotation(
                              (_shimmerController.value * 2 * 3.14159),
                            ),
                          ).createShader(bounds);
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Stroked outline for stronger glowing outline effect
                            Text(
                              'StudentMate',
                              style: GoogleFonts.orbitron(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                foreground: Paint()
                                  ..style = ui.PaintingStyle.stroke
                                  ..strokeWidth = 6
                                  ..color = Colors.black.withOpacity(0.75),
                                letterSpacing: 2.5,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            // Filled gradient text with glow shadows
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFFFFD700), // Gold
                                    const Color(0xFFFFA500), // Orange Gold
                                    const Color(0xFFDAA520), // Goldenrod
                                    const Color(0xFFFFCC00), // Yellow Gold
                                    const Color(0xFFFFD700), // Back to Gold
                                  ],
                                  stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                                  tileMode: TileMode.mirror,
                                  transform: GradientRotation(
                                    (_shimmerController.value * 2 * 3.14159),
                                  ),
                                ).createShader(bounds);
                              },
                              child: Text(
                                'StudentMate',
                                style: GoogleFonts.orbitron(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2.5,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.yellow.withOpacity(0.45),
                                      blurRadius: 18,
                                      offset: const Offset(0, 0),
                                    ),
                                    Shadow(
                                      color: Colors.orange.withOpacity(0.25),
                                      blurRadius: 32,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 60),

                // Two Buttons Row
                ScaleTransition(
                  scale: Tween<double>(begin: 0.8, end: 1).animate(
                    CurvedAnimation(
                      parent: _fadeController,
                      curve: const Interval(0.4, 1, curve: Curves.easeOut),
                    ),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    alignment: WrapAlignment.center,
                    children: [
                      // Login / Sign Up Button
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/signin');
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFFFD700),
                                      const Color(0xFFFFA500),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFFD700)
                                          .withOpacity(0.5 +
                                              0.2 *
                                                  (_shimmerController.value *
                                                              2 -
                                                          1)
                                                      .abs()),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'Login / Sign Up',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // View Notes Button
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/notes');
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF2246FF),
                                      const Color(0xFF8a2be2),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4cc9ff)
                                          .withOpacity(0.5 +
                                              0.2 *
                                                  (_shimmerController.value *
                                                              2 -
                                                          1)
                                                      .abs()),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'View Notes',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
