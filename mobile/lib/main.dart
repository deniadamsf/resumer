import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/colors.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/ad_service.dart';
import 'core/services/api_service.dart';
import 'core/services/iap_service.dart';
import 'core/services/signature_service.dart';
import 'core/widgets/responsive_wrapper.dart';
import 'features/splash/screens/splash_screen.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  debugPrint('=== RESUMER APP STARTING ===');

  try {
    debugPrint('1. Initializing localization...');
    await AppLocalizations.instance.init('id_ID');
    debugPrint('2. Localization initialized.');

    debugPrint('3. Initializing ApiService...');
    await ApiService.instance.init();
    debugPrint('4. ApiService initialized. Authenticated: ${ApiService.instance.isAuthenticated}');

    debugPrint('5. Initializing SignatureService...');
    await SignatureService.instance.init();
    debugPrint('6. SignatureService initialized. HasSignature: ${SignatureService.instance.hasSignature}');

    debugPrint('7. Initializing AdService (AdMob SDK & Preload)...');
    await AdService.instance.init();
    debugPrint('8. AdService initialized.');

    debugPrint('9. Initializing IapService (Google Play Billing)...');
    await IapService.instance.init();
    debugPrint('10. IapService initialized.');
  } catch (e, stack) {
    debugPrint('ERROR during main initialization: $e\n$stack');
  }

  debugPrint('11. Calling runApp...');
  runApp(const ResumerApp());
  debugPrint('12. runApp called successfully.');
}


class ResumerApp extends StatelessWidget {
  const ResumerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.instance.localeNotifier,
      builder: (context, currentLocale, _) {
        return MaterialApp(
          title: 'Resumer',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: AppColors.oysterCanvas,
            colorScheme: const ColorScheme.light(
              primary: AppColors.midnightNavy,
              secondary: AppColors.mutedSteelSlate,
              surface: AppColors.cardSurface,
            ),
            textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
            ),
          ),
          builder: (context, child) {
            // Enforce anti-text blowout textScaler clamping per GEMINI.md Bagian 4
            return ResponsiveWrapper(child: child!);
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}
