import 'package:flutter/material.dart';

import '../data/dolch_words.dart';
import '../game/flash_dash_round.dart';
import '../widgets/answer_button.dart';
import '../widgets/level_card.dart';
import '../widgets/word_card.dart';

/// Flash Dash gameplay screen.
///
/// Shows the current word from a [FlashDashRound] on a neutral card, with
/// a green check zone (know it) and red circle zone (practice again) plus
/// matching swipe gestures. The round timer and completion navigation are
/// wired up in follow-up commits.
class FlashDashScreen extends StatefulWidget {
  final DolchLevel level;

  const FlashDashScreen({super.key, required this.level});

  @override
  State<FlashDashScreen> createState() => _FlashDashScreenState();
}

class _FlashDashScreenState extends State<FlashDashScreen> {
  static const _transitionDuration = Duration(milliseconds: 220);
  static const _swipeVelocityThreshold = 300.0;

  late final FlashDashRound _round;

  /// True while a card transition is in flight. Every input handler bails
  /// out early while this is true, so rapid/repeated taps can never queue
  /// up more than one answer at a time.
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _round = FlashDashRound(level: widget.level.label, words: widget.level.words);
  }

  void _handleAnswer({required bool known}) {
    if (_isTransitioning || _round.isComplete) return;
    setState(() {
      _isTransitioning = true;
      if (known) {
        _round.markKnown();
      } else {
        _round.markPracticeAgain();
      }
    });
    Future.delayed(_transitionDuration, () {
      if (!mounted) return;
      setState(() => _isTransitioning = false);
    });
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < _swipeVelocityThreshold) return;
    _handleAnswer(known: velocity > 0);
  }

  @override
  Widget build(BuildContext context) {
    final visual = visualForLevel(widget.level.id);
    final word = _round.currentWord;

    return Scaffold(
      backgroundColor: visual.color,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: _isTransitioning ? null : _handleSwipe,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: _transitionDuration,
                    child: word == null
                        ? Icon(visual.icon, size: 120, color: Colors.white, key: const ValueKey('done'))
                        : WordCard(key: ValueKey(word), word: word),
                  ),
                ),
              ),
            ),
            if (word != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: AnswerButton(
                        color: const Color(0xFFFF6B6B),
                        icon: Icons.cancel_rounded,
                        enabled: !_isTransitioning,
                        onTap: () => _handleAnswer(known: false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AnswerButton(
                        color: const Color(0xFF51CF66),
                        icon: Icons.check_circle_rounded,
                        enabled: !_isTransitioning,
                        onTap: () => _handleAnswer(known: true),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
