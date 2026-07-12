import 'package:flutter/material.dart';

/// A big color+icon tap zone for one Flash Dash answer ("know it" /
/// "practice again"). Dims when [enabled] is false so a disabled state
/// during a card transition is visible without any text.
class AnswerButton extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const AnswerButton({
    super.key,
    required this.color,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 150),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 64, minHeight: 96),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Icon(icon, size: 48, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
