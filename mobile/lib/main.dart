import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/colors.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/api_service.dart';
import 'core/services/signature_service.dart';
import 'core/widgets/responsive_wrapper.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/navigation/screens/main_navigation_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
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
    if (kDebugMode && !ApiService.instance.isAuthenticated) {
      await ApiService.instance.saveToken('dev_mock_sanctum_token');
    }
    debugPrint('4. ApiService initialized. Authenticated: ${ApiService.instance.isAuthenticated}');

    debugPrint('5. Initializing SignatureService...');
    await SignatureService.instance.init();
    debugPrint('6. SignatureService initialized. HasSignature: ${SignatureService.instance.hasSignature}');
  } catch (e, stack) {
    debugPrint('ERROR during main initialization: $e\n$stack');
  }

  debugPrint('7. Calling runApp...');
  runApp(const ResumerApp());
  debugPrint('8. runApp called successfully.');
}

class ResumerApp extends StatelessWidget {
  const ResumerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.instance.localeNotifier,
      builder: (context, currentLocale, _) {
        return MaterialApp(
          key: ValueKey(currentLocale),
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
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarIconBrightness: Brightness.dark,
              ),
            ),
          ),
          builder: (context, child) {
            // Enforce anti-text blowout textScaler clamping per GEMINI.md Bagian 4
            return ResponsiveWrapper(child: child!);
          },
          home: ApiService.instance.isAuthenticated
              ? const MainNavigationShell()
              : const LoginScreen(),
        );
      },
    );
  }
}
