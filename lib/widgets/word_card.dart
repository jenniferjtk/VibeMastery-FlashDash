import 'package:flutter/material.dart';

/// Large centered word on a neutral, high-contrast card.
class WordCard extends StatelessWidget {
  final String word;

  const WordCard({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 240, minHeight: 240),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 8)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        word,
        style: const TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2B2640),
        ),
      ),
    );
  }
}
