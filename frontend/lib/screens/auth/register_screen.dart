import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Thêm 2 Controller mới
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final Color _backgroundColor = const Color(0xFF191A1F);
  final Color _inputFillColor = const Color(0xFF25262E);
  final Color _primaryGreen = const Color(0xFF57B869);

  @override
  void dispose() {
    _fullNameController.dispose();
    _userNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final fullName = _fullNameController.text.trim();
    final userName = _userNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 1. Validate kiểm tra trống
    if (fullName.isEmpty ||
        userName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin'),
            backgroundColor: Colors.orange),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Mật khẩu xác nhận không khớp!'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Truyền THÊM fullName và userName vào AuthProvider
      final authProvider = context.read<AuthProvider>();
      await authProvider.register(email, password, fullName, userName);

      // Thành công -> Router tự chuyển trang
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logoscreen2green.png',
                      height: 40, width: 40),
                  const SizedBox(width: 12),
                  const Text('SCREEN2GREEN',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 30),

              const Text('Create an Account',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              // --- Ô NHẬP FULL NAME ---
              _buildTextField(
                controller: _fullNameController,
                hintText: 'Full Name (e.g. Rocky Doe)',
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 16),

              // --- Ô NHẬP USERNAME ---
              _buildTextField(
                controller: _userNameController,
                hintText: 'Username (e.g. rocky_99)',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              // --- Ô NHẬP EMAIL ---
              _buildTextField(
                controller: _emailController,
                hintText: 'something.work@email.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // --- Ô NHẬP PASSWORD ---
              _buildPasswordField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: _obscurePassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              const SizedBox(height: 16),

              // --- Ô NHẬP CONFIRM PASSWORD ---
              _buildPasswordField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: _obscureConfirmPassword,
                onToggleVisibility: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 30),

              // --- NÚT SIGN UP ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : const Text('Sign Up',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),

              // --- CHUYỂN VỀ TRANG LOGIN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account? ",
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  GestureDetector(
                    onTap: _isLoading ? null : () => context.pop(),
                    child: Text('Sign In',
                        style: TextStyle(
                            color: _primaryGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Các widget phụ trợ giữ nguyên như cũ
  Widget _buildTextField(
      {required TextEditingController controller,
      required String hintText,
      required IconData icon,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      enabled: !_isLoading,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: _inputFillColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _primaryGreen, width: 1.5)),
      ),
    );
  }

  Widget _buildPasswordField(
      {required TextEditingController controller,
      required String hintText,
      required bool obscureText,
      required VoidCallback onToggleVisibility}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      obscureText: obscureText,
      enabled: !_isLoading,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
        suffixIcon: IconButton(
            icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.white54),
            onPressed: onToggleVisibility),
        filled: true,
        fillColor: _inputFillColor,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: _primaryGreen, width: 1.5)),
      ),
    );
  }
}
