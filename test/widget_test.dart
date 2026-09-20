import 'package:flutter_test/flutter_test.dart';
import 'package:agri_pv_navigator/main.dart';

void main() {
  testWidgets('Agri-PV Navigator smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgriPvNavigatorApp());
    expect(find.byType(AgriPvNavigatorApp), findsOneWidget);
  });
}
