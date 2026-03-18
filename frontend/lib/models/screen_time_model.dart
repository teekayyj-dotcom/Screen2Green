// ============================================================================
// 1. DTO GỬI LÊN BACKEND (Khớp với ScreenTimeSyncRequest của FastAPI)
// ============================================================================
class AppUsageData {
  final String packageName;
  final int minutes;

  AppUsageData({required this.packageName, required this.minutes});

  Map<String, dynamic> toJson() {
    return {
      'package_name': packageName,
      'minutes': minutes,
    };
  }
}

class ScreenTimeSyncRequest {
  final double totalHours;
  final List<AppUsageData> apps;

  ScreenTimeSyncRequest({
    required this.totalHours,
    required this.apps,
  });

  Map<String, dynamic> toJson() {
    return {
      'total_hours': totalHours,
      'apps': apps.map((app) => app.toJson()).toList(),
    };
  }
}

// ============================================================================
// 2. MODEL NHẬN VỀ CHO DASHBOARD (Khớp với ScreenTimeDashboardResponse)
// ============================================================================
class DashboardStatsModel {
  // Chỉ số thời gian
  final double totalHours;
  final double blacklistHours;
  final double hoursProgress;
  final double blacklistProgress;

  // Chỉ số Gamification môi trường
  final int totalTrees;
  final double co2Offset;
  final int greenPoints;

  // Dữ liệu biểu đồ
  final List<double> todayUsage;
  final List<double> todayBlacklistUsage;

  DashboardStatsModel({
    required this.totalHours,
    required this.blacklistHours,
    required this.hoursProgress,
    required this.blacklistProgress,
    required this.totalTrees,
    required this.co2Offset,
    required this.greenPoints,
    required this.todayUsage,
    required this.todayBlacklistUsage,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalHours: (json['total_hours'] ?? 0).toDouble(),
      blacklistHours: (json['blacklist_hours'] ?? 0).toDouble(),
      hoursProgress:
          (json['hours_progress'] ?? json['total_progress'] ?? 0).toDouble(),
      blacklistProgress: (json['blacklist_progress'] ?? 0).toDouble(),
      totalTrees: json['total_trees'] ?? 0,
      co2Offset: (json['co2_offset'] ?? 0).toDouble(),
      greenPoints: json['green_points'] ?? 0,
      todayUsage: json['today_usage'] != null
          ? List<double>.from(json['today_usage'].map((x) => x.toDouble()))
          : [0.0, 0.0, 0.0, 0.0, 0.0],
      todayBlacklistUsage: json['today_blacklist_usage'] != null
          ? List<double>.from(
              json['today_blacklist_usage'].map((x) => x.toDouble()))
          : [0.0, 0.0, 0.0, 0.0, 0.0],
    );
  }
}
