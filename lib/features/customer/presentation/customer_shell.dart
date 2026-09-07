import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../auth/data/session_repository.dart';
import '../../cars/data/customer_car_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../profile/presentation/profile_page.dart';
import '../../reviews/data/review_repository.dart';
import '../../showrooms/data/showroom_repository.dart';
import '../../showrooms/presentation/showrooms_list_page.dart';
import 'browse_cars_page.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({
    super.key,
    this.showroomRepository,
    this.carRepository,
    this.profileRepository,
    this.reviewRepository,
    this.sessionRepository,
  });

  final ShowroomRepository? showroomRepository;
  final CustomerCarRepository? carRepository;
  final ProfileRepository? profileRepository;
  final ReviewRepository? reviewRepository;
  final SessionRepository? sessionRepository;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _index,
        children: [
          ShowroomsListPage(repository: widget.showroomRepository),
          BrowseCarsPage(repository: widget.carRepository),
          ProfilePage(
            profileRepository: widget.profileRepository,
            reviewRepository: widget.reviewRepository,
            sessionRepository: widget.sessionRepository,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xF2162B34), Color(0xF20A181F)],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.border),
            boxShadow: const [AppShadows.card],
          ),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (index) => setState(() => _index = index),
            height: 66,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.accent.withValues(alpha: 0.18),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.directions_car_outlined),
                selectedIcon: Icon(Icons.directions_car),
                label: 'Cars',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}