import 'package:flutter/material.dart';

import '../data/dolch_words.dart';
import '../widgets/level_card.dart';

/// Flash Dash gameplay screen. This is a placeholder navigation target —
/// the real word card, tap zones, and timer are built out in follow-up
/// commits.
class FlashDashScreen extends StatelessWidget {
  final DolchLevel level;

  const FlashDashScreen({super.key, required this.level});

  @override
  Widget build(BuildContext context) {
    final visual = visualForLevel(level.id);
    return Scaffold(
      backgroundColor: visual.color,
      body: Center(
        child: Icon(visual.icon, size: 120, color: Colors.white),
      ),
    );
  }
}
