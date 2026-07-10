import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vibemastery/game/flash_dash_round.dart';
import 'package:vibemastery/game/round_timer.dart';

void main() {
  group('FlashDashRound', () {
    test('knowing every word on the first try scores 100 and completes the round', () {
      final round = FlashDashRound(level: 'Pre-Primer', words: ['a', 'and'], random: Random(1));

      round.markKnown();
      round.markKnown();

      expect(round.isComplete, isTrue);
      expect(round.wordsTotal, 2);
      expect(round.wordsKnown, 2);
      expect(round.wordsKnownFirstTry, 2);
      expect(round.computeRoundScore(), 100);
    });

    test('a recycled word still counts toward completion but not toward first-try score', () {
      final round = FlashDashRound(level: 'Pre-Primer', words: ['a', 'and'], random: Random(1));

      final recycledWord = round.currentWord;
      round.markPracticeAgain();
      round.markKnown(); // the other word, known first try

      // the recycled word should have cycled back to the front.
      expect(round.currentWord, recycledWord);
      round.markKnown(); // known, but only after being recycled once

      expect(round.isComplete, isTrue);
      expect(round.wordsTotal, 2);
      expect(round.wordsKnown, 2);
      expect(round.wordsKnownFirstTry, 1);
      expect(round.computeRoundScore(), 50);
    });

    test('computeRoundScore rounds to the nearest integer', () {
      final round = FlashDashRound(level: 'Primer', words: ['a', 'b', 'c'], random: Random(1));

      round.markKnown(); // 1st word, known first try

      round.markPracticeAgain(); // 2nd word, recycled
      round.markKnown(); // 3rd word, known first try
      round.markKnown(); // 2nd word, now known but not first try

      expect(round.isComplete, isTrue);
      expect(round.wordsTotal, 3);
      expect(round.wordsKnownFirstTry, 2);
      // 100 * 2 / 3 = 66.66... -> rounds to 67.
      expect(round.computeRoundScore(), 67);
    });

    test('markKnown throws once the round is already complete', () {
      final round = FlashDashRound(level: 'Pre-Primer', words: ['a'], random: Random(1));
      round.markKnown();

      expect(round.isComplete, isTrue);
      expect(() => round.markKnown(), throwsStateError);
      expect(() => round.markPracticeAgain(), throwsStateError);
    });

    test('toScoreEntry converts the finished round into a matching ScoreEntry', () {
      final round = FlashDashRound(level: 'Nouns', words: ['cat', 'dog'], random: Random(1));
      round.markKnown();
      round.markKnown();

      final playedAt = DateTime(2026, 1, 1);
      final entry = round.toScoreEntry(playedAt: playedAt);

      expect(entry.gameId, FlashDashRound.gameId);
      expect(entry.gameId, 'flash_dash');
      expect(entry.level, 'Nouns');
      expect(entry.wordsTotal, 2);
      expect(entry.wordsKnownFirstTry, 2);
      expect(entry.roundScore, 100);
      expect(entry.playedAt, playedAt);
    });
  });

  group('RoundTimer', () {
    test('defaults to a 60 second round', () {
      final timer = RoundTimer();
      expect(timer.roundDuration, const Duration(seconds: 60));
      expect(timer.remainingFraction, 1.0);
      expect(timer.isExpired, isFalse);
    });

    test('remainingFraction decreases as time elapses and clamps at zero', () {
      final timer = RoundTimer(roundDuration: const Duration(seconds: 10));

      timer.elapse(const Duration(seconds: 5));
      expect(timer.remainingFraction, closeTo(0.5, 0.001));
      expect(timer.isExpired, isFalse);

      timer.elapse(const Duration(seconds: 10)); // overshoot past zero
      expect(timer.remaining, Duration.zero);
      expect(timer.remainingFraction, 0.0);
      expect(timer.isExpired, isTrue);
    });
  });
}
