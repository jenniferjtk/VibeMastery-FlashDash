import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibemastery/screens/flash_dash_screen.dart';
import 'package:vibemastery/screens/home_screen.dart';
import 'package:vibemastery/screens/stats_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  /// FlashDashScreen's round timer ticks continuously for the whole round
  /// duration, so pumpAndSettle would run out the clock instead of
  /// settling. A few fixed pumps are enough to clear the push transition.
  Future<void> settlePush(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('rapid double tap on a level card only pushes one Flash Dash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    // Two taps with no pump in between, simulating a mashing child. The
    // second tap is expected to land after the first push has already
    // covered this widget with the new route, hence warnIfMissed: false.
    await tester.tap(find.text('Pre-Primer'));
    await tester.tap(find.text('Pre-Primer'), warnIfMissed: false);
    await settlePush(tester);

    expect(tester.takeException(), isNull);
    // If both taps had pushed, there would be two FlashDashScreens stacked.
    expect(find.byType(FlashDashScreen), findsOneWidget);
  });

  testWidgets('rapid double tap on the stats icon only pushes one Stats screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    final statsIcon = find.byIcon(Icons.bar_chart_rounded);
    await tester.tap(statsIcon);
    await tester.tap(statsIcon, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(StatsScreen), findsOneWidget);
  });
}
