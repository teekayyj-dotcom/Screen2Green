import 'package:usage_stats/usage_stats.dart';
import '../models/screen_time_model.dart';
// import 'api_service.dart'; // Mở comment khi có api_service

class ScreenTrackingService {
  // Danh sách các package name của app Blacklist (Mạng xã hội, Game...)
  // Bạn có thể thêm bớt tùy ý
  final List<String> _blacklistPackages = [
    'com.facebook.katana', // Facebook
    'com.zhiliaoapp.musically', // TikTok
    'com.instagram.android', // Instagram
    'com.google.android.youtube', // YouTube
  ];

  // ==========================================================
  // 1. LẤY VÀ PHÂN LOẠI DỮ LIỆU TỪ HỆ ĐIỀU HÀNH
  // ==========================================================
  Future<ScreenTimeSyncRequest> getDailyUsageStats() async {
    try {
      DateTime endDate = DateTime.now();
      DateTime startDate = DateTime(endDate.year, endDate.month, endDate.day);

      List<UsageInfo> usageStats =
          await UsageStats.queryUsageStats(startDate, endDate);

      double totalMillis = 0;
      double blacklistMillis = 0;

      for (var info in usageStats) {
        if (info.packageName != null && info.totalTimeInForeground != null) {
          int timeInMillis = int.tryParse(info.totalTimeInForeground!) ?? 0;

          // Cộng vào Tổng thời gian
          totalMillis += timeInMillis;

          // Nếu package nằm trong Blacklist -> Cộng thêm vào Blacklist
          if (_blacklistPackages.contains(info.packageName)) {
            blacklistMillis += timeInMillis;
          }
        }
      }

      return ScreenTimeSyncRequest(
        totalHours: totalMillis / (1000 * 60 * 60),
        blacklistHours: blacklistMillis / (1000 * 60 * 60),
      );
    } catch (e) {
      return ScreenTimeSyncRequest(totalHours: 0, blacklistHours: 0);
    }
  }

  // ==========================================================
  // 2. GỌI API ĐỒNG BỘ (/api/v1/screen-time/sync)
  // ==========================================================
  Future<DashboardStatsModel> syncAndGetDashboardData() async {
    // 1. Quét dữ liệu máy
    ScreenTimeSyncRequest currentUsage = await getDailyUsageStats();

    try {
      // ==========================================
      // [KẾT NỐI VỚI BACKEND FASTAPI THỰC TẾ]
      // final response = await apiService.post(
      //   '/api/v1/screen-time/sync',
      //   data: currentUsage.toJson(), // Gửi 2 biến total_hours và blacklist_hours
      // );
      // return DashboardStatsModel.fromJson(response.data);
      // ==========================================

      // --- MOCK DATA ĐỂ TEST UI TRONG LÚC CHỜ NỐI API ---
      await Future.delayed(const Duration(seconds: 1));

      return DashboardStatsModel(
        totalHours: double.parse(currentUsage.totalHours.toStringAsFixed(1)),
        blacklistHours:
            double.parse(currentUsage.blacklistHours.toStringAsFixed(1)),
        hoursProgress: currentUsage.totalHours / 5.0,
        blacklistProgress: currentUsage.blacklistHours / 1.5, // Target 1.5h
        totalTrees: 12,
        co2Offset: 144.0,
        greenPoints: 80,
        todayUsage: [0.5, 1.2, 2.5, 3.0, currentUsage.totalHours],
        todayBlacklistUsage: [0.2, 0.5, 1.0, 1.2, currentUsage.blacklistHours],
      );
    } catch (e) {
      throw Exception("Lỗi đồng bộ dữ liệu: $e");
    }
  }
}
