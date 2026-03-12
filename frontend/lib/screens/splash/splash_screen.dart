import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  // Hàm xử lý logic chờ 2s và chuyển hướng thông minh
  Future<void> _checkAuthAndNavigate() async {
    // Đợi 2 giây để user ngắm logo Screen2Green
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Đọc trạng thái từ AuthProvider
    final authProvider = context.read<AuthProvider>();

    // Nếu user đã đăng nhập -> vào Dashboard. Nếu chưa -> vào Login.
    if (authProvider.isAuthenticated) {
      context.go('/dashboard');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191A1F), // Nền tối chuẩn Dark Mode
      body: Center(
        // Gọi đường dẫn tương đối, Flutter sẽ tự ánh xạ tới file trên máy Mac của bạn
        child: Image.asset(
          'assets/images/logoscreen2green.png',
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
