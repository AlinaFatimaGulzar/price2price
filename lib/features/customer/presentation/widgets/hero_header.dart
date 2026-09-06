import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.emoji = Icons.directions_car,
    this.searchHint,
    this.onSearchChanged,
    this.searchController,
    this.action,
  });

  final String title;
  final String subtitle;
  final IconData emoji;
  final String? searchHint;
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? searchController;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E202A), Color(0xFF0A181F), AppColors.paper],
          stops: [0, 0.72, 1],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 640;
            final titleWidget = Text(
              title,
              style: Theme.of(context).textTheme.displaySmall,
            );
            final subtitleWidget = Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontSize: 15, height: 1.5),
            );

            final searchBar = _StyledSearch(
              controller: searchController,
              hint: searchHint,
              onChanged: onSearchChanged,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0x0FFFFFFF),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Icon(emoji, color: AppColors.accent, size: 34),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (wide) ...[titleWidget, const SizedBox(height: 8)],
                          if (!wide)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: titleWidget,
                            ),
                          subtitleWidget,
                          if (action != null) ...[
                            const SizedBox(height: 14),
                            action!,
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                if (onSearchChanged != null) ...[
                  const SizedBox(height: 20),
                  searchBar,
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StyledSearch extends StatelessWidget {
  const _StyledSearch({this.controller, this.hint, this.onChanged});

  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.ink),
      decoration: InputDecoration(
        hintText: hint ?? 'Search...',
        prefixIcon: const Icon(Icons.search, color: AppColors.accent),
        filled: true,
        fillColor: const Color(0x14FFFFFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
        ),
      ),
    );
  }
}
