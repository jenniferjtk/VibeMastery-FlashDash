import 'package:flutter/material.dart';

/// A shrinking horizontal bar representing time remaining in a round.
///
/// Deliberately non-numeric — a child shouldn't have to read a countdown
/// to know time is running out.
class RoundTimerBar extends StatelessWidget {
  final double remainingFraction;

  const RoundTimerBar({super.key, required this.remainingFraction});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 20,
        color: Colors.white.withValues(alpha: 0.35),
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: remainingFraction.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
