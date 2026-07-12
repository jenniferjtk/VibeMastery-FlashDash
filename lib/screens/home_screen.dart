import 'package:flutter/material.dart';

import '../data/dolch_words.dart';
import '../widgets/level_card.dart';
import 'flash_dash_screen.dart';
import 'stats_screen.dart';

/// Level-select entry point: one big color-coded, icon-led card per
/// Dolch level. Tapping a card goes straight into Flash Dash for that
/// level, no instructional text to read first.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8, top: 4),
                child: IconButton(
                  icon: const Icon(Icons.bar_chart_rounded, size: 32),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StatsScreen()),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: dolchLevels.length,
                  itemBuilder: (context, index) {
                    final level = dolchLevels[index];
                    return LevelCard(
                      level: level,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => FlashDashScreen(level: level)),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
