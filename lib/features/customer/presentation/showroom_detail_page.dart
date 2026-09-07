import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/launch_service.dart';
import '../../../core/widgets/automotive_art.dart';
import '../../../core/widgets/glass.dart';
import '../../cars/data/customer_car_repository.dart';
import '../../cars/domain/car.dart';
import '../../enquiries/data/supabase_enquiry_repository.dart';
import '../../enquiries/domain/enquiry_repository.dart';
import '../../enquiries/presentation/enquiry_sheet.dart';
import '../../reviews/data/review_repository.dart';
import '../../showrooms/domain/showroom.dart';
import 'car_detail_page.dart';
import 'widgets/customer_car_card.dart';
import 'widgets/showroom_reviews_section.dart';

class ShowroomDetailPage extends StatefulWidget {
  const ShowroomDetailPage({
    super.key,
    required this.showroom,
    this.carRepository,
    this.reviewRepository,
    this.enquiryRepository,
    this.launchService = const UrlLaunchService(),
  });

  final Showroom showroom;
  final CustomerCarRepository? carRepository;
  final ReviewRepository? reviewRepository;
  final EnquiryRepository? enquiryRepository;
  final LaunchService launchService;

  @override
  State<ShowroomDetailPage> createState() => _ShowroomDetailPageState();
}

class _ShowroomDetailPageState extends State<ShowroomDetailPage> {
  late final CustomerCarRepository _repository =
      widget.carRepository ?? const SupabaseCustomerCarRepository();
  late final EnquiryRepository _enquiryRepository =
      widget.enquiryRepository ?? const SupabaseEnquiryRepository();
  late Future<List<Car>> _carsFuture;

  @override
  void initState() {
    super.initState();
    _carsFuture = _repository.getCarsForShowroom(widget.showroom.id);
  }

  @override
  Widget build(BuildContext context) {
    final showroom = widget.showroom;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
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
                  if (showroom.imageUrl == null)
                    const AutomotiveArt(kind: AutomotiveKind.showroom)
                  else
                    Image.network(
                      showroom.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const AutomotiveArt(kind: AutomotiveKind.showroom),
                    ),
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              showroom.name,
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 20,
                                  color: AppColors.accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  showroom.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${showroom.reviewCount} reviews)',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${showroom.address}, ${showroom.city}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  if (showroom.description != null &&
                      showroom.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    Text(
                      showroom.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  if (showroom.phone != null || showroom.whatsapp != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (showroom.phone != null)
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 50),
                              ),
                              onPressed: () =>
                                  widget.launchService.call(showroom.phone!),
                              icon: const Icon(Icons.call, size: 18),
                              label: const Text('Call'),
                            ),
                          ),
                        if (showroom.whatsapp != null) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 50),
                              ),
                              onPressed: () => widget.launchService.whatsApp(
                                phoneNumber: showroom.whatsapp!,
                                message: 'Hi, I am interested in your cars.',
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
                        minimumSize: const Size(0, 50),
                        side: const BorderSide(color: AppColors.accent),
                      ),
                      onPressed: () => showEnquirySheet(
                        context,
                        repository: _enquiryRepository,
                        showroomId: showroom.id,
                        showroomName: showroom.name,
                      ),
                      icon: const Icon(Icons.forum_outlined, size: 18),
                      label: const Text('Send Enquiry'),
                    ),
                  ),
                  if (showroom.email != null ||
                      showroom.latitude != null ||
                      showroom.longitude != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (showroom.email != null)
                          IconButton(
                            tooltip: 'Email',
                            onPressed: () => widget.launchService.mailTo(
                              email: showroom.email!,
                              subject: 'Enquiry about cars at ${showroom.name}',
                            ),
                            icon: const Icon(Icons.mail_outline),
                          ),
                        if (showroom.latitude != null &&
                            showroom.longitude != null)
                          IconButton(
                            tooltip: 'Get directions',
                            onPressed: () => widget.launchService.openMap(
                              showroom.address,
                              city: showroom.city,
                              latitude: showroom.latitude,
                              longitude: showroom.longitude,
                            ),
                            icon: const Icon(Icons.map_outlined),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Available Cars',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          FutureBuilder<List<Car>>(
            future: _carsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Column(
                      children: const [
                        SkeletonCarCard(aspect: 2.4),
                        SizedBox(height: 18),
                        SkeletonCarCard(aspect: 2.4),
                      ],
                    ),
                  ),
                );
              }
              if (snapshot.hasError) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: Text('Could not load cars')),
                  ),
                );
              }
              final cars = snapshot.data ?? [];
              if (cars.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No cars available at this showroom yet',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 320,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 0.86,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final car = cars[index];
                    return CustomerCarCard(
                      car: car,
                      showroomName: showroom.name,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CarDetailPage(car: car),
                        ),
                      ),
                    );
                  }, childCount: cars.length),
                ),
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: ShowroomReviewsSection(
                showroomId: showroom.id,
                reviewRepository: widget.reviewRepository,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
