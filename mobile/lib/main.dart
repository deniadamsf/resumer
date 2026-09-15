import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/colors.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/api_service.dart';
import 'core/widgets/responsive_wrapper.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/cv_editor/screens/cv_editor_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization with automatic fallback to en_US
  await AppLocalizations.instance.init('id_ID');

  // Initialize ApiService (Device UUID & Sanctum Auth state)
  await ApiService.instance.init();

  runApp(const ResumerApp());
}

class ResumerApp extends StatelessWidget {
  const ResumerApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        ),
      ),
      builder: (context, child) {
        // Enforce anti-text blowout textScaler clamping per GEMINI.md Bagian 4
        return ResponsiveWrapper(child: child!);
      },
      home: ApiService.instance.isAuthenticated
          ? const CvEditorScreen()
          : const LoginScreen(),
    );
  }
}
