import 'package:flutter/material.dart';

import '../data/dolch_words.dart';
import '../game/flash_dash_round.dart';
import '../widgets/level_card.dart';
import '../widgets/word_card.dart';

/// Flash Dash gameplay screen.
///
/// Shows the current word from a [FlashDashRound] on a neutral card.
/// Tap zones/swipe and the round timer are wired up in follow-up commits.
class FlashDashScreen extends StatefulWidget {
  final DolchLevel level;

  const FlashDashScreen({super.key, required this.level});

  @override
  State<FlashDashScreen> createState() => _FlashDashScreenState();
}

class _FlashDashScreenState extends State<FlashDashScreen> {
  late final FlashDashRound _round;

  @override
  void initState() {
    super.initState();
    _round = FlashDashRound(level: widget.level.label, words: widget.level.words);
  }

  @override
  Widget build(BuildContext context) {
    final visual = visualForLevel(widget.level.id);
    final word = _round.currentWord;

    return Scaffold(
      backgroundColor: visual.color,
      body: SafeArea(
        child: Center(
          child: word == null
              ? Icon(visual.icon, size: 120, color: Colors.white)
              : WordCard(word: word),
        ),
      ),
    );
  }
}
