import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Lưu trạng thái tab đang được chọn

  // Bảng màu chuẩn theo yêu cầu của bạn
  final Color _bgColor = const Color(0xFFF6F6F6);
  final Color _activeIconColor = const Color(0xFF01B764);
  final Color _redColor = const Color(0xFFF44336);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Stack(
        children: [
          // 1. LỚP NỀN (BACKGROUND GRADIENT TỪ TRÊN XUỐNG)
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF57B869), // Xanh lá
                  Color(0xFF329D9C), // Xanh teal
                  Color(0xFF2081C3), // Xanh dương
                ],
              ),
            ),
          ),

          // 2. NỘI DUNG CUỘN (DASHBOARD CONTENT)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 20, bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildAlertCard(),
                  const SizedBox(height: 24),
                  _buildChartCard(),
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                ],
              ),
            ),
          ),

          // 3. THANH ĐIỀU HƯỚNG TÙY CHỈNH (CUSTOM BOTTOM NAV BAR)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: _buildCustomBottomNavBar(),
          ),
        ],
      ),
    );
  }

  // --- CÁC THÀNH PHẦN GIAO DIỆN CHÍNH ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Hello Rocky,',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: Icon(Icons.notifications_none, color: Colors.grey[600]),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: Icon(Icons.person, color: Colors.grey[600]),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildAlertCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'High afternoon usage detected',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'You spend more than 4 hours after 5:30pm. Do more exercises!',
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF57B869),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Set Reminder',
                style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF35363D), // Màu tối như thiết kế
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today\'s Usage',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const Spacer(),
          // Bắt chước biểu đồ vạch sáng bằng CustomPaint đơn giản
          SizedBox(
            height: 80,
            width: double.infinity,
            child: CustomPaint(painter: _MockChartPainter()),
          ),
          const Spacer(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0 AM',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('6 AM',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('12 PM',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('6 PM',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              Text('Now',
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Hours',
                endValue: 8,
                subtitle: 'Total screen time',
                progressText: '130% Max',
                progressValue: 1.0,
                color: _redColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: 'Trees',
                endValue: 12,
                subtitle: 'Total tree planted',
                progressText: '+3 this month',
                progressValue: 0,
                color: _activeIconColor,
                isTextBottom: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'kg CO2',
                endValue: 144,
                subtitle: 'Total offset estimated',
                progressText: '40% Target',
                progressValue: 0.4,
                color: _activeIconColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                title: '',
                endValue: 80,
                subtitle: 'Total GreenPoints',
                progressText: '16%',
                progressValue: 0.16,
                color: _activeIconColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- WIDGET CARD THỐNG KÊ (CÓ ANIMATION SỐ NHẢY) ---
  Widget _buildStatCard({
    required String title,
    required double endValue,
    required String subtitle,
    required String progressText,
    required double progressValue,
    required Color color,
    bool isTextBottom = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HIỆU ỨNG SỐ NHẢY TỪ 0 LÊN
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: endValue),
            duration:
                const Duration(milliseconds: 1500), // Thời gian chạy (1.5s)
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Text.rich(
                TextSpan(
                  text: value.toInt().toString(),
                  style: TextStyle(
                      color: color,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1),
                  children: [
                    TextSpan(
                      text: title.isNotEmpty ? ' $title' : '',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(subtitle,
              style: const TextStyle(color: Colors.black87, fontSize: 14)),
          const SizedBox(height: 20),

          if (isTextBottom)
            Text(progressText, style: TextStyle(color: color, fontSize: 14))
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(progressText.split(' ')[0],
                    style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                if (progressText.contains(' '))
                  Text(progressText.substring(progressText.indexOf(' ') + 1),
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 6),
            // Thanh Progress Bar (Dùng LinearProgressIndicator)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            )
          ]
        ],
      ),
    );
  }

  // --- HIỆU ỨNG BOTTOM NAV BAR ---
  Widget _buildCustomBottomNavBar() {
    // Các Icon
    final List<IconData> icons = [
      Icons.home,
      Icons.bar_chart,
      Icons.settings,
      Icons.person
    ];

    // Xác định vị trí của ô trắng dựa trên tab đang chọn (-1.0 là trái cùng, 1.0 là phải cùng)
    // Chia 4 khoảng: -1.0 | -0.33 | 0.33 | 1.0
    final double alignmentX = -1.0 + (_selectedIndex * (2.0 / 3.0));

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF51B96B), // Màu nền thanh Nav
        borderRadius: BorderRadius.circular(35), // Bo tròn cực mạnh
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Stack(
        children: [
          // Ô TRẮNG TRƯỢT THEO INDEX
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment(alignmentX, 0),
            child: Container(
              width: 70, // Chiều rộng bằng khoảng 1 phần 4
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),

          // LỚP CHỨA CÁC ICON BẤM ĐƯỢC
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(icons.length, (index) {
              final isSelected = index == _selectedIndex;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                // Vùng bấm trong suốt bao trọn icon
                child: Container(
                  width: 70,
                  color: Colors.transparent,
                  child: Center(
                    // Icon sẽ tự đổi màu nếu được nằm trong ô trắng
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        icons[index],
                        size: 32,
                        color: isSelected ? _activeIconColor : Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
          )
        ],
      ),
    );
  }
}

// Lớp vẽ mô phỏng lại đường Line Chart rực sáng màu xanh lá
class _MockChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF57B869)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.lineTo(size.width * 0.15, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.4);
    path.lineTo(size.width * 0.6, size.height * 0.4);
    path.lineTo(size.width * 0.8, size.height * 0.1);
    path.lineTo(size.width, size.height * 0.05);

    // Thêm hiệu ứng phát sáng (Glow)
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF57B869).withOpacity(0.3)
          ..strokeWidth = 12
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
