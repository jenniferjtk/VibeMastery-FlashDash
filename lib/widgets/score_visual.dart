import 'package:flutter/material.dart';

/// A non-numeric visual representation of a 0-100 round score: a filled
/// ring, a mascot face, and a row of stars. A young child can read "how
/// well did I do" from color, fill, and expression without reading the
/// number.
class ScoreVisual extends StatelessWidget {
  final int score;

  const ScoreVisual({super.key, required this.score});

  IconData get _mascotIcon {
    if (score >= 80) return Icons.sentiment_very_satisfied_rounded;
    if (score >= 50) return Icons.sentiment_satisfied_rounded;
    return Icons.sentiment_neutral_rounded;
  }

  Color get _mascotColor {
    if (score >= 80) return const Color(0xFF51CF66);
    if (score >= 50) return const Color(0xFFFFA94D);
    return const Color(0xFF6C63FF);
  }

  int get _starCount => (score / 20).round().clamp(0, 5);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 16,
                  backgroundColor: Colors.black12,
                  valueColor: AlwaysStoppedAnimation<Color>(_mascotColor),
                ),
              ),
              Icon(_mascotIcon, size: 96, color: _mascotColor),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final filled = i < _starCount;
            return Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              size: 40,
              color: const Color(0xFFFFD43B),
            );
          }),
        ),
      ],
    );
  }
}
