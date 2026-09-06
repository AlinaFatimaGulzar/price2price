import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../showrooms/domain/showroom.dart';
import '../data/supabase_admin_showroom_repository.dart';
import '../domain/admin_showroom_repository.dart';
import 'showroom_form_page.dart';

class AdminShowroomsPage extends StatefulWidget {
  const AdminShowroomsPage({super.key, this.repository});

  final AdminShowroomRepository? repository;

  @override
  State<AdminShowroomsPage> createState() => _AdminShowroomsPageState();
}

class _AdminShowroomsPageState extends State<AdminShowroomsPage> {
  late final AdminShowroomRepository _repository =
      widget.repository ?? const SupabaseAdminShowroomRepository();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Showroom>> _showroomsFuture;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _showroomsFuture = _repository.getAllShowrooms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() {
    setState(() {
      _showroomsFuture = _repository.getAllShowrooms();
    });
  }

  void _search(String query) {
    setState(() {
      _showroomsFuture = query.trim().isEmpty
          ? _repository.getAllShowrooms()
          : _repository.searchAllShowrooms(query.trim());
    });
  }

  Future<void> _openForm({Showroom? showroom}) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ShowroomFormPage(showroom: showroom)),
    );
    if (result == true) _reload();
  }

  Future<void> _confirmAndDelete(Showroom showroom) async {
    final confirmed = await _showConfirmDialog(
      title: 'Delete Showroom',
      message:
          'Are you sure you want to delete "${showroom.name}"? '
          'This action cannot be undone.',
      confirmLabel: 'Delete',
      isDanger: true,
    );
    if (confirmed != true) return;

    await _runAction(() async {
      await _repository.deleteShowroom(showroom.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted "${showroom.name}"')));
    });
    if (mounted) _reload();
  }

  Future<void> _setStatus(Showroom showroom, String status) async {
    final confirmed = await _showConfirmDialog(
      title: status == 'approved' ? 'Approve Showroom' : 'Reject Showroom',
      message: status == 'approved'
          ? 'Approve "${showroom.name}"? It will become visible to customers.'
          : 'Reject "${showroom.name}"? It will be hidden from customers.',
      confirmLabel: status == 'approved' ? 'Approve' : 'Reject',
      isDanger: status != 'approved',
    );
    if (confirmed != true) return;

    await _runAction(
      () => _repository.updateShowroomStatus(showroom.id, status),
    );
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
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: isDanger ? Colors.red : AppColors.accent,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
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
                  'Manage Showrooms',
                  style: Theme.of(context).textTheme.displaySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isBusy ? null : () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Add Showroom'),
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
              labelText: 'Search showrooms',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Showroom>>(
              future: _showroomsFuture,
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

                final showrooms = snapshot.data ?? [];

                if (showrooms.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.store_outlined,
                          size: 64,
                          color: AppColors.mutedInk,
                        ),
                        SizedBox(height: 16),
                        Text('No showrooms found'),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: showrooms.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _AdminShowroomCard(
                      showroom: showrooms[index],
                      onEdit: () => _openForm(showroom: showrooms[index]),
                      onDelete: () => _confirmAndDelete(showrooms[index]),
                      onApprove: () => _setStatus(showrooms[index], 'approved'),
                      onReject: () => _setStatus(showrooms[index], 'rejected'),
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

class _AdminShowroomCard extends StatelessWidget {
  const _AdminShowroomCard({
    required this.showroom,
    required this.onEdit,
    required this.onDelete,
    required this.onApprove,
    required this.onReject,
  });

  final Showroom showroom;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (showroom.imageUrl != null) ...[
              Container(
                width: 72,
                height: 58,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: AppColors.sage,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Image.network(
                  showroom.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.store,
                    color: AppColors.accent,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          showroom.name,
                          style: Theme.of(context).textTheme.headlineSmall,
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
                            showroom.status,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          showroom.status.toUpperCase(),
                          style: TextStyle(
                            color: _statusColor(showroom.status),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${showroom.address}, ${showroom.city}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Avg rating: ${showroom.averageRating} '
                    '(${showroom.reviewCount} reviews)',
                    style: Theme.of(context).textTheme.bodySmall,
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
                if (showroom.status != 'approved')
                  IconButton(
                    onPressed: onApprove,
                    icon: const Icon(Icons.check_circle_outline),
                    tooltip: 'Approve',
                    color: Colors.green,
                  ),
                if (showroom.status != 'rejected')
                  IconButton(
                    onPressed: onReject,
                    icon: const Icon(Icons.cancel_outlined),
                    tooltip: 'Reject',
                    color: Colors.red,
                  ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
