import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumer/core/widgets/admob_banner_widget.dart';

void main() {
  testWidgets('AdMobBannerWidget collapses to SizedBox.shrink when ad is not loaded', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AdMobBannerWidget(),
          ),
        ),
      ),
    );

    // Initial state before load completion must collapse to SizedBox.shrink
    // taking zero height to prevent empty whitespace
    final sizedBoxFinder = find.descendant(
      of: find.byType(AdMobBannerWidget),
      matching: find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.width == 0.0 && widget.height == 0.0,
      ),
    );

    expect(sizedBoxFinder, findsOneWidget);
  });
}
