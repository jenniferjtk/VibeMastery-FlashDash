import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../data/dolch_words.dart';
import '../game/flash_dash_round.dart';
import '../game/round_timer.dart';
import '../widgets/answer_button.dart';
import '../widgets/go_home_button.dart';
import '../widgets/level_card.dart';
import '../widgets/round_timer_bar.dart';
import '../widgets/word_card.dart';
import 'results_screen.dart';

/// Flash Dash gameplay screen.
///
/// Shows the current word from a [FlashDashRound] on a neutral card, with
/// a green check zone (know it) and red circle zone (practice again) plus
/// matching swipe gestures, and a shrinking [RoundTimerBar] driven by a
/// [RoundTimer]. The round ends — and input is disabled — the moment the
/// queue empties or the timer runs out, and the player is taken to the
/// [ResultsScreen] shortly after.
///
/// If [level] somehow has no words, no round/timer is started at all and
/// a friendly fallback is shown instead of crashing.
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

  FlashDashRound? _round;
  RoundTimer? _timer;
  Ticker? _ticker;
  Duration _lastTick = Duration.zero;

  /// True while a card transition is in flight. Every input handler bails
  /// out early while this is true, so rapid/repeated taps can never queue
  /// up more than one answer at a time.
  bool _isTransitioning = false;

  /// Guards against navigating to Results more than once — both the tick
  /// callback and the answer handler can independently notice the round
  /// just ended.
  bool _hasFinished = false;

  bool get _isRoundOver => _round!.isComplete || _timer!.isExpired;

  @override
  void initState() {
    super.initState();
    if (widget.level.words.isEmpty) return;
    _round = FlashDashRound(level: widget.level.label, words: widget.level.words);
    _timer = RoundTimer(roundDuration: widget.roundDuration);
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final timer = _timer!;
    final ticker = _ticker!;
    if (timer.isExpired) {
      ticker.stop();
      return;
    }
    final delta = elapsed - _lastTick;
    _lastTick = elapsed;
    setState(() {
      timer.elapse(delta);
    });
    if (timer.isExpired) {
      ticker.stop();
      _navigateToResults();
    }
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  void _handleAnswer({required bool known}) {
    if (_isTransitioning || _isRoundOver) return;
    setState(() {
      _isTransitioning = true;
      if (known) {
        _round!.markKnown();
      } else {
        _round!.markPracticeAgain();
      }
    });
    if (_isRoundOver) {
      _navigateToResults();
      return;
    }
    Future.delayed(_transitionDuration, () {
      if (!mounted) return;
      setState(() => _isTransitioning = false);
    });
  }

  /// Pauses briefly (so the completion icon is visible for a beat) then
  /// replaces this screen with the Results screen for the finished round.
  void _navigateToResults() {
    if (_hasFinished) return;
    _hasFinished = true;
    _ticker?.stop();
    Future.delayed(_transitionDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResultsScreen(round: _round!)),
      );
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

    if (widget.level.words.isEmpty) {
      return _EmptyLevelFallback(visual: visual);
    }

    final roundOver = _isRoundOver;
    final word = roundOver ? null : _round!.currentWord;

    return Scaffold(
      backgroundColor: visual.color,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: RoundTimerBar(remainingFraction: _timer!.remainingFraction),
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

/// Shown instead of gameplay when a level's word list is somehow empty,
/// so the app never crashes on a bad/missing data set.
class _EmptyLevelFallback extends StatelessWidget {
  final LevelVisual visual;

  const _EmptyLevelFallback({required this.visual});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: visual.color,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Icon(visual.icon, size: 120, color: Colors.white),
              const Spacer(),
              const GoHomeButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
