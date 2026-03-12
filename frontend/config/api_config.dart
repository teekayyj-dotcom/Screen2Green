import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class ApiConfig {
  // Biến kReleaseMode tự động bằng true khi bạn build app để đẩy lên Store/Production
  // và bằng false khi bạn đang cắm cáp/máy ảo để code (Debug).
  static const bool isProduction = kReleaseMode;

  // 1. URL Server Thật (Khi app đã được deploy lên Cloud, ví dụ: Render, AWS, GCP)
  static const String _productionUrl = 'https://api.screen2green.com/api';

  // 2. URL Môi trường Test (Localhost)
  // Android Emulator coi máy tính của bạn là 10.0.2.2
  static const String _androidLocalUrl = 'http://10.0.2.2:8000/api';
  // iOS Simulator và Web dùng 127.0.0.1 hoặc localhost
  static const String _iosLocalUrl = 'http://127.0.0.1:8000/api';

  // Hàm Get tự động trả về đúng Base URL
  static String get baseUrl {
    // Nếu đang chạy bản thật, luôn dùng Production URL
    if (isProduction) {
      return _productionUrl;
    }

    // Nếu đang chạy bản Debug trên Web (Flutter Web không hỗ trợ dart:io nên phải check riêng)
    if (kIsWeb) {
      return _iosLocalUrl;
    }

    // Nếu đang chạy bản Debug trên Mobile
    try {
      if (Platform.isAndroid) {
        return _androidLocalUrl;
      } else if (Platform.isIOS) {
        return _iosLocalUrl;
      }
    } catch (e) {
      print('Lỗi nhận diện nền tảng: $e');
    }

    // Mặc định an toàn
    return _androidLocalUrl;
  }
}
