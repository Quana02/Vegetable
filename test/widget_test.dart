import 'package:flutter_test/flutter_test.dart';
import 'package:vegetable_project/app.dart';

void main() {
  testWidgets('Hiển thị màn hình đăng nhập', (tester) async {
    await tester.pumpWidget(const GreenBasketApp());

    expect(find.text('Chào mừng trở lại!'), findsOneWidget);
    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.text('Tiếp tục với Google'), findsOneWidget);
  });
}
