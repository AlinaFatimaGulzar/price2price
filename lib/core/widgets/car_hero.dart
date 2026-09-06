import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/tilt_3d.dart';
import '../../app/theme/app_theme.dart';

/// A stylized 3D sports sedan that subtly floats, breathes a light sheen
/// across its body, and tilts to follow the cursor on desktop. Painted with
/// pure Canvas so we need no image assets.
class CarHero extends StatefulWidget {
  const CarHero({super.key, this.size = 220});

  /// Approximate width of the painted car, in logical pixels.
  final double size;

  @override
  State<CarHero> createState() => _CarHeroState();
}

class _CarHeroState extends State<CarHero> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 7000),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tilt3D(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final float = math.sin(t * 2 * math.pi) * 4;
          final sheen = ((t * 1.6) % 1.0);
          return Transform.translate(
            offset: Offset(0, float),
            child: SizedBox(
              width: widget.size,
              height: widget.size * 0.42,
              child: CustomPaint(painter: _CarPainter(sheenX: sheen)),
            ),
          );
        },
      ),
    );
  }
}

class _CarPainter extends CustomPainter {
  const _CarPainter({required this.sheenX});

  final double sheenX;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Road + dashed lane line.
    final roadPaint = Paint()
      ..color = const Color(0xFF0C1117).withValues(alpha: 0.55);
    canvas.drawRect(Rect.fromLTRB(0, h * 0.78, w, h), roadPaint);
    final dashPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 2;
    for (double x = w * 0.04; x < w; x += w * 0.13) {
      canvas.drawLine(
        Offset(x, h * 0.9),
        Offset(math.min(x + w * 0.07, w), h * 0.9),
        dashPaint,
      );
    }

    // Soft ground glow under the car.
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            center: Alignment(0, 0),
            colors: [
              AppColors.accent.withValues(alpha: 0.28),
              AppColors.accent.withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCenter(
              center: Offset(w * 0.5, h * 0.82),
              width: w * 0.9,
              height: h * 0.5,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.82),
        width: w * 0.85,
        height: h * 0.22,
      ),
      glowPaint,
    );

    final bodyPath = _bodyPath(w, h);

    // Body shadow / silhouette beneath.
    canvas.save();
    canvas.translate(0, h * 0.05);
    canvas.scale(1, -0.25);
    final shadowPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
    canvas.drawPath(bodyPath, shadowPaint);
    canvas.restore();

    // Body with vertical gradient + racing stripe.
    final bodyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF203654),
        const Color(0xFF12202F),
        const Color(0xFF0B1520),
      ],
    );
    canvas.drawPath(
      bodyPath,
      Paint()..shader = bodyGradient.createShader(_carRect(w, h)),
    );

    // Racing stripe along the belt line.
    final stripe = Path()
      ..moveTo(w * 0.06, h * 0.44)
      ..quadraticBezierTo(w * 0.5, h * 0.36, w * 0.94, h * 0.44)
      ..lineTo(w * 0.94, h * 0.49)
      ..quadraticBezierTo(w * 0.5, h * 0.41, w * 0.06, h * 0.49)
      ..close();
    canvas.drawPath(stripe, Paint()..color = AppColors.accent);

    // Glass cabin.
    final glass = Path()
      ..moveTo(w * 0.25, h * 0.4)
      ..quadraticBezierTo(w * 0.4, h * 0.16, w * 0.62, h * 0.17)
      ..lineTo(w * 0.74, h * 0.3)
      ..quadraticBezierTo(w * 0.5, h * 0.29, w * 0.3, h * 0.31)
      ..lineTo(w * 0.25, h * 0.4)
      ..close();
    final glassPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFCDE3F2).withValues(alpha: 0.95),
          const Color(0xFF5E7C99).withValues(alpha: 0.85),
          const Color(0xFF1E3247).withValues(alpha: 0.9),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(glass, glassPaint);
    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Colors.white.withValues(alpha: 0.28),
    );

    // Light sheen sweeping along the body.
    canvas.save();
    canvas.clipPath(bodyPath);
    final bandWidth = w * 0.22;
    final bandX = sheenX * (w * 1.4) - bandWidth;
    final bandRect = Rect.fromLTWH(bandX, 0, bandWidth, h);
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.16),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(bandRect);
    canvas.drawRect(bandRect, sheenPaint);
    canvas.restore();

    // Wheels.
    for (final cx in [w * 0.22, w * 0.78]) {
      final wheelCenter = Offset(cx, h * 0.68);
      final tireR = h * 0.16;
      final rimR = h * 0.09;
      final hubR = h * 0.03;
      canvas.drawCircle(
        wheelCenter,
        tireR,
        Paint()..color = const Color(0xFF05080C),
      );
      canvas.drawCircle(
        wheelCenter,
        rimR,
        Paint()..color = const Color(0xFF9AA7B4),
      );
      final spokes = Paint()
        ..color = const Color(0xFFFFB27A).withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      for (var i = 0; i < 5; i++) {
        final angle = i * 2 * math.pi / 5 + sheenX * math.pi;
        canvas.drawLine(
          wheelCenter,
          wheelCenter + Offset(math.cos(angle), math.sin(angle)) * (rimR - 3),
          spokes,
        );
      }
      canvas.drawCircle(wheelCenter, hubR, Paint()..color = AppColors.accent);
    }

    // Accent headlight.
    canvas.save();
    canvas.clipPath(bodyPath);
    final headlight = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white,
              const Color(0xFFFFE0B5).withValues(alpha: 0.85),
              const Color(0xFFFFE0B5).withValues(alpha: 0),
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(w * 0.93, h * 0.47),
              radius: w * 0.05,
            ),
          );
    canvas.drawCircle(Offset(w * 0.93, h * 0.47), w * 0.05, headlight);
    canvas.restore();

    // Tail light.
    canvas.save();
    canvas.clipPath(bodyPath);
    canvas.drawCircle(
      Offset(w * 0.095, h * 0.475),
      w * 0.02,
      Paint()..color = const Color(0xFFFF3B30),
    );
    canvas.restore();

    // Outline for definition.
    canvas.drawPath(
      bodyPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.10),
    );
  }

  Rect _carRect(double w, double h) => Rect.fromLTWH(0, h * 0.1, w, h * 0.7);

  Path _bodyPath(double w, double h) {
    return Path()
      ..moveTo(w * 0.045, h * 0.62)
      ..lineTo(w * 0.04, h * 0.48)
      ..quadraticBezierTo(w * 0.05, h * 0.42, w * 0.09, h * 0.44)
      ..lineTo(w * 0.16, h * 0.43)
      ..quadraticBezierTo(w * 0.26, h * 0.25, w * 0.48, h * 0.2)
      ..quadraticBezierTo(w * 0.7, h * 0.17, w * 0.82, h * 0.32)
      ..lineTo(w * 0.9, h * 0.36)
      ..quadraticBezierTo(w * 0.95, h * 0.38, w * 0.955, h * 0.46)
      ..lineTo(w * 0.96, h * 0.62)
      ..close();
  }

  @override
  bool shouldRepaint(_CarPainter oldDelegate) => oldDelegate.sheenX != sheenX;
}
