import 'package:flutter_test/flutter_test.dart';
import 'package:resumer/core/utils/social_link_helper.dart';
import 'package:resumer/features/cv_editor/models/cv_model.dart';

void main() {
  group('SocialLinkHelper Tests', () {
    test('extractHandle cleans full URLs, @ handles, and trailing slashes', () {
      // GitHub
      expect(SocialLinkHelper.extractHandle(SocialPlatform.github, 'deniadams'), 'deniadams');
      expect(SocialLinkHelper.extractHandle(SocialPlatform.github, '@deniadams'), 'deniadams');
      expect(SocialLinkHelper.extractHandle(SocialPlatform.github, 'https://github.com/deniadams/'), 'deniadams');
      expect(SocialLinkHelper.extractHandle(SocialPlatform.github, 'github.com/deniadams'), 'deniadams');

      // LinkedIn
      expect(SocialLinkHelper.extractHandle(SocialPlatform.linkedin, 'johndoe'), 'johndoe');
      expect(SocialLinkHelper.extractHandle(SocialPlatform.linkedin, 'https://linkedin.com/in/johndoe/'), 'johndoe');

      // WhatsApp
      expect(SocialLinkHelper.extractHandle(SocialPlatform.whatsapp, '08123456789'), '628123456789');
      expect(SocialLinkHelper.extractHandle(SocialPlatform.whatsapp, '+62 812-3456-789'), '628123456789');

      // Instagram
      expect(SocialLinkHelper.extractHandle(SocialPlatform.instagram, '@creativestudio'), 'creativestudio');
      expect(SocialLinkHelper.extractHandle(SocialPlatform.instagram, 'https://instagram.com/creativestudio'), 'creativestudio');

      // Website
      expect(SocialLinkHelper.extractHandle(SocialPlatform.website, 'https://myportfolio.dev/'), 'myportfolio.dev');
      expect(SocialLinkHelper.extractHandle(SocialPlatform.website, 'myportfolio.dev'), 'myportfolio.dev');
    });

    test('buildUrl constructs valid clickable URLs', () {
      expect(
        SocialLinkHelper.buildUrl(SocialPlatform.github, 'deniadams'),
        'https://github.com/deniadams',
      );
      expect(
        SocialLinkHelper.buildUrl(SocialPlatform.linkedin, 'johndoe'),
        'https://linkedin.com/in/johndoe',
      );
      expect(
        SocialLinkHelper.buildUrl(SocialPlatform.whatsapp, '08123456789'),
        'https://wa.me/628123456789',
      );
      expect(
        SocialLinkHelper.buildUrl(SocialPlatform.website, 'portfolio.com'),
        'https://portfolio.com',
      );
    });

    test('buildDisplayText formats compact, readable strings', () {
      expect(
        SocialLinkHelper.buildDisplayText(SocialPlatform.github, 'deniadams'),
        'github.com/deniadams',
      );
      expect(
        SocialLinkHelper.buildDisplayText(SocialPlatform.instagram, 'creativestudio'),
        '@creativestudio',
      );
      expect(
        SocialLinkHelper.buildDisplayText(SocialPlatform.whatsapp, '08123456789'),
        '+628123456789',
      );
    });

    test('getSvgIcon returns non-empty valid SVG strings', () {
      for (final platform in SocialPlatform.values) {
        final svg = SocialLinkHelper.getSvgIcon(platform, hexColor: '#0B132B');
        expect(svg.startsWith('<svg'), isTrue);
        expect(svg.contains('</svg>'), isTrue);
        expect(svg.contains('#0B132B'), isTrue);
      }
    });
  });

  group('PersonalInfo and CvDocument Social Links Integration', () {
    test('PersonalInfo serializes and deserializes all 6 social fields', () {
      final info = PersonalInfo(
        fullName: 'Alexander Wright',
        email: 'alex@example.com',
        phone: '+628123456789',
        location: 'Jakarta, Indonesia',
        linkedin: 'alexwright',
        github: 'alexdev',
        instagram: 'alex.design',
        facebook: 'alexwrightfb',
        whatsapp: '08123456789',
        website: 'alexwright.dev',
      );

      final json = info.toJson();
      expect(json['github'], 'alexdev');
      expect(json['instagram'], 'alex.design');
      expect(json['facebook'], 'alexwrightfb');
      expect(json['whatsapp'], '08123456789');
      expect(json['website'], 'alexwright.dev');

      final reconstructed = PersonalInfo.fromJson(json);
      expect(reconstructed.github, 'alexdev');
      expect(reconstructed.instagram, 'alex.design');
      expect(reconstructed.facebook, 'alexwrightfb');
      expect(reconstructed.whatsapp, '08123456789');
      expect(reconstructed.website, 'alexwright.dev');
    });

    test('PersonalInfo backward compatibility with legacy JSON', () {
      final legacyJson = {
        'full_name': 'Old User',
        'email': 'old@example.com',
        'linkedin': 'olduser',
      };

      final reconstructed = PersonalInfo.fromJson(legacyJson);
      expect(reconstructed.fullName, 'Old User');
      expect(reconstructed.linkedin, 'olduser');
      expect(reconstructed.github, '');
      expect(reconstructed.instagram, '');
      expect(reconstructed.facebook, '');
      expect(reconstructed.whatsapp, '');
      expect(reconstructed.website, '');
    });

    test('toPlainText includes all active social links in ATS format', () {
      final cv = CvDocument(
        personalInfo: PersonalInfo(
          fullName: 'Alexander Wright',
          professionalTitle: 'Lead Software Architect',
          email: 'alex@example.com',
          phone: '+628123456789',
          location: 'Jakarta',
          linkedin: 'alexwright',
          github: 'alexdev',
          website: 'alexwright.dev',
          whatsapp: '08123456789',
        ),
      );

      final plainText = cv.toPlainText();
      expect(plainText.contains('ALEXANDER WRIGHT'), isTrue);
      expect(plainText.contains('LinkedIn: linkedin.com/in/alexwright'), isTrue);
      expect(plainText.contains('GitHub: github.com/alexdev'), isTrue);
      expect(plainText.contains('Portfolio: alexwright.dev'), isTrue);
      expect(plainText.contains('WhatsApp: +628123456789'), isTrue);
    });
  });
}
