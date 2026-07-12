import 'package:flutter/material.dart';

import '../utils/navigation_guard.dart';

/// A big, icon-only button that returns the player to Home. Used on
/// "round finished" screens and any friendly-fallback screen.
class GoHomeButton extends StatelessWidget {
  const GoHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF6C63FF),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          if (!isRouteCurrent(context)) return;
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Icon(Icons.home_rounded, size: 48, color: Colors.white),
        ),
      ),
    );
  }
}
