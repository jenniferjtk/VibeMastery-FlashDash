/// A single completed round of any game, normalized to a 0-100 score.
///
/// [roundScore] is always on a 0-100 scale regardless of the game, so
/// combined-score calculations can average across every game without
/// per-game weighting logic. [wordsTotal] and [wordsKnownFirstTry] are kept
/// alongside the score so the formula can be audited or revised later
/// without losing the underlying data.
class ScoreEntry {
  final String gameId;
  final String level;
  final DateTime playedAt;
  final int roundScore;
  final int wordsTotal;
  final int wordsKnownFirstTry;

  const ScoreEntry({
    required this.gameId,
    required this.level,
    required this.playedAt,
    required this.roundScore,
    required this.wordsTotal,
    required this.wordsKnownFirstTry,
  });

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'level': level,
        'playedAt': playedAt.toIso8601String(),
        'roundScore': roundScore,
        'wordsTotal': wordsTotal,
        'wordsKnownFirstTry': wordsKnownFirstTry,
      };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
        gameId: json['gameId'] as String,
        level: json['level'] as String,
        playedAt: DateTime.parse(json['playedAt'] as String),
        roundScore: json['roundScore'] as int,
        wordsTotal: json['wordsTotal'] as int,
        wordsKnownFirstTry: json['wordsKnownFirstTry'] as int,
      );
}
