import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/services/launch_service.dart';
import '../../cars/data/customer_car_repository.dart';
import '../../cars/domain/car.dart';
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
    this.launchService = const UrlLaunchService(),
  });

  final Showroom showroom;
  final CustomerCarRepository? carRepository;
  final ReviewRepository? reviewRepository;
  final LaunchService launchService;

  @override
  State<ShowroomDetailPage> createState() => _ShowroomDetailPageState();
}

class _ShowroomDetailPageState extends State<ShowroomDetailPage> {
  late final CustomerCarRepository _repository =
      widget.carRepository ?? const SupabaseCustomerCarRepository();
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
                color: AppColors.paper.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(14),
                child: const BackButton(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.sage, Color(0xFFB9D3C3)],
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.storefront,
                  size: 88,
                  color: AppColors.ink,
                ),
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
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  showroom.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
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
                          style: Theme.of(context).textTheme.bodyLarge,
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
                  Text(
                    'Available Cars',
                    style: Theme.of(context).textTheme.headlineSmall,
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
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
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
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text('No cars available at this showroom yet'),
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
