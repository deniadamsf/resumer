import 'package:flutter/material.dart';

/// Root Responsive Wrapper untuk membatasi penskalaan font sistem
/// Mencegah RenderFlex overflow pada layar sempit & font jumbo (GEMINI.md Bagian 4)
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.textScalerOf(context).clamp(
          minScaleFactor: 0.85,
          maxScaleFactor: 1.15,
        ),
      ),
      child: child,
    );
  }
}
