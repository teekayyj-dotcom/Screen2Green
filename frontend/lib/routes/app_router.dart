import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import Provider
import '../providers/auth_provider.dart';

// Import Screens
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/welcome/welcome_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final GoRouter router = GoRouter(
    refreshListenable: authProvider,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
    ],

    // --- BỘ ĐÁNH CHẶN (GUARD) ĐIỀU HƯỚNG THÔNG MINH ---
    redirect: (context, state) {
      final bool isAuthenticated = authProvider.isAuthenticated;
      final bool isLoading = authProvider.isLoading;

      // Kiểm tra xem người dùng đang ở trang nào
      final bool isAtSplash = state.matchedLocation == '/';
      final bool isAtLogin = state.matchedLocation == '/login';
      final bool isAtRegister = state.matchedLocation == '/register';

      // 1. Nếu đang check Token -> Cho phép ở lại Splash
      if (isLoading || isAtSplash) return null;

      // 2. CHƯA ĐĂNG NHẬP
      if (!isAuthenticated) {
        // Cho phép ở lại Login hoặc Register
        if (isAtLogin || isAtRegister) return null;
        // Đang lảng vảng chỗ khác -> Đá về Login
        return '/login';
      }

      // 3. ĐÃ ĐĂNG NHẬP
      if (isAuthenticated) {
        // Nếu vừa đăng nhập/đăng ký thành công (đang ở login/register) -> Chuyển tới Welcome
        if (isAtLogin || isAtRegister) return '/welcome';
        // Cho phép ở lại Welcome hoặc Dashboard
        return null;
      }

      return null;
    },
  );
}
