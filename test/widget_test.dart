import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vibemastery/data/dolch_words.dart';
import 'package:vibemastery/main.dart';
import 'package:vibemastery/screens/flash_dash_screen.dart';
import 'package:vibemastery/widgets/word_card.dart';

void main() {
  testWidgets('App launches to the home screen without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const SightWordApp());
    await tester.pump();

    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Tapping a level card navigates into Flash Dash for that level', (WidgetTester tester) async {
    await tester.pumpWidget(const SightWordApp());
    await tester.pump();

    expect(find.text('Pre-Primer'), findsOneWidget);
    expect(find.byType(FlashDashScreen), findsNothing);

    await tester.tap(find.text('Pre-Primer'));
    // FlashDashScreen's round timer ticks for the whole round duration, so
    // pumpAndSettle would run out the clock instead of settling. A few
    // fixed pumps are enough to clear the page transition animation.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final flashDashScreen = tester.widget<FlashDashScreen>(find.byType(FlashDashScreen));
    expect(flashDashScreen.level.label, 'Pre-Primer');

    final wordCard = tester.widget<WordCard>(find.byType(WordCard));
    expect(prePrimerWords, contains(wordCard.word));
  });
}
