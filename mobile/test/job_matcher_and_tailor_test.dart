import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resumer/features/cv_editor/models/cv_model.dart';
import 'package:resumer/features/cv_editor/services/cv_profile_manager.dart';
import 'package:resumer/features/job_matcher/models/job_match_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('JobMatchResult correctly cleans keyword and suggestion objects', () {
    final rawJson = {
      'match_score': 85,
      'verdict': 'Kecocokan Kuat',
      'fit_summary': 'Kandidat memiliki fondasi kuat untuk posisi Backend Developer.',
      'matched_keywords': ['Golang', {'keyword': 'PostgreSQL'}, '{"keyword": "Docker"}'],
      'missing_keywords': ['Redis', {'name': 'Kafka'}],
      'tailoring_suggestions': [
        'Tambahkan metrik efisiensi sistem pada ringkasan.',
        {'suggestion': 'Sertakan penggunaan Redis pada pengalaman kerja.'},
        {'description': 'Tonjolkan arsitektur event-driven dengan Kafka.'},
      ],
      'tailored_cv_data': {
        'summary': 'Backend Engineer berpengalaman dengan keahlian Go dan PostgreSQL.',
        'experiences': [
          {
            'company': 'Tech Corp',
            'position': 'Backend Dev',
            'bullet_points': [
              'Mengoptimasi database query PostgreSQL sebesar 40% menggunakan Redis cache.'
            ]
          }
        ],
        'skills': [
          {'name': 'Redis', 'description': 'In-memory caching and session store'},
          {'name': 'Kafka', 'description': 'Event streaming messaging'},
        ],
      }
    };

    final result = JobMatchResult.fromJson(rawJson);

    expect(result.matchScore, 85);
    expect(result.matchedKeywords, containsAll(['Golang', 'PostgreSQL', 'Docker']));
    expect(result.missingKeywords, containsAll(['Redis', 'Kafka']));
    expect(result.tailoringSuggestions.length, 3);
    expect(result.tailoringSuggestions[1], 'Sertakan penggunaan Redis pada pengalaman kerja.');
    expect(result.tailoringSuggestions[2], 'Tonjolkan arsitektur event-driven dengan Kafka.');
    expect(result.tailoredCvData, isNotNull);
  });

  test('Job Tailoring merges skills uniquely without wiping candidate existing skills', () {
    final candidateCv = CvDocument(
      personalInfo: PersonalInfo(fullName: 'John Doe'),
      skills: [
        SkillItem(name: 'Flutter', description: 'Cross-platform app development'),
        SkillItem(name: 'Dart', description: 'Core language'),
        SkillItem(name: 'REST API', description: 'Integration'),
      ],
    );

    // AI suggestions return new skills: Redis and Kafka, plus re-prioritizing Flutter
    final tailoredSkillsRaw = [
      {'name': 'Redis', 'description': 'High speed caching'},
      {'name': 'Flutter', 'description': 'Production architecture with clean architecture'},
      {'name': 'Kafka', 'description': 'Message streaming'},
    ];

    final parsedSkills = tailoredSkillsRaw.map((s) => SkillItem.fromJson(s)).toList();

    final existingNames = <String>{};
    final mergedSkills = <SkillItem>[];
    for (final s in parsedSkills) {
      if (s.name.trim().isNotEmpty && existingNames.add(s.name.trim().toLowerCase())) {
        mergedSkills.add(s);
      }
    }
    for (final s in candidateCv.skills) {
      if (s.name.trim().isNotEmpty && existingNames.add(s.name.trim().toLowerCase())) {
        mergedSkills.add(s);
      }
    }

    candidateCv.skills = mergedSkills;

    // Verify skills order and preservation:
    // Tailored skills come first
    expect(candidateCv.skills[0].name, 'Redis');
    expect(candidateCv.skills[1].name, 'Flutter');
    expect(candidateCv.skills[1].description, 'Production architecture with clean architecture');
    expect(candidateCv.skills[2].name, 'Kafka');
    // Pre-existing skills not in tailored list are preserved!
    expect(candidateCv.skills.any((s) => s.name == 'Dart'), isTrue);
    expect(candidateCv.skills.any((s) => s.name == 'REST API'), isTrue);
    expect(candidateCv.skills.length, 5);
  });

  test('Job Tailoring supports multiline string bullet points and descriptions', () {
    final candidateCv = CvDocument(
      personalInfo: PersonalInfo(fullName: 'John Doe'),
      experiences: [
        WorkExperience(company: 'ABC Corp', position: 'Engineer', highlights: ['Old task']),
      ],
      projects: [
        ProjectItem(name: 'Alpha Project', role: 'Lead', description: 'Old desc'),
      ],
    );

    final tailoredExpItem = {
      'company': 'ABC Corp',
      'position': 'Engineer',
      'bullet_points': '• Built scalable backend handling 10k RPS\n• Reduced memory footprint by 25%'
    };

    final rawBullets = tailoredExpItem['bullet_points'];
    List<String> bullets = [];
    if (rawBullets is String) {
      bullets = rawBullets
          .split('\n')
          .map((e) => e.replaceAll(RegExp(r'^[•\-\*]\s*'), '').trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    candidateCv.experiences[0].highlights = bullets;
    expect(candidateCv.experiences[0].highlights.length, 2);
    expect(candidateCv.experiences[0].highlights[0], 'Built scalable backend handling 10k RPS');
    expect(candidateCv.experiences[0].highlights[1], 'Reduced memory footprint by 25%');
  });

  test('CvProfileManager immediately delivers updated draft to match execution', () async {
    final manager = CvProfileManager.instance;
    await manager.init();

    // User types in editor
    final editorCv = manager.currentCv.clone();
    editorCv.summary = 'Senior Fullstack Engineer with 5+ years experience';
    editorCv.skills.add(SkillItem(name: 'TypeScript', description: 'Type-safe frontends'));
    manager.updateDraftSilently(editorCv);

    // Job Matcher accesses profile
    final freshCvForMatch = manager.currentCv.clone();
    expect(freshCvForMatch.summary, 'Senior Fullstack Engineer with 5+ years experience');
    expect(freshCvForMatch.skills.any((s) => s.name == 'TypeScript'), isTrue);
    expect(freshCvForMatch.toPlainText(), contains('TypeScript'));
  });
}
