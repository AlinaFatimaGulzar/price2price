import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// Full-screen backdrop for the public/auth screens: a deep automotive
/// gradient with soft accent glows that slowly drift, keeping every auth
/// page visually consistent and premium.
class AuthBackdrop extends StatefulWidget {
  const AuthBackdrop({super.key, required this.child});

  final Widget child;

  @override
  State<AuthBackdrop> createState() => _AuthBackdropState();
}

class _AuthBackdropState extends State<AuthBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 12000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final dx1 = (math.sin(t * 2 * math.pi) * 0.5 + 0.5);
          final dx2 = (math.sin(t * 2 * math.pi + math.pi) * 0.5 + 0.5);
          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0A1220),
                      Color(0xFF16283C),
                      Color(0xFF0D1826),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: -120 + dx1 * 120,
                top: -80,
                child: _Glow(
                  radius: 320,
                  color: AppColors.accent.withValues(alpha: 0.16),
                ),
              ),
              Positioned(
                left: -140 + dx2 * 140,
                bottom: -60,
                child: _Glow(
                  radius: 360,
                  color: const Color(0xFF3E7BFA).withValues(alpha: 0.13),
                ),
              ),
              SafeArea(child: widget.child),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: _FadeUp(
                    child: CustomPaint(
                      size: Size(double.infinity, 8),
                      painter: _RoadPainter(),
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

class _Glow extends StatelessWidget {
  const _Glow({required this.radius, required this.color});

  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _FadeUp extends StatelessWidget {
  const _FadeUp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A1220).withValues(alpha: 0),
            const Color(0xFF0A1220),
          ],
        ),
      ),
      child: child,
    );
  }
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 2;
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + 26, size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RoadPainter oldDelegate) => false;
}
