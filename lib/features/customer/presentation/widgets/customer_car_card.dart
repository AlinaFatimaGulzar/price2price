import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/widgets/tilt_3d.dart';
import '../../../../core/utils/formatters.dart';
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
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
        ),
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
    final fallback = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.sage, Color(0xFFB9D3C3)],
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.directions_car_filled,
        size: 54,
        color: AppColors.ink,
      ),
    );

    final imageWidget = image == null || image!.trim().isEmpty
        ? fallback
        : Image.network(
            image!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, _, _) => fallback,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return fallback;
            },
          );

    return Stack(
      fit: StackFit.expand,
      children: [
        imageWidget,
        Positioned(
          top: 10,
          left: 10,
          child: _Chip(
            color: car.condition == 'new' ? AppColors.accent : AppColors.ink,
            label: car.condition == 'new' ? 'NEW' : 'USED',
          ),
        ),
        if (car.fuel != null)
          Positioned(
            top: 10,
            right: 10,
            child: _Chip(
              color: AppColors.ink.withValues(alpha: 0.75),
              label: car.fuel!.toUpperCase(),
            ),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
