import 'dart:math';

import '../models/score_entry.dart';

/// Pure state machine for one round of Flash Dash.
///
/// Holds the recycling word queue: a word marked "practice again" goes to
/// the back of the queue instead of being removed, and only counts toward
/// [wordsKnownFirstTry] if it is marked "know it" before it is ever
/// recycled. The round is complete once every word has been known at
/// least once. Timing lives in a separate piece added on top of this class.
class FlashDashRound {
  static const String gameId = 'flash_dash';

  final String level;
  final List<String> words;

  final List<String> _queue;
  final Set<String> _recycled = {};
  int _wordsKnownFirstTry = 0;
  int _wordsKnown = 0;

  FlashDashRound({required this.level, required List<String> words, Random? random})
      : words = List.unmodifiable(words),
        _queue = List.of(words)..shuffle(random ?? Random());

  /// The word currently on top of the deck, or null once the round is over.
  String? get currentWord => _queue.isEmpty ? null : _queue.first;

  /// True once every word in [words] has been marked "know it" at least once.
  bool get isComplete => _queue.isEmpty;

  int get wordsTotal => words.length;

  int get wordsKnownFirstTry => _wordsKnownFirstTry;

  int get wordsKnown => _wordsKnown;

  /// Marks the current word as known and removes it from the queue.
  void markKnown() {
    final word = _requireCurrentWord();
    _queue.removeAt(0);
    _wordsKnown++;
    if (!_recycled.contains(word)) {
      _wordsKnownFirstTry++;
    }
  }

  /// Marks the current word as needing more practice and sends it to the
  /// back of the queue.
  void markPracticeAgain() {
    final word = _requireCurrentWord();
    _queue.removeAt(0);
    _recycled.add(word);
    _queue.add(word);
  }

  String _requireCurrentWord() {
    final word = currentWord;
    if (word == null) {
      throw StateError('No current word: the round is already complete.');
    }
    return word;
  }

  /// roundScore = round(100 * wordsKnownFirstTry / wordsTotal).
  ///
  /// Words known only after one or more recycles still count toward
  /// completion but pull the score down versus a first-try knowledge,
  /// since they still needed practice.
  int computeRoundScore() {
    if (wordsTotal == 0) return 0;
    return (100 * _wordsKnownFirstTry / wordsTotal).round();
  }

  /// Converts the round's outcome into a persistable [ScoreEntry].
  ScoreEntry toScoreEntry({DateTime? playedAt}) {
    return ScoreEntry(
      gameId: gameId,
      level: level,
      playedAt: playedAt ?? DateTime.now(),
      roundScore: computeRoundScore(),
      wordsTotal: wordsTotal,
      wordsKnownFirstTry: wordsKnownFirstTry,
    );
  }
}
