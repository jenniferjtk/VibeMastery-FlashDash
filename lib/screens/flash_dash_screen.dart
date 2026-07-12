import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../data/dolch_words.dart';
import '../game/flash_dash_round.dart';
import '../game/round_timer.dart';
import '../widgets/answer_button.dart';
import '../widgets/level_card.dart';
import '../widgets/round_timer_bar.dart';
import '../widgets/word_card.dart';

/// Flash Dash gameplay screen.
///
/// Shows the current word from a [FlashDashRound] on a neutral card, with
/// a green check zone (know it) and red circle zone (practice again) plus
/// matching swipe gestures, and a shrinking [RoundTimerBar] driven by a
/// [RoundTimer]. The round ends — and input is disabled — the moment the
/// queue empties or the timer runs out. Completion navigation is wired up
/// in a follow-up commit.
class FlashDashScreen extends StatefulWidget {
  final DolchLevel level;
  final Duration roundDuration;

  const FlashDashScreen({
    super.key,
    required this.level,
    this.roundDuration = RoundTimer.defaultRoundDuration,
  });

  @override
  State<FlashDashScreen> createState() => _FlashDashScreenState();
}

class _FlashDashScreenState extends State<FlashDashScreen> with SingleTickerProviderStateMixin {
  static const _transitionDuration = Duration(milliseconds: 220);
  static const _swipeVelocityThreshold = 300.0;

  late final FlashDashRound _round;
  late final RoundTimer _timer;
  late final Ticker _ticker;
  Duration _lastTick = Duration.zero;

  /// True while a card transition is in flight. Every input handler bails
  /// out early while this is true, so rapid/repeated taps can never queue
  /// up more than one answer at a time.
  bool _isTransitioning = false;

  bool get _isRoundOver => _round.isComplete || _timer.isExpired;

  @override
  void initState() {
    super.initState();
    _round = FlashDashRound(level: widget.level.label, words: widget.level.words);
    _timer = RoundTimer(roundDuration: widget.roundDuration);
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (_timer.isExpired) {
      _ticker.stop();
      return;
    }
    final delta = elapsed - _lastTick;
    _lastTick = elapsed;
    setState(() {
      _timer.elapse(delta);
    });
    if (_timer.isExpired) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _handleAnswer({required bool known}) {
    if (_isTransitioning || _isRoundOver) return;
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
    final roundOver = _isRoundOver;
    final word = roundOver ? null : _round.currentWord;

    return Scaffold(
      backgroundColor: visual.color,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: RoundTimerBar(remainingFraction: _timer.remainingFraction),
            ),
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (_isTransitioning || roundOver) ? null : _handleSwipe,
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
            if (!roundOver)
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
