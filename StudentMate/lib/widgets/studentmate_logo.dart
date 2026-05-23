import 'package:flutter/material.dart';

class StudentMateLogo extends StatefulWidget {
  final double size;
  final bool animate;

  const StudentMateLogo({
    Key? key,
    this.size = 120,
    this.animate = true,
  }) : super(key: key);

  @override
  State<StudentMateLogo> createState() => _StudentMateLogoState();
}

class _StudentMateLogoState extends State<StudentMateLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.animate) {
      _floatController = AnimationController(
        duration: const Duration(seconds: 4),
        vsync: this,
      )..repeat(reverse: true);

      _floatAnimation = Tween<double>(begin: 0, end: 12).animate(
        CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _floatController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.size * 0.2),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4cc9ff), // Electric blue
            Color(0xFF2246ff), // Royal blue
            Color(0xFF8a2be2), // Neon purple
            Color(0xFFda70d6), // Orchid
          ],
        ),
        boxShadow: [
          // Soft blue glow
          BoxShadow(
            color: const Color(0xFF4cc9ff).withOpacity(0.6),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          // Purple glow
          BoxShadow(
            color: const Color(0xFF8a2be2).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top circle accent
            Container(
              width: widget.size * 0.35,
              height: widget.size * 0.15,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.2),
                  ],
                ),
              ),
            ),
            SizedBox(height: widget.size * 0.08),
            // SM Text
            Text(
              'SM',
              style: TextStyle(
                fontSize: widget.size * 0.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );

    if (!widget.animate) {
      return logo;
    }

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_floatAnimation.value),
          child: logo,
        );
      },
    );
  }
}
