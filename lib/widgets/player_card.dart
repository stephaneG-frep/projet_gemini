import 'package:flutter/material.dart';

import '../models/player.dart';
import 'hp_bar.dart';
import 'xp_bar.dart';

class PlayerCard extends StatelessWidget {
  const PlayerCard({super.key, required this.player});

  final Player player;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE1A8),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: const Color(0xFFFFB86B), width: 4),
              ),
              child: const Icon(Icons.self_improvement, size: 76, color: Color(0xFF5278C8)),
            ),
            const SizedBox(height: 16),
            Text('Aventurier du focus', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Niveau ${player.level}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 20),
            XpBar(xp: player.xp, xpToNextLevel: player.xpToNextLevel),
            const SizedBox(height: 14),
            HpBar(hp: player.hp, maxHp: player.maxHp),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                _Pill(icon: Icons.toll, label: '${player.coins} pieces'),
                _Pill(icon: Icons.local_fire_department, label: 'Serie ${player.streak}'),
                _Pill(icon: Icons.emoji_events, label: 'Record ${player.bestStreak}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
