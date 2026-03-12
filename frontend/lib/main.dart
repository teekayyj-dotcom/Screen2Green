import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import các file cấu hình, provider và router của bạn
import 'firebase_options.dart'; // File này được tạo tự động bởi FlutterFire CLI
import 'providers/auth_provider.dart';
import 'routes/app_router.dart';

void main() async {
  // 1. Bắt buộc phải có dòng này để Flutter giao tiếp với Native (Android/iOS)
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase với cấu hình chuẩn cho từng nền tảng
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Khởi chạy App
  runApp(const Screen2GreenApp());
}

class Screen2GreenApp extends StatelessWidget {
  const Screen2GreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Bọc toàn bộ app bằng MultiProvider
    // Sau này bạn có thể dễ dàng thêm ScreenProvider, RewardProvider vào danh sách này
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(),
        ),
      ],
      // 5. Dùng Builder để lấy context đã chứa AuthProvider truyền vào AppRouter
      child: Builder(
        builder: (context) {
          final authProvider = context.read<AuthProvider>();
          final appRouter = AppRouter(authProvider);

          // 6. Dùng MaterialApp.router thay vì MaterialApp thông thường
          return MaterialApp.router(
            title: 'Screen2Green',
            debugShowCheckedModeBanner: false,

            // connect GoRouter
            routerConfig: appRouter.router,

            // Thiết lập Theme mặc định cho toàn bộ App
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF191A1F),
              primaryColor: const Color(0xFF57B869),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF57B869),
                surface: Color(0xFF191A1F),
              ),
              useMaterial3: true,
            ),
          );
        },
      ),
    );
  }
}
