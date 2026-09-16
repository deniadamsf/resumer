import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resumer/core/localization/app_localizations.dart';
import 'package:resumer/features/navigation/screens/main_navigation_shell.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLocalizations.instance.init('id_ID');
  });

  testWidgets('MainNavigationShell renders 4 tabs without overflow', (WidgetTester tester) async {
    // Set standard phone screen size 390x844 (iPhone 12/13/14 or Android 360-400 width)
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: MainNavigationShell(),
      ),
    );
    await tester.pump();

    // Verify all 4 tab labels exist
    expect(find.text('Editor'), findsWidgets);
    expect(find.text('Skor ATS'), findsOneWidget);
    expect(find.text('Job Match'), findsOneWidget);
    expect(find.text('Surat Lamaran'), findsOneWidget);

    // Verify Quick Action buttons inside Editor do not overflow and show correct text
    expect(find.text('Poles AI'), findsOneWidget);
    expect(find.text('Ekspor PDF'), findsOneWidget);

    // Tap on 'Skor ATS' tab
    await tester.tap(find.text('Skor ATS'));
    await tester.pumpAndSettle();

    // Tap on 'Job Match' tab
    await tester.tap(find.text('Job Match'));
    await tester.pumpAndSettle();

    // Tap on 'Surat Lamaran' tab
    await tester.tap(find.text('Surat Lamaran'));
    await tester.pumpAndSettle();

    // Tap back to 'Editor' tab
    await tester.tap(find.text('Editor'));
    await tester.pumpAndSettle();
  });
}
