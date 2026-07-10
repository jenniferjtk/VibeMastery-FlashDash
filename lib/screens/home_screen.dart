import 'package:flutter/material.dart';

import '../data/dolch_words.dart';
import '../widgets/level_card.dart';
import 'flash_dash_screen.dart';

/// Level-select entry point: one big color-coded, icon-led card per
/// Dolch level. Tapping a card goes straight into Flash Dash for that
/// level no instructional text to read first.
/// 
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          // GridView of LevelCards
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
    );
  }
}
