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

  testWidgets('MainNavigationShell renders 5 tabs without overflow and handles profile navigation', (WidgetTester tester) async {
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

    // Verify all 5 tab labels exist
    expect(find.text('Editor'), findsWidgets);
    expect(find.text('Skor ATS'), findsOneWidget);
    expect(find.text('Job Match'), findsOneWidget);
    expect(find.text('Lamaran'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // Verify Quick Action buttons inside Editor do not overflow and show correct text
    expect(find.text('Poles AI'), findsOneWidget);
    expect(find.text('Ekspor PDF'), findsOneWidget);

    // Tap on 'Skor ATS' tab
    await tester.tap(find.text('Skor ATS'));
    await tester.pumpAndSettle();

    // Tap on 'Job Match' tab
    await tester.tap(find.text('Job Match'));
    await tester.pumpAndSettle();

    // Tap on 'Lamaran' tab
    await tester.tap(find.text('Lamaran'));
    await tester.pumpAndSettle();

    // Tap on 'Profil' tab
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();

    // Verify Profile screen components are rendered
    expect(find.text('Bahasa Aplikasi & AI'), findsOneWidget);
    expect(find.text('Jatah AI Harian'), findsOneWidget);
    expect(find.text('Kelola Variasi CV (Maksimal 3)'), findsOneWidget);

    // Tap back to 'Editor' tab
    await tester.tap(find.text('Editor'));
    await tester.pumpAndSettle();
  });
}
