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
    // Lắng nghe sự thay đổi trạng thái từ AuthProvider
    refreshListenable: authProvider,
    initialLocation: '/',

    // --- DANH SÁCH CÁC MÀN HÌNH ---
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
        builder: (context, state) =>
            const RegisterScreen(), // Đã thêm màn hình Đăng ký
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

    // --- BỘ ĐÁNH CHẶN (GUARD) ĐIỀU HƯỚNG ---
    redirect: (context, state) {
      final isAuth = authProvider.isAuthenticated;
      final isLoading = authProvider.isLoading;
      final location = state.matchedLocation;

      final isAtSplash = location == '/';
      final isAtLogin = location == '/login';
      final isAtRegister = location == '/register';
      final isAtWelcome = location == '/welcome';

      if (isLoading) {
        return isAtSplash ? null : '/';
      }

      if (!isAuth) {
        if (isAtSplash || isAtLogin || isAtRegister) {
          return null;
        }
        return '/login';
      }

      if (isAtSplash || isAtLogin || isAtRegister) {
        return '/welcome';
      }

      if (isAtWelcome) {
        return null;
      }

      return null;
    },
  );
}
