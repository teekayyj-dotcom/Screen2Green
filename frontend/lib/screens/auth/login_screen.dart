import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
// Nếu sau này bạn cần chuyển sang trang Register, hãy import thêm go_router:
// import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers để lấy dữ liệu từ text field
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Biến trạng thái
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false; // Cờ hiệu để hiển thị vòng xoay loading

  // Các hằng số màu sắc dùng chung trong file này
  final Color _backgroundColor = const Color(0xFF191A1F);
  final Color _inputFillColor = const Color(0xFF25262E);
  final Color _primaryGreen = const Color(0xFF57B869);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Hàm xử lý đăng nhập chính
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Kiểm tra đầu vào (Validation)
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ Email và Password'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // 2. Bật trạng thái loading
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Gọi hàm đăng nhập từ AuthProvider
      final authProvider = context.read<AuthProvider>();
      await authProvider.signInWithEmailPassword(email, password);

      // Chú ý: Đăng nhập thành công thì Router sẽ tự động chuyển trang,
      // không cần dùng lệnh Navigator hay context.go() ở đây!
    } catch (e) {
      // 4. Bắt lỗi (sai mật khẩu, email không tồn tại...) và hiển thị lên UI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Cắt bỏ chữ "Exception: " dư thừa để thông báo nhìn sạch sẽ hơn
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // 5. Tắt loading dù thành công hay thất bại
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- PHẦN LOGO & TÊN APP ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logoscreen2green.png',
                    height: 48,
                    width: 48,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'SCREEN2GREEN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // --- TIÊU ĐỀ ---
              const Text(
                'Login to your Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // --- Ô NHẬP EMAIL ---
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                // Vô hiệu hóa ô nhập liệu khi đang loading
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'something.work@email.com',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon:
                      const Icon(Icons.email_outlined, color: Colors.white),
                  filled: true,
                  fillColor: _inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: _primaryGreen, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Ô NHẬP PASSWORD ---
              TextField(
                controller: _passwordController,
                style: const TextStyle(color: Colors.white),
                obscureText: _obscurePassword,
                // Vô hiệu hóa ô nhập liệu khi đang loading
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: '***************',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon:
                      const Icon(Icons.lock_outline, color: Colors.white),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: _inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: _primaryGreen, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                        color: _primaryGreen.withOpacity(0.5), width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- REMEMBER ME CHECKBOX ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Theme(
                    data: ThemeData(
                      unselectedWidgetColor: _primaryGreen.withOpacity(0.5),
                    ),
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: _primaryGreen,
                      checkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // Không cho đổi trạng thái khi đang loading
                      onChanged: _isLoading
                          ? null
                          : (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                    ),
                  ),
                  const Text(
                    'Remember me',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- NÚT SIGN IN ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  // Vô hiệu hóa nút (trở thành màu xám nhạt) khi đang loading
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    disabledBackgroundColor: _primaryGreen.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // --- QUÊN MẬT KHẨU ---
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        // TODO: Xử lý quên mật khẩu
                      },
                child: Text(
                  'Forgot your password?',
                  style: TextStyle(color: _primaryGreen, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              // --- ĐƯỜNG KẺ "OR CONTINUE WITH" ---
              Row(
                children: [
                  const Expanded(
                      child: Divider(color: Colors.white24, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Text(
                      'or continue with',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Expanded(
                      child: Divider(color: Colors.white24, thickness: 1)),
                ],
              ),
              const SizedBox(height: 24),

              // --- NÚT SOCIAL LOGIN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.facebook, Colors.blue),
                  const SizedBox(width: 20),
                  _buildSocialButton(Icons.g_mobiledata, Colors.red,
                      iconSize: 40, isGoogle: true),
                  const SizedBox(width: 20),
                  _buildSocialButton(Icons.apple, Colors.white),
                ],
              ),
              const SizedBox(height: 40),

              // --- TEXT ĐĂNG KÝ ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have account? ",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: _isLoading
                        ? null
                        : () {
                            // TODO: Navigate to Register Screen
                            // context.push('/register');
                          },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        color: _primaryGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm phụ trợ để vẽ các nút Social
  Widget _buildSocialButton(IconData icon, Color iconColor,
      {double iconSize = 30, bool isGoogle = false}) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: _inputFillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor, size: iconSize),
        onPressed: _isLoading
            ? null
            : () async {
                if (isGoogle) {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await context.read<AuthProvider>().signInWithGoogle();
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Lỗi đăng nhập Google: $e'),
                            backgroundColor: Colors.redAccent),
                      );
                    }
                  } finally {
                    if (mounted)
                      setState(() {
                        _isLoading = false;
                      });
                  }
                }
              },
      ),
    );
  }
}
