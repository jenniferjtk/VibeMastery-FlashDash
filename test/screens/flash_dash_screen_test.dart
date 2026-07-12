import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vibemastery/data/dolch_words.dart';
import 'package:vibemastery/game/round_timer.dart';
import 'package:vibemastery/screens/flash_dash_screen.dart';
import 'package:vibemastery/screens/results_screen.dart';
import 'package:vibemastery/widgets/word_card.dart';

const _testLevel = DolchLevel(id: 'test_level', label: 'Test Level', words: ['dog', 'cat', 'sun']);

Future<void> _pumpScreen(
  WidgetTester tester, {
  Duration roundDuration = RoundTimer.defaultRoundDuration,
}) async {
  await tester.pumpWidget(MaterialApp(home: FlashDashScreen(level: _testLevel, roundDuration: roundDuration)));
  await tester.pump();
}

/// Resolves the card-transition animation without using pumpAndSettle:
/// the round timer's ticker keeps requesting frames for the whole round
/// duration, so pumpAndSettle would just run out the clock instead of
/// settling.
Future<void> _settleTransition(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Same idea as [_settleTransition] but longer, to also clear the
/// completion pause plus the page-route push animation that follow a
/// finished round.
Future<void> _settleNavigation(WidgetTester tester) async {
  for (var i = 0; i < 24; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('rapid double tap on "know it" only advances one word (debounced)', (WidgetTester tester) async {
    await _pumpScreen(tester);

    final knowItButton = find.byIcon(Icons.check_circle_rounded);
    expect(find.byType(WordCard), findsOneWidget);

    // Simulate a mashing child: two taps with no pump/settle in between.
    await tester.tap(knowItButton);
    await tester.tap(knowItButton);
    await _settleTransition(tester);

    // If both taps had registered, all 3 words would already be gone.
    // Only one should have counted, leaving 2 words and the card visible.
    expect(find.byType(WordCard), findsOneWidget);

    await tester.tap(knowItButton);
    await _settleTransition(tester);
    expect(find.byType(WordCard), findsOneWidget);

    await tester.tap(knowItButton);
    await _settleTransition(tester);
    // All 3 words now known: the card is replaced by the completion icon.
    expect(find.byType(WordCard), findsNothing);
  });

  testWidgets('tapping "practice again" recycles the word instead of removing it', (WidgetTester tester) async {
    await _pumpScreen(tester);

    final practiceAgainButton = find.byIcon(Icons.cancel_rounded);

    for (var i = 0; i < 5; i++) {
      await tester.tap(practiceAgainButton);
      await _settleTransition(tester);
      // Recycling never removes a word, so the card should always be there,
      // and repeated taps must never crash the screen.
      expect(find.byType(WordCard), findsOneWidget);
    }
  });

  testWidgets('round ends and hides input once the timer expires, even mid-word', (WidgetTester tester) async {
    await _pumpScreen(tester, roundDuration: const Duration(seconds: 2));

    expect(find.byType(WordCard), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await _settleTransition(tester);

    // Time ran out before the words were cleared: the round is over even
    // though words remain, tap zones are gone, and nothing crashed.
    expect(find.byType(WordCard), findsNothing);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    expect(find.byIcon(Icons.cancel_rounded), findsNothing);
  });

  testWidgets('timer expiry navigates to the Results screen', (WidgetTester tester) async {
    await _pumpScreen(tester, roundDuration: const Duration(seconds: 2));

    await tester.pump(const Duration(seconds: 3));
    await _settleNavigation(tester);

    expect(find.byType(FlashDashScreen), findsNothing);
    expect(find.byType(ResultsScreen), findsOneWidget);
  });

  testWidgets('clearing every word navigates to the Results screen', (WidgetTester tester) async {
    await _pumpScreen(tester);

    final knowItButton = find.byIcon(Icons.check_circle_rounded);
    for (var i = 0; i < 3; i++) {
      await tester.tap(knowItButton);
      await _settleTransition(tester);
    }
    await _settleNavigation(tester);

    expect(find.byType(FlashDashScreen), findsNothing);
    final resultsScreen = tester.widget<ResultsScreen>(find.byType(ResultsScreen));
    expect(resultsScreen.round.wordsTotal, 3);
    expect(resultsScreen.round.wordsKnownFirstTry, 3);
    expect(resultsScreen.round.computeRoundScore(), 100);
  });

  testWidgets('an empty word list shows a friendly fallback instead of crashing', (WidgetTester tester) async {
    const emptyLevel = DolchLevel(id: 'empty_level', label: 'Empty Level', words: []);

    await tester.pumpWidget(const MaterialApp(home: FlashDashScreen(level: emptyLevel)));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(WordCard), findsNothing);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    expect(find.byIcon(Icons.cancel_rounded), findsNothing);
    // The fallback offers a way back home instead of soft-locking.
    expect(find.byIcon(Icons.home_rounded), findsOneWidget);
  });
}
