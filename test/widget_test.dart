import 'package:flutter_test/flutter_test.dart';

import 'package:miila_app/main.dart';

void main() {
  testWidgets('Ilova ishga tushadi', (WidgetTester tester) async {
    await tester.pumpWidget(const MiilaApp());
    expect(find.byType(MiilaApp), findsOneWidget);
  });
}
