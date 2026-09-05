class DashboardStats {
  final int showrooms;
  final int pendingShowrooms;
  final int cars;
  final int pendingCars;
  final int reviews;
  final int activeUsers;
  final double avgRating;
  final List<ActivityEntry> recentActivity;

  DashboardStats({
    required this.showrooms,
    required this.pendingShowrooms,
    required this.cars,
    required this.pendingCars,
    required this.reviews,
    required this.activeUsers,
    required this.avgRating,
    required this.recentActivity,
  });

  int get pendingApprovals => pendingShowrooms + pendingCars;
}

class ActivityEntry {
  final String action;
  final String description;
  final DateTime createdAt;

  ActivityEntry({
    required this.action,
    required this.description,
    required this.createdAt,
  });
}
