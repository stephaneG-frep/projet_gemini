import 'package:flutter/material.dart';

class XpBar extends StatelessWidget {
  const XpBar({super.key, required this.xp, required this.xpToNextLevel});

  final int xp;
  final int xpToNextLevel;

  @override
  Widget build(BuildContext context) {
    final value = xpToNextLevel == 0 ? 0.0 : xp / xpToNextLevel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('XP $xp / $xpToNextLevel', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 12,
            backgroundColor: const Color(0xFFE8EDF8),
            color: const Color(0xFF5278C8),
          ),
        ),
      ],
    );
  }
}
