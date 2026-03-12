import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Các màu sắc lấy từ thiết kế
    const Color backgroundColor = Color(0xFF191A1F);
    const Color primaryGreen =
        Color(0xFF10C66F); // Màu xanh này tươi hơn ở trang Login một chút

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PHẦN HEADER (LOGO & TEXT) ---
            Padding(
              padding:
                  const EdgeInsets.only(left: 24.0, top: 40.0, right: 24.0),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/logoscreen2green.png',
                    height: 40,
                    width: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'SCREEN2GREEN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- PHẦN TIÊU ĐỀ (TITLE & SUBTITLE) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dùng RichText để tô màu riêng cho chữ "Application"
                  RichText(
                    text: const TextSpan(
                      text: 'Welcome To The\nWellbeing ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1.2, // Khoảng cách giữa các dòng
                      ),
                      children: [
                        TextSpan(
                          text: 'Application',
                          style: TextStyle(
                            color: primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Improve Your Screentime',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- PHẦN HÌNH ẢNH TRUNG TÂM ---
            // Dùng Expanded để hình ảnh chiếm toàn bộ không gian trống ở giữa
            Expanded(
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/images/welcome_bg.png', // Nhớ thêm ảnh này vào assets nhé
                  fit: BoxFit.cover, // Cắt cúp ảnh cho vừa khung
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- PHẦN NÚT BẤM (BOTTOM) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Khi bấm Get Started -> Chuyển thẳng vào Dashboard
                        context.go('/dashboard');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dòng text này hơi thừa nếu đã login, nhưng mình vẫn code chuẩn UI cho bạn
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have account? ",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to Register
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30), // Căn lề đáy
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
