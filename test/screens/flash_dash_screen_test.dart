import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vibemastery/data/dolch_words.dart';
import 'package:vibemastery/screens/flash_dash_screen.dart';
import 'package:vibemastery/widgets/word_card.dart';

const _testLevel = DolchLevel(id: 'test_level', label: 'Test Level', words: ['dog', 'cat', 'sun']);

Future<void> _pumpScreen(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(home: FlashDashScreen(level: _testLevel)));
  await tester.pump();
}

void main() {
  testWidgets('rapid double tap on "know it" only advances one word (debounced)', (WidgetTester tester) async {
    await _pumpScreen(tester);

    final knowItButton = find.byIcon(Icons.check_circle_rounded);
    expect(find.byType(WordCard), findsOneWidget);

    // Simulate a mashing child: two taps with no pump/settle in between.
    await tester.tap(knowItButton);
    await tester.tap(knowItButton);
    await tester.pumpAndSettle();

    // If both taps had registered, all 3 words would already be gone.
    // Only one should have counted, leaving 2 words and the card visible.
    expect(find.byType(WordCard), findsOneWidget);

    await tester.tap(knowItButton);
    await tester.pumpAndSettle();
    expect(find.byType(WordCard), findsOneWidget);

    await tester.tap(knowItButton);
    await tester.pumpAndSettle();
    // All 3 words now known: the card is replaced by the completion icon.
    expect(find.byType(WordCard), findsNothing);
  });

  testWidgets('tapping "practice again" recycles the word instead of removing it', (WidgetTester tester) async {
    await _pumpScreen(tester);

    final practiceAgainButton = find.byIcon(Icons.cancel_rounded);

    for (var i = 0; i < 5; i++) {
      await tester.tap(practiceAgainButton);
      await tester.pumpAndSettle();
      // Recycling never removes a word, so the card should always be there,
      // and repeated taps must never crash the screen.
      expect(find.byType(WordCard), findsOneWidget);
    }
  });
}
