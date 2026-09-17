import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resumer/core/localization/app_localizations.dart';
import 'package:resumer/features/ats_checker/screens/ats_checker_screen.dart';
import 'package:resumer/features/ats_checker/widgets/ats_score_gauge.dart';
import 'package:resumer/features/ats_checker/widgets/ats_breakdown_section.dart';
import 'package:resumer/features/ats_checker/widgets/ats_feedback_section.dart';
import 'package:resumer/features/cv_editor/services/cv_profile_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppLocalizations.instance.init('id_ID');
    await CvProfileManager.instance.init();
  });

  testWidgets('AtsScoreGauge renders empty placeholder and unanalyzed verdict when score is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AtsScoreGauge(score: null),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('—'), findsOneWidget);
    expect(find.text('Belum Dianalisis'), findsOneWidget);
    expect(find.text('SKOR ATS'), findsOneWidget);
  });

  testWidgets('AtsBreakdownSection renders empty dashes and hint banner when breakdown is null', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AtsBreakdownSection(breakdown: null),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('— / 25'), findsNWidgets(4));
    expect(
      find.text('Lakukan pengujian untuk melihat rincian kalkulasi 4 pilar seleksi ATS pada CV aktif Anda.'),
      findsOneWidget,
    );
  });

  testWidgets('AtsFeedbackSection renders educational placeholder when isAnalyzed is false', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AtsFeedbackSection(feedbackList: [], isAnalyzed: false),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Rekomendasi'), findsOneWidget);
    expect(
      find.text('Jalankan uji skor ATS untuk mendapatkan rekomendasi konkret perbaikan format dan konten CV dari AI simulator HRD.'),
      findsOneWidget,
    );
  });

  testWidgets('AtsCheckerScreen renders unanalyzed state cleanly without hardcoded 92', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: AtsCheckerScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify hardcoded 92 is NOT present
    expect(find.text('92'), findsNothing);

    // Verify unanalyzed indicators exist
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Belum Dianalisis'), findsOneWidget);
    expect(find.text('Uji Skor ATS'), findsOneWidget);
    expect(find.text('Belum Ada Rekomendasi'), findsOneWidget);
  });

  test('CvProfileManager stores and retrieves full ATS analysis meta per profile', () async {
    final mgr = CvProfileManager.instance;
    await mgr.init();

    // Profile 1 starts with null atsScore
    expect(mgr.getMeta(1).atsScore, isNull);
    expect(mgr.getMeta(1).atsVerdict, isNull);

    // Update Profile 1 with analysis results
    await mgr.updateProfileMeta(
      1,
      atsScore: 94,
      atsVerdict: 'Top 5% ATS Ready',
      atsBreakdown: {'keyword_match': 24, 'impact_verbs': 24, 'readability': 23, 'completeness': 23},
      atsFeedback: [{'section': 'Experience', 'issue': 'Add metric', 'suggestion': 'Use XYZ formula'}],
    );

    expect(mgr.getMeta(1).atsScore, 94);
    expect(mgr.getMeta(1).atsVerdict, 'Top 5% ATS Ready');
    expect(mgr.getMeta(1).atsBreakdown?['keyword_match'], 24);
    expect(mgr.getMeta(1).atsFeedback?.length, 1);

    // Profile 2 is still unanalyzed
    expect(mgr.getMeta(2).atsScore, isNull);
    expect(mgr.getMeta(2).atsVerdict, isNull);

    // Switch to Profile 2
    await mgr.switchProfile(2);
    expect(mgr.currentMeta.profileIndex, 2);
    expect(mgr.currentMeta.atsScore, isNull);

    // Switch back to Profile 1
    await mgr.switchProfile(1);
    expect(mgr.currentMeta.profileIndex, 1);
    expect(mgr.currentMeta.atsScore, 94);
    expect(mgr.currentMeta.atsVerdict, 'Top 5% ATS Ready');
  });
}
