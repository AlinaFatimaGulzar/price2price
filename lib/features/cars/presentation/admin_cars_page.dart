import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/widgets/glass.dart';
import '../data/supabase_admin_car_repository.dart';
import '../domain/admin_car_repository.dart';
import '../domain/car.dart';
import 'car_form_page.dart';

class AdminCarsPage extends StatefulWidget {
  const AdminCarsPage({super.key, this.repository});

  final AdminCarRepository? repository;

  @override
  State<AdminCarsPage> createState() => _AdminCarsPageState();
}

class _AdminCarsPageState extends State<AdminCarsPage> {
  late final AdminCarRepository _repository =
      widget.repository ?? const SupabaseAdminCarRepository();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Car>> _carsFuture;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _carsFuture = _repository.getAllCars();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _carsFuture = _repository.getAllCars();
    });
  }

  void _search(String query) {
    setState(() {
      _carsFuture = query.trim().isEmpty
          ? _repository.getAllCars()
          : _repository.searchAllCars(query.trim());
    });
  }

  Future<void> _openForm({Car? car}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CarFormPage(car: car, repository: _repository),
      ),
    );
    if (result == true) _reload();
  }

  Future<void> _confirmAndDelete(Car car) async {
    final confirmed = await _showConfirmDialog(
      title: 'Delete Car',
      message:
          'Are you sure you want to delete "${car.title}"? '
          'This action cannot be undone.',
      confirmLabel: 'Delete',
      isDanger: true,
    );
    if (confirmed != true) return;

    await _runAction(() async {
      await _repository.deleteCar(car.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted "${car.title}"')));
    });
    if (mounted) _reload();
  }

  Future<void> _setStatus(Car car, String status) async {
    final confirmed = await _showConfirmDialog(
      title: status == 'approved' ? 'Approve Car' : 'Reject Car',
      message: status == 'approved'
          ? 'Approve "${car.title}"? It will become visible to customers.'
          : 'Reject "${car.title}"? It will be hidden from customers.',
      confirmLabel: status == 'approved' ? 'Approve' : 'Reject',
      isDanger: status != 'approved',
    );
    if (confirmed != true) return;

    await _runAction(() => _repository.updateCarStatus(car.id, status));
    if (mounted) _reload();
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Action failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    bool isDanger = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => LiquidDialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(color: AppColors.mutedInk, height: 1.5),
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: isDanger
                        ? AppColors.warning
                        : AppColors.accent,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmLabel),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(num? price) {
    if (price == null) return 'Price not set';
    return 'PKR ${price.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Manage Cars',
                  style: Theme.of(context).textTheme.displaySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isBusy ? null : () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add Car'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 54),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: _search,
            decoration: InputDecoration(
              labelText: 'Search cars',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Car>>(
              future: _carsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: _reload,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final cars = snapshot.data ?? [];

                if (cars.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 64,
                          color: AppColors.mutedInk,
                        ),
                        SizedBox(height: 16),
                        Text('No cars found'),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: cars.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final car = cars[index];
                    return _AdminCarCard(
                      car: car,
                      onEdit: () => _openForm(car: car),
                      onDelete: () => _confirmAndDelete(car),
                      onApprove: () => _setStatus(car, 'approved'),
                      onReject: () => _setStatus(car, 'rejected'),
                      formatPrice: _formatPrice,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminCarCard extends StatelessWidget {
  const _AdminCarCard({
    required this.car,
    required this.onEdit,
    required this.onDelete,
    required this.onApprove,
    required this.onReject,
    required this.formatPrice,
  });

  final Car car;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final String Function(num? price) formatPrice;

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.mutedInk;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Car thumbnail
            Container(
              width: 84,
              height: 68,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.sage,
                borderRadius: BorderRadius.circular(12),
              ),
              child: car.imageUrl == null
                  ? const Icon(
                      Icons.directions_car,
                      color: AppColors.accent,
                      size: 36,
                    )
                  : Image.network(
                      car.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.directions_car,
                        color: AppColors.accent,
                        size: 36,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          car.title,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(
                            car.status,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          car.status.toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(car.status),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      car.brand,
                      car.model ?? '',
                      car.year?.toString() ?? '',
                    ].where((s) => s.isNotEmpty).join(' · '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatPrice(car.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit',
                  color: AppColors.accent,
                ),
                if (car.status != 'approved')
                  IconButton(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: 'Approve',
                    color: AppColors.success,
                  ),
                if (car.status != 'rejected')
                  IconButton(
                    onPressed: onReject,
                    icon: const Icon(Icons.cancel_outlined),
                    tooltip: 'Reject',
                    color: AppColors.warning,
                  ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  color: AppColors.warning,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
