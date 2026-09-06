import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// What subject the painted artwork should depict.
enum AutomotiveKind { car, showroom }

/// Painted, asset-free automotive artwork used as a premium placeholder for
/// vehicle and showroom imagery. No network dependency, always available,
/// styled to match the midnight/gold brand language.
class AutomotiveArt extends StatelessWidget {
  const AutomotiveArt({super.key, this.kind = AutomotiveKind.car});

  final AutomotiveKind kind;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: _AutomotivePainter(kind)),
    );
  }
}

class _AutomotivePainter extends CustomPainter {
  const _AutomotivePainter(this.kind);

  final AutomotiveKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0C1B23),
            const Color(0xFF0A141B),
            const Color(0xFF081118),
          ],
        ).createShader(Offset.zero & size),
    );

    // Faint ambient gold wash near the ground so art never feels flat.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.74),
        width: w * 0.96,
        height: h * 0.34,
      ),
      Paint()
        ..shader =
            RadialGradient(
              colors: [
                AppColors.accent.withValues(alpha: 0.12),
                AppColors.accent.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCenter(
                center: Offset(w * 0.5, h * 0.74),
                width: w * 0.96,
                height: h * 0.34,
              ),
            ),
    );

    switch (kind) {
      case AutomotiveKind.car:
        _drawCar(canvas, w, h);
      case AutomotiveKind.showroom:
        _drawShowroom(canvas, w, h);
    }
  }

  void _drawCar(Canvas canvas, double w, double h) {
    final scale = math.min(w / 300, 1.25);
    final bodyTop = h * 0.52;
    final carW = 300 * scale;
    final carH = 68 * scale;

    canvas.save();
    canvas.translate((w - carW) / 2, bodyTop);

    // Ground shadow.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(carW * 0.5, carH * 0.98),
        width: carW * 0.86,
        height: carH * 0.2,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.4),
    );

    final body = _carBody(carW, carH);
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF27415A),
            const Color(0xFF152839),
            const Color(0xFF0D1A26),
          ],
        ).createShader(Rect.fromLTWH(0, 0, carW, carH)),
    );
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = Colors.white.withValues(alpha: 0.10),
    );

    // Gold belt-line stripe.
    final stripe = Path()
      ..moveTo(carW * 0.06, carH * 0.44)
      ..quadraticBezierTo(carW * 0.5, carH * 0.36, carW * 0.94, carH * 0.44)
      ..lineTo(carW * 0.94, carH * 0.485)
      ..quadraticBezierTo(carW * 0.5, carH * 0.405, carW * 0.06, carH * 0.485)
      ..close();
    canvas.drawPath(stripe, Paint()..color = AppColors.accent);

    // Glass cabin.
    final glass = Path()
      ..moveTo(carW * 0.26, carH * 0.4)
      ..quadraticBezierTo(carW * 0.41, carH * 0.14, carW * 0.63, carH * 0.15)
      ..lineTo(carW * 0.74, carH * 0.3)
      ..quadraticBezierTo(carW * 0.5, carH * 0.29, carW * 0.3, carH * 0.31)
      ..lineTo(carW * 0.26, carH * 0.4)
      ..close();
    canvas.drawPath(
      glass,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFD8ECF8).withValues(alpha: 0.85),
            const Color(0xFF4E6C86).withValues(alpha: 0.75),
            const Color(0xFF1A2C3D).withValues(alpha: 0.85),
          ],
        ).createShader(Rect.fromLTWH(0, 0, carW, carH)),
    );
    canvas.drawPath(
      glass,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3
        ..color = Colors.white.withValues(alpha: 0.22),
    );

    // Soft sheen across the body.
    canvas.save();
    canvas.clipPath(body);
    final sheen = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(Rect.fromLTWH(carW * 0.16, 0, carW * 0.28, carH));
    canvas.drawRect(Rect.fromLTWH(carW * 0.16, 0, carW * 0.28, carH), sheen);
    canvas.restore();

    // Wheels.
    for (final cx in [carW * 0.22, carW * 0.78]) {
      final center = Offset(cx, carH * 0.74);
      canvas.drawCircle(
        center,
        carH * 0.19,
        Paint()..color = const Color(0xFF05080C),
      );
      canvas.drawCircle(
        center,
        carH * 0.10,
        Paint()..color = const Color(0xFF8A97A4),
      );
      canvas.drawCircle(
        center,
        carH * 0.033,
        Paint()..color = AppColors.accent,
      );
    }

    // Headlight accent.
    canvas.save();
    canvas.clipPath(body);
    canvas.drawCircle(
      Offset(carW * 0.92, carH * 0.47),
      carW * 0.025,
      Paint()..color = const Color(0xFFFFD9A0).withValues(alpha: 0.9),
    );
    canvas.restore();

    canvas.restore();
  }

  Path _carBody(double w, double h) {
    return Path()
      ..moveTo(w * 0.05, h * 0.72)
      ..lineTo(w * 0.042, h * 0.52)
      ..quadraticBezierTo(w * 0.05, h * 0.42, w * 0.095, h * 0.45)
      ..lineTo(w * 0.165, h * 0.44)
      ..quadraticBezierTo(w * 0.27, h * 0.22, w * 0.49, h * 0.16)
      ..quadraticBezierTo(w * 0.71, h * 0.13, w * 0.83, h * 0.3)
      ..lineTo(w * 0.9, h * 0.345)
      ..quadraticBezierTo(w * 0.95, h * 0.365, w * 0.955, h * 0.47)
      ..lineTo(w * 0.962, h * 0.72)
      ..close();
  }

  void _drawShowroom(Canvas canvas, double w, double h) {
    final buildingW = w * 0.78;
    final buildingH = h * 0.46;
    final left = (w - buildingW) / 2;
    final top = h * 0.26;

    // Building mass.
    final building = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, buildingW, buildingH),
      Radius.circular(math.min(w, h) * 0.045),
    );
    canvas.drawRRect(
      building,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF1B3140), const Color(0xFF0E1B24)],
        ).createShader(building.outerRect),
    );
    canvas.drawRRect(
      building,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = AppColors.accent.withValues(alpha: 0.55),
    );

    // Showroom glass facade.
    final glass = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        left + buildingW * 0.12,
        top + buildingH * 0.2,
        buildingW * 0.76,
        buildingH * 0.6,
      ),
      Radius.circular(6),
    );
    canvas.drawRRect(
      glass,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF243F52).withValues(alpha: 0.9),
            const Color(0xFF10202C).withValues(alpha: 0.9),
          ],
        ).createShader(glass.outerRect),
    );

    // Facade mullions.
    final mullionPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.2;
    for (var i = 1; i < 4; i++) {
      final x = glass.outerRect.left + glass.outerRect.width * i / 4;
      canvas.drawLine(
        Offset(x, glass.outerRect.top),
        Offset(x, glass.outerRect.bottom),
        mullionPaint,
      );
    }
    canvas.drawLine(
      Offset(glass.outerRect.left, glass.outerRect.center.dy),
      Offset(glass.outerRect.right, glass.outerRect.center.dy),
      mullionPaint,
    );

    // Gold awning strip above the entrance.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          left + buildingW * 0.36,
          top + buildingH * 0.78,
          buildingW * 0.28,
          buildingH * 0.12,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = AppColors.accent.withValues(alpha: 0.85),
    );

    // A small car waiting in front of the dealership.
    final carW = w * 0.42;
    final carH = carW * 0.24;
    canvas.save();
    canvas.translate((w - carW) / 2, top + buildingH + h * 0.02);
    final car = _carBody(carW, carH);
    canvas.drawPath(
      car,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF2A4157),
            const Color(0xFF16293A),
            const Color(0xFF0E1B26),
          ],
        ).createShader(Rect.fromLTWH(0, 0, carW, carH)),
    );
    canvas.drawPath(
      car,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: 0.10),
    );
    final stripe = Path()
      ..moveTo(carW * 0.06, carH * 0.44)
      ..quadraticBezierTo(carW * 0.5, carH * 0.36, carW * 0.94, carH * 0.44)
      ..lineTo(carW * 0.94, carH * 0.485)
      ..quadraticBezierTo(carW * 0.5, carH * 0.405, carW * 0.06, carH * 0.485)
      ..close();
    canvas.drawPath(
      stripe,
      Paint()..color = AppColors.accent.withValues(alpha: 0.8),
    );
    for (final cx in [carW * 0.22, carW * 0.78]) {
      canvas.drawCircle(
        Offset(cx, carH * 0.74),
        carH * 0.19,
        Paint()..color = const Color(0xFF05080C),
      );
      canvas.drawCircle(
        Offset(cx, carH * 0.74),
        carH * 0.062,
        Paint()..color = AppColors.accent.withValues(alpha: 0.7),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_AutomotivePainter oldDelegate) =>
      oldDelegate.kind != kind;
}
