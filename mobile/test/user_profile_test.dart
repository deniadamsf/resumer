import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resumer/core/services/api_service.dart';
import 'package:resumer/features/cv_editor/services/cv_profile_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ApiService.instance.init();
    await CvProfileManager.instance.init();
  });

  test('ApiService saves and updates custom user name', () async {
    await ApiService.instance.saveUserData(
      name: 'Deni Adam',
      email: 'deni@example.com',
    );

    expect(ApiService.instance.userName, equals('Deni Adam'));
    expect(ApiService.instance.userEmail, equals('deni@example.com'));

    // Update name manually
    final result = await ApiService.instance.updateUserName('Deni Adam, S.Kom');
    expect(result['success'], isTrue);
    expect(ApiService.instance.userName, equals('Deni Adam, S.Kom'));

    // Verify persistence in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_name'), equals('Deni Adam, S.Kom'));
  });

  test('Custom user name can synchronize to active CV draft', () async {
    final cv = CvProfileManager.instance.currentCv;
    cv.personalInfo.fullName = 'Deni Adam, S.Kom';
    CvProfileManager.instance.updateDraftSilently(cv);
    await CvProfileManager.instance.persistDraftLocally();

    expect(CvProfileManager.instance.currentCv.personalInfo.fullName, equals('Deni Adam, S.Kom'));
  });
}
