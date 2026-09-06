import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

class ImagePickerField extends StatelessWidget {
  const ImagePickerField({
    super.key,
    required this.label,
    this.bytes,
    this.existingUrl,
    this.isUploading = false,
    this.canClear = true,
    required this.onPick,
    this.onClear,
  });

  final String label;
  final Uint8List? bytes;
  final String? existingUrl;
  final bool isUploading;
  final bool canClear;
  final Future<void> Function() onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasImage = bytes != null || existingUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.mutedInk,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1C3443), Color(0xFF0D1B24)],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: hasImage ? _buildPreview() : const _NoImagePlaceholder(),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isUploading ? null : onPick,
                        icon: isUploading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.accent,
                                ),
                              )
                            : const Icon(Icons.add_photo_alternate_outlined),
                        label: Text(
                          isUploading
                              ? 'Uploading...'
                              : hasImage
                              ? 'Change Image'
                              : 'Choose Image',
                        ),
                      ),
                    ),
                    if (hasImage && canClear) ...[
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: isUploading ? null : onClear,
                        tooltip: 'Remove image',
                        icon: const Icon(Icons.delete_outline),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    if (bytes != null) {
      return Image.memory(bytes!, fit: BoxFit.cover);
    }
    return Image.network(
      existingUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const _NoImagePlaceholder();
      },
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
        );
      },
    );
  }
}

class _NoImagePlaceholder extends StatelessWidget {
  const _NoImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 48,
            color: AppColors.mutedInk,
          ),
          SizedBox(height: 8),
          Text(
            'No image selected',
            style: TextStyle(color: AppColors.mutedInk),
          ),
        ],
      ),
    );
  }
}
