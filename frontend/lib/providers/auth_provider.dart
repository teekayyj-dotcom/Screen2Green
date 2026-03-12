import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Lưu ý: Nhớ sửa lại đường dẫn import này cho đúng với cấu trúc thư mục của bạn
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();

  User? _user;
  bool _isLoading = true; // Cờ hiệu để biết app đang check token lúc mới mở

  // Getters để các UI và Router đọc trạng thái
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _initAuthListener();
  }

  // Lắng nghe Stream từ Firebase Auth Service
  void _initAuthListener() {
    _authService.authStateChanges.listen((User? firebaseUser) {
      _user = firebaseUser;
      _isLoading = false; // Đã check xong trạng thái

      // Báo cho tất cả các widget/router đang lắng nghe Provider này biết trạng thái đã đổi
      notifyListeners();
    });
  }

  // --- CÁC HÀM GỌI TỪ GIAO DIỆN (UI) ---

  Future<void> signInWithGoogle() async {
    try {
      await _authService.signInWithGoogle();
      // Không cần gọi notifyListeners() ở đây vì Stream listener ở trên sẽ tự động bắt được sự kiện thay đổi
    } catch (e) {
      rethrow; // Ném lỗi ra để giao diện Login bắt và hiển thị SnackBar
    }
  }

  Future<void> signInWithEmailPassword(String email, String password) async {
    try {
      await _authService.signInWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await _authService.registerWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
