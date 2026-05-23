import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget? child;

  const AnimatedGradientBackground({
    Key? key,
    this.child,
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _floatController1;
  late AnimationController _floatController2;

  @override
  void initState() {
    super.initState();

    _gradientController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _floatController1 = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);

    _floatController2 = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _floatController1.dispose();
    _floatController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient background - brighter, more luminous
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1a0d4d), // Deep blue-purple
                Color(0xFF2d1b69), // Royal blue
                Color(0xFF3d2a8f), // Bright indigo
                Color(0xFF5a3db8), // Lavender-purple
                Color(0xFF2246ff), // Electric blue
                Color(0xFF4cc9ff), // Neon blue
                Color(0xFF1b2a6b), // Deep blue
              ],
              stops: [0.0, 0.15, 0.3, 0.45, 0.6, 0.75, 1.0],
            ),
          ),
        ),

        // Animated gradient overlay with brighter colors
        AnimatedBuilder(
          animation: _gradientController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF4cc9ff)
                        .withOpacity(0.15 * _gradientController.value),
                    const Color(0xFF8a2be2)
                        .withOpacity(0.12 * (1 - _gradientController.value)),
                    const Color(0xFFda70d6)
                        .withOpacity(0.1 * _gradientController.value),
                  ],
                ),
              ),
            );
          },
        ),

        // Floating blob 1 (left) - Blue glow
        Positioned(
          left: -100,
          top: 20,
          child: AnimatedBuilder(
            animation: _floatController1,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -40 * _floatController1.value),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4cc9ff).withOpacity(0.4),
                        blurRadius: 80,
                        spreadRadius: 30,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Floating blob 2 (right) - Purple glow
        Positioned(
          right: -80,
          top: 150,
          child: AnimatedBuilder(
            animation: _floatController2,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -50 * _floatController2.value),
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF8a2be2).withOpacity(0.35),
                        blurRadius: 70,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Floating blob 3 (bottom center) - Lavender glow
        Positioned(
          bottom: -150,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedBuilder(
              animation: _floatController1,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * _floatController1.value),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFda70d6).withOpacity(0.3),
                          blurRadius: 60,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Content layer
        if (widget.child != null) widget.child!,
      ],
    );
  }
}
