import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// A liquid-glass dialog shell used for confirmations and alerts.
class LiquidDialog extends StatelessWidget {
  const LiquidDialog({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(24, 24, 24, 14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        decoration: AppGlass.liquid(),
        padding: padding,
        child: child,
      ),
    );
  }
}

/// A simple dark glass card with a hairline border and soft elevation.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppRadius.lg,
    this.color = AppColors.surface,
    this.borderColor,
    this.shadows,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final Color? borderColor;
  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: AppGlass.card(
            radius: radius,
            color: color,
            borderColor: borderColor,
            shadows: shadows,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// A shimmering glass block used to build premium skeleton loaders.
class GlassSkeleton extends StatefulWidget {
  const GlassSkeleton({
    super.key,
    this.width,
    this.height,
    this.radius = AppRadius.md,
    this.shape = BoxShape.rectangle,
  });

  final double? width;
  final double? height;
  final double radius;
  final BoxShape shape;

  @override
  State<GlassSkeleton> createState() => _GlassSkeletonState();
}

class _GlassSkeletonState extends State<GlassSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.35 + (_controller.value * 0.45);
        return Opacity(
          opacity: opacity,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: const Color(0x1FFFFFFF).withValues(alpha: 0.14),
              shape: widget.shape,
              borderRadius: widget.shape == BoxShape.rectangle
                  ? BorderRadius.circular(widget.radius)
                  : null,
              border: Border.all(color: AppColors.border),
            ),
          ),
        );
      },
    );
  }
}

/// A premium skeleton preview for a vehicle inventory card.
class SkeletonCarCard extends StatelessWidget {
  const SkeletonCarCard({super.key, this.aspect = 0.86});

  final double aspect;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspect,
      child: Container(
        decoration: AppGlass.card(color: AppColors.surface),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 5, child: GlassSkeleton(radius: 0)),
            const Expanded(flex: 4, child: SizedBox()),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GlassSkeleton(
                    width: double.infinity,
                    height: 14,
                    radius: 6,
                  ),
                  const SizedBox(height: 8),
                  const GlassSkeleton(width: 120, height: 10, radius: 5),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const GlassSkeleton(width: 90, height: 16, radius: 6),
                      Container(
                        width: 54,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A premium skeleton preview for a showroom card.
class SkeletonShowroomCard extends StatelessWidget {
  const SkeletonShowroomCard({super.key, this.aspect = 2.1});

  final double aspect;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspect,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppGlass.card(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const GlassSkeleton(width: 58, height: 58, radius: 16),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GlassSkeleton(
                        width: double.infinity,
                        height: 15,
                        radius: 6,
                      ),
                      const SizedBox(height: 10),
                      const GlassSkeleton(width: 130, height: 11, radius: 5),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const GlassSkeleton(width: 16, height: 16, radius: 8),
                const SizedBox(width: 6),
                const Expanded(child: GlassSkeleton(height: 11, radius: 5)),
                const SizedBox(width: 10),
                GlassSkeleton(width: 56, height: 22, radius: 11),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A grid of skeleton cards matching the showroom grid.
class ShowroomSkeletonGrid extends StatelessWidget {
  const ShowroomSkeletonGrid({
    super.key,
    this.columns = 1,
    this.aspect = 2.1,
    this.items = 6,
  });

  final int columns;
  final double aspect;
  final int items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: aspect,
      ),
      itemCount: items,
      itemBuilder: (context, index) => SkeletonShowroomCard(aspect: aspect),
    );
  }
}

/// A grid of skeleton cards matching the cars grid.
class CarSkeletonGrid extends StatelessWidget {
  const CarSkeletonGrid({
    super.key,
    this.columns = 1,
    this.aspect = 0.86,
    this.items = 6,
  });

  final int columns;
  final double aspect;
  final int items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 18,
        crossAxisSpacing: 18,
        childAspectRatio: aspect,
      ),
      itemCount: items,
      itemBuilder: (context, index) => SkeletonCarCard(aspect: aspect),
    );
  }
}
