import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/glass.dart';
import '../../../core/widgets/status_pane.dart';
import '../../cars/data/customer_car_repository.dart';
import '../../cars/domain/car.dart';
import 'car_detail_page.dart';
import 'widgets/customer_car_card.dart';
import 'widgets/hero_header.dart';

enum _SortMode { newest, priceLowHigh, priceHighLow }

class BrowseCarsPage extends StatefulWidget {
  const BrowseCarsPage({super.key, this.repository});

  final CustomerCarRepository? repository;

  @override
  State<BrowseCarsPage> createState() => _BrowseCarsPageState();
}

class _BrowseCarsPageState extends State<BrowseCarsPage> {
  late final CustomerCarRepository _repository =
      widget.repository ?? const SupabaseCustomerCarRepository();
  late Future<List<Car>> _carsFuture;
  final TextEditingController _searchController = TextEditingController();

  String? _fuel;
  String? _transmission;
  String? _condition;
  int? _maxPrice;
  _SortMode _sort = _SortMode.newest;
  int _appliedFilters = 0;

  @override
  void initState() {
    super.initState();
    _carsFuture = _repository.getApprovedCars();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _carsFuture = _repository.getApprovedCars();
    });
  }

  List<Car> _applyFilters(List<Car> cars, String query) {
    final q = query.trim().toLowerCase();
    var result = cars.where((c) {
      if (_fuel != null && c.fuel != _fuel) return false;
      if (_transmission != null && c.transmission != _transmission) {
        return false;
      }
      if (_condition != null && c.condition != _condition) return false;
      if (_maxPrice != null && (c.price ?? 0) > _maxPrice!) return false;
      if (q.isEmpty) return true;
      return c.title.toLowerCase().contains(q) ||
          c.brand.toLowerCase().contains(q) ||
          (c.model?.toLowerCase().contains(q) ?? false) ||
          (c.year?.toString() == q);
    }).toList();

    switch (_sort) {
      case _SortMode.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case _SortMode.priceLowHigh:
        result.sort((a, b) => (a.price ?? 0).compareTo((b.price ?? 0)));
        break;
      case _SortMode.priceHighLow:
        result.sort((a, b) => (b.price ?? 0).compareTo((a.price ?? 0)));
        break;
    }
    return result;
  }

  Future<void> _openFilters() async {
    final applied = await showModalBottomSheet<_FiltersResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) => _FiltersSheet(
        initialFuel: _fuel,
        initialTransmission: _transmission,
        initialCondition: _condition,
        initialMaxPrice: _maxPrice,
        initialSort: _sort,
      ),
    );
    if (applied == null) return;

    setState(() {
      _fuel = applied.fuel;
      _transmission = applied.transmission;
      _condition = applied.condition;
      _maxPrice = applied.maxPrice;
      _sort = applied.sort;
      _appliedFilters =
          (_fuel != null ? 1 : 0) +
          (_transmission != null ? 1 : 0) +
          (_condition != null ? 1 : 0) +
          (_maxPrice != null ? 1 : 0);
    });
  }

  int get _activeCount => _appliedFilters;

  int _columnsFor(double width) => width >= 1100
      ? 4
      : width >= 760
      ? 3
      : width >= 480
      ? 2
      : 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            HeroHeader(
              title: 'Browse Cars',
              subtitle: 'Handpicked cars from trusted showrooms in Gujranwala',
              emoji: Icons.directions_car_filled,
              searchHint: 'Search by title, brand, model or year',
              searchController: _searchController,
              onSearchChanged: (_) => setState(() {}),
              action: _FilterChipsBar(
                onFiltersTap: _openFilters,
                activeCount: _activeCount,
                currentSort: _sort,
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Car>>(
                future: _carsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LayoutBuilder(
                      builder: (context, constraints) => CarSkeletonGrid(
                        columns: _columnsFor(constraints.maxWidth),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return StatusPane(
                      icon: Icons.error_outline,
                      message: 'Could not load cars.',
                      subtitle: 'Please try again.',
                      actionLabel: 'Retry',
                      onAction: _reload,
                    );
                  }
                  final cars = _applyFilters(
                    snapshot.data ?? [],
                    _searchController.text,
                  );
                  if (cars.isEmpty) {
                    return StatusPane(
                      icon: Icons.search_off,
                      message: 'No cars match your search',
                      subtitle: 'Try clearing filters or changing keywords.',
                      actionLabel: 'Clear filters',
                      onAction: () {
                        _searchController.clear();
                        setState(() {
                          _fuel = null;
                          _transmission = null;
                          _condition = null;
                          _maxPrice = null;
                          _appliedFilters = 0;
                          _sort = _SortMode.newest;
                        });
                      },
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
                          childAspectRatio: 0.86,
                        ),
                        itemCount: cars.length,
                        itemBuilder: (context, index) {
                          final car = cars[index];
                          return CustomerCarCard(
                            car: car,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => CarDetailPage(car: car),
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

class _FilterChipsBar extends StatelessWidget {
  const _FilterChipsBar({
    required this.onFiltersTap,
    required this.activeCount,
    required this.currentSort,
  });

  final VoidCallback onFiltersTap;
  final int activeCount;
  final _SortMode currentSort;

  @override
  Widget build(BuildContext context) {
    final sortLabel = switch (currentSort) {
      _SortMode.newest => 'Newest first',
      _SortMode.priceLowHigh => 'Price: low to high',
      _SortMode.priceHighLow => 'Price: high to low',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          ActionChip(
            avatar: activeCount > 0
                ? const Icon(Icons.check_circle, size: 18)
                : null,
            label: Text(activeCount > 0 ? 'Filters ($activeCount)' : 'Filters'),
            onPressed: onFiltersTap,
          ),
          const SizedBox(width: 8),
          Chip(
            avatar: const Icon(Icons.sort, size: 18),
            label: Text(sortLabel),
            backgroundColor: AppColors.surface,
          ),
        ],
      ),
    );
  }
}

class _FiltersResult {
  const _FiltersResult({
    this.fuel,
    this.transmission,
    this.condition,
    this.maxPrice,
    required this.sort,
  });

  final String? fuel;
  final String? transmission;
  final String? condition;
  final int? maxPrice;
  final _SortMode sort;
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({
    required this.initialFuel,
    required this.initialTransmission,
    required this.initialCondition,
    required this.initialMaxPrice,
    required this.initialSort,
  });

  final String? initialFuel;
  final String? initialTransmission;
  final String? initialCondition;
  final int? initialMaxPrice;
  final _SortMode initialSort;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late String? _fuel = widget.initialFuel;
  late String? _transmission = widget.initialTransmission;
  late String? _condition = widget.initialCondition;
  late int? _maxPrice = widget.initialMaxPrice;
  late _SortMode _sort = widget.initialSort;

  static const _priceSteps = <int, String>{
    1000000: '≤ PKR 10 lakh',
    3000000: '≤ PKR 30 lakh',
    5000000: '≤ PKR 50 lakh',
    8000000: '≤ PKR 80 lakh',
    12000000: '≤ PKR 1.2 crore',
    0: 'Any price',
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _fuel = null;
                      _transmission = null;
                      _condition = null;
                      _maxPrice = null;
                      _sort = _SortMode.newest;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OptionGroup<String>(
                      title: 'Fuel type',
                      options: const {
                        'petrol': 'Petrol',
                        'diesel': 'Diesel',
                        'hybrid': 'Hybrid',
                        'electric': 'Electric',
                        'cng': 'CNG',
                      },
                      value: _fuel,
                      onChanged: (v) => setState(() => _fuel = v),
                    ),
                    const SizedBox(height: 16),
                    _OptionGroup<String>(
                      title: 'Transmission',
                      options: const {
                        'automatic': 'Automatic',
                        'manual': 'Manual',
                      },
                      value: _transmission,
                      onChanged: (v) => setState(() => _transmission = v),
                    ),
                    const SizedBox(height: 16),
                    _OptionGroup<String>(
                      title: 'Condition',
                      options: const {'new': 'New', 'used': 'Used'},
                      value: _condition,
                      onChanged: (v) => setState(() => _condition = v),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Price',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _OptionGroup<int>(
                      options: _priceSteps,
                      value: _maxPrice,
                      onChanged: (v) => setState(() => _maxPrice = v),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sort',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _OptionGroup<_SortMode>(
                      options: const {
                        _SortMode.newest: 'Newest first',
                        _SortMode.priceLowHigh: 'Price: low to high',
                        _SortMode.priceHighLow: 'Price: high to low',
                      },
                      value: _sort,
                      onChanged: (v) => setState(() => _sort = v!),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(
                          _FiltersResult(
                            fuel: _fuel,
                            transmission: _transmission,
                            condition: _condition,
                            maxPrice: _maxPrice,
                            sort: _sort,
                          ),
                        ),
                        child: const Text('Apply'),
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

class _OptionGroup<T> extends StatelessWidget {
  const _OptionGroup({
    this.title,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String? title;
  final Map<T, String> options;
  final T? value;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in options.entries)
              ChoiceChip(
                label: Text(entry.value),
                selected: value == entry.key,
                onSelected: (_) =>
                    onChanged(value == entry.key ? null : entry.key),
              ),
          ],
        ),
      ],
    );
  }
}
