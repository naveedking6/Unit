import 'package:flutter_test/flutter_test.dart';
import 'package:unit_saathi/main.dart';

void main() {
  testWidgets('App boots and shows splash without crashing', (tester) async {
    await tester.pumpWidget(const UnitSaathiApp());
    // Splash screen shows the app name immediately.
    expect(find.text('یونٹ ساتھی'), findsOneWidget);
  });
}
