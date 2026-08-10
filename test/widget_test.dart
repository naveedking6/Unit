import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unit_saathi/screens/name_entry_screen.dart';
import 'package:unit_saathi/theme.dart';

void main() {
  testWidgets('Name entry screen renders Urdu prompt and save button', (tester) async {
    // NameEntryScreen has no plugin/database calls during build (only on
    // save), so it's safe to test headlessly without a real device.
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.theme,
      home: const NameEntryScreen(),
    ));

    expect(find.text('اپنا نام درج کریں'), findsOneWidget);
    expect(find.text('محفوظ کریں'), findsOneWidget);
  });
}
