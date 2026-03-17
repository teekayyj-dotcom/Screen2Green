import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  // Trạng thái của user
  User? _user;
  bool _isAuthenticated = false;
  String? _backendSyncError;

  // Trạng thái loading chung cho các tác vụ Auth
  bool _isLoading = true;

  // --- GETTERS ---
  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get backendSyncError => _backendSyncError;

  // Constructor: Tự động lắng nghe trạng thái đăng nhập khi app khởi động
  AuthProvider() {
    _checkAuthState();
  }

  // --- LẮNG NGHE TRẠNG THÁI FIREBASE ---
  void _checkAuthState() {
    _auth.authStateChanges().listen((User? user) {
      final bool didUserChange = _user?.uid != user?.uid;

      _user = user;
      _isAuthenticated = user != null;
      _isLoading = false;

      if (user == null) {
        _backendSyncError = null;
        notifyListeners();
        return;
      }

      notifyListeners();

      if (didUserChange) {
        unawaited(_syncUserToBackendSilently());
      }
    });
  }

  // Hàm phụ trợ để bật/tắt loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _buildFallbackUsername(User user) {
    final email = user.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'user_${user.uid.substring(0, 8)}';
  }

  Future<void> _syncUserToBackend({String? fullName, String? userName}) async {
    final User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('Không tìm thấy người dùng Firebase để đồng bộ backend.');
    }

    final payload = <String, dynamic>{
      'email': user.email,
      'full_name': fullName ?? user.displayName,
      'username': (userName != null && userName.trim().isNotEmpty)
          ? userName.trim()
          : _buildFallbackUsername(user),
    };

    try {
      await _apiService.client.post('/auth/sync-user', data: payload);
      _backendSyncError = null;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Firebase đăng nhập thành công nhưng app chưa kết nối được backend. Hãy kiểm tra FastAPI đang chạy và base URL đúng với emulator.',
        );
      }

      final backendMessage = e.response?.data is Map<String, dynamic>
          ? e.response?.data['detail']
          : null;
      throw Exception(
        backendMessage?.toString() ??
            'Không thể đồng bộ người dùng với backend.',
      );
    }
  }

  Future<void> _syncUserToBackendSilently({
    String? fullName,
    String? userName,
  }) async {
    try {
      await _syncUserToBackend(fullName: fullName, userName: userName);
      notifyListeners();
    } catch (e) {
      _backendSyncError = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  // ==========================================
  // 1. ĐĂNG NHẬP BẰNG EMAIL & PASSWORD
  // ==========================================
  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      _setLoading(true);
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng nhập thất bại';
      if (e.code == 'user-not-found') {
        message = 'Không tìm thấy tài khoản với email này.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Mật khẩu hoặc email không chính xác.';
      } else if (e.code == 'invalid-email') {
        message = 'Định dạng email không hợp lệ.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // 2. ĐĂNG KÝ TÀI KHOẢN MỚI
  // ==========================================
  Future<void> register(
      String email, String password, String fullName, String userName) async {
    try {
      _setLoading(true);

      // 1. Tạo tài khoản trên Firebase Auth
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Cập nhật Full Name vào hồ sơ Firebase (Để hiển thị "Hello Rocky" ở Dashboard)
      await userCredential.user?.updateDisplayName(fullName);

      // Làm mới lại thông tin user để app nhận tên vừa cập nhật
      await userCredential.user?.reload();
      _user = _auth.currentUser;
      await _syncUserToBackendSilently(fullName: fullName, userName: userName);
    } on FirebaseAuthException catch (e) {
      String message = 'Đăng ký thất bại';
      if (e.code == 'weak-password') {
        message = 'Mật khẩu quá yếu (cần ít nhất 6 ký tự).';
      } else if (e.code == 'email-already-in-use') {
        message = 'Email này đã được sử dụng bởi tài khoản khác.';
      } else if (e.code == 'invalid-email') {
        message = 'Định dạng email không hợp lệ.';
      }
      throw Exception(message);
    } catch (e) {
      throw Exception('Lỗi không xác định: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // 3. ĐĂNG XUẤT
  // ==========================================
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _auth.signOut();
      // Router sẽ tự động văng ra trang Login nhờ _checkAuthState()
    } catch (e) {
      throw Exception('Lỗi khi đăng xuất: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // 4. ĐĂNG NHẬP BẰNG GOOGLE (Khung chuẩn bị)
  // ==========================================
  Future<void> signInWithGoogle() async {
    // Lưu ý: Để dùng tính năng này, bạn cần cài đặt package 'google_sign_in'
    // flutter pub add google_sign_in
    throw Exception('Tính năng đăng nhập bằng Google đang được phát triển!');
  }
}
