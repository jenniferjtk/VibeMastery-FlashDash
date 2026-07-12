import 'package:flutter/material.dart';

import '../game/flash_dash_round.dart';
import '../services/score_repository.dart';
import '../theme/app_theme.dart';
import '../widgets/go_home_button.dart';
import '../widgets/score_visual.dart';

/// Results screen shown immediately after a round ends.
///
/// Score is communicated visually (ring fill, mascot expression, stars) —
/// not just as a number a young child can't interpret unassisted. The
/// round is persisted as a [ScoreEntry] as soon as this screen is shown.
class ResultsScreen extends StatefulWidget {
  final FlashDashRound round;

  const ResultsScreen({super.key, required this.round});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final ScoreRepository _repository = ScoreRepository();

  @override
  void initState() {
    super.initState();
    // Fire-and-forget: persistence failures are swallowed inside the
    // repository and must never block or crash this screen.
    _repository.addEntry(widget.round.toScoreEntry());
  }

  @override
  Widget build(BuildContext context) {
    final score = widget.round.computeRoundScore();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              ScoreVisual(score: score),
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
