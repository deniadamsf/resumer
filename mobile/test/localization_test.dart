import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resumer/core/localization/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('AppLocalizations dynamically switches locale and notifies listeners', () async {
    final loc = AppLocalizations.instance;
    await loc.init('id_ID');

    expect(loc.currentLocale, 'id_ID');
    expect(loc.localeNotifier.value, 'id_ID');
    expect('tabs.editor'.tr, 'Editor');
    expect('tabs.profile'.tr, 'Profil');

    // Switch to English
    await loc.setLocale('en_US');
    expect(loc.currentLocale, 'en_US');
    expect(loc.localeNotifier.value, 'en_US');
    expect('tabs.profile'.tr, 'Profile');
    expect('tabs.ats_score'.tr, 'ATS Score');

    // Switch back to Indonesian
    await loc.setLocale('id_ID');
    expect(loc.currentLocale, 'id_ID');
    expect('tabs.profile'.tr, 'Profil');
    expect('tabs.ats_score'.tr, 'Skor ATS');
  });
}
