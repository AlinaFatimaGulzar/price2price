import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/automotive_art.dart';
import '../../../../core/widgets/tilt_3d.dart';
import '../../../cars/domain/car.dart';

class CustomerCarCard extends StatelessWidget {
  const CustomerCarCard({
    super.key,
    required this.car,
    required this.onTap,
    this.showroomName,
  });

  final Car car;
  final VoidCallback onTap;
  final String? showroomName;

  @override
  Widget build(BuildContext context) {
    final image = car.imageUrl;

    return Tilt3D(
      onTap: onTap,
      child: Container(
        decoration: AppGlass.card(radius: 22),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 132,
              width: double.infinity,
              child: _CarImage(image: image, car: car),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        car.brand,
                        car.model ?? '',
                        car.year?.toString() ?? '',
                      ].where((s) => s.isNotEmpty).join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (showroomName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.store,
                            size: 14,
                            color: AppColors.mutedInk,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              showroomName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Spacer(),
                    Text(
                      formatPkr(car.price),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarImage extends StatelessWidget {
  const _CarImage({required this.image, required this.car});

  final String? image;
  final Car car;

  @override
  Widget build(BuildContext context) {
    final artwork = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C1B23), Color(0xFF081118)],
        ),
      ),
      child: const AutomotiveArt(kind: AutomotiveKind.car),
    );

    final Widget imageWidget;
    if (image == null || image!.trim().isEmpty) {
      imageWidget = artwork;
    } else {
      imageWidget = Image.network(
        image!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, _, _) => artwork,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return artwork;
        },
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        // Soft dark scrim so chips stay legible over photography.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0x6000080C)],
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 10,
          child: _Chip(
            kind: car.condition == 'new' ? _ChipKind.gold : _ChipKind.glass,
            label: car.condition == 'new' ? 'NEW' : 'USED',
          ),
        ),
        if (car.fuel != null)
          Positioned(
            top: 10,
            right: 10,
            child: _Chip(kind: _ChipKind.dark, label: car.fuel!.toUpperCase()),
          ),
      ],
    );
  }
}

enum _ChipKind { gold, glass, dark }

class _Chip extends StatelessWidget {
  const _Chip({required this.kind, required this.label});

  final _ChipKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (kind) {
      _ChipKind.gold => (AppColors.accent, AppColors.onAccent),
      _ChipKind.glass => (const Color(0x24FFFFFF), AppColors.ink),
      _ChipKind.dark => (const Color(0x6600070B), Colors.white),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
