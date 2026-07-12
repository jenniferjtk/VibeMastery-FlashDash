import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:vibemastery/models/score_entry.dart';
import 'package:vibemastery/screens/home_screen.dart';
import 'package:vibemastery/screens/stats_screen.dart';
import 'package:vibemastery/widgets/score_visual.dart';

void main() {
  testWidgets('shows a friendly empty state when no rounds have been played', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: StatsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No rounds played yet!'), findsOneWidget);
    expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
  });

  testWidgets('shows history and a correctly averaged combined score', (WidgetTester tester) async {
    final entries = [
      ScoreEntry(
        gameId: 'flash_dash',
        level: 'Pre-Primer',
        playedAt: DateTime(2026, 1, 1),
        roundScore: 80,
        wordsTotal: 5,
        wordsKnownFirstTry: 4,
      ),
      ScoreEntry(
        gameId: 'flash_dash',
        level: 'Primer',
        playedAt: DateTime(2026, 1, 2),
        roundScore: 60,
        wordsTotal: 5,
        wordsKnownFirstTry: 3,
      ),
    ];
    SharedPreferences.setMockInitialValues({
      'score_entries': jsonEncode(entries.map((e) => e.toJson()).toList()),
    });

    await tester.pumpWidget(const MaterialApp(home: StatsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('No rounds played yet!'), findsNothing);
    expect(find.text('Pre-Primer'), findsOneWidget);
    expect(find.text('Primer'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
    expect(find.text('60'), findsOneWidget);

    // Combined score = round((80 + 60) / 2) = 70. ScoreVisual never renders
    // the number as text, so check its score property directly.
    final scoreVisual = tester.widget<ScoreVisual>(find.byType(ScoreVisual));
    expect(scoreVisual.score, 70);
  });

  testWidgets('the stats icon on Home navigates to Stats, and its home icon pops back', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(StatsScreen), findsNothing);
    await tester.tap(find.byIcon(Icons.bar_chart_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(StatsScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(StatsScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
