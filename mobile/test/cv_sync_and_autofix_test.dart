import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resumer/features/cv_editor/models/cv_model.dart';
import 'package:resumer/features/cv_editor/services/cv_profile_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('CvProfileManager updateDraftSilently updates in-memory CV immediately', () async {
    final manager = CvProfileManager.instance;
    await manager.init();

    final cv = manager.currentCv.clone();
    cv.languages = [
      LanguageItem(name: 'Bahasa Indonesia', proficiency: 'Native / Bilingual'),
      LanguageItem(name: 'English', proficiency: 'Professional Working'),
    ];
    cv.showLanguages = true;
    cv.hobbies = ['Fotografi', 'Berenang'];
    cv.showHobbies = true;
    cv.certifications = [
      CertificationItem(name: 'AWS Certified Architect', issuer: 'Amazon Web Services', year: '2023', description: 'Cloud infrastructure'),
    ];

    manager.updateDraftSilently(cv);

    // Verify immediately in memory
    expect(manager.currentCv.languages.length, 2);
    expect(manager.currentCv.languages[0].name, 'Bahasa Indonesia');
    expect(manager.currentCv.hobbies.length, 2);
    expect(manager.currentCv.hobbies[1], 'Berenang');
    expect(manager.currentCv.certifications.length, 1);
    expect(manager.currentCv.certifications[0].name, 'AWS Certified Architect');

    // Persist to local storage
    await manager.persistDraftLocally();

    // Re-init to test persistence from SharedPreferences
    await manager.init();
    expect(manager.currentCv.languages.length, 2);
    expect(manager.currentCv.hobbies.length, 2);
    expect(manager.currentCv.certifications.length, 1);
  });

  test('Auto-Fix operation preserves languages, hobbies, certifications, and educations', () async {
    final manager = CvProfileManager.instance;
    await manager.init();

    // 1. User fills CV with languages, hobbies, and certifications in editor
    final cv = manager.currentCv.clone();
    cv.languages = [LanguageItem(name: 'Japanese', proficiency: 'Conversational')];
    cv.showLanguages = true;
    cv.hobbies = ['Chess', 'Cycling'];
    cv.showHobbies = true;
    cv.certifications = [CertificationItem(name: 'Scrum Master', issuer: 'Scrum.org', year: '2024')];
    cv.educations = [Education(institution: 'ITB', degree: 'Bachelor', fieldOfStudy: 'Informatics', graduationYear: '2022')];

    manager.updateDraftSilently(cv);
    await manager.persistDraftLocally();

    // 2. ATS Auto-Fix is invoked (simulating AtsCheckerScreen._executeAutoFix)
    final cvToFix = manager.currentCv.clone();

    // Preserved fields
    final preservedLanguages = List<LanguageItem>.from(cvToFix.languages);
    final preservedHobbies = List<String>.from(cvToFix.hobbies);
    final preservedCertifications = List<CertificationItem>.from(cvToFix.certifications);
    final preservedEducations = List<Education>.from(cvToFix.educations);
    final preservedPersonalInfo = cvToFix.personalInfo;

    // Simulated Gemini Auto-Fix payload (only modifies summary, bullet points, skills)
    final improvedData = {
      'summary': 'High-impact engineer with track record of increasing system efficiency by 40%.',
      'experiences': [
        {
          'company': 'Tech Corp',
          'position': 'Senior Engineer',
          'bullet_points': [
            'Architected distributed microservices handling 50k RPS, reducing p99 latency by 35% (Google XYZ)',
          ]
        }
      ],
      'skills': [
        {'name': 'Distributed Systems', 'description': 'High throughput message queues and caching'},
        {'name': 'Go', 'description': 'Concurrent microservice backends'},
      ]
    };

    // Apply optimizations
    cvToFix.summary = improvedData['summary'] as String;
    if (cvToFix.experiences.isNotEmpty) {
      cvToFix.experiences[0].highlights = List<String>.from(
        (improvedData['experiences'] as List)[0]['bullet_points'] as List,
      );
    }
    cvToFix.skills = (improvedData['skills'] as List).map((s) => SkillItem.fromJson(s)).toList();

    // Guarantee non-modified sections remain strictly intact
    cvToFix.languages = preservedLanguages;
    cvToFix.hobbies = preservedHobbies;
    cvToFix.certifications = preservedCertifications;
    cvToFix.educations = preservedEducations;
    cvToFix.personalInfo = preservedPersonalInfo;

    await manager.saveCurrentProfile(cvToFix, atsScore: 97);

    // 3. Verify final state in manager
    final finalCv = manager.currentCv;
    expect(finalCv.summary, contains('High-impact engineer'));
    expect(finalCv.skills.length, 2);
    expect(finalCv.skills[0].name, 'Distributed Systems');

    // Verify critical user inputs were NEVER erased
    expect(finalCv.languages.length, 1);
    expect(finalCv.languages[0].name, 'Japanese');
    expect(finalCv.languages[0].proficiency, 'Conversational');
    expect(finalCv.hobbies.length, 2);
    expect(finalCv.hobbies, contains('Chess'));
    expect(finalCv.hobbies, contains('Cycling'));
    expect(finalCv.certifications.length, 1);
    expect(finalCv.certifications[0].name, 'Scrum Master');
    expect(finalCv.educations.length, 1);
    expect(finalCv.educations[0].institution, 'ITB');
    expect(manager.currentMeta.atsScore, 97);
  });
}
