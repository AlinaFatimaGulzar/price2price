import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/status_pane.dart';
import '../../customer/presentation/browse_cars_page.dart';
import '../../customer/presentation/showroom_detail_page.dart';
import '../../customer/presentation/widgets/customer_showroom_card.dart';
import '../../customer/presentation/widgets/hero_header.dart';
import '../data/showroom_repository.dart';
import '../domain/showroom.dart';

class ShowroomsListPage extends StatefulWidget {
  const ShowroomsListPage({super.key, this.repository});

  final ShowroomRepository? repository;

  @override
  State<ShowroomsListPage> createState() => _ShowroomsListPageState();
}

class _ShowroomsListPageState extends State<ShowroomsListPage> {
  late final ShowroomRepository _repository =
      widget.repository ?? const SupabaseShowroomRepository();
  late Future<List<Showroom>> _showroomsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _showroomsFuture = _repository.getApprovedShowrooms();
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _showroomsFuture = _repository.getApprovedShowrooms();
      } else {
        _showroomsFuture = _repository.searchShowrooms(query);
      }
    });
  }

  void _reload() {
    setState(() {
      _showroomsFuture = _repository.getApprovedShowrooms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _columnsFor(double width) => width >= 1100
      ? 3
      : width >= 740
      ? 2
      : 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HeroHeader(
              title: 'Find your next\ncar in Gujranwala.',
              subtitle: 'Browse trusted showrooms and their cars',
              emoji: Icons.storefront,
              searchHint: 'Search showrooms...',
              searchController: _searchController,
              onSearchChanged: _search,
              action: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  minimumSize: const Size(0, 46),
                  side: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.45),
                  ),
                  backgroundColor: const Color(0x0FFFFFFF),
                ),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BrowseCarsPage(),
                  ),
                ),
                icon: const Icon(Icons.directions_car, size: 18),
                label: const Text('Browse cars'),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Showroom>>(
                future: _showroomsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LayoutBuilder(
                      builder: (context, constraints) => ShowroomSkeletonGrid(
                        columns: _columnsFor(constraints.maxWidth),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return StatusPane(
                      icon: Icons.error_outline,
                      message: 'Could not load showrooms.',
                      subtitle: 'Please try again.',
                      actionLabel: 'Retry',
                      onAction: _reload,
                    );
                  }

                  final showrooms = snapshot.data ?? [];

                  if (showrooms.isEmpty) {
                    return StatusPane(
                      icon: Icons.store_outlined,
                      message: 'No showrooms found',
                      subtitle: 'Try a different search or check back soon.',
                    );
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _columnsFor(constraints.maxWidth),
                          mainAxisSpacing: 18,
                          crossAxisSpacing: 18,
                          childAspectRatio: 2.1,
                        ),
                        itemCount: showrooms.length,
                        itemBuilder: (context, index) {
                          final showroom = showrooms[index];
                          return CustomerShowroomCard(
                            showroom: showroom,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    ShowroomDetailPage(showroom: showroom),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
