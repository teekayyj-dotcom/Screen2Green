import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Đảm bảo tên package 'frontend' trùng với tên trong pubspec.yaml của bạn
import 'package:frontend/main.dart';

void main() {
  testWidgets('Screen2GreenApp khởi động thành công (Smoke test)',
      (WidgetTester tester) async {
    // 1. Build app của chúng ta
    await tester.pumpWidget(const Screen2GreenApp());

    // 2. Chỉ cần kiểm tra xem MaterialApp có được render ra không (không bị crash)
    expect(find.byType(MaterialApp), findsWidgets);

    // Lưu ý: Chúng ta đã xóa app đếm số, nên không cần test nút '+' hay số '0' nữa.
  });
}
