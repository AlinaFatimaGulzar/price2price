import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/launch_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/automotive_art.dart';
import '../../cars/domain/car.dart';
import '../../enquiries/data/supabase_enquiry_repository.dart';
import '../../enquiries/domain/enquiry_repository.dart';
import '../../enquiries/presentation/enquiry_sheet.dart';
import '../../showrooms/data/showroom_repository.dart';
import '../../showrooms/domain/showroom.dart';

class CarDetailPage extends StatefulWidget {
  const CarDetailPage({
    super.key,
    required this.car,
    this.showroomRepository,
    this.enquiryRepository,
    this.launchService = const UrlLaunchService(),
  });

  final Car car;
  final ShowroomRepository? showroomRepository;
  final EnquiryRepository? enquiryRepository;
  final LaunchService launchService;

  @override
  State<CarDetailPage> createState() => _CarDetailPageState();
}

class _CarDetailPageState extends State<CarDetailPage> {
  late final ShowroomRepository _repository =
      widget.showroomRepository ?? const SupabaseShowroomRepository();
  late final EnquiryRepository _enquiryRepository =
      widget.enquiryRepository ?? const SupabaseEnquiryRepository();
  late Future<Showroom?> _showroomFuture;

  @override
  void initState() {
    super.initState();
    _showroomFuture = _repository.getShowroomById(widget.car.showroomId);
  }

  @override
  Widget build(BuildContext context) {
    final car = widget.car;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            stretch: true,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: Material(
                color: const Color(0x66070F14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: const BackButton(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _CarBigImage(image: car.imageUrl),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC071116)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.title,
                    style: Theme.of(context).textTheme.displaySmall,
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
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          formatPkr(car.price),
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: AppColors.accent, fontSize: 30),
                        ),
                      ),
                      if (car.condition != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: car.condition == 'new'
                                ? AppColors.accent
                                : const Color(0x24FFFFFF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            car.condition!.toUpperCase(),
                            style: TextStyle(
                              color: car.condition == 'new'
                                  ? AppColors.onAccent
                                  : AppColors.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Specifications',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 14),
                  _SpecGrid(car: car),
                  if (car.description != null &&
                      car.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      car.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 28),
                  FutureBuilder<Showroom?>(
                    future: _showroomFuture,
                    builder: (context, snapshot) {
                      final showroom = snapshot.data;
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (showroom == null) {
                        return const SizedBox.shrink();
                      }
                      return _ShowroomPanel(
                        showroom: showroom,
                        car: car,
                        enquiryRepository: _enquiryRepository,
                        launchService: widget.launchService,
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecGrid extends StatelessWidget {
  const _SpecGrid({required this.car});

  final Car car;

  @override
  Widget build(BuildContext context) {
    final specs = <(IconData, String, String)>[
      (Icons.calendar_today_outlined, 'Year', car.year?.toString() ?? '—'),
      (Icons.speed_outlined, 'Km driven', car.km != null ? '${car.km}' : '—'),
      (Icons.local_gas_station_outlined, 'Fuel', car.fuel ?? '—'),
      (Icons.settings_outlined, 'Transmission', car.transmission ?? '—'),
      (Icons.airline_seat_recline_normal, 'Condition', car.condition ?? '—'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 3 : 2;
        final cellWidth = (constraints.maxWidth - 12 * (columns - 1)) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final spec in specs)
              SizedBox(
                width: cellWidth,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(spec.$1, size: 20, color: AppColors.accent),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              spec.$2,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              spec.$3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CarBigImage extends StatelessWidget {
  const _CarBigImage({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    final artwork = const AutomotiveArt(kind: AutomotiveKind.car);

    if (image == null || image!.trim().isEmpty) return artwork;

    return Image.network(
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
}

class _ShowroomPanel extends StatelessWidget {
  const _ShowroomPanel({
    required this.showroom,
    required this.car,
    required this.enquiryRepository,
    required this.launchService,
  });

  final Showroom showroom;
  final Car car;
  final EnquiryRepository enquiryRepository;
  final LaunchService launchService;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0x0FFFFFFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront, color: AppColors.accent, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  showroom.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                  Text(
                    showroom.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.mutedInk,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '${showroom.address}, ${showroom.city}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (showroom.phone != null || showroom.whatsapp != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                if (showroom.phone != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: () => launchService.call(showroom.phone!),
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text('Call'),
                    ),
                  ),
                if (showroom.whatsapp != null) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      onPressed: () => launchService.whatsApp(
                        phoneNumber: showroom.whatsapp!,
                        message: 'Hi, I am interested in this car.',
                      ),
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text('WhatsApp'),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                side: const BorderSide(color: AppColors.accent),
              ),
              onPressed: () => showEnquirySheet(
                context,
                repository: enquiryRepository,
                carId: car.id,
                carTitle: car.title,
                showroomId: showroom.id,
                showroomName: showroom.name,
              ),
              icon: const Icon(Icons.forum_outlined, size: 18),
              label: const Text('Send Enquiry'),
            ),
          ),
        ],
      ),
    );
  }
}
