import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Providers và Models
import '../../providers/auth_provider.dart';
import '../../providers/screen_provider.dart';
import '../../models/screen_time_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final Color _backgroundColor = const Color(0xFF191A1F);
  final Color _cardColor = const Color(0xFF25262E);
  final Color _primaryGreen = const Color(0xFF57B869);
  bool _requestedInitialStats = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _requestedInitialStats) {
        return;
      }

      _requestedInitialStats = true;
      context.read<ScreenProvider>().fetchAndSyncStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe ScreenProvider để cập nhật UI khi có data mới
    final screenProvider = context.watch<ScreenProvider>();
    final stats = screenProvider.stats;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: _primaryGreen,
          backgroundColor: _cardColor,
          // Kéo màn hình xuống để làm mới dữ liệu
          onRefresh: () async {
            await context
                .read<ScreenProvider>()
                .fetchAndSyncStats(forceRefresh: true);
          },
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // Đảm bảo luôn cuộn được để pull-to-refresh
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 30),

                // HIỂN THỊ TRẠNG THÁI LOADING, ERROR HOẶC DATA
                if (screenProvider.isLoading && stats == null)
                  SizedBox(
                    height: 300,
                    child: Center(
                        child: CircularProgressIndicator(color: _primaryGreen)),
                  )
                else if (screenProvider.errorMessage != null)
                  _buildErrorState(screenProvider.errorMessage!)
                else if (stats != null)
                  _buildDashboardContent(stats),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // 1. PHẦN HEADER CÓ AVATAR DROPDOWN MENU
  // =========================================================
  Widget _buildHeader() {
    // Lấy tên hiển thị từ Firebase (Nếu null thì để 'User')
    final authProvider = context.read<AuthProvider>();
    final String displayName = authProvider.user?.displayName ?? 'User';
    final String firstName =
        displayName.split(' ').first; // Chỉ lấy tên gọi cho thân mật

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello $firstName,',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: _cardColor,
              child:
                  const Icon(Icons.notifications_none, color: Colors.white70),
            ),
            const SizedBox(width: 12),

            // MENU DROPDOWN NHƯ BẠN YÊU CẦU
            Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: _cardColor,
                elevation: 4,
                child: CircleAvatar(
                  backgroundColor: _primaryGreen.withValues(alpha: 0.2),
                  child: Icon(Icons.person, color: _primaryGreen),
                ),
                onSelected: (String value) async {
                  switch (value) {
                    case 'profile':
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Sắp ra mắt Edit Profile!')));
                      break;
                    case 'greenpoints':
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Sắp ra mắt Chi tiết GreenPoints!')));
                      break;
                    case 'signout':
                      await context.read<AuthProvider>().signOut();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.manage_accounts_outlined,
                            color: Colors.white70),
                        SizedBox(width: 12),
                        Text('Edit Profile',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'greenpoints',
                    child: Row(
                      children: [
                        Icon(Icons.eco_outlined, color: _primaryGreen),
                        const SizedBox(width: 12),
                        const Text('GreenPoints',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'signout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent),
                        SizedBox(width: 12),
                        Text('Sign Out',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  // =========================================================
  // 2. PHẦN NỘI DUNG CHÍNH (KHI ĐÃ CÓ DATA)
  // =========================================================
  Widget _buildDashboardContent(DashboardStatsModel stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- THẺ TỔNG THỜI GIAN SỬ DỤNG ---
        _buildScreenTimeCard(
          title: 'Total Screen Time',
          hours: stats.totalHours,
          progress: stats.hoursProgress,
          icon: Icons.smartphone,
          color: Colors.blueAccent,
        ),
        const SizedBox(height: 16),

        // --- THẺ BLACKLIST (MÔ HÌNH HYBRID MỚI) ---
        _buildScreenTimeCard(
          title: 'Distracting Apps',
          hours: stats.blacklistHours,
          progress: stats.blacklistProgress,
          icon: Icons.block,
          color: Colors.redAccent,
        ),
        const SizedBox(height: 24),

        const Text('Your Environmental Impact',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // --- HÀNG CÁC CHỈ SỐ GAMIFICATION ---
        Row(
          children: [
            Expanded(
                child: _buildImpactCard('Trees', stats.totalTrees.toString(),
                    Icons.park, _primaryGreen)),
            const SizedBox(width: 16),
            Expanded(
                child: _buildImpactCard(
                    'CO2 Offset',
                    '${stats.co2Offset.toStringAsFixed(1)} kg',
                    Icons.cloud_done_outlined,
                    Colors.cyan)),
          ],
        ),
        const SizedBox(height: 16),
        _buildImpactCard('GreenPoints Earned', stats.greenPoints.toString(),
            Icons.stars_rounded, Colors.amber),
      ],
    );
  }

  // =========================================================
  // WIDGET PHỤ TRỢ
  // =========================================================

  // Thẻ hiển thị Giờ (Dùng chung cho Total và Blacklist)
  Widget _buildScreenTimeCard(
      {required String title,
      required double hours,
      required double progress,
      required IconData icon,
      required Color color}) {
    // Tính toán số giờ và phút để hiển thị cho đẹp
    int h = hours.floor();
    int m = ((hours - h) * 60).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: _cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$h',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height: 1)),
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4, right: 8),
                child: Text('h',
                    style: TextStyle(color: Colors.white70, fontSize: 20)),
              ),
              Text('$m',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      height: 1)),
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: Text('m',
                    style: TextStyle(color: Colors.white70, fontSize: 20)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Thanh Progress (Sẽ chuyển đỏ nếu vượt quá 100% mục tiêu)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                  progress > 1.0 ? Colors.redAccent : color),
            ),
          ),
        ],
      ),
    );
  }

  // Thẻ hiển thị Gamification (Cây, CO2, Điểm)
  Widget _buildImpactCard(
      String title, String value, IconData icon, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: _cardColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 12),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
        ],
      ),
    );
  }

  // UI khi có lỗi đồng bộ
  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Text(error, style: const TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }
}
