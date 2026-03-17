import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:usage_stats/usage_stats.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

// Thêm "with WidgetsBindingObserver" để app lắng nghe trạng thái (ngủ đông/thức dậy)
class _WelcomeScreenState extends State<WelcomeScreen>
    with WidgetsBindingObserver {
  bool _isWaitingForPermission = false; // Cờ đánh dấu user đang ở màn Cài đặt

  @override
  void initState() {
    super.initState();
    // Đăng ký "máy nghe lén" sự kiện vòng đời của app
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Hủy đăng ký khi rời khỏi màn hình này để tránh rò rỉ bộ nhớ
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Bắt sự kiện mỗi khi người dùng vuốt/mở lại app từ Background
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    // Nếu app vừa "thức dậy" (resumed) VÀ trước đó user đã bấm nút "Go To Setting"
    if (state == AppLifecycleState.resumed && _isWaitingForPermission) {
      // Tắt cờ đi để tránh check liên tục
      _isWaitingForPermission = false;

      // Kiểm tra xem user có thực sự gạt công tắc cấp quyền không
      bool? isGranted = await UsageStats.checkUsagePermission();

      // Nếu có quyền -> Cho bay thẳng vào Dashboard!
      if (isGranted == true && mounted) {
        context.go('/dashboard');
      }
    }
  }

  // --- HÀM XỬ LÝ KHI BẤM NÚT GET STARTED ---
  Future<void> _handleGetStarted() async {
    bool? isGranted = await UsageStats.checkUsagePermission();

    if (isGranted == true) {
      if (mounted) context.go('/dashboard');
    } else {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              backgroundColor: const Color(0xFF25262E),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.privacy_tip_outlined, color: Color(0xFF01B764)),
                  SizedBox(width: 10),
                  Text(
                    'Permission Required',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: const Text(
                'Screen2Green needs access to your screen time usage to calculate your carbon offset and reward you with GreenPoints.',
                style:
                    TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
              ),
              actionsPadding:
                  const EdgeInsets.only(right: 16, bottom: 16, top: 8),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    // Nếu user từ chối, vẫn có thể cho vào Dashboard (tuỳ luồng của bạn)
                    // Hoặc bạn có thể xoá dòng context.go này để bắt ép họ cấp quyền
                    context.go('/dashboard');
                  },
                  child: const Text('Maybe Later',
                      style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(dialogContext); // Đóng popup

                    // Bật cờ thông báo: "Chuẩn bị đi sang màn hình Cài đặt nè"
                    _isWaitingForPermission = true;

                    // Mở màn hình Cài đặt của Android
                    await UsageStats.grantUsagePermission();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF01B764),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Go To Setting',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            );
          },
        );
      }
    }
  }

  // Giao diện giữ nguyên như cũ
  Widget _buildWelcomeArtwork() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1B2424), Color(0xFF203B33), Color(0xFF16202C)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 30,
            right: 30,
            child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                    color: const Color(0xFF10C66F).withValues(alpha: 0.12),
                    shape: BoxShape.circle)),
          ),
          Positioned(
            left: 24,
            bottom: 24,
            child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(32))),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10C66F).withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFF10C66F).withValues(alpha: 0.4),
                        width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.eco_outlined,
                      color: Colors.white, size: 44),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Track smarter,\nlive lighter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF191A1F);
    const Color primaryGreen = Color(0xFF10C66F);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 24.0, top: 40.0, right: 24.0),
              child: Row(
                children: [
                  Image.asset('assets/images/logoscreen2green.png',
                      height: 40, width: 40, fit: BoxFit.contain),
                  const SizedBox(width: 12),
                  const Text('SCREEN2GREEN',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      text: 'Welcome To The\nWellbeing ',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.2),
                      children: [
                        TextSpan(
                            text: 'Application',
                            style: TextStyle(color: primaryGreen))
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Improve Your Screentime',
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Expanded(child: _buildWelcomeArtwork()),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _handleGetStarted,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: const Text('Get Started',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
