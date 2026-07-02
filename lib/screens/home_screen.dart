import 'package:flutter/material.dart';

/// Level-select entry point. Card grid is added in a follow-up commit.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Icon(Icons.auto_stories_rounded, size: 96, color: Color(0xFF6C63FF)),
      ),
    );
  }
}
