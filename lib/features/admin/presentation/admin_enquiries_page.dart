import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../enquiries/data/supabase_enquiry_repository.dart';
import '../../enquiries/domain/enquiry.dart';
import '../../enquiries/domain/enquiry_repository.dart';

class AdminEnquiriesPage extends StatefulWidget {
  const AdminEnquiriesPage({super.key, this.repository});

  final EnquiryRepository? repository;

  @override
  State<AdminEnquiriesPage> createState() => _AdminEnquiriesPageState();
}

class _AdminEnquiriesPageState extends State<AdminEnquiriesPage> {
  late final EnquiryRepository _repository =
      widget.repository ?? const SupabaseEnquiryRepository();
  late Future<List<Enquiry>> _enquiriesFuture;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _enquiriesFuture = _repository.getAllEnquiries();
  }

  void _reload() {
    setState(() {
      _enquiriesFuture = _repository.getAllEnquiries();
    });
  }

  Future<void> _setStatus(Enquiry enquiry, String status) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await _repository.updateEnquiryStatus(enquiry.id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Enquiry: ${enquiry.statusLabel}')),
        );
      }
      _reload();
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
                  'Customer Enquiries',
                  style: Theme.of(context).textTheme.displaySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: _isBusy ? null : _reload,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Enquiry>>(
              future: _enquiriesFuture,
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

                final enquiries = snapshot.data ?? [];

                if (enquiries.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          size: 64,
                          color: AppColors.mutedInk,
                        ),
                        SizedBox(height: 16),
                        Text('No enquiries yet'),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: enquiries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _AdminEnquiryCard(
                      enquiry: enquiries[index],
                      isBusy: _isBusy,
                      onContacted: () =>
                          _setStatus(enquiries[index], 'contacted'),
                      onDone: () => _setStatus(enquiries[index], 'done'),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  Color get _color {
    switch (status) {
      case 'contacted':
        return const Color(0xFF62B1F6);
      case 'done':
        return Colors.green;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AdminEnquiryCard extends StatelessWidget {
  const _AdminEnquiryCard({
    required this.enquiry,
    required this.isBusy,
    required this.onContacted,
    required this.onDone,
  });

  final Enquiry enquiry;
  final bool isBusy;
  final VoidCallback onContacted;
  final VoidCallback onDone;

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }

  @override
  Widget build(BuildContext context) {
    final subject = enquiry.carTitle ?? enquiry.showroomName;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.sage,
                        child: Text(
                          enquiry.name.isNotEmpty
                              ? enquiry.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              enquiry.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              enquiry.phone,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: enquiry.status),
              ],
            ),
            if (subject != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.subject,
                    size: 15,
                    color: AppColors.mutedInk,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      subject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.mutedInk,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Text(
              enquiry.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.schedule, size: 14, color: AppColors.mutedInk),
                const SizedBox(width: 6),
                Text(
                  _formatTime(enquiry.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 12),
                if (enquiry.status != 'contacted') ...[
                  OutlinedButton(
                    onPressed: isBusy ? null : onContacted,
                    child: const Text('Contacted'),
                  ),
                  const SizedBox(width: 8),
                ],
                if (enquiry.status != 'done') ...[
                  if (enquiry.status != 'contacted') const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isBusy ? null : onDone,
                    child: const Text('Done'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
