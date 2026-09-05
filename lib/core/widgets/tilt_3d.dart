import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Wraps a child with a subtle 3D tilt that follows the cursor on hover,
/// plus a lift + glow shadow. Smooth exit animation for a premium feel.
class Tilt3D extends StatefulWidget {
  const Tilt3D({
    super.key,
    required this.child,
    this.maxTiltDegrees = 7,
    this.onTap,
  });

  final Widget child;
  final double maxTiltDegrees;
  final VoidCallback? onTap;

  @override
  State<Tilt3D> createState() => _Tilt3DState();
}

class _Tilt3DState extends State<Tilt3D> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dx = 0;
  double _dy = 0;
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEnterEvent event) {
    if (!_enabled) return;
    _controller.forward();
  }

  void _onExit(PointerExitEvent event) {
    if (!_enabled) return;
    _controller.reverse();
    setState(() {
      _dx = 0;
      _dy = 0;
    });
  }

  void _onHover(PointerHoverEvent event) {
    if (!_enabled) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || box.hasSize == false) return;
    final size = box.size;
    if (size.width == 0 || size.height == 0) return;
    final local = box.globalToLocal(event.position);
    _dx = (((local.dx / size.width) - 0.5) * 2).clamp(-1.0, 1.0);
    _dy = (((local.dy / size.height) - 0.5) * 2).clamp(-1.0, 1.0);
    setState(() {});
  }

  void _handleTapDown(TapDownDetails details) {
    _enabled = false;
    _controller.reverse();
    setState(() {
      _dx = 0;
      _dy = 0;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    _enabled = true;
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final t = _controller.value;
    final tiltX = -_dy * widget.maxTiltDegrees * t;
    final tiltY = _dx * widget.maxTiltDegrees * t;

    final transform = Matrix4.identity()
      ..setEntry(3, 2, 0.0012)
      ..rotateX(tiltX * math.pi / 180)
      ..rotateY(tiltY * math.pi / 180);

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: _onEnter,
      onExit: _onExit,
      onHover: _onHover,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: () {
          _enabled = true;
          _controller.forward();
        },
        child: AnimatedBuilder(
          animation: _controller,
          child: widget.child,
          builder: (context, child) {
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  if (t > 0)
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.16 * t),
                      blurRadius: 28,
                      offset: Offset(0, 12 * t),
                    ),
                ],
              ),
              child: Transform(
                alignment: Alignment.center,
                transform: transform,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}
