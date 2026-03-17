import 'package:flutter/material.dart';
import '../models/screen_time_model.dart';
import '../services/screen_tracking_service.dart';

class ScreenProvider extends ChangeNotifier {
  final ScreenTrackingService _trackingService = ScreenTrackingService();

  DashboardStatsModel? _stats;
  bool _isLoading = false;
  String? _errorMessage;
  Future<void>? _ongoingFetch;

  DashboardStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Gọi hàm này khi khởi động màn hình Dashboard
  Future<void> fetchAndSyncStats({bool forceRefresh = false}) {
    if (_ongoingFetch != null) {
      return _ongoingFetch!;
    }

    if (!forceRefresh && (_isLoading || _stats != null)) {
      return Future.value();
    }

    final future = _fetchAndSyncStatsInternal();
    _ongoingFetch = future.whenComplete(() {
      _ongoingFetch = null;
    });
    return _ongoingFetch!;
  }

  Future<void> _fetchAndSyncStatsInternal() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Báo UI hiện vòng xoay

    try {
      _stats = await _trackingService.syncAndGetDashboardData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // Báo UI tắt vòng xoay và cập nhật số liệu
    }
  }
}
