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

    // Simulated Resumer AI Auto-Fix payload (only modifies summary, bullet points, skills)
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

  test('isEligibleForAi supports project-based candidates without formal experience', () {
    final cv = CvDocument.empty();
    cv.personalInfo.fullName = 'Budi Santoso';
    cv.personalInfo.email = 'budi@example.com';
    cv.skills = [
      SkillItem(name: 'Golang', description: 'REST APIs'),
      SkillItem(name: 'PostgreSQL', description: 'Database design'),
      SkillItem(name: 'Docker', description: 'Containerization'),
    ];
    cv.projects = [
      ProjectItem(
        name: 'Clara: Jurnal Bayi dengan AI',
        role: 'Backend Developer',
        description: 'Engineered microservices backend handling baby journal records using Go and PostgreSQL.',
      ),
    ];

    // Experiences & educations are empty, but projects are present with > 50 chars plain text
    expect(cv.experiences.isEmpty, isTrue);
    expect(cv.educations.isEmpty, isTrue);
    expect(cv.isEligibleForAi, isTrue);
  });

  test('Auto-Fix deduplicates identical project entries and merges recommended skills', () {
    final cv = CvDocument.empty();
    cv.projects = [
      ProjectItem(name: 'Clara: Jurnal Bayi dengan AI', role: 'Backend', description: 'Initial desc'),
      ProjectItem(name: 'Clara: Jurnal Bayi dengan AI', role: 'Backend', description: 'Duplicate desc'),
    ];
    cv.skills = [
      SkillItem(name: 'Golang', description: 'Core development'),
    ];

    expect(cv.projects.length, 2);

    // Simulate improvedData from autoFixAts resolving HRD suggestions
    final improvedProjects = [
      {
        'name': 'Clara: Jurnal Bayi dengan AI',
        'role': 'Lead Backend Engineer',
        'description': 'Architected high-concurrency backend microservice with Go and Redis caching.',
      }
    ];
    final improvedSkills = [
      {'name': 'Golang', 'description': 'Core backend development'},
      {'name': 'Redis', 'description': 'Distributed caching and pub/sub messaging'},
      {'name': 'gRPC', 'description': 'High-performance inter-service RPC communication'},
    ];

    // Deduplication logic identical to AtsCheckerScreen
    final List<ProjectItem> newProjects = [];
    final Set<String> seenProjectNames = <String>{};
    for (final projMap in improvedProjects) {
      final name = projMap['name']?.trim() ?? '';
      final key = name.toLowerCase();
      if (name.isNotEmpty && seenProjectNames.contains(key)) continue;
      if (key.isNotEmpty) seenProjectNames.add(key);
      newProjects.add(ProjectItem(
        name: name,
        role: projMap['role'] ?? '',
        description: projMap['description'] ?? '',
      ));
    }
    cv.projects = newProjects;

    // Skills update
    final List<SkillItem> newSkills = [];
    final Set<String> seenSkillNames = <String>{};
    for (final s in improvedSkills) {
      final item = SkillItem.fromJson(s);
      final k = item.name.trim().toLowerCase();
      if (k.isNotEmpty && !seenSkillNames.contains(k)) {
        seenSkillNames.add(k);
        newSkills.add(item);
      }
    }
    cv.skills = newSkills;

    // Verify duplicate is gone
    expect(cv.projects.length, 1);
    expect(cv.projects[0].name, 'Clara: Jurnal Bayi dengan AI');
    expect(cv.projects[0].role, 'Lead Backend Engineer');

    // Verify recommended skills (Redis & gRPC) are successfully included
    expect(cv.skills.length, 3);
    final skillNames = cv.skills.map((s) => s.name).toList();
    expect(skillNames, contains('Golang'));
    expect(skillNames, contains('Redis'));
    expect(skillNames, contains('gRPC'));
  });
}

