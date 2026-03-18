import 'package:usage_stats/usage_stats.dart';
import '../models/screen_time_model.dart';
// import 'package:dio/dio.dart';
import 'api_service.dart';

class ScreenTrackingService {
  final ApiService _apiService = ApiService();

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
      List<AppUsageData> usedApps = []; // Raise a blank for app usage

      for (var info in usageStats) {
        if (info.packageName != null && info.totalTimeInForeground != null) {
          int timeInMillis = int.tryParse(info.totalTimeInForeground!) ?? 0;

          if (timeInMillis > 0) {
            totalMillis += timeInMillis;

            int minutesUsed = timeInMillis ~/ 60000; //change millis to minutes

            if (minutesUsed > 0) {
              usedApps.add(AppUsageData(
                  packageName: info.packageName!, minutes: minutesUsed));
            }
          }
        }
      }

      return ScreenTimeSyncRequest(
        totalHours: totalMillis / (1000 * 60 * 60),
        apps: usedApps,
      );
    } catch (e) {
      return ScreenTimeSyncRequest(totalHours: 0, apps: []);
    }
  }

  // ==========================================================
  // 2. GỌI API ĐỒNG BỘ VÀ NHẬN DỮ LIỆU TỪ FASTAPI
  // ==========================================================
  Future<DashboardStatsModel> syncAndGetDashboardData() async {
    // 1. Quét dữ liệu máy (Thu thập mảng apps)
    ScreenTimeSyncRequest currentUsage = await getDailyUsageStats();

    try {
      // 2. Ném toàn bộ cục dữ liệu lên cho FastAPI phân xử
      // Lưu ý: Vì trong api_service.dart bạn đã cấu hình _baseUrl có sẵn '/api/v1',
      // nên ở đây chỉ cần gọi endpoint '/screen-time/sync' là đủ.
      final response = await _apiService.client.post(
        '/screen-time/sync',
        data: currentUsage.toJson(),
      );

      // 3. FastAPI tính toán xong sẽ trả về cục JSON chuẩn xác.
      // Hứng lấy và biến nó thành DashboardStatsModel!
      return DashboardStatsModel.fromJson(response.data);
    } catch (e) {
      throw Exception("Lỗi đồng bộ dữ liệu: $e");
    }
  }
}
