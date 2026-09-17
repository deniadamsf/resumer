import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resumer/core/localization/app_localizations.dart';
import 'package:resumer/features/onboarding/screens/onboarding_screen.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLocalizations.instance.init('id_ID');
  });

  testWidgets('OnboardingScreen renders smoothly, handles interactions and saves flag', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );
    await tester.pump();

    // 1. Verify Top Bar
    expect(find.text('RESUMER AI'), findsOneWidget);
    expect(find.text('Lewati'), findsOneWidget);

    // 2. Slide 1 Verification & Interaction
    expect(find.text('CV Standar Korporat Dunia Berbasis AI'), findsOneWidget);
    expect(find.text('Polesan Formula XYZ'), findsOneWidget);
    expect(find.text('Sebelum AI'), findsOneWidget);

    // Default is After content
    expect(find.text('Google XYZ Formula'), findsOneWidget);

    // Tap "Sebelum AI" tab
    await tester.tap(find.text('Sebelum AI'));
    await tester.pumpAndSettle();
    expect(find.text('Format Pasif'), findsOneWidget);

    // Tap "Polesan Formula XYZ" tab back
    await tester.tap(find.text('Polesan Formula XYZ'));
    await tester.pumpAndSettle();
    expect(find.text('Google XYZ Formula'), findsOneWidget);

    // 3. Move to Slide 2
    await tester.tap(find.text('Lanjutkan'));
    await tester.pumpAndSettle();

    expect(find.text('Uji Skor ATS 0–100 & Poles Otomatis'), findsOneWidget);
    expect(find.text('Sentuh Uji Auto-Fix AI'), findsOneWidget);

    // Tap Auto-Fix button
    await tester.tap(find.text('Sentuh Uji Auto-Fix AI'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Sentuh untuk Mengulang Uji'), findsOneWidget);
    expect(find.text('3 Poin Pengalaman Sukses Dioptimalkan!'), findsOneWidget);

    // 4. Move to Slide 3 (Slide 3 contains infinite radar animation, so use pump with duration)
    await tester.tap(find.text('Lanjutkan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Pencocok Loker Cerdas & Surat Lamaran'), findsOneWidget);
    expect(find.text('Mulai Sekarang'), findsOneWidget);
    expect(find.text('Scan Loker'), findsOneWidget);
    expect(find.text('Surat Lamaran'), findsOneWidget);

    // Tap "Surat Lamaran" tab
    await tester.tap(find.text('Surat Lamaran'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Resumer AI Executive Letterhead'), findsOneWidget);
    expect(find.text('Tanda Tangan Digital Tersemat'), findsOneWidget);

    // Tap "Mulai Sekarang"
    await tester.tap(find.text('Mulai Sekarang'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify SharedPreferences flag has_seen_onboarding is true
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('has_seen_onboarding'), isTrue);
  });
}
