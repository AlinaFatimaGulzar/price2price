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
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.sage,
            AppColors.accent.withValues(alpha: 0.14),
            AppColors.paper,
          ],
          stops: const [0, 0.55, 1],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 640;
          final titleWidget = Text(
            title,
            style: Theme.of(context).textTheme.displaySmall,
          );
          final subtitleWidget = Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge,
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
                      color: AppColors.surface.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(18),
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
                          const SizedBox(height: 12),
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
      decoration: InputDecoration(
        hintText: hint ?? 'Search...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: AppColors.surface.withValues(alpha: 0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
