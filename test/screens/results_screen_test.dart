import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibemastery/game/flash_dash_round.dart';
import 'package:vibemastery/screens/results_screen.dart';
import 'package:vibemastery/services/score_repository.dart';
import 'package:vibemastery/widgets/score_visual.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows the score visual and persists a matching ScoreEntry', (WidgetTester tester) async {
    final round = FlashDashRound(level: 'Pre-Primer', words: ['a', 'and']);
    round.markKnown();
    round.markKnown();

    await tester.pumpWidget(MaterialApp(home: ResultsScreen(round: round)));
    await tester.pumpAndSettle();

    expect(find.byType(ScoreVisual), findsOneWidget);

    final entries = await ScoreRepository().loadEntries();
    expect(entries, hasLength(1));
    expect(entries.first.gameId, 'flash_dash');
    expect(entries.first.level, 'Pre-Primer');
    expect(entries.first.roundScore, 100);
    expect(entries.first.wordsTotal, 2);
    expect(entries.first.wordsKnownFirstTry, 2);
  });

  testWidgets('the home button pops back to the screen underneath', (WidgetTester tester) async {
    final round = FlashDashRound(level: 'Primer', words: ['at']);
    round.markKnown();

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ResultsScreen(round: round)),
                ),
                child: const Text('Go to results'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go to results'));
    await tester.pumpAndSettle();
    expect(find.byType(ResultsScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(ResultsScreen), findsNothing);
    expect(find.text('Go to results'), findsOneWidget);
  });
}
