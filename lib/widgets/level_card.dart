import 'package:flutter/material.dart';

import '../data/dolch_words.dart';

/// Color + icon pairing for one Dolch level, used so a level is
/// recognizable by sight alone rather than by reading its name.
class LevelVisual {
  final Color color;
  final IconData icon;

  const LevelVisual({required this.color, required this.icon});
}

const Map<String, LevelVisual> _levelVisuals = {
  'pre_primer': LevelVisual(color: Color(0xFFFF6B6B), icon: Icons.emoji_emotions_rounded),
  'primer': LevelVisual(color: Color(0xFFFFA94D), icon: Icons.favorite_rounded),
  'first_grade': LevelVisual(color: Color(0xFF51CF66), icon: Icons.pets_rounded),
  'second_grade': LevelVisual(color: Color(0xFF4DABF7), icon: Icons.wb_sunny_rounded),
  'third_grade': LevelVisual(color: Color(0xFF9775FA), icon: Icons.rocket_launch_rounded),
  'nouns': LevelVisual(color: Color(0xFF20C997), icon: Icons.category_rounded),
};

const LevelVisual _fallbackVisual = LevelVisual(color: Color(0xFF6C63FF), icon: Icons.stars_rounded);

LevelVisual visualForLevel(String id) => _levelVisuals[id] ?? _fallbackVisual;

/// A big, high-contrast, icon-led card for one Dolch level.
///
/// Color and icon carry the meaning; the label is a small supplementary
/// cue, not something the player has to read to know what to tap.
class LevelCard extends StatelessWidget {
  final DolchLevel level;
  final VoidCallback onTap;

  const LevelCard({super.key, required this.level, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final visual = visualForLevel(level.id);
    return Semantics(
      button: true,
      label: level.label,
      child: Material(
        color: visual.color,
        borderRadius: BorderRadius.circular(28),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 64, minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(visual.icon, size: 56, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    level.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
