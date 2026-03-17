import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

class ApiService {
  late final Dio _dio;

  String get _baseUrl {
    if (kReleaseMode) {
      return 'https://api.screen2green.com/api/v1';
    }

    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }

    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api/v1';
      }

      if (Platform.isIOS) {
        return 'http://127.0.0.1:8000/api/v1';
      }
    } catch (e) {
      debugPrint('Lỗi nhận diện nền tảng: $e');
    }

    return 'http://127.0.0.1:8000/api/v1';
  }

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10), // Time out kết nối
        receiveTimeout: const Duration(seconds: 10), // Time out nhận dữ liệu
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Thêm Interceptor để tự động xử lý Request và Response
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Lấy user hiện tại từ Firebase
          final User? user = FirebaseAuth.instance.currentUser;

          if (user != null) {
            try {
              // 2. Lấy JWT Token. Hàm getIdToken() của Firebase rất thông minh,
              // nó sẽ tự động lấy token trong cache, nếu hết hạn nó mới call API để lấy token mới.
              final String? token = await user.getIdToken();

              if (token != null) {
                // 3. Gắn token vào header của request chuẩn bị gửi đi
                options.headers['Authorization'] = 'Bearer $token';
              }
            } catch (e) {
              debugPrint('Lỗi khi lấy JWT Token gắn vào header: $e');
            }
          }

          // Tiếp tục gửi request đi
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Xử lý chung các response thành công ở đây nếu cần (vd: log ra console)
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          // Xử lý lỗi chung toàn cục (Global Error Handling)
          if (e.response?.statusCode == 401) {
            debugPrint('Lỗi 401: Token không hợp lệ hoặc đã hết hạn.');
            // Có thể trigger logic đăng xuất hoặc thông báo cho user ở đây
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Expose instance của Dio ra ngoài để các Service khác (như ScreenTrackingService) sử dụng
  Dio get client => _dio;
}
