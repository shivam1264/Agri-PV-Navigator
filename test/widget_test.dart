import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_pv_navigator/main.dart';
import 'package:agri_pv_navigator/providers/farm_provider.dart';

void main() {
  testWidgets('Agri-PV Navigator smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
        ],
        child: const AgriPvNavigatorApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(AgriPvNavigatorApp), findsOneWidget);
  });
}
