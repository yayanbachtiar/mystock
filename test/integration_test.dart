import 'package:flutter_test/flutter_test.dart';
import 'package:mystok/main.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.text('Login'), findsOneWidget);
  });
}
